# Crowdfunding-ETL

## Overview

Independent Funding, a crowdfunding platform, tasked me with transferring its large CSV file into a PostgreSQL database. I worked with Britta to Extract and Transform a large amount of inforation from one csv file into four distinct CSV files. The CSV files were connected to each other through primary and foreign keys to construct a database schema and Entity Relationship Diagram (ERD). The schema was then constructed in PostgreSQL using `CREATE TABLE` queries. The CSV files were subsequently loaded into the database using the import functions within PostgreSQL. Finally, SQL queries were performed to generate relevant aggregate information for reports to stakeholders regarding the number of backers on each campaign and corresponding remaining figures from the funding goals.

### Analysis

The foundation of our database came from several sources. There were five csv files and four of these files were each linked to the campaign.csv file. The layout of the database is listed below:

!(crowdfunding_db_relationships)[https://github.com/willmino/Crowdfunding-ETL/blob/main/images/crowdfunding_db_relationships.png]


`pd.set_option('max_colwidth', 400)`

`backer_info = pd.read_csv("backer_info.csv")`

`backer_df = pd.DataFrame(backer_info)`

`backer_df.head()`




An iterative process of Inspect, Plan, Execute was carried out at each step of the way to ensure a successful Extract-Transform-Load processing of our data into our target database.