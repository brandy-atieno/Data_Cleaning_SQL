-- Data cleaning Practise Project

# 1. Load data 
select * from club_member_info;
#check columns and the data types
describe  club_member_info;

#load the data
select * from club_member_staging;

-- Remove duplicates
# 2 Using a cte (preferred)
with duplicate_cte as(
select *,
row_number() over(
partition by full_name,age,martial_status,email,phone,full_address,job_title,membership_date) as row_num
from club_member_staging
)
select * from duplicate_cte where row_num > 1 ;

#2.2 Create a new table with row_num column then drop the row_num >1
CREATE TABLE `club_member_staging4` (
  `full_name` text,
  `age` int DEFAULT NULL,
  `martial_status` text,
  `email` text,
  `phone` text,
  `full_address` text,
  `job_title` text,
  `membership_date` text,
  row_num int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

#insert data
insert into club_member_staging4
select *,
row_number() over(
partition by full_name,age,martial_status,email,phone,full_address,job_title,membership_date) as row_num
from club_member_staging;

#view table
select * from club_member_staging4;
#view duplicates
select *  from club_member_staging4 where row_num > 1;
#delete duplicates
delete  from club_member_staging4 where row_num > 1;
#confirm deletion
select *  from club_member_staging4 where row_num > 1; 
#remove the row_num column
alter table club_member_staging4
drop column row_num;
#view changes
select * from club_member_staging4;

-- Standardise Data
-- 1. full_name
# 1 remove white spaces from full_name
#view table
select * from club_member_staging4;
select full_name, trim(full_name) 
from club_member_staging4;

#1.2 update the table
update club_member_staging4
set full_name = trim(full_name);
#view table
select * from club_member_staging4;

#1.3 remove special characters
select replace(full_name, '\W+', '' ) as clean_full_name
from club_member_staging4;

#1.4 create  first_name and last_name column
alter table club_member_staging4
add first_name varchar(200), 
add last_name varchar(200);

#view changes
select * from club_member_staging4;

#update the table
UPDATE club_member_staging4
SET first_name = SUBSTRING_INDEX(full_name, ' ', 1);
UPDATE club_member_staging4
SET last_name = SUBSTRING_INDEX(full_name, ' ', -1);
#convert to lower_case
update club_member_staging4
set first_name = lower(first_name);

update club_member_staging4
set last_name = lower(last_name);

#delete the full_name column
alter table club_member_staging4
drop column full_name;
#view  changes
select * from club_member_staging4 ;

-- 2. age
#2.1 Remove additional digit from age column
UPDATE club_member_staging4
SET age = SUBSTRING(age, 1, 2)
WHERE LENGTH(age) > 2;

#set the empty values to null
update club_member_staging4
set age = null
where age = '';

#view changes
select * from club_member_staging4;

#3 Martial status
#rename column
ALTER TABLE club_member_staging4
CHANGE COLUMN martial_status marital_status varchar(100);
#view changes
select * from club_member_staging4;

#3.1 remove white spaces
update club_member_staging4
set marital_status = trim(marital_status);

#set empty values to null
update club_member_staging4
set marital_status = null
where marital_status = '';

#convert to lower case
update club_member_staging4
set marital_status = lower(marital_status);

#view changes
select * from club_member_staging4;

#4 Email Address
#remove white spaces
update club_member_staging4
set email = trim(email);

#convert to lower case
update club_member_staging4
set email = lower(email);

# 5 phone
#remove whit spaces
update club_member_staging4
set phone = trim(phone);

#set empty values to null
update club_member_staging4
set phone = null
where phone ='';

# 6 Full_address
#remove whitespaces and convert to lower case
update club_member_staging4
set full_address = trim(lower(full_address));
#view changes
select * from club_member_staging4;

#6.2 create  street_address,state,city
alter table club_member_staging4
add street_address varchar(200), 
add state varchar(200),
add city varchar(200);
#view changes
select * from club_member_staging4;

#update the table
UPDATE club_member_staging4
SET 
    street_address = SUBSTRING_INDEX(full_address, ',', 1),
    city = SUBSTRING_INDEX(SUBSTRING_INDEX(full_address, ',', 2), ',', -1),
    state = TRIM(SUBSTRING_INDEX(full_address, ',', -1));
#view changes
select * from club_member_staging4;

#delete the full_address column
alter table club_member_staging4
drop column full_address;

#view changes
select * from club_member_staging4;

#7 job_title
#rename column
ALTER TABLE club_member_staging4
CHANGE COLUMN job_title occupation varchar(100);

#view changes
select * from club_member_staging4;

#remove white-spaces and convert to lower case
update club_member_staging2
set occupation = trim((occupation));
#convert to null type
update club_member_staging4
set occupation = null
where occupation = '';
#view changes
select * from club_member_staging4;

#test logic
SELECT
    occupation,
    CASE
        WHEN LOWER(SUBSTRING_INDEX(occupation, ' ', -1)) = 'i'   THEN REPLACE(occupation, ' I', ' Level 1')
        WHEN LOWER(SUBSTRING_INDEX(occupation, ' ', -1)) = 'ii'  THEN REPLACE(occupation, ' II', ' Level 2')
        WHEN LOWER(SUBSTRING_INDEX(occupation, ' ', -1)) = 'iii' THEN REPLACE(occupation, ' III', ' Level 3')
        WHEN LOWER(SUBSTRING_INDEX(occupation, ' ', -1)) = 'iv'  THEN REPLACE(occupation, ' IV', ' Level 4')
        ELSE occupation
    END AS updated_occupation
FROM
    club_member_staging4;
#update changes
UPDATE club_member_staging4
SET occupation = CASE
    WHEN LOWER(SUBSTRING_INDEX(occupation, ' ', -1)) = 'i'   THEN REPLACE(occupation, ' I', ' Level 1')
    WHEN LOWER(SUBSTRING_INDEX(occupation, ' ', -1)) = 'ii'  THEN REPLACE(occupation, ' II', ' Level 2')
    WHEN LOWER(SUBSTRING_INDEX(occupation, ' ', -1)) = 'iii' THEN REPLACE(occupation, ' III', ' Level 3')
    WHEN LOWER(SUBSTRING_INDEX(occupation, ' ', -1)) = 'iv'  THEN REPLACE(occupation, ' IV', ' Level 4')
    ELSE occupation
END;
#convert to lowercase
update club_member_staging4
set occupation = lower(occupation);
#view changes
select * from club_member_staging4;

# 8 membership_date
select membership_date from club_member_staging4;
SELECT membership_date,
    
    CASE 
        WHEN EXTRACT(YEAR FROM membership_date) < 2000 
            THEN STR_TO_DATE(CONCAT('20', SUBSTRING(YEAR(membership_date), 3, 2), '-',
            LPAD(MONTH(membership_date), 2, '0'), '-',
            LPAD(DAY(membership_date), 2, '0')), '%Y-%m-%d')
        ELSE membership_date
    END AS membership_date
FROM 
    club_member_staging4;
        

alter table club_member_staging4
drop column new_membership_date;
select * from club_member_staging4;
#To review the date conversion to 2000's