## MRR, Churn & Revenue Intelligence

*(This README goes in `saas-analytics-portfolio/01-mrr-churn-analysis/README.md`, alongside `mrr_churn_analysis.sql`.)*

### Business problem

A subscription business lives or dies by three numbers: how much recurring revenue is coming in, how many customers are leaving, and how much of the revenue that's owed actually gets collected. Most SaaS companies I've looked at can answer one of those questions cleanly and are fuzzy on the other two, usually because the data sits in three different systems (a billing tool, a CRM, a spreadsheet someone updates by hand).

This project answers all three from one place: how much revenue is landing each month, what the churn rate looks like, which plans are actually worth the most, and where money is slipping through the cracks on unpaid invoices. The goal is the kind of report a head of growth or a CFO could open and immediately know whether the business is healthy or quietly bleeding.

### Data source

Six related tables: `customers`, `subscriptions`, `subscription_plans`, `invoices`, and `payments` (this project doesn't touch `usage_logs`, that's project 2). I generated the data myself to behave like a real SaaS company rather than pulling from an actual company's books, and the full schema and row counts are documented in `data/README.md` at the root of this repo. Scale: 5,000 customers, 5,000 subscription records, 6,000 invoices, 6,000 payments, across 5 pricing plans from $29.99 to $199.99 a month.

### Methodology

I followed the process the script lays out at the top: validate the data first, clean what needs cleaning, build one reporting view that joins everything together, then run the KPI queries against that view instead of hitting the raw tables over and over. Building `v_saas_master` once and reusing it for six of the nine KPIs keeps the logic in one place. If the join logic ever needs to change, I only have to change it once instead of hunting through nine separate queries.

I ran the validation queries first (checking for null customer IDs, null invoice amounts, and subscriptions where the start date is somehow after the end date) before writing a single KPI. There's no point calculating churn rate on top of data that might have broken subscription records underneath it.

### Analysis & error check

I went through this script the way I'd review a teammate's pull request, not just checking that it runs, but checking that it gives the right answer for the right reason. Two real issues turned up:

The churn rate and churned revenue queries (KPI 3 and KPI 6) filter on `status = 'cancelled'`, which only works correctly after Step 3 has already run and converted all the status values to lowercase. Run the file top to bottom and you're fine. But the moment someone (including future me) copies just the churn rate query into a scheduled report or a dashboard's data source without also running Step 3 first, it silently returns 0% churn instead of throwing an error, which is worse than a query that fails loudly. I fixed both by wrapping the comparison in `LOWER()` so the query is correct regardless of whether the standardization step ran.

The customer segmentation query (KPI 9) checks `SUM(AmountPaid) < 100` before it checks whether the sum is NULL. In SQL, comparing NULL to a number doesn't return false, it returns unknown, which behaves like false for CASE purposes, so the query still worked. But it worked by accident of NULL-handling behavior rather than by clearly stated intent, and that's the kind of thing that looks fine in testing and confuses someone six months later. I moved the NULL check to the top of the CASE statement so the logic reads the way it actually executes.

I also renamed the output of KPI 1 from "MRR" to "collected_revenue." The original query sums `AmountPaid`, which only counts money that has actually come in. That's a legitimate and useful number, but it's a cash-collected view, not the standard MRR definition (active subscriptions times their monthly price, regardless of whether that month's invoice has been paid yet). Calling it MRR when it's really "revenue we've actually collected" would mislead anyone using this for forecasting.

Beyond those, I checked the dataset itself against what the validation queries were designed to catch: no negative invoice or payment amounts, no missing customer IDs. The corrected script is in `mrr_churn_analysis.sql`, with each fix marked inline as a comment.

### Insight

Cancellation rate came out to 29% of all subscriptions (1,452 of 5,000). On its own that's a number you'd want lower, but it's not the number that stood out most.

What stood out is that 1,772 subscriptions, or 35.4% of the total, are sitting in "Past Due" status, almost exactly matching the 1,776 subscriptions that are "Active" (35.5%). For every customer currently paying on time, there's very nearly one customer who is behind. Past Due isn't cancelled yet, but it's the stage right before cancellation, and a book of business where a third of subscriptions are already behind on payment is not a book of business that's stable. It's a leading indicator, and it's a bigger one than the churn rate itself.

On the leakage side, unpaid invoices are sitting at 1,471 out of 6,000 total, 24.5% of everything ever billed. That's revenue this business has technically earned and hasn't collected.

### Recommendation

Treat Past Due as its own workflow, not a waiting room before cancellation. Right now the data suggests these accounts sit in that status without a clear trigger for action. I'd build an automated dunning sequence (payment retry, then an email, then a call from someone on the team) that kicks in the moment a subscription flips to Past Due, rather than waiting for it to become Cancelled. Given how close the Past Due count is to the Active count, this single workflow probably has more revenue impact than any acquisition initiative the company could run this quarter.

Second, don't report "MRR" without specifying whether it's billed or collected. Finance and growth teams often use these interchangeably in conversation, and a 24.5% unpaid invoice rate means the gap between the two numbers is real money, not a rounding error.

### Business impact

If even half of the Past Due subscriptions are recoverable through a faster, more structured follow-up process, that's roughly 880 subscriptions moving back to Active instead of drifting into Cancelled. At an average plan price across the five tiers of roughly $98/month, that's in the neighborhood of $86,000 in monthly recurring revenue retained rather than lost, plus whatever share of the $1,471 unpaid invoices get collected once there's an actual process chasing them instead of a status sitting quietly in a database.

### What was done

Reviewed the original script section by section, ran the validation logic against the actual data to confirm what it would and wouldn't catch, fixed the two logic issues described above, renamed one misleading output column, and documented every change inline in the corrected SQL file.

### Tools used and how they helped

Written in T-SQL (SQL Server), using `FORMAT()` for date-to-month grouping, a `CASE` statement for segmentation, and a single reusable view (`v_saas_master`) to avoid repeating five-table joins across nine separate KPI queries. Building the view once meant every KPI downstream automatically inherited the same join logic, so there's only one place to fix a join bug instead of nine.

### Results

A nine-KPI reporting layer covering recurring revenue collected by month, active customer count, churn rate, revenue by plan, customer lifetime value, churned revenue, cohort growth, unpaid invoice count, and a customer value segmentation, all built on top of one shared view. Two real logic bugs found and fixed, both documented with the reasoning behind the fix, not just the fix itself.
