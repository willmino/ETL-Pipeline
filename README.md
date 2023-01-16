# Crowdfunding-ETL

## Overview

Independent Funding, a crowdfunding platform, tasked me with transferring its large CSV file into a PostgreSQL database. I worked with Britta to Extract and Transform a large amount of inforation from one csv file into four distinct CSV files. The CSV files were connected to each other through primary and foreign keys to construct a database schema and Entity Relationship Diagram (ERD). The schema was then constructed in PostgreSQL using `CREATE TABLE` queries. The CSV files were subsequently loaded into the database using the import functions within PostgreSQL. Finally, SQL queries were performed to generate relevant aggregate information for reports to stakeholders regarding the number of backers on each campaign and corresponding remaining figures from the funding goals.

### Analysis

The foundation of our database came from several sources. There were five csv files and four of these files were each linked to the `campaign.csv file`. The layout of the database is listed below:

!(crowdfunding_db_relationships)[https://github.com/willmino/Crowdfunding-ETL/blob/main/images/crowdfunding_db_relationships.png]

Before constructing the database, we needed to extract relevant information from the `backer_info.csv` file. This file was a table and each row was a dictionary of key value pairs corresponding to each column header and row value of an entire row. To extract the relevant information, the csv file was loaded into a pandas DataFrame.

`pd.set_option('max_colwidth', 400)`

`backer_info = pd.read_csv("backer_info.csv")`

`backer_df = pd.DataFrame(backer_info)`

`backer_df.head()`

![backer_df](https://github.com/willmino/Crowdfunding-ETL/blob/main/images/backer_info.png)

The below block of code iterated through each row of the resulting DataFrame, and 


`dict_backer = []`

`dict_rows = []`

`for i,row in backer_df.iterrows():`

&nbsp;&nbsp;&nbsp;&nbsp;`# backer_df.iterrows() creates a list of lists, each list is a row from the dataframe`

&nbsp;&nbsp;&nbsp;&nbsp;`# and it containts a string enclosing a dictionary containing the row's` &nbsp;&nbsp;&nbsp;&nbsp;`# information. Use index pos 0 to access the string`

&nbsp;&nbsp;&nbsp;&nbsp;`data = row[0]`

&nbsp;&nbsp;&nbsp;&nbsp;`# convert each row, initially starting as a string, to a python dictionary`

&nbsp;&nbsp;&nbsp;&nbsp;`converted_data = json.loads(data)`

    # Dictionary Manipulation: Iterate through each dictionary (row) and get the values for each row using list comprehension.

    columns = [k for k,v in converted_data.items()]

    row_values = [v for k,v in converted_data.items()]

    # Append the list of values for each row to a list. 
    
    dict_rows.append(row_values)


# Print out the list of values for each row.

print(dict_rows)






An iterative process of Inspect, Plan, Execute was carried out at each step of the way to ensure a successful Extract-Transform-Load processing of our data into our target database.