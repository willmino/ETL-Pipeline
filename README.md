# Crowdfunding-ETL

## Overview

I transferred "Independent Funding" data from on premesis excel database to a Postgres Data Warehouse using an automated pipeline (Python + SQL).
- ETL of particular CSV file
- Raw data SQL database
- SQL Data Warehouse
- Automatic Schema generation for tables for input csv files
- Automatic writing of csv file data to SQL tables

### Analysis

The `backer_info.csv` file needed cleaning. I converted a dataframe of json objects into a dataframe with keys as columns and rows as object values.
`pd.set_option('max_colwidth', 400)`

`backer_info = pd.read_csv("backer_info.csv")`

`backer_df = pd.DataFrame(backer_info)`

`backer_df.head()`

![backer_df](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/backer_info.png)

This code converted each key of the json object to columns and each value as the column fields in a pandas dataframe.

`backers_df = pd.json_normalize(backer_df['backer_info'].apply(pd.io.json.loads))`
`backers_df`

![backer_info_df](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/backers_d01.png)

The `name` column was split into `first_name` and `last_name` columns.

`backers_df[["first_name", "last_name"]] = backers_df["name"].str.split(" ", n=1, expand=True)`

`backers_df`

![backers_df](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/backers_df.png)

The DataFrame was exported to a csv file with the following code:

`backers_df.to_csv("backers.csv", index=False, encoding = "utf8")`

![crowdfunding_db_relationships](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/crowdfunding_db_relationships.png)

## Automatic Schema Creation for Database
The python script generated a table schema for each csv file from the employer.
The script then automatically wrote the csv file data to SQL tables.

Refer to the [data_pipeline.ipynb script](https://github.com/willmino/Crowdfunding-ETL/blob/main/scripts/data_pipeline.ipynb) for the query code.

### Results

The Data Warehouse contained two important tables "email_contacts_remaining_goal_amount" and "email_backers_remaining_goal_amount".
Each table provided the necessary contact information for either the invidiual backers or the campaign primary contact for notifications on each campaign's remaining funding ($) amount.

![email_backers_remaining_goal_amount](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/email_backers_remaining_goal_amount.png)


![email_contacts_remaining_goal_amount](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/email_contacts_remaining_goal_amount.png)

### Conclusion
With this information, we were able to successfully contact every campaign backer and primary contact of the remaining funding goals.
