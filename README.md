# Crowdfunding-ETL

## Overview

Independent Funding, a crowdfunding platform, tasked me with transferring its large CSV file into a PostgreSQL database. I worked with Britta to Extract and Transform a large amount of inforation from one csv file into four distinct CSV files. The CSV files were connected to each other through primary and foreign keys to construct a database schema and Entity Relationship Diagram (ERD). The schema was then constructed in PostgreSQL using `CREATE TABLE` queries. The CSV files were subsequently loaded into the database using the import functions within PostgreSQL. Finally, SQL queries were performed to generate relevant aggregate information for reports to stakeholders regarding the number of backers on each campaign and corresponding remaining figures from the funding goals.

### Analysis

Before constructing the database, we needed to extract relevant information from the `backer_info.csv` file. This file was a table and each row was a dictionary of key value pairs corresponding to each column header and row value of an entire row. To extract the relevant information, the csv file was loaded into a pandas DataFrame.

`pd.set_option('max_colwidth', 400)`

`backer_info = pd.read_csv("backer_info.csv")`

`backer_df = pd.DataFrame(backer_info)`

`backer_df.head()`

![backer_df](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/backer_info.png)

The below block of code iterated through each row of the resulting DataFrame, first creating a list of lists. Each list item it a string that contains its own dictionary. The line `data = row[0]` sets the variable `data` equal to accessing the first index position 0 and sole element of each list. This sole element is a list containing a python dictionary wrapped in quotes as a string. The `json.loads()` function then takes the string text of each row and converts it to a json file. Now that each row is a json file, we can iterate through it like a dictionary. The, using list comprehension, we iterated through each row/dictionary and extracted the value for every key, value pair in the json format data. The line `row_values = [v for k,v in converted_data.items()]` specifically takes all of the values from each json format data row, and adds it to a list that pertains to every row of the DataFrame we wish to construct. 


`dict_backer = []`

`dict_rows = []`

`for i,row in backer_df.iterrows():`

&nbsp;&nbsp;&nbsp;&nbsp;`# backer_df.iterrows() creates a list of lists, each list is a row from the dataframe`

&nbsp;&nbsp;&nbsp;&nbsp;`# and it contains a string enclosing a dictionary containing the row's`

&nbsp;&nbsp;&nbsp;&nbsp;`# information. Use index pos 0 to access the string`

&nbsp;&nbsp;&nbsp;&nbsp;`data = row[0]`

&nbsp;&nbsp;&nbsp;&nbsp;`# convert each row, initially starting as a string, to a python dictionary`

&nbsp;&nbsp;&nbsp;&nbsp;`converted_data = json.loads(data)`

&nbsp;&nbsp;&nbsp;&nbsp;`# Dictionary Manipulation: Iterate through each dictionary (row) and get the`

&nbsp;&nbsp;&nbsp;&nbsp;`# values for each row using list comprehension.`

&nbsp;&nbsp;&nbsp;&nbsp;`columns = [k for k,v in converted_data.items()]`

&nbsp;&nbsp;&nbsp;&nbsp;`row_values = [v for k,v in converted_data.items()]`

&nbsp;&nbsp;&nbsp;&nbsp;`# Append the list of values for each row to a list.`
    
&nbsp;&nbsp;&nbsp;&nbsp;`dict_rows.append(row_values)`


`# Print out the list of values for each row.`

`print(dict_rows)`

When we print the `dict_rows` variable, we can see that it is now a list of of lists. Each list within the parental list serves as values which are separated by commas. Each item separated by commas indicates the value for each column in the dataframe we are going to create. A sample image of the resulting list of lists is visualized below:

![backer_df_row_values](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/backer_df_row_values.png)


We then transformed this list of lists into a pandas DataFrame using the below block of code. Notice that we manually designated the column names, but imported the list `dict_values` as the primary set of rows for the resulting dataframe.

`backers_df = pd.DataFrame(dict_rows, columns = ["backer_id", "cf_id", "name", "email"])`

`backers_df.head(10)`

The resulting DataFrame was visualized below:

![backer_info_df](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/backers_d01.png)

We then separated the `name` column into two columns denoted as `first_name` and `last_name`.

The code block to execute this was :

`backers_df[["first_name", "last_name"]] = backers_df["name"].str.split(" ", n=1, expand=True)`

`backers_df`

This resulted in the following modified dataframe.

![backers_df](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/backers_df.png)

The DataFrame was exported to a csv file with the following code:

`backers_df.to_csv("backers.csv", index=False, encoding = "utf8")`

Finally, we were able to begin constructing our database.

