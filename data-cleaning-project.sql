-- Data Cleaning Project
-- Steps
-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Check for null values
-- 4.Remove unnecessary columns( create and use a staging table of the original data for reference incase of changes)

# Load table data
select * from layoffs;

# Create the staging table like the original table
create table layoffs_staging
like layoffs;

# Insert the original  table data to staging data
insert layoffs_staging
select * from layoffs;

#Load staging data
select * from layoffs_staging;

-- 1.Remove Duplicates
# 1.1use the window func row_number() to identify duplicate rows in columns
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

#1.2 use a cte to identify duplicates 
with duplicate_cte as(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select * from duplicate_cte where row_num > 1 ;

#1.3 Confirm that the values are duplicates
select * from layoffs_staging 
where company = 'Cazoo';

#1.4 Create a new table with row_num column then drop the row_num >1
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

#Load new table
select * from layoffs_staging2;

#Insert data
insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

#Load table data
select * from layoffs_staging2;

#select duplicates
select * from layoffs_staging2
where row_num > 1;

#delete duplicates
delete  from layoffs_staging2 where row_num > 1;








