# Customer Health & Churn Prevention Analytics

A SQL-based customer health analysis that uses product usage and subscription history to identify customers showing signs of disengagement before they become churn statistics.

The dataset is synthetic and contains **5,000 customers, 5,000 subscription records, and 7,000+ product usage events** across five tracked product features.

**Stack:** SQL Server, T-SQL  
**Focus:** Customer health, product engagement, churn risk, retention

## The business problem

A customer can still be paying, have an active subscription, and look healthy in a billing report while quietly getting less value from the product.

By the time that customer appears in a monthly churn report, the opportunity to intervene may already be gone.

This analysis looks for the warning signs earlier:

- Which customers are becoming less active?
- Which accounts show weak product engagement?
- Which features are associated with stronger usage?
- Which customers need Customer Success attention?
- What separates retained customers from churned customers?

The goal is simple:

> **Identify customers who may need help while they are still customers.** :contentReference[oaicite:0]{index=0}

## How it works

```text
Customers
    ↓
Subscription History
    ↓
Usage Events
    ↓
Data Validation
    ↓
Current Subscription Resolution
    ↓
Customer Usage Layer
    ↓
Engagement | Feature Adoption | Health | Churn Signals
    ↓
Customer Segmentation
    ↓
Retention Actions
