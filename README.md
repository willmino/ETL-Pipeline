# Crowdfunding-ETL

## Overview

Independent Funding, a crowdfunding platform, tasked me with transferring its large CSV file into a PostgreSQL database. I worked with Britta to Extract and Transform a large amount of inforation from one csv file into four distinct CSV files. The CSV files were connected to each other through primary and foreign keys to construct a database schema and Entity Relationship Diagram (ERD). The schema was then constructed in PostgreSQL using `CREATE TABLE` queries. The CSV files were subsequently loaded into the database using the import functions within PostgreSQL. Finally, SQL queries were performed to generate relevant aggregate information for reports to stakeholders regarding the number of backers on each campaign and corresponding remaining figures from the funding goals.

### Analysis

The foundation of our database came from several sources. First, two worksheets from the `crowdfunding.xlsx` file were imported into pandas DataFrames. These sheets were called `crowdfunding_info` and `contact_info`. `crowdfunding_info` was simply loaded into a datase as several columns. However, the `cotact_info` worksheet was actually a table of dictionaries. This meant that each key and correponding list of values, data structure for column header and each row pertaining to the column, needed to be extracted from the initial format in order to create columns for our DataFrame.

Importing the `crowdfunding_info` worksheet.

`pd.set_option('max_colwidth', 400)`

`crowdfunding_info_df = pd.read_excel(crowdfunding_data, sheet_name='crowdfunding_info')`

`crowdfunding_info_df.head()`


`pd.set_option('max_colwidth', 400)`

`contact_info_df = pd.read_excel(crowdfunding_data, sheet_name='contact_info', header=2)`

`contact_info_df.head()`



![crowdfunding_info_df](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/crowdfunding_info.png)


Importing the `contact_info` worksheet.




An iterative process of Inspect, Plan, Execute was carried out at each step of the way to ensure a successful Extract-Transform-Load processing of our data into our target database.