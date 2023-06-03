# Crowdfunding-ETL

## Overview

Independent Funding, a crowdfunding platform, tasked Britta and me with transferring its large CSV file into a PostgreSQL database. I worked with Britta to Extract and Transform a large amount of information from one csv file into four distinct CSV files. The CSV files were connected to each other through primary and foreign keys to construct a database schema and Entity Relationship Diagram (ERD). The schema was then constructed in PostgreSQL using `CREATE TABLE` queries. The CSV files were subsequently loaded into the database using the import functions within PostgreSQL. Finally, SQL queries were performed to generate relevant aggregate information for reports to stakeholders regarding the number of backers on each campaign and the corresponding remaining dollar figures left towards the funding goals.

### Analysis

Before constructing the database, we needed to extract relevant information from the `backer_info.csv` file. This file was a table and each row was a dictionary of key value pairs corresponding to each column header and row value of an entire row. To extract the relevant information, the csv file was loaded into a pandas DataFrame.

`pd.set_option('max_colwidth', 400)`

`backer_info = pd.read_csv("backer_info.csv")`

`backer_df = pd.DataFrame(backer_info)`

`backer_df.head()`

![backer_df](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/backer_info.png)

The below block of code iterated through each row of the resulting DataFrame, first creating a list of lists. Each list item was a string that contained its own dictionary. The line `data = row[0]` sets the variable `data` equal to accessing the first index position 0 and sole element of each list. This sole element was a list containing a python dictionary wrapped in quotes as a string. The `json.loads()` function then took the string text of each row and converted it to a json file. Now that each row was a json file, we could iterate through it like a dictionary. Then, using list comprehension, we iterated through each row/dictionary and extracted the value for every key,value pair in the json format data. The line `row_values = [v for k,v in converted_data.items()]` specifically takes all of the values from each json format data row, and adds it to a list that pertains to every row of the DataFrame we wish to construct. 


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

When we print the `dict_rows` variable, we can see that it is now a list of of lists. Each list within the parental list is a row and serves as the row's values which are separated by commas. Each item separated by commas indicates the value for each column in the dataframe we are going to create. A sample image of the resulting list of lists is visualized below:


We then transformed this list of lists into a pandas DataFrame using the below block of code. Notice that we manually designated the column names, but imported the list `dict_values` as the primary set of rows for the resulting dataframe.

`backers_df = pd.DataFrame(dict_rows, columns = ["backer_id", "cf_id", "name", "email"])`

`backers_df.head(10)`

The resulting DataFrame was visualized below:

![backer_info_df](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/backers_d01.png)

We then separated the `name` column into two columns denoted as `first_name` and `last_name`.
The code block to execute this was:

`backers_df[["first_name", "last_name"]] = backers_df["name"].str.split(" ", n=1, expand=True)`

`backers_df`

This resulted in the following modified dataframe.

![backers_df](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/backers_df.png)

The DataFrame was exported to a csv file with the following code:

`backers_df.to_csv("backers.csv", index=False, encoding = "utf8")`

Finally, we were able to begin constructing our database.

The five csv files were used to construct our database: `contacts.csv`, `category.csv`, `subcategory.csv`, `campaign.csv`, `backers.csv`. There were five csv files and four of these files were each linked to the `campaign.csv` file. The layout of the database is listed below:

![crowdfunding_db_relationships](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/crowdfunding_db_relationships.png)

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
The data was successfully imported. Due to the schema of the databse, the last available file for import was `backers.csv`. When it was finally imported into the database, we could see it within postgreSQL:

![backers_table](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/backers.png)

Refer to the SQL file for the query code for the corresponding resulting tables:

