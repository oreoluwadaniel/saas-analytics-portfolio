/*===========================================================
BILLING, PAYMENT & REVENUE LEAKAGE DETECTION SYSTEM

Business Objective
------------------------------------------------------------
This analysis evaluates the effectiveness of the company's
billing and payment processes by measuring revenue collection,
payment performance, customer payment behavior, and potential
revenue leakage.

Key Questions Answered
------------------------------------------------------------
1. Are all billed invoices being paid?
2. How much revenue has been successfully collected?
3. Where are potential revenue leakages occurring?
4. Which customers present collection risks?
5. How quickly are customers paying their invoices?
6. Which subscription plans generate the most revenue?
7. What percentage of invoices are successfully collected?
8. How much outstanding revenue remains unpaid?

This workflow follows a finance analytics process:

Data Validation -> Data Preparation -> Revenue Collection
Analysis -> Payment Performance Analysis -> Customer Payment
Analysis -> Revenue Leakage Detection -> Decision Support

Reviewed and corrected by Daniel Olatunji. See the project
README for the full list of what was found and why it mattered.
===========================================================*/


/*-----------------------------------------------------------
STEP 1: DATA QUALITY VALIDATION

Identify invoices that do not have corresponding payment
records and may represent outstanding collections.
-----------------------------------------------------------*/

SELECT *
FROM invoices i
LEFT JOIN payments p
    ON i.invoiceid = p.invoiceid
WHERE p.paymentid IS NULL;


/*-----------------------------------------------------------
STEP 2: DATA CLEANING

Replace missing payment amounts with zero to improve the
accuracy of payment and revenue calculations.
-----------------------------------------------------------*/

UPDATE payments
SET amountpaid = 0
WHERE amountpaid IS NULL;


/*-----------------------------------------------------------
STEP 3: REMOVE DUPLICATE PAYMENT RECORDS

Identify and remove duplicate payment transactions to prevent
revenue from being overstated.
-----------------------------------------------------------*/

WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY paymentid
               ORDER BY paymentdate
           ) AS rn
    FROM payments
)
DELETE FROM cte
WHERE rn > 1;


/*-----------------------------------------------------------
STEP 4: BUSINESS RULE VALIDATION

Identify invalid billing and payment records containing
negative monetary values that may require further review.
-----------------------------------------------------------*/

SELECT *
FROM invoices
WHERE amount < 0;


SELECT *
FROM payments
WHERE AmountPaid < 0;


/*-----------------------------------------------------------
STEP 5: BUILD ANALYTICAL DATA MODEL

Create a consolidated reporting view that combines
subscription, billing, payment, and plan information for
financial analysis.
-----------------------------------------------------------*/

CREATE VIEW v_billing_master AS
SELECT
    s.subscriptionid,
    s.customerid,
    s.planid,
    s.status,

    sp.planname,
    sp.monthlyprice,

    i.invoiceid,
    i.amount AS billed_amount,
    i.invoicedate,

    p.paymentid,
    p.AmountPaid,
    p.paymentdate

FROM subscriptions s
LEFT JOIN subscription_plans sp
    ON s.planid = sp.planid
LEFT JOIN invoices i
    ON s.subscriptionid = i.subscriptionid
LEFT JOIN payments p
    ON i.invoiceid = p.invoiceid;


/*-----------------------------------------------------------
KPI 1: TOTAL BILLED VS COLLECTED REVENUE

Measures total invoiced revenue, total payments collected,
and the remaining revenue gap requiring attention.

FIX: wrapped AmountPaid in COALESCE(..., 0). Invoices that
never received any payment at all come through the view with
a NULL AmountPaid (that's what the LEFT JOIN to payments
produces). Subtracting a NULL from billed_amount returns NULL,
and SUM() silently ignores NULL rows, so every fully-unpaid
invoice was dropping out of the revenue_gap total entirely
instead of counting as a full loss. That's the opposite of
what a revenue leakage report is supposed to catch, it was
quietly excluding the worst cases.
-----------------------------------------------------------*/

SELECT
    SUM(billed_amount) AS total_billed,
    SUM(COALESCE(AmountPaid, 0)) AS total_collected,
    SUM(billed_amount - COALESCE(AmountPaid, 0)) AS revenue_gap
FROM v_billing_master;


/*-----------------------------------------------------------
KPI 2: UNPAID INVOICE ANALYSIS

Identifies invoices that have not received any payment and
represent outstanding revenue.
-----------------------------------------------------------*/

