# Netflix Data Analysis Project (ETL Pipeline and SQL Analytics) 

## Overview

This project involves building an **ETL (Extract, Transform, Load)** pipeline to analyze Netflix data sourced from Kaggle. Using Python and Jupyter Notebook for data extraction and transformation, and SQL (MSSQL) for data loading and querying, performed comprehensive data cleaning, transformations, and analysis.

---

## Objectives

- Build an end-to-end ETL pipeline using **Python** and **MSSQL**.
- Perform advanced **data cleaning** and transformation to ensure high-quality analysis.
- Showcase SQL skills by creating derived tables and performing complex queries.

---

## Technical Stack

- **Languages:** Python (Pandas, NumPy), SQL (MSSQL)
- **Tools:** Jupyter Notebook, Microsoft SQL Server
- **Data Source:** [Kaggle Netflix Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows)

---

## Project Workflow

### ETL Pipeline

1. **Extract:**
   - Data imported into Python for initial exploration.

2. **Transform:**
   - Cleaned data and standardized formats.
   - Resolved missing values and inconsistencies.
   - Normalized multi-valued columns.
  
3. **Load:**
   - Data loaded into MSSQL for structured storage and querying.

### Example Transformations
- **Duplicate Removal:** Cleaned records to eliminate redundant entries.
- **Genre Normalization:** Split rows with multiple genres into separate entries for relational mapping.
- **Country and Director Normalization:** Created separate tables to improve data granularity.


---

## Sample Queries

### what is average duration of movies in each genre

```sql

 select  distinct ng.genre ,avg(cast(replace(duration, ' min', '')as int)) as average_duration
 from netflix_filtered as nf
 inner join netflix_genre as  ng
 on nf.show_id = ng.show_id
 where type ='movie'
 group by ng.genre
 order by  average_duration
;




     