The five csv files were used to construct our database: contact.csv, category.csv, subcategory.csv, campaign.csv, backers.csv. There were five csv files and four of these files were each linked to the `campaign.csv file`. The layout of the database is listed below:

!(crowdfunding_db_relationships)[https://github.com/willmino/Crowdfunding-ETL/blob/main/images/crowdfunding_db_relationships.png]

The resulting schema allowed us to perform `CREATE TABLE` queries. `ALTER TABLE` queries were also used to clarify the relationship between primary and foreign keys within the database.
The code block below illustrates the table construction within our database.



`CREATE TABLE "campaign" (`

&nbsp;&nbsp;&nbsp;&nbsp;`"cf_id" int   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"contact_id" int   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"company_name" varchar(100)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"description" text   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"goal" numeric(10,2)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"pledged" numeric(10,2)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"outcome" varchar(50)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"backers_count" int   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"country" varchar(10)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"currency" varchar(10)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"launch_date" date   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"end_date" date   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"category_id" varchar(10)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"subcategory_id" varchar(10)   NOT NULL`
`);`

`CREATE TABLE "category" (`

&nbsp;&nbsp;&nbsp;&nbsp;`"category_id" varchar(10)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"category_name" varchar(50)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`CONSTRAINT "pk_category" PRIMARY KEY (`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`"category_id"`

&nbsp;&nbsp;&nbsp;&nbsp;`)`
`);`

`CREATE TABLE "subcategory" (`
&nbsp;&nbsp;&nbsp;&nbsp;`"subcategory_id" varchar(10)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"subcategory_name" varchar(50)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`CONSTRAINT "pk_subcategory" PRIMARY KEY (`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`"subcategory_id"`

&nbsp;&nbsp;&nbsp;&nbsp;`)`
`);`

`CREATE TABLE "contacts" (`

&nbsp;&nbsp;&nbsp;&nbsp;`"contact_id" int   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"first_name" varchar(50)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"last_name" varchar(50)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"email" varchar(100)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`CONSTRAINT "pk_contacts" PRIMARY KEY (`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`"contact_id"`

&nbsp;&nbsp;&nbsp;&nbsp;`)`
`);`

`CREATE TABLE "backers" (`

&nbsp;&nbsp;&nbsp;&nbsp;`"backer_id" VARCHAR(10)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"cf_id" int  NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"first_name" VARCHAR(50)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"last_name" VARCHAR(50)   NOT NULL,`

&nbsp;&nbsp;&nbsp;&nbsp;`"email" VARCHAR(50)   NOT NULL`

`);`



`ALTER TABLE "campaign" ADD CONSTRAINT "pk_capmaign_cf_id" PRIMARY KEY("cf_id")`

`ALTER TABLE "campaign" ADD CONSTRAINT "fk_campaign_contact_id" FOREIGN KEY("contact_id")`
`REFERENCES "contacts" ("contact_id");`

`ALTER TABLE "campaign" ADD CONSTRAINT "fk_campaign_category_id" FOREIGN KEY("category_id")`
`REFERENCES "category" ("category_id");`

`ALTER TABLE "campaign" ADD CONSTRAINT "fk_campaign_subcategory_id" FOREIGN KEY("subcategory_id")`
`REFERENCES "subcategory" ("subcategory_id");`

`ALTER TABLE "backers" ADD CONSTRAINT "fk_backers_cf_id" FOREIGN KEY("cf_id")`
`REFERENCES "campaign" ("cf_id");`

We then manually imported our corresponding csv files into each new table within the database.
The data was successfully imported. Due to the schema of the databse, the last available file for import was the `backers.csv` file. When it was finally imrpoted into the database, we could see it within postgreSQL:

![backers_table](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/backers.png)

Refer to the SQL file for the query code for the corresponding resulting tables:

[SQL_queries](https://github.com/willmino/Crowdfunding-ETL/blob/main/queries/crowdfunding_SQL_Analysis.sql)

The first deliverable to show to the stakeholders regarding campaign backing was a list of each campaign_id along with the number of backers per campaign. This was accomplished by `SELECT COUNT(b.backer_id), c.cf_id`.
We took the count of backer_id's from the backers table as alias `b`. We took the `cf_id` from the campaign table as alias `c`. The data was stored `INTO` the new table `campaign_backers`. A `JOIN` function was able to join the backers and campaign tables. We selected `WHERE` (c.outcome) = "live", meaning only the live campaigns that were currently receving funding. Finally, we ordered by the `COUNT(b.backer_id)` in descending order. This yield the below table.

![]()