import json
import requests
import urllib.parse


url_base = "http://localhost:8088/search.php?countrycodes=us&addressdetails=1&format=json&q={}"
addresses = ["south 9th street BROOKLYN"]
for address in addresses:
	url = url_base.format(urllib.parse.quote_plus(address))
	print(url)
	res = requests.get(url)
	print(res.status_code)
	res_dict = json.loads(res.content)
	for item in res_dict:
		print(item)
