# SaaS Revenue, Retention & Subscription Intelligence

A SQL-based revenue intelligence framework that helps a SaaS business see beyond headline MRR: what revenue is growing, what is at risk, what customers are leaving, and what has been billed but not collected.

The dataset is synthetic and contains 5,000 customers, 5,000 subscriptions, 6,000 invoices, 6,000 payments, and five pricing plans.

**Stack:** SQL Server, T-SQL  
**Focus:** Revenue, churn, collections, subscription health, customer value

## The business problem

A SaaS company can report healthy revenue growth while problems are building underneath it.

Customers can be cancelling. Payments can be falling behind. Past-due subscriptions can be growing. Revenue can be billed but never collected.

This project brings those signals together so management can answer:

- Is recurring revenue actually healthy?
- How much revenue is being lost to churn?
- Which subscriptions need attention?
- How much revenue remains uncollected?
- Which customers are most valuable?
- Are payment problems becoming an early warning sign of churn?

The goal is not simply to report revenue. It is to understand **how reliable and sustainable that revenue is**.

## What the system covers

```text
Customers
    ↓
Subscriptions → Plans
    ↓
Invoices → Payments
    ↓
Data Validation
    ↓
Revenue Intelligence Layer
    ↓
Revenue | Retention | Collections | Customer Value
    ↓
Management Decisions
