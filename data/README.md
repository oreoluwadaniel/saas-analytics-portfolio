## Data dictionary

*(This file goes in `saas-analytics-portfolio/data/README.md` in the repo.)*

Six tables make up this dataset. I generated it to mimic a real SaaS business at a mid-size scale, with realistic messiness built in: some subscriptions are past due, some invoices never get paid, some payments fail. Row counts below are exact, pulled directly from the CSVs.

### customers (5,000 rows)

| Column | Type | Notes |
|---|---|---|
| CustomerID | int | primary key |
| CustomerName | text | |
| Email | text | |
| Country | text | |
| SignupDate | date | |

### subscription_plans (5 rows)

| Column | Type | Notes |
|---|---|---|
| PlanID | int | primary key |
| PlanName | text | Basic, Startup, Business, Pro, Enterprise |
| MonthlyPrice | decimal | $29.99 to $199.99 |

### subscriptions (5,000 rows)

| Column | Type | Notes |
|---|---|---|
| SubscriptionID | int | primary key |
| CustomerID | int | foreign key to customers |
| PlanID | int | foreign key to subscription_plans |
| StartDate | date | |
| EndDate | date | blank if the subscription hasn't ended |
| Status | text | Active, Past Due, or Cancelled |

Status breakdown: 1,776 Active, 1,772 Past Due, 1,452 Cancelled. That Past Due number sitting almost level with Active is the single biggest flag in the whole dataset, and it shows up as a real finding in two of the three write-ups.

### invoices (6,000 rows)

| Column | Type | Notes |
|---|---|---|
| InvoiceID | int | primary key |
| SubscriptionID | int | foreign key to subscriptions |
| InvoiceDate | date | |
| Amount | decimal | billed amount |
| Status | text | Paid or Unpaid |

Status breakdown: 4,529 Paid, 1,471 Unpaid (24.5% of all invoices).

### payments (6,000 rows)

| Column | Type | Notes |
|---|---|---|
| PaymentID | int | primary key |
| InvoiceID | int | foreign key to invoices |
| PaymentDate | date | |
| AmountPaid | decimal | |
| PaymentStatus | text | Completed or Failed |

Status breakdown: 4,776 Completed, 1,224 Failed (20.4% of all payment attempts).

### usage_logs (7,000 rows)

| Column | Type | Notes |
|---|---|---|
| LogID | int | primary key |
| CustomerID | int | foreign key to customers |
| FeatureUsed | text | Automation Run, API Call, Integration Sync, Workflow Edit, or Error Event |
| UsageCount | int | |
| UsageDate | date | |

### A note on data quality

I ran the null and negative-value checks that each script's Step 1 calls for directly against these CSVs before writing anything up. There are no negative amounts anywhere in invoices or payments, and no blank CustomerID or UsageDate rows in usage_logs. That doesn't mean the cleaning steps in the scripts are pointless. It means this particular generated batch came out clean on those dimensions, and the defensive SQL is still exactly what you'd want running against messier real-world data. I noted that distinction inside each project's Analysis & Error Check section instead of pretending I found dirty data that wasn't there.

### Getting the actual CSV files

The CSVs themselves aren't duplicated across all three project folders since they're shared. Drop `customers.csv`, `subscriptions.csv`, `subscription_plans.csv`, `invoices.csv`, `payments.csv`, and `usage_logs.csv` straight into this `data/` folder when you upload the repo. You've already got them from the same source I worked from.
