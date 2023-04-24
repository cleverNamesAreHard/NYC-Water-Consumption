select * from datafeed d;
use water;
drop table water_info;




-- Fucking magic right here, bro
select 
	wi.*,
	tn.address,
	tn.city,
	tn.state,
	tn.zip_code
from water_info wi 
join tds_numbers tn 
	on 
		tn.tds_no = wi.tds_no and 
		tn.building_no = wi.location 
where 
	wi.consumption_hcf != 0
order by rand() limit 10;





select * from tds_numbers tn order by rand() limit 10;

select * from water_info where tds_no = 66 and location like '%27' order by location asc;
select * from tds_nos where tds_no = 66 and building_no = 27 order by building_no asc;
select * from tds_numbers where tds_no = 283;
select * from water_info wi where tds_no = 283;

drop user 'water_consumption_user'@'localhost';
create user 'water_consumption_user'@'localhost' identified by '<your_password_here>';
grant select, drop, create, insert, update on water.* to 'water_consumption_user'@'localhost';

drop table tds_nos;
CREATE TABLE tds_nos (
	development TEXT,
	tds_no INT,
	building_no TEXT,
	borough TEXT,
	house_no TEXT,
	street TEXT,
	address TEXT,
	city TEXT,
	state TEXT,
	zip_code TEXT,
	bin TEXT,
	block TEXT,
	lot TEXT,
	borough_block_lot_no TEXT,
	census_tract_2010 TEXT,
	neighborhood_tabulation_area_code TEXT,
	neighborhood_tabulation_area_name TEXT,
	community_district TEXT,
	city_council_district TEXT,
	state_assembly_district TEXT,
	state_senate_district TEXT,
	us_congressional_district TEXT,
	latitude TEXT,
	longitude TEXT);

select * from tds_nos order by rand() limit 10;
select * from tds_nos where tds_no = 118;

select * from tds_nos where tds_no = 66;
select * from tds_nos where building_no = 1;


drop table tds_numbers;

create table tds_numbers (
	tds_no int not null,
	building_no text not null,
	address text not null,
	city text not null,
	state text not null,
	zip_code text not null,
	neighborhood_name text
);

insert into tds_numbers (tds_no, building_no, address, city, state, zip_code, neighborhood_name)
select tds_no, building_no, address, city, state, zip_code, neighborhood_tabulation_area_name
from tds_nos
group by 1, 2, 3, 4, 5, 6, 7;

select distinct building_no from tds_nos;

select tds_no, address, city, state, zip_code, neighborhood_tabulation_area_name
from tds_nos
group by 1, 2, 3, 4, 5, 6;

select tds_no, building_no, address, city, state, zip_code, neighborhood_tabulation_area_name
from tds_nos
group by 1, 2, 3, 4, 5, 6, 7;

create table tds_numbers (
	tds_no int not null,
	building_no text not null,
	address text not null,
	city text not null,
	state text not null,
	zip_code text not null,
	neighborhood_name text,
	read_date DATE,
	consumption_hcf 
);

select * from tds_numbers tn where tds_no = 209;

select * from water_info wi where tds_no = 325;

CREATE TABLE consumption (
	borough TEXT,
	account_name TEXT,
	location TEXT,
	meter_amr TEXT,
	tds_no INT,
	service_end_date DATE,
	num_days INT,
	estimated TEXT,
	consumption_hcf INT,
	address TEXT,
	city TEXT,
	state TEXT,
	zip_code TEXT,
	lat TEXT,
	lng TEXT
);

drop table consumption;

insert into consumption (borough, account_name, location, meter_amr, tds_no, service_end_date, num_days, estimated, consumption_hcf, address, city, state, zip_code)
select 
	wi.borough, wi.account_name, wi.location, wi.meter_amr, wi.tds_no, STR_TO_DATE(wi.service_end_date, '%m/%d/%Y'), wi.`#_days`, wi.estimated, wi.consumption_hcf, tn.address, tn.city, tn.state, tn.zip_code
