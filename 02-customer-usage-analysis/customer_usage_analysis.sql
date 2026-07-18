/*===========================================================
CUSTOMER BEHAVIOR & PRODUCT USAGE INTELLIGENCE SYSTEM

Business Objective
------------------------------------------------------------
This analysis evaluates how customers interact with the
product by measuring engagement levels, feature adoption,
usage patterns, retention signals, and churn risk.

Key Questions Answered
------------------------------------------------------------
1. Which customers actively use the product?
2. How many users engage with the platform daily and monthly?
3. Which behaviors are associated with customer retention?
4. Which product features drive the highest engagement?
5. Who are the most valuable and highly engaged users?
6. Which customers are inactive or at risk of churning?
7. How can customers be segmented based on usage patterns?
8. What early warning signs indicate potential churn?

This workflow follows a product analytics process:

Data Validation -> Data Preparation -> Product Usage Analysis
-> Customer Engagement Analysis -> Retention Analysis
-> Churn Risk Assessment -> Decision Support

Reviewed and corrected by Daniel Olatunji. See the project
README for the full list of what was found and why it mattered.
===========================================================*/


/*-----------------------------------------------------------
STEP 1: DATA QUALITY VALIDATION

Identify records with missing customer identifiers or usage
dates that could affect product usage metrics.
-----------------------------------------------------------*/

SELECT *
FROM usage_logs
WHERE customerid IS NULL
   OR UsageDate IS NULL;


/*-----------------------------------------------------------
STEP 2: DATA CLEANING

Remove records with missing customer identifiers or missing
usage dates to preserve the accuracy of user-level analysis.

FIX: the original DELETE only removed rows with a null
customerid, even though Step 1 also checks for a null
UsageDate. Any row with a valid customer ID but a missing date
would have passed cleaning untouched and then landed in a NULL
bucket in the DAU and MAU queries further down, quietly
understating those counts. The DELETE now matches what Step 1
actually validates.
-----------------------------------------------------------*/

DELETE FROM usage_logs
WHERE customerid IS NULL
   OR UsageDate IS NULL;


/*-----------------------------------------------------------
STEP 3: REMOVE DUPLICATE RECORDS

Identify and remove duplicate usage records to ensure that
engagement metrics accurately reflect customer activity.

FIX: the original partition was customerid + usagedate only,
which meant a customer using two different features on the
same day (a completely normal thing to do) would get flagged
as a "duplicate" of themselves and one of the rows would be
deleted. That's real usage data being thrown away, not
deduplication. Adding FeatureUsed to the partition means a row
only gets removed if it's a true duplicate: same customer, same
feature, same day.
-----------------------------------------------------------*/

WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customerid, usagedate, featureused
               ORDER BY usagedate
           ) AS rn
    FROM usage_logs
)
DELETE FROM cte
WHERE rn > 1;


/*-----------------------------------------------------------
STEP 4: BUILD ANALYTICAL DATA MODEL

Create a consolidated reporting view that combines customer,
subscription, and product usage information to support
engagement and retention analysis.

FIX: the original view joined customers straight to
subscriptions on customerid. If a customer has more than one
subscription record over time (a cancellation followed by a
resubscribe, for example), that join produces one row per
subscription per usage event instead of one row per usage
event, which inflates every usage-based KPI that reads from
this view. The subquery below picks a single "current"
subscription per customer (the most recently started one) so
downstream KPIs aren't quietly counting the same usage event
multiple times.
-----------------------------------------------------------*/

CREATE VIEW v_usage_master AS
WITH current_subscription AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customerid
               ORDER BY startdate DESC
           ) AS rn
    FROM subscriptions
)
SELECT
    c.customerid,
    c.signupdate,
    c.country,

    s.subscriptionid,
    s.status,

    u.UsageDate,
    u.FeatureUsed,
    u.usagecount

FROM customers c
LEFT JOIN current_subscription s
    ON c.customerid = s.customerid AND s.rn = 1
LEFT JOIN usage_logs u
    ON c.customerid = u.customerid;


/*-----------------------------------------------------------
KPI 1: CUSTOMER ENGAGEMENT LEVEL

Measures the total number of product interactions for each
customer and provides a high-level view of user activity.
-----------------------------------------------------------*/

SELECT
    customerid,
    COUNT(*) AS usagecount
FROM usage_logs
GROUP BY customerid;


/*-----------------------------------------------------------
KPI 2: DAILY ACTIVE USERS (DAU)

Measures the number of unique users engaging with the product
each day and helps monitor short-term engagement trends.
-----------------------------------------------------------*/

