/*===========================================================
MRR, CHURN & REVENUE INTELLIGENCE SYSTEM

Business Objective
------------------------------------------------------------
This analysis evaluates the overall health of a SaaS business
by measuring recurring revenue, customer retention, churn,
revenue leakage, and customer value.

Key Questions Answered
------------------------------------------------------------
1. How much recurring revenue is collected each month?
2. How many active customers are currently subscribed?
3. What percentage of customers have churned?
4. Which subscription plans generate the most revenue?
5. What is the lifetime value of each customer?
6. How much revenue has been lost due to churn?
7. How are customer cohorts growing over time?
8. Are there unpaid invoices causing revenue leakage?
9. Which customers require retention attention?

This workflow follows a typical SaaS revenue analytics process:
Data Validation -> Data Preparation -> Revenue Analysis ->
Customer Analysis -> Churn Analysis -> Decision Support

Reviewed and corrected by Daniel Olatunji. See the project
README for the full list of what was found and why it mattered.
===========================================================*/


/*-----------------------------------------------------------
STEP 1: DATA QUALITY VALIDATION

Before performing any analysis, validate critical fields to
identify missing values that could impact revenue reporting,
customer metrics, or subscription tracking.
-----------------------------------------------------------*/

SELECT * FROM subscriptions WHERE customerid IS NULL;
SELECT * FROM invoices WHERE amount IS NULL;
SELECT * FROM payments WHERE PaymentID IS NULL;


/*-----------------------------------------------------------
STEP 2: BUSINESS RULE VALIDATION

Identify subscriptions with invalid date ranges where the
start date occurs after the end date.
-----------------------------------------------------------*/

SELECT * FROM subscriptions
WHERE StartDate > enddate;


/*-----------------------------------------------------------
STEP 3: DATA STANDARDIZATION

Convert subscription status values to lowercase to ensure
consistent filtering and reporting across analyses.
-----------------------------------------------------------*/

UPDATE subscriptions
SET status = LOWER(status);


/*-----------------------------------------------------------
STEP 4: BUILD ANALYTICAL DATA MODEL

Create a unified SaaS reporting view that combines customer,
subscription, plan, invoice, and payment information into a
single source for downstream analysis.
-----------------------------------------------------------*/

CREATE VIEW v_saas_master AS
SELECT
    c.customerid,
    c.country,
    c.signupdate,

    s.subscriptionid,
    s.planid,
    s.status,
    s.startdate,
    s.enddate,

    sp.planname,
    sp.MonthlyPrice,

    i.invoiceid,
    i.amount AS invoice_amount,
    i.invoicedate,

    p.paymentid,
    p.AmountPaid,
    p.paymentdate

FROM customers c
LEFT JOIN subscriptions s
    ON c.customerid = s.customerid
LEFT JOIN subscription_plans sp
    ON s.planid = sp.planid
LEFT JOIN invoices i
    ON s.subscriptionid = i.subscriptionid
LEFT JOIN payments p
    ON i.invoiceid = p.invoiceid;


/*-----------------------------------------------------------
KPI 1: MONTHLY RECURRING REVENUE (COLLECTED)

Measures recurring revenue actually collected each month.

FIX: renamed from "MRR" to make clear this is cash collected,
not billed revenue. SUM(AmountPaid) only counts money that has
actually landed, so an invoice sitting unpaid contributes
nothing here even though it was billed. That's the right
number for a cash view, but it's a different number from
"billed MRR," and the original label blurred the two together.
-----------------------------------------------------------*/

SELECT
    FORMAT(invoicedate, 'yyyy-MM') AS month,
    SUM(AmountPaid) AS collected_revenue
FROM v_saas_master
GROUP BY FORMAT(invoicedate, 'yyyy-MM')
ORDER BY month;


/*-----------------------------------------------------------
KPI 2: ACTIVE CUSTOMER COUNT

Measures the number of customers with active subscriptions.
This serves as a key indicator of customer retention and
business scale.
-----------------------------------------------------------*/