[SQL_queries](https://github.com/willmino/Crowdfunding-ETL/blob/main/queries/crowdfunding_SQL_Analysis.sql)

## Results

The first deliverable to show to the stakeholders regarding campaign backing was a list of each campaign_id along with the number of backers per campaign. This was accomplished by `SELECT COUNT(b.backer_id), c.cf_id`.
We took the count of backer_id's from the backers table as alias `b`. We took the `cf_id` from the campaign table as alias `c`. The data was stored `INTO` the new table `campaign_backers`. A `JOIN` function was able to join the `backers` and `campaign` tables. We selected `WHERE` (c.outcome) = "live", meaning only the live campaigns that were currently receving funding. Finally, we ordered by the `COUNT(b.backer_id)` in descending order. This yielded the below table.

![campaign_backers](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/campaign_backers.png)

This table was confirmed to have the same data from the backers table by performing a test acquisition of the original data. The code to do so was listed below:

`SELECT COUNT(backer_id), cf_id`

`INTO backers_count_per_cfid`

`FROM backers`

`GROUP BY cf_id`

`ORDER BY COUNT DESC;`

`ALTER TABLE backers_count_per_cfid RENAME COLUMN count TO backers_count;`

`--Check the table`

`SELECT * FROM backers_count_per_cfid;`

The selected data was identical to the `campaign_backers` table. This meant that all of the backer_id's from the backers table pertained to only "live" campaigns.

Britta's manager wanted us to construct a table that showed each campaign's contact information. We needed to perform this query so that we could inform the campaign contacts how much funding was still required for each campaign to meet its goal.

To perform this query, we executed the below block of code. We needed to select for the `goal` and `pledged` columns to later perform a calculation for the `"Remaining Goal Amount"` dollar figure. The relevant contact information we selected was the `first_name`, `last_name`, and `email` of each campaign contact. We performed a `JOIN` to aggregate the `campaign` and `contacts` tables on the `contact_id` unique identifier. This allowed each unique contact's information to be represented in the resulting table. The `ALTER TABLE` clause was used to add a column `ADD COLUMN "Remaining Goal Amount" numeric`. After adding the column, we used the `UPDATE TABLE` clause to perform a calculation of `SET "Remaining Goal Amount"  = goal - pledged;`. This allowed for the `"Remaining Goal Amount"` column to assume the value of the calculation. This information could then be conveyed to each campaign contact as to how much funding was left to satify their funding goal.

`SELECT ca.goal, ca.pledged,`

&nbsp;&nbsp;&nbsp;&nbsp;`co.first_name, co.Last_name, co.email`

`INTO notsorted_contacts_remaining_goal_amount`

`FROM campaign as ca`

`JOIN contacts as co`

`ON ca.contact_id = co.contact_id`

`WHERE ca.outcome = 'live';`

&nbsp;&nbsp;&nbsp;&nbsp; 

`ALTER TABLE notsorted_contacts_remaining_goal_amount`

`ADD COLUMN "Remaining Goal Amount" numeric`

&nbsp;&nbsp;&nbsp;&nbsp; 

`UPDATE notsorted_contacts_remaining_goal_amount`

`SET "Remaining Goal Amount"  = goal - pledged;`

&nbsp;&nbsp;&nbsp;&nbsp; 

`SELECT first_name, last_name, email, "Remaining Goal Amount" `

`INTO email_contacts_remaining_goal_amount`

`FROM notsorted_contacts_remaining_goal_amount`

`ORDER BY "Remaining Goal Amount"  DESC;`

&nbsp;&nbsp;&nbsp;&nbsp; 

`-- Check the table`

`SELECT * FROM email_contacts_remaining_goal_amount;`

![email_contacts_remaining_goal_amount](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/email_contacts_remaining_goal_amount.png)

Finally, we performed the last SQL query to inform all of the backers from each campaign of their remaining goal amount that needed to be satisfied (linked together by their unique campaign IDs). This query was similar to the `email_contacts...` table, but we instead selected the `cf_id` from the backers table along with all relevant backer information (`email`, `first_name`, `last_name`), and also the relevant campaign information such as the `company_name`, `description`, `end_date`, `goal`, and `pledged` columns. Selecting all of these values would eventually import every single backer and their relevant information into the `email_backers_remaining_goal_amount`, along with the corresponding campaign timeline and funding information. Before our final table was created, we added the column `"Left of Goal"`, using the `ALTER TABLE` and `ADD COLUMN` clauses, to the intermediate table `notsorted_backers_remaining_goal_amount`. We then used the `ALTER TABLE` and `SET` clauses to get the values for the `"Left of Goal"` dollar requirements. This `"Left of Goal"` value was calculated by subtracting the `pledged` dollar amount from the `goal` dollar amount. The resulting value was the remaining dollar value required to satisfy each campaign's funding goal. The below code block summarized the query:

`SELECT b.email, b.first_name, b.last_name, b.cf_id,`

&nbsp;&nbsp;&nbsp;&nbsp;`c.company_name, c.description, c.end_date, c.goal, c.pledged`

`INTO notsorted_backers_remaining_goal_amount`

`FROM backers as b`

`JOIN campaign as c`

`ON b.cf_id = c.cf_id;`

&nbsp;&nbsp;&nbsp;&nbsp; 

`ALTER TABLE notsorted_backers_remaining_goal_amount`

`ADD COLUMN "Left of Goal" numeric;`

&nbsp;&nbsp;&nbsp;&nbsp; 

`UPDATE notsorted_backers_remaining_goal_amount`

`SET "Left of Goal"  = goal - pledged;`

&nbsp;&nbsp;&nbsp;&nbsp; 

`SELECT email, first_name, last_name, cf_id, company_name, description, end_date,`

&nbsp;&nbsp;&nbsp;&nbsp;`"Left of Goal"`

`INTO email_backers_remaining_goal_amount`

`FROM notsorted_backers_remaining_goal_amount`

`ORDER BY email DESC;`

&nbsp;&nbsp;&nbsp;&nbsp; 

`-- Check the table`

`SELECT * FROM email_backers_remaining_goal_amount;`

![email_backers_remaining_goal_amount](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/email_backers_remaining_amount.png)

## Conclusion

With our final table deliverable, Britta and I were able to generate the necessary information to show stakeholders the remaining funding goals for the active crowdfunding campaigns at Independent Funding.
