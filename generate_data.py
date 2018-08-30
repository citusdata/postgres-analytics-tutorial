
#CREATE TABLE events(
#  id bigint,
#  timestamp timestamp, 
#  customer_id bigint,
#  event_type varchar,
#  country varchar,
#  browser varchar,
#  device_id bigint,
#  session_id bigint
#  );

from country_list import countries_for_language
import random

browsers=['chrome','firefox','safari','opera'];
len_browsers=len(browsers)

customer_ids=list(range(1001))[1:]
len_customer_ids=len(customer_ids)

countries = ['United States','United Kingdom','India','France','Germany','China','China']
len_countries=len(countries)

event_types=['click','buy','scroll','download']
len_event_types=len(event_types)

device_ids = list(range(10001))[1:]
len_device_ids=len(device_ids)

session_ids= list(range(100001))[1:]
len_session_ids=len(session_ids)

print("customer_id,event_type,country,browser,device_id,session_id")

for i in range(0,500000):
	row=''

	row = row + str(customer_ids[random.randint(0,len_customer_ids-1)]) +','
	row = row + (event_types[random.randint(0,len_event_types-1)]) + ','
	row = row + (countries[random.randint(0,len_countries-1)]) + ','
	row = row + (browsers[random.randint(0,len_browsers-1)]) + ','
	row = row + str(device_ids[random.randint(0,len_device_ids-1)]) + ','
	row = row + str(session_ids[random.randint(0,len_session_ids-1)])
	print(row);