SELECT
    UsageDate,
    COUNT(DISTINCT customerid) AS DAU
FROM usage_logs
GROUP BY UsageDate
ORDER BY UsageDate;


/*-----------------------------------------------------------
KPI 3: MONTHLY ACTIVE USERS (MAU)

Measures the number of unique customers interacting with the
platform each month and provides insights into long-term
engagement patterns.
-----------------------------------------------------------*/

SELECT
    FORMAT(usagedate,'yyyy-MM') AS month,
    COUNT(DISTINCT customerid) AS MAU
FROM usage_logs
GROUP BY FORMAT(UsageDate,'yyyy-MM')
ORDER BY month;


/*-----------------------------------------------------------
KPI 4: PRODUCT USAGE VS CUSTOMER CHURN

Compares average usage levels across subscription statuses
to determine whether engagement influences customer retention.

FIX: now reads from v_usage_master, which resolves each
customer down to a single current subscription before joining
to usage. The original version joined subscriptions and
usage_logs directly, so a customer with two subscription rows
would have their usage counted twice in the average, once per
subscription. That's a fan-out bug, and it would have quietly
skewed the average usage number for any status with customers
who re-subscribed.
-----------------------------------------------------------*/

SELECT
    status,
    AVG(usagecount) AS avg_usage
FROM v_usage_master
GROUP BY status;


/*-----------------------------------------------------------
KPI 5: FEATURE ADOPTION ANALYSIS

Identifies the most frequently used product features and
highlights areas delivering the greatest customer value.
-----------------------------------------------------------*/

SELECT
    FeatureUsed,
    COUNT(*) AS usage_frequency
FROM usage_logs
GROUP BY FeatureUsed
ORDER BY usage_frequency DESC;


/*-----------------------------------------------------------
KPI 6: POWER USER IDENTIFICATION

Identifies highly engaged customers based on total product
usage and helps uncover potential advocates or premium users.
-----------------------------------------------------------*/

SELECT
    customerid,
    SUM(usagecount) AS total_usage
FROM usage_logs
GROUP BY customerid
ORDER BY total_usage DESC;


/*-----------------------------------------------------------
KPI 7: INACTIVE CUSTOMER ANALYSIS

Identifies customers who have not interacted with the product
and may require re-engagement initiatives.
-----------------------------------------------------------*/

SELECT
    c.customerid
FROM customers c
LEFT JOIN usage_logs u
    ON c.customerid = u.customerid
WHERE u.customerid IS NULL;


/*-----------------------------------------------------------
KPI 8: USAGE FREQUENCY SEGMENTATION

Groups customers according to their engagement levels to
support targeted retention and product adoption strategies.
-----------------------------------------------------------*/

SELECT
    customerid,
    SUM(usagecount) AS total_usage,

    CASE
        WHEN SUM(usagecount) < 10 THEN 'Low Usage'
        WHEN SUM(usagecount) < 50 THEN 'Medium Usage'
        ELSE 'High Usage'
    END AS usage_segment

FROM usage_logs
GROUP BY customerid;


/*-----------------------------------------------------------
KPI 9: RETENTION DRIVER ANALYSIS

Measures feature adoption across the customer base to identify
which product capabilities contribute most to user retention.
-----------------------------------------------------------*/

SELECT
    FeatureUsed,
    COUNT(DISTINCT customerid) AS users
FROM usage_logs
GROUP BY FeatureUsed
ORDER BY users DESC;


/*-----------------------------------------------------------
KPI 10: CUSTOMER CHURN RISK MODEL

Uses customer usage behavior to classify subscribers into
risk categories, providing an early warning system for
potential customer churn.

High Churn Risk  : Minimal product engagement.
Medium Risk      : Moderate product engagement.
Low Risk         : Strong and consistent engagement.

FIX: now built on v_usage_master for the same reason as KPI 4.
Reading straight from customers/usage_logs/subscriptions with
three separate LEFT JOINs meant a customer with more than one
subscription record would show up as more than one row in the
GROUP BY, splitting (and understating) their usage total across
rows instead of reflecting it as one customer with one risk
score.
-----------------------------------------------------------*/

SELECT
    customerid,
    SUM(usagecount) AS total_usage,
    status,

    CASE
        WHEN SUM(usagecount) < 5 THEN 'High Churn Risk'
        WHEN SUM(usagecount) < 20 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS churn_risk

FROM v_usage_master
GROUP BY customerid, status;
