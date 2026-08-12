# SaaS Revenue, Product & Billing Analytics

Three SQL case studies built from one synthetic SaaS dataset, covering the three areas that matter when recurring revenue starts moving: **revenue, customer usage, and cash collection**.

The same customer, subscription, usage, invoice, and payment data is used to answer different management questions across Finance, Product, Customer Success, and Revenue Operations.

**Data:** Synthetic  
**Stack:** SQL Server, T-SQL  
**Scale:** 5,000 customers and subscriptions, 6,000 invoices and payments, 7,000+ usage records

## The three business questions

| Case study | Business question | What it measures |
|---|---|---|
| [01. MRR & Churn](01-mrr-churn-analysis/) | Is recurring revenue growing, and where is churn eating into it? | MRR, churn, CLV, revenue movement |
| [02. Customer Usage](02-customer-usage-analysis/) | Are customers using the product enough to stay? | DAU, MAU, feature adoption, engagement, churn signals |
| [03. Billing & Revenue Leakage](03-billing-revenue-leakage/) | What has been billed but not collected? | Collections, aging, receivables, payment performance |

## One data foundation, three views

```text
Customers
   |
   +---- Subscriptions ---- Plans
   |
   +---- Usage Logs ------- Product Activity
   |
   +---- Invoices --------- Payments
                |
                v
        SQL Analysis Layer
                |
       +--------+--------+
       |        |        |
    Revenue  Product   Billing
