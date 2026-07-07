select *
from layoffs; 

-- 1. Create the staging table with the same structure
CREATE TABLE layoffs_staging LIKE layoffs;

-- 2. Copy all data into the staging table
INSERT INTO layoffs_staging SELECT * FROM layoffs;

select *
from layoffs_staging;