# Crowdfunding-ETL

## Overview

I transferred "Independent Funding" data from on premesis excel database to a Postgres Data Warehouse using an automated pipeline (Python + SQL).
- ETL of particular CSV file
- Raw data SQL database
- SQL Data Warehouse
- Automatic Schema generation for tables for input csv files
- Automatic writing of csv file data to SQL tables

### Analysis

The `backer_info.csv` file needed cleaning. I converted a dataframe json objects into a pandas dataframe with keys as columns and rows as object values.
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

Finally, we were able to begin constructing our database.

The five csv files were used to construct our database: `contacts.csv`, `category.csv`, `subcategory.csv`, `campaign.csv`, `backers.csv`. There were five csv files and four of these files were each linked to the `campaign.csv` file. Schema below:
![crowdfunding_db_relationships](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/crowdfunding_db_relationships.png)

## Automatic Schema Creation for Database
I executed a python script via sqlAlchemy. This script generated a schema for each csv file from the employer.
The script then automatically wrote the csv file data to SQL tables.


![backers_table](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/backers.png)

Refer to the [data_pipeline.ipynb script](https://github.com/willmino/Crowdfunding-ETL/blob/main/scripts/data_pipeline.ipynb) for the query code.

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
