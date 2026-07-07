select *
from layoffs; 

-- 1. Create the staging table with the same structure
CREATE TABLE layoffs_staging LIKE layoffs;

-- 2. Copy all data into the staging table
INSERT INTO layoffs_staging SELECT * FROM layoffs;

select *
from layoffs_staging;

-- 3. Remove Duplicates

WITH duplicate_cte AS (
SELECT *, 
    ROW_NUMBER() OVER(
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
    FROM layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

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

select *
from layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER(
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
    FROM layoffs_staging;

select *
from layoffs_staging2
where row_num > 1;

delete 
from layoffs_staging2
where row_num > 1;

select *
from layoffs_staging2
where row_num > 1;

-- 4. Standardize data

select company, TRIM(company)
from layoffs_staging2;

-- Remove trailing spaces 
UPDATE layoffs_staging2 SET company = TRIM(company);

select distinct industry
from layoffs_staging2
order by industry;

-- Fix inconsistent categories (e.g., "Crypto Currency" -> "Crypto")
UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2 SET country = "United States" WHERE country LIKE 'United States%';
-- UPDATE layoffs_staging2 SET country = TRIM(TRAILING '.' from country) WHERE country LIKE 'United States%';

select distinct country
from layoffs_staging2;

-- convert date column into date formate
select `date`, str_to_date(`date`,'%m/%d/%Y')
from layoffs_staging2;

UPDATE layoffs_staging2 SET `date` = str_to_date(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2 MODIFY COLUMN `date` DATE;

select distinct company
from layoffs_staging2
order by company;

select distinct stage
from layoffs_staging2
order by stage;

select distinct location
from layoffs_staging2
order by location;

select distinct industry
from layoffs_staging2
order by industry;

select distinct country
from layoffs_staging2
order by country;

-- 5. Remove / Populate null or blank values

-- Change blank strings to NULLs
UPDATE layoffs_staging2 SET industry = NULL WHERE industry = '';

-- Populate NULLs. If a company is missing an industry, but another row for the same company has it, you can join the table to itself to fill it in.

select *
from layoffs_staging2
where industry IS NULL;

select *
from layoffs_staging2
where company = "Airbnb";  -- Same company and same location but one has industry as Travel and other one is null. So we assume null one is also Travel and populate it.

select *
from layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company AND t1.location = t2.location
where t1.industry IS NULL AND t2.industry IS NOT NULL;

update layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company AND t1.location = t2.location
set t1.industry = t2.industry
where t1.industry IS NULL AND t2.industry IS NOT NULL;

select *
from layoffs_staging2
where industry IS NULL;  -- WE cannot populate the "Bally's Intereactive"

-- Remove only both total_paid_off and percentage_laid_off is NULL

select *
from layoffs_staging2
where total_laid_off IS NULL AND percentage_laid_off IS NULL;

delete 
from layoffs_staging2
where total_laid_off IS NULL AND percentage_laid_off IS NULL;

select count(*)
from layoffs_staging2;

select *
from layoffs_staging2;
