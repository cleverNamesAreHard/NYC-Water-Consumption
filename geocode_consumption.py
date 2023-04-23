from dotenv import load_dotenv
import json
import mysql.connector
import os
import platform
import re
import requests
from time import time
import urllib.parse


load_dotenv("C:\\Users\\nmedo\\knime-workspace\\Water\\env.env")
USERNAME = os.environ.get("db_user")
PASSWORD = os.environ.get("db_pass")
URL_BASE = "http://localhost:8088/search.php?countrycodes=us&addressdetails=1&format=json&q={}"

def clear_screen():
	clear_command = "clear"
	if platform.system() == "Windows":
		clear_command = "cls"
	print(platform.system)
	os.system(clear_command)

def new_conn() -> mysql.connector.connection.MySQLConnection:
	return mysql.connector.connect(
		host="localhost",
		user=USERNAME,
		password=PASSWORD,
		database="water"
	)

def get_data() -> list:
	data = []
	with new_conn() as conn:
		with conn.cursor() as cur:
			query = """
				select 
					tds_no, location, address, city, state, zip_code, account_name, borough
				from consumption 
				where 
					lat is null
				group by 1, 2, 3, 4, 5, 6, 7, 8
				limit 20
			"""
			cur.execute(query)
			res = cur.fetchall()
			data = [list(x) for x in res]
	return data

def update_lat_and_long(tds_no: int, location: str, lat: str, lon: str) -> None:
	with new_conn() as conn:
		with conn.cursor() as cur:
			query = """
				UPDATE consumption SET 
					lat = %s,
					lng = %s
				WHERE
					tds_no = %s AND
					location = %s
			"""
			
			params = (lat, lon, tds_no, location)
			cur.execute(query, params)
			conn.commit()

def geocode_record(record: list) -> None:
	tds_no = record[0]
	location = record[1]
	address = record[2]
	city = record[3]
	state = record[4]
	zip_code = record[5]
	account_name = record[6]
	borough = record[7]
	lat = "Failed to GeoCode"
	lon = "Failed to GeoCode"
	
	addr_str = f"{address} {zip_code}"
	url = URL_BASE.format(urllib.parse.quote_plus(addr_str))
	new_url = None
	req = requests.get(url)
	res = req.json()
	
	if res != [] and address is not None:
		lat = res[0]["lat"]
		lon = res[0]["lon"]
	else:
		if address is not None:
			new_address = re.sub("[^0-9]", "", addr_str) + " " + " ".join(x for x in address.split(" ")[-2:])
			new_addr_str = f"{new_address} {zip_code}"
			new_url = URL_BASE.format(urllib.parse.quote_plus(new_addr_str))
			req = requests.get(new_url)
			res = req.json()
			if res != []:
				lat = res[0]["lat"]
				lon = res[0]["lon"]
		else:
			new_address = account_name
			if "-" in account_name:
				new_address = new_address.split("-")[0]
			new_addr_str = f"{new_address} {borough}"
			new_url = URL_BASE.format(urllib.parse.quote_plus(new_addr_str))
			req = requests.get(new_url)
			res = req.json()
			
			if res != []:
				lat = res[0]["lat"]
				lon = res[0]["lon"]
			else:
				new_address = location
				new_addr_str = f"{new_address} {borough}"
				new_url = URL_BASE.format(urllib.parse.quote_plus(new_addr_str))
				res = req.json()
			
				if res != []:
					lat = res[0]["lat"]
					lon = res[0]["lon"]
			
	update_lat_and_long(tds_no, location, lat, lon)

# Init 
clear_screen()
# Setup
data = get_data()
running = False
if data:
	running = True
else:
	print("There were no records requiring geocoding")
# Processing
batches = 1
current = 1
while running:
	start_time = time()
	for record in data:
		print(f"[Batch {batches:04}] - {current:02} / 20", end="\r")
		geocode_record(record)
		current += 1
	total_time = time() - start_time
	print(f"[Batch {batches:04}] - Completed in {total_time:.01f} seconds")	
	data = get_data()
	if not data:
		running = False
	else:
		batches += 1
		current = 1
print("Completed all available geocoding")
