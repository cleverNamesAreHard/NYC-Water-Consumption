import csv
import mysql.connector
import os
import sys
import time


FILE_NAME = "data/NYCHA_Residential_Addresses.csv"
USERNAME = "water_consumption_user"
PASSWORD = "X57e85e78*"

# Look at the top row of a file
def peek(file_name: str, delim: str = ",") -> list:
    headers = []
    if os.path.exists(file_name):
        with open(file_name, "r") as f_in:
            for row in csv.reader(f_in, delimiter=delim):
                headers = row
                break
    else:
        raise Exception(f"File {file_name} does not exist")
    return headers

def get_data(file_name: str, delim: str = ",", headers: bool = True) -> list:
    data = []
    passed_headers = False if headers else True
    if os.path.exists(file_name):
        with open(file_name, "r") as f_in:
            for row in csv.reader(f_in, delimiter=delim):
                if passed_headers:
                    new_row = row
                    if "BLD" in new_row[3]:
                        print(new_row[3])
                    data.append(row)
                else:
                    passed_headers = True
    else:
        raise Exception(f"File {file_name} does not exist")
    return data

def write_data_to_table(data: list, table_name: str) -> None:
    with mysql.connector.connect(
        host="localhost",
        user=USERNAME,
        password=PASSWORD,
        database="water"
    ) as conn:
        progress = 1
        total_rows = len(data)
        load_start_time = time.time()
        for row in data:
            print(f"Writing record {progress:05} / {total_rows:05}", end = "\r")
            with conn.cursor() as cur:
                query = """
                    INSERT INTO tds_nos (development,tds_no,building_no,borough,house_no,street,address,city,state,zip_code,bin,block,lot,borough_block_lot_no,census_tract_2010,neighborhood_tabulation_area_code,neighborhood_tabulation_area_name,community_district,city_council_district,state_assembly_district,state_senate_district,us_congressional_district,latitude,longitude) 
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """
                params = tuple(row)
                cur.execute(query, params)
                conn.commit()
            progress += 1
        total_time = time.time() - load_start_time
        print(f"Completed data load in {total_time:.03f} seconds!" + (" " * 32), end="\n")  
            
                

headers = peek(FILE_NAME)
data = get_data(FILE_NAME)

table_name = "tds_nums"
write_data_to_table(data, table_name)