SELECT
    COUNT(DISTINCT customerid) AS active_customers
FROM subscriptions
WHERE LOWER(status) = 'active';


/*-----------------------------------------------------------
KPI 3: CUSTOMER CHURN RATE

Calculates the proportion of subscriptions that have been
cancelled relative to total subscriptions.

FIX: wrapped status in LOWER() so this query gives the right
answer whether or not Step 3 has already run. The original
version relied on Step 3 having executed first, which is fine
in a top-to-bottom run of this file but breaks the moment
someone copies just this query into a scheduled report.
-----------------------------------------------------------*/

SELECT
    COUNT(CASE WHEN LOWER(status) = 'cancelled' THEN 1 END) * 1.0
    / COUNT(*) AS churn_rate
FROM subscriptions;


/*-----------------------------------------------------------
KPI 4: REVENUE CONTRIBUTION BY PLAN

Identifies which subscription plans generate the highest
revenue and highlights the most valuable offerings.
-----------------------------------------------------------*/

SELECT
    sp.planname,
    SUM(p.AmountPaid) AS revenue
FROM subscription_plans sp
JOIN subscriptions s
    ON sp.planid = s.planid
JOIN invoices i
    ON s.subscriptionid = i.subscriptionid
JOIN payments p
    ON i.invoiceid = p.invoiceid
GROUP BY sp.planname
ORDER BY revenue DESC;


/*-----------------------------------------------------------
KPI 5: CUSTOMER LIFETIME VALUE (CLV)

Measures total revenue generated by each customer throughout
their relationship with the business.
-----------------------------------------------------------*/

SELECT
    customerid,
    SUM(amountpaid) AS lifetime_value
FROM v_saas_master
GROUP BY customerid
ORDER BY lifetime_value DESC;


/*-----------------------------------------------------------
KPI 6: CHURNED REVENUE

Calculates revenue associated with cancelled subscriptions
to estimate revenue lost through customer churn.

FIX: same LOWER() fix as KPI 3, for the same reason.
-----------------------------------------------------------*/

SELECT
    SUM(AmountPaid) AS lost_revenue
FROM v_saas_master
WHERE LOWER(status) = 'cancelled';


/*-----------------------------------------------------------
KPI 7: CUSTOMER COHORT ANALYSIS

Groups customers by signup month to understand acquisition
patterns and support future retention analysis.
-----------------------------------------------------------*/

SELECT
    FORMAT(signupdate, 'yyyy-MM') AS cohort,
    COUNT(DISTINCT customerid) AS customers
FROM customers
GROUP BY FORMAT(signupdate, 'yyyy-MM')
ORDER BY cohort;


/*-----------------------------------------------------------
KPI 8: REVENUE LEAKAGE ANALYSIS

Identifies invoices that have not received a corresponding
payment and may represent missed revenue opportunities.
-----------------------------------------------------------*/

SELECT
    COUNT(*) AS unpaid_invoices
FROM invoices i
LEFT JOIN payments p
    ON i.invoiceid = p.invoiceid
WHERE p.paymentid IS NULL;


/*-----------------------------------------------------------
KPI 9: CUSTOMER VALUE SEGMENTATION

Classifies customers into value tiers based on total revenue
generated, helping support retention and growth strategies.

FIX: moved the "no payment history" check to the top of the
CASE statement. It worked in the original order too, since a
NULL comparison against a number silently evaluates to false
and SQL just keeps falling through to the next WHEN, but that's
relying on a NULL-handling quirk rather than stating the intent
plainly. Checking IS NULL first says exactly what's happening
instead of making the next person trace through it.
-----------------------------------------------------------*/

SELECT
    customerid,
    SUM(amountpaid) AS revenue,

    CASE
        WHEN SUM(AmountPaid) IS NULL THEN 'No Value'
        WHEN SUM(AmountPaid) < 100 THEN 'At Risk'
        WHEN SUM(AmountPaid) < 500 THEN 'Mid Value'
        ELSE 'High Value'
    END AS customer_segment
FROM v_saas_master
GROUP BY customerid;
