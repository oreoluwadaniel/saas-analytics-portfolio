# SaaS Revenue, Product and Billing Analytics

A set of three SQL case studies built from one synthetic SaaS dataset. The work follows a subscription business from recurring revenue and churn, through product usage, to unpaid invoices and revenue leakage.

The point of the repository is not to show a long list of SQL functions. It is to show how the same customer, subscription, billing, and usage data can answer different questions for Finance, Product, Customer Success, and Revenue Operations.

**Data:** synthetic
**Primary tool:** SQL Server (T-SQL)
**Coverage:** 5,000 customers and subscriptions, 6,000 invoices and payments, 7,000+ usage records

---

## The three decisions

| Case study | Management question | Main measures |
|---|---|---|
| [01. MRR and Churn](01-mrr-churn-analysis/) | Is recurring revenue growing, and where is churn reducing it? | MRR, churn, CLV, revenue movement |
| [02. Customer Usage](02-customer-usage-analysis/) | Which usage patterns are associated with retention and churn? | DAU, MAU, feature adoption, engagement, churn risk |
| [03. Billing and Revenue Leakage](03-billing-revenue-leakage/) | What has been billed but not collected, and where is cash at risk? | Collections, invoice aging, outstanding receivables, payment performance |

---

## How the data connects

```text
Customers
   |
   +---- Subscriptions ---- Subscription Plans
   |
   +---- Usage Logs ------- Product Usage
   |
   +---- Invoices --------- Payments

                 |
                 v
        SQL analytical views
                 |
        +--------+---------+
        |        |         |
      Revenue  Product   Billing
      review   review    review
```

The three analyses use the same underlying business entities, but they answer different questions. This is deliberate. In a real SaaS company, Finance should not have to rebuild the customer population every time Product needs a retention analysis.

---

## 01. MRR and Churn

The first case study looks at recurring revenue performance.

It answers:

- Is MRR increasing or declining?
- Which customers and plans contribute most to recurring revenue?
- How much MRR is lost when customers cancel?
- Which customer groups have stronger lifetime value?
- Where does revenue movement need management attention?

The analysis uses subscription history to calculate recurring revenue movement rather than treating every invoice as recurring revenue.

**Primary users:** Finance, Revenue Operations, executive leadership.

---

## 02. Customer Usage

Revenue numbers alone do not explain whether customers are getting value from a product.

This case study connects usage records to customer and subscription information to examine:

- Active users over time
- Feature adoption
- Engagement levels
- Differences between retained and churned customers
- Accounts showing weaker usage patterns

The output is intended to help Customer Success and Product teams decide which accounts need attention and which product behaviors deserve further investigation.

A usage pattern is treated as a risk signal, not proof that a customer will churn.

**Primary users:** Product, Customer Success, Growth.

---

## 03. Billing and Revenue Leakage

A customer can be active and revenue can look healthy while cash collection is deteriorating.

This case study examines:

- Unpaid invoices
- Invoice aging
- Collection rates
- Payment timing
- Accounts with larger outstanding balances
- Revenue that has been billed but not collected

The purpose is to give Finance and Revenue Operations a clear queue of accounts and invoices that need follow-up.

**Primary users:** Finance, Billing Operations, Revenue Operations.

---

## Data

The repository uses synthetic data created for portfolio analysis. No real customer, subscription, payment, or product records are included.

| Table | Approximate records |
|---|---:|
| Customers | 5,000 |
| Subscriptions | 5,000 |
| Subscription Plans | Pricing-plan records |
| Invoices | 6,000 |
| Payments | 6,000 |
| Usage Logs | 7,000+ |

The data was designed to contain enough variation to test recurring revenue, customer behavior, billing, and churn calculations.

---

## Analytical checks

Before interpreting the results, each case study checks the assumptions that can quietly break SaaS reporting:

- Customer and subscription keys match
- Subscription dates are logically ordered
- Invoice and payment relationships are valid
- Revenue measures use the intended business grain
- Customers are not counted more than once because of one-to-many joins
- Churn definitions use a stated denominator and time window
- Billing balances reconcile to invoice and payment records

These checks matter because a SQL query can run without errors while still producing the wrong business number.

---

## Repository structure

```text
saas-analytics-portfolio/
|
|-- README.md
|-- data/
|   `-- README.md
|
|-- 01-mrr-churn-analysis/
|   |-- README.md
|   `-- mrr_churn_analysis.sql
|
|-- 02-customer-usage-analysis/
|   |-- README.md
|   `-- customer_usage_analysis.sql
|
`-- 03-billing-revenue-leakage/
    |-- README.md
    `-- billing_revenue_leakage.sql
```

Start with the case-study README, then open the SQL file to follow the calculations.

---

## What this demonstrates

The repository shows how to move from operational SaaS records to three connected management views:

**Revenue:** what is happening to recurring revenue and churn?

**Product:** what are customers actually doing with the product?

**Billing:** what has been earned, billed, and collected?

The strongest part of the work is the connection between those questions. Revenue decline can be investigated alongside customer behavior, while billing problems can be separated from genuine subscription churn.

**Built by Daniel Olatunji**