from water_info wi 
left outer join tds_numbers tn 
	on 
		tn.tds_no = wi.tds_no and 
		tn.building_no = wi.location;

update consumption c
inner join tds_numbers tn 
	on
		tn.tds_no = c.tds_no and
		tn.address = c.location
set 
	c.city = tn.city and 
	c.state = tn.state and 
	c.zip_code = tn.zip_code
where c.city is null;

select * from consumption order by rand() limit 10;

SELECT * FROM consumption WHERE lat is null order by rand();

select count(distinct address) from consumption;
select count(*) from consumption;


select * from tds_numbers tn
where 
	tds_no = 377 and 
	building_no = 33;


SELECT * FROM consumption WHERE lat is null LIMIT 20;
select * from consumption order by rand() limit 20;

select count(distinct lat) from consumption;
select count(*) from consumption;
select * from consumption where lat is null;
select count(*) from water_info wi ;
select * from tds_numbers tn where tds_no = '273' and address = '113-44 SPRINGFIELD BOULEVARD';
select * from water_info wi where tds_no = 273;
select * from consumption where tds_no = 273 and location = '113-44 SPRINGFIELD BOULEVARD';



-- 19,226 (down from 65k) when last run
select count(*) from consumption where lat is null;
-- We mapped everything we could map an address for directly in the 
select count(*) from consumption where lat is null and address is not null;
select count(*) from consumption c where lat is not null;
select * from consumption where lat = 'Failed to GeoCode';
select * from consumption c where tds_no = 209 and location = '114-69 145TH STREET';

select * from consumption where lat is null;


-- Using this to research some properties we can use to clean up the rest
select tds_no, location, count(*) from consumption where lat is null group by 1, 2 order by count(*) desc;
select * from water_info wi where tds_no = 353 and location = '01';
select * from consumption c where tds_no = 353 and location = '01';
select * from consumption where city is null and account_name not like '%-%';


select * from consumption where city is null;
select * from water_info wi where tds_no = 91;
select * from tds_numbers tn where tds_no = 91;
select * from consumption c where tds_no = 260;
select * from tds_numbers c where tds_no = 260;
select * from water_info c where tds_no = 260;

select * from consumption c where tds_no = 284 and location is null;

select * from consumption c where lat = 'Failed to GeoCode';

select 
	tds_no, location, address, city, state, zip_code 
from consumption 
where lat is null 
group by 1, 2, 3, 4, 5, 6 
limit 20;

				select 
					tds_no, location, address, city, state, zip_code, account_name, borough, lat
				from consumption 
				where 
					lat is null
				group by 1, 2, 3, 4, 5, 6, 7, 8, 9
				limit 20;

-- We can finally run some fucking analytics
select 
	service_end_date as read_date, 
	lat, 
	lng, 
	sum(cast(consumption_hcf as float) * 748.052) as consumption_gal,
	count(*)
from consumption 
group by 1, 2, 3 
order by 
	read_date desc, 
	consumption_gal desc;


-- Seasonal grouping
select 
	year(service_end_date),
	case 
		when 
			DATE_FORMAT(service_end_date, '%m-%d') between '12-21' and '12-31' or
			DATE_FORMAT(service_end_date, '%m-%d') between '01-01' and '03-19'
		then '4 - Winter'
		when 
			DATE_FORMAT(service_end_date, '%m-%d') between '03-20' and '06-20'
		then '1 - Spring'
		when 
			DATE_FORMAT(service_end_date, '%m-%d') between '06-21' and '09-22'
		then '2 - Summer' 
		when 
			DATE_FORMAT(service_end_date, '%m-%d') between '09-23' and '12-20'
		then '3 - Fall'
	end as season,
	lat,
	lng,
	TRUNCATE(sum(cast(consumption_hcf as float) * 748.052), 2) as consumption_gal,
	count(*)
from consumption
where 
	(lat is not null or lat = 'Failed to GeoCode') and 
	year(service_end_date) = 2022
group by 1, 2, 3, 4
order by 1 desc, 2 desc;