SELECT
    invoiceid,
    billed_amount
FROM v_billing_master
WHERE paymentid IS NULL;


/*-----------------------------------------------------------
KPI 3: PARTIAL PAYMENT ANALYSIS

Identifies invoices that have been partially paid and require
additional collection efforts.
-----------------------------------------------------------*/

SELECT
    invoiceid,
    billed_amount,
    SUM(COALESCE(AmountPaid, 0)) AS paid

FROM v_billing_master
GROUP BY invoiceid, billed_amount
HAVING SUM(COALESCE(AmountPaid, 0)) < billed_amount;


/*-----------------------------------------------------------
KPI 4: PAYMENT SUCCESS RATE

Measures the percentage of invoices that have received
successful payment transactions.
-----------------------------------------------------------*/

SELECT
    COUNT(CASE WHEN paymentid IS NOT NULL THEN 1 END) * 1.0
    / COUNT(*) AS payment_success_rate
FROM v_billing_master;


/*-----------------------------------------------------------
KPI 5: REVENUE CONTRIBUTION BY PLAN

Identifies the subscription plans generating the highest
levels of collected revenue.
-----------------------------------------------------------*/

SELECT
    planname,
    SUM(COALESCE(AmountPaid, 0)) AS revenue
FROM v_billing_master
GROUP BY planname
ORDER BY revenue DESC;


/*-----------------------------------------------------------
KPI 6: CUSTOMER PAYMENT BEHAVIOR

Evaluates how customers are paying over time by measuring
their invoice volumes and total payments collected.
-----------------------------------------------------------*/

SELECT
    customerid,
    COUNT(invoiceid) AS invoices,
    SUM(COALESCE(amountpaid, 0)) AS total_paid
FROM v_billing_master
GROUP BY customerid;


/*-----------------------------------------------------------
KPI 7: PAYMENT DELAY ANALYSIS

Measures the number of days taken by customers to settle
their invoices and provides insights into collection cycles.
-----------------------------------------------------------*/

SELECT
    invoiceid,
    DATEDIFF(DAY, invoicedate, paymentdate) AS payment_delay
FROM v_billing_master
WHERE paymentdate IS NOT NULL;


/*-----------------------------------------------------------
KPI 8: HIGH RISK CUSTOMER IDENTIFICATION

Identifies customers with outstanding balances that may
require proactive collection efforts.

FIX: this is the most consequential fix in the file. The
original HAVING clause compared SUM(billed_amount - AmountPaid)
against 0, and for a customer whose invoices have zero payment
records at all, AmountPaid is NULL on every row, so the sum of
(billed_amount - NULL) is NULL, and "NULL > 0" is never true.
Those customers, the ones with the worst possible payment
behavior, were being silently excluded from the high-risk list
instead of appearing at the top of it. Wrapping AmountPaid in
COALESCE fixes the underlying sum so customers with zero
payments show up with their full billed amount as unpaid,
exactly where they belong.
-----------------------------------------------------------*/

SELECT
    customerid,
    SUM(billed_amount) AS billed,
    SUM(COALESCE(amountpaid, 0)) AS paid,

    SUM(billed_amount - COALESCE(amountpaid, 0)) AS unpaid

FROM v_billing_master
GROUP BY customerid
HAVING SUM(billed_amount - COALESCE(AmountPaid, 0)) > 0;


/*-----------------------------------------------------------
KPI 9: REVENUE LEAKAGE DETECTION ENGINE

Classifies customers based on their payment behavior to help
prioritize collection activities and reduce revenue leakage.

No Payment      : No payments have been received.
Partial Payment : Payments received are below billed amounts.
Fully Paid      : All billed amounts have been collected.

Note: this query already handled the NULL-payment case
correctly in the original script (the "IS NULL" branch below).
It's the one KPI in this file that got the NULL handling right
the first time, which is exactly why KPI 1 and KPI 8 needed to
be brought up to the same standard instead of left inconsistent
with it.
-----------------------------------------------------------*/

SELECT
    customerid,
    SUM(billed_amount) AS billed,
    SUM(AmountPaid) AS paid,

    CASE
        WHEN SUM(AmountPaid) IS NULL THEN 'No Payment'
        WHEN SUM(AmountPaid) = 0 THEN 'No Payment'
        WHEN SUM(AmountPaid) < SUM(billed_amount)
            THEN 'Partial Payment'
        ELSE 'Fully Paid'
    END AS payment_status

FROM v_billing_master
GROUP BY customerid;
