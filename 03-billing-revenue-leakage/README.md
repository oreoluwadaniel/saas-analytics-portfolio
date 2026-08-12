# Revenue Operations & Revenue Recovery Analytics

A SQL-based billing and collections analysis that helps a SaaS business identify **what has been billed, what has actually been collected, where revenue is leaking, and which accounts need attention first**.

The dataset is synthetic and contains **5,000 subscriptions, 6,000 invoices, and 6,000 payment records** across five pricing plans.

**Stack:** SQL Server, T-SQL  
**Focus:** Billing, collections, revenue leakage, payment risk, revenue recovery

## The business problem

A SaaS company can report strong revenue growth while cash collection quietly deteriorates.

Invoices may remain unpaid. Payment attempts may fail. Customers may make partial payments. Accounts with no payment record may disappear from collection reports if NULL values are handled incorrectly.

This analysis focuses on the question Finance and Revenue Operations actually need answered:

> **Which revenue should we recover first?**

It looks at:

- Billed versus collected revenue
- Unpaid invoices
- Payment failures
- Partial payments
- Invoice aging
- Customer payment behavior
- Revenue leakage
- Collection risk

## How it works

```text
Subscriptions
      ↓
Subscription Plans
      ↓
Invoices
      ↓
Payments
      ↓
Data Validation
      ↓
Billing Master View
      ↓
Collections | Payment Risk | Revenue Leakage
      ↓
Recovery Prioritization
      ↓
Management Action
