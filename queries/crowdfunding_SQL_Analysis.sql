-- Challenge Bonus queries.
-- 1. (2.5 pts)
-- Retrieve all the number of backer_counts in descending order for each `cf_id` for the "live" campaigns.

SELECT COUNT(b.backer_id), c.cf_id
INTO campaign_backers
FROM campaign as c
JOIN backers as b
ON c.cf_id = b.cf_id
WHERE (c.outcome = 'live')
GROUP BY c.cf_id
ORDER BY COUNT(b.backer_id) DESC;

ALTER TABLE campaign_backers RENAME COLUMN count TO backers_count;

--Check the table
SELECT * FROM campaign_backers;


-- 2. (2.5 pts)
-- Using the "backers" table confirm the results in the first query.

SELECT COUNT(backer_id), cf_id
INTO backers_count_per_cfid
FROM backers
GROUP BY cf_id
ORDER BY COUNT DESC;

ALTER TABLE backers_count_per_cfid RENAME COLUMN count TO backers_count;

--Check the table
SELECT * FROM backers_count_per_cfid;


-- 3. (5 pts)
-- Create a table that has the first and last name, and email address of each contact.
-- and the amount left to reach the goal for all "live" projects in descending order. 

SELECT ca.goal, ca.pledged,
	co.first_name, co.Last_name, co.email
INTO notsorted_contacts_remaining_goal_amount
FROM campaign as ca
JOIN contacts as co
ON ca.contact_id = co.contact_id
WHERE ca.outcome = 'live';

ALTER TABLE notsorted_contacts_remaining_goal_amount
ADD COLUMN "Remaining Goal Amount" numeric

UPDATE notsorted_contacts_remaining_goal_amount
SET "Remaining Goal Amount"  = goal - pledged;

SELECT first_name, last_name, email, "Remaining Goal Amount" 
INTO email_contacts_remaining_goal_amount
FROM notsorted_contacts_remaining_goal_amount
ORDER BY "Remaining Goal Amount"  DESC;

-- Check the table
SELECT * FROM email_contacts_remaining_goal_amount;


-- 4. (5 pts)
-- Create a table, "email_backers_remaining_goal_amount" that contains the email address of each backer in descending order, 
-- and has the first and last name of each backer, the cf_id, company name, description, 
-- end date of the campaign, and the remaining amount of the campaign goal as "Left of Goal". 

SELECT b.email, b.first_name, b.last_name, b.cf_id,
	c.company_name, c.description, c.end_date, c.goal, c.pledged
INTO notsorted_backers_remaining_goal_amount
FROM backers as b
JOIN campaign as c
ON b.cf_id = c.cf_id;

ALTER TABLE notsorted_backers_remaining_goal_amount
ADD COLUMN "Left of Goal" numeric;

UPDATE notsorted_backers_remaining_goal_amount
SET "Left of Goal"  = goal - pledged;

SELECT email, first_name, last_name, cf_id, company_name, description, end_date,
	"Left of Goal"
INTO email_backers_remaining_goal_amount
FROM notsorted_backers_remaining_goal_amount
ORDER BY email DESC;

-- Check the table
SELECT * FROM email_backers_remaining_goal_amount;