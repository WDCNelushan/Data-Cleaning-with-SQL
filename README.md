#  Data Cleaning with SQL: Global Tech Layoffs Dataset

Welcome to my SQL Data Cleaning project! This repository contains the SQL scripts used to transform a raw, messy CSV dataset of global tech layoffs into a clean, structured, and analysis-ready database. 

This project demonstrates practical data cleaning techniques using **MySQL**, including removing duplicates, standardizing text, handling missing values, and formatting data types.

---

##  About the Dataset
The dataset (`layoffs.csv`) contains information about tech company layoffs globally from **March 2020 to March 2023**. It includes columns such as:
* **Company & Location:** Where the layoffs happened.
* **Industry & Stage:** The sector and funding stage of the company.
* **Layoff Metrics:** Total number of employees laid off and the percentage of the workforce affected.
* **Financials:** Total funds raised (in millions).
* **Date:** The date the layoffs were announced.

---

## 🛠️ Data Cleaning Process

The raw data was imported into a staging table (`layoffs_staging`) and then systematically cleaned using the following 5 steps:

### 1. Removing Duplicates
Raw data often contains duplicate rows. To identify and remove them:
* Used a **Common Table Expression (CTE)** with the `ROW_NUMBER()` window function, partitioning by all relevant columns to assign a unique row number to duplicate records.
* Inserted the results into a new table (`layoffs_staging2`) and deleted all rows where `row_num > 1`.

### 2. Standardizing Data
Text data from CSVs often contains typos, trailing spaces, and inconsistent categories.
* **Trimmed Spaces:** Used the `TRIM()` function to remove accidental leading/trailing spaces from the `company` column.
* **Standardized Categories:** 
  * Grouped all crypto-related industries by updating `industry LIKE 'Crypto%'` to `'Crypto'`.
  * Standardized country names by updating `country LIKE 'United States%'` to `'United States'`.
* **Date Formatting:** Converted the `date` column from a `VARCHAR` (MM/DD/YYYY) to a proper `DATE` data type using `STR_TO_DATE()`.

### 3. Handling NULLs and Blank Values
Missing data can skew analysis. I handled this in three ways:
* **Blanks to NULLs:** Converted empty strings (`''`) in the `industry` column to actual `NULL` values for consistency.
* **Populating NULLs (Self-Join):** For companies with missing industries, I performed a **Self-Join** on `company` and `location`. If a duplicate row had a known industry, I updated the `NULL` row with that value (e.g., populating Airbnb's missing industry).
* **Deleting Irrelevant Rows:** Removed rows where **both** `total_laid_off` and `percentage_laid_off` were `NULL`, as these records provided no analytical value regarding the scale of the layoffs.

### 4. Dropping Unnecessary Columns
* Dropped the temporary `row_num` column used for duplicate detection to finalize the clean schema.

---

## 💻 Technologies Used
* **Database Management System:** MySQL
* **Query Language:** SQL (Window Functions, CTEs, Self-Joins, String Functions)
* **Version Control:** Git & GitHub
