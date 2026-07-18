## SaaS Analytics Portfolio

This repo holds three SQL analyses I built on the same simulated SaaS company dataset. I built one dataset (customers, subscriptions, plans, invoices, payments, and product usage logs) and then asked three different business questions of it, because that's closer to how analytics actually works in a real company. Nobody hands you one ticket and says "do the analysis." Finance asks about revenue leakage, the product team asks about engagement, and leadership asks about churn, and it's usually the same handful of tables answering all of it.

Each project below is a complete, standalone write-up. You can open any one of them without reading the others and still get the full picture: the business problem, how I approached it, what I found wrong with the SQL when I reviewed it, what the data actually showed, and what I'd tell a stakeholder to do about it.

### The three projects

**01 - MRR, Churn & Revenue Intelligence** (`01-mrr-churn-analysis/`)
Looks at recurring revenue, churn rate, customer lifetime value, and where revenue is leaking out through unpaid invoices. This is the one a CFO or head of growth would care about most.

**02 - Customer Behavior & Product Usage Intelligence** (`02-customer-usage-analysis/`)
Looks at how customers actually use the product: daily and monthly active users, feature adoption, and a churn risk score based on engagement rather than billing status. This is the product team's view of the same customers.

**03 - Billing, Payment & Revenue Leakage Detection** (`03-billing-revenue-leakage/`)
Looks at the mechanics of getting paid: which invoices never got collected, how long customers take to pay, and which accounts are the biggest collection risk. This is the finance ops view.

### About the data

All three projects pull from the same six tables: `customers`, `subscriptions`, `subscription_plans`, `invoices`, `payments`, and `usage_logs`. The data is synthetic. I built it to behave like a real SaaS company at a mid-size scale (5,000 customers, 5,000 subscriptions, 6,000 invoices, 6,000 payments, 7,000 usage events) so the numbers would be large enough to produce genuine patterns instead of toy examples. Full column definitions and row counts are in `data/README.md`.

I'm calling this out directly rather than letting it pass as real customer data, because an honest data source note is part of doing this right. The SQL, the modeling decisions, and the bugs I found and fixed are all real. The company isn't.

### Why three separate write-ups instead of one

Every KPI query below was written against the same six tables, so it would have been easy to lump this into a single "SaaS analytics" write-up. I split it into three instead because that's what happens in practice: a churn analysis and a billing-leakage analysis get read by different people and get acted on differently, even when the underlying joins look similar. Treating them as three separate projects forced me to be sharper about what each one is actually for.

### Tools and approach

Every script is written in T-SQL (SQL Server syntax, using functions like `FORMAT()` and `DATEDIFF`). Each project follows the same general shape: validate the data, clean it, build one reporting view, then run a set of KPI queries against that view. I reviewed every script line by line for logic errors before publishing it here, not just for syntax. Where I found a real bug, I documented what it was, why it mattered, and how I fixed it, inside that project's own README.

### Repo structure

```
saas-analytics-portfolio/
  README.md                          <- this file
  data/
    README.md                        <- table definitions, row counts, how to get the CSVs
  01-mrr-churn-analysis/
    README.md
    mrr_churn_analysis.sql
  02-customer-usage-analysis/
    README.md
    customer_usage_analysis.sql
  03-billing-revenue-leakage/
    README.md
    billing_revenue_leakage.sql
```
