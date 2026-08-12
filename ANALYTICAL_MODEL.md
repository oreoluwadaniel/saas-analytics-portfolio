# SaaS Analytical Model

The three case studies use related business entities so revenue, product usage, and billing can be investigated together.

```text
Customers
   |
   +--> subscriptions --> plans
   |
   +--> usage logs
   |
   +--> invoices --> payments
   |
   v
SQL analytical views
   |
   +--> MRR and churn
   +--> product engagement
   +--> billing leakage
```

## Metric controls

- MRR is based on subscription records, not invoice totals.
- Churn uses a stated customer population and time window.
- One-to-many joins are checked so customers are not counted repeatedly.
- Invoice balances reconcile to invoice amounts and payments.
- Usage signals are treated as risk indicators, not proof of future churn.

The dataset is synthetic and is used to demonstrate the SQL analysis rather than report on a real SaaS company.
