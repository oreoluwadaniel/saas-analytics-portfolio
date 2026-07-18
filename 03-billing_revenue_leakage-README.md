## Billing, Payment & Revenue Leakage Detection

*(This README goes in `saas-analytics-portfolio/03-billing-revenue-leakage/README.md`, alongside `billing_revenue_leakage.sql`.)*

### Business problem

Getting a customer to agree to pay is only half the job. The other half is actually collecting the money, and in subscription billing that second half fails more often than most people assume: failed card charges, invoices nobody follows up on, customers who pay part of what they owe and stop there. Every one of those is revenue the business earned and never received, and unlike churn, it often doesn't show up on anyone's dashboard until finance goes looking for it.

This project is that finance-ops view: how much of what's been billed has actually been collected, which invoices are sitting unpaid, which customers are the biggest collection risk, and how long people take to pay once they do. It's built to answer the question "where exactly is the money we're owed" rather than the broader "is the business healthy" question project 1 covers.

### Data source

Four tables: `subscriptions`, `subscription_plans`, `invoices`, and `payments`. Same synthetic SaaS dataset used across all three projects in this repo, fully documented in `data/README.md`. 6,000 invoices, 6,000 payment records, across 5,000 subscriptions and 5 pricing plans.

### Methodology

Validate, clean, build one view, run the KPIs against it, same process as the other two projects. The validation step here specifically checks for invoices with no matching payment record, negative billed amounts, and negative payments, since a finance-facing report is the one place where a data error can directly produce a wrong dollar figure that someone acts on.

I paid particular attention to how NULLs behave through this script, because that turned out to be where the real problems were hiding.

### Analysis & error check

This is the project where I found the most consequential bug of all three, and it's worth walking through carefully because it's a pattern that shows up constantly in financial SQL.

`v_billing_master` is built with LEFT JOINs from subscriptions through invoices to payments, so any invoice with zero payment history comes through with `AmountPaid` as NULL, not zero. That's correct and expected. The problem is what happens next: `billed_amount - AmountPaid`, when `AmountPaid` is NULL, evaluates to NULL, and `SUM()` ignores NULLs rather than treating them as zero.

That single behavior broke two KPIs. In KPI 1 (total billed vs. collected), any invoice with no payment at all contributed nothing to the `revenue_gap` calculation, meaning the worst-case invoices, the ones that never got paid a cent, were invisible to the one metric meant to surface exactly that. In KPI 8 (high risk customer identification), a customer whose every invoice went unpaid would have `SUM(billed_amount - AmountPaid)` come out as NULL for every group, and `HAVING NULL > 0` is never true, so that customer never appears on the high-risk list at all. The customers with the single worst payment behavior in the entire dataset, zero dollars collected against them, were the ones this report was silently leaving out. A collections report that excludes your worst accounts isn't just incomplete, it's actively pointing attention away from where it's needed most.

The fix is `COALESCE(AmountPaid, 0)` everywhere the calculation touches a payment amount that might not exist. I applied it consistently across KPI 1, 3, 5, 6, and 8.

Worth noting: KPI 9, the revenue leakage classification engine, already had this right in the original script. It explicitly checks `WHEN SUM(AmountPaid) IS NULL THEN 'No Payment'` before anything else. That's the correct pattern, and it's exactly why the inconsistency in KPI 1 and KPI 8 stood out once I found it: one query in the same file was handling this correctly and two others weren't, which is the kind of inconsistency that's easy to miss when a script is written over multiple sessions and never gets a full read-through against its own internal logic.

### Insight

24.5% of all invoices (1,471 of 6,000) are sitting unpaid. On the payment attempt side, 20.4% of payment attempts (1,224 of 6,000) came back as Failed rather than Completed. Those are two different failure points in the same pipeline, and they compound: an invoice can go unpaid because nobody ever attempted to collect it, or because collection was attempted and the card declined.

Using the average plan price across the five tiers (roughly $98/month) as a rough per-invoice estimate, 1,471 unpaid invoices represent somewhere in the neighborhood of $144,000 sitting uncollected. That number is an approximation, not an exact sum from the corrected KPI 1 query, but it's the right order of magnitude to make the point: this isn't a rounding error, it's a material chunk of revenue that was earned and never landed in the bank account, and before the fix described above, a meaningful slice of it wasn't even visible in the report meant to catch it.

### Recommendation

Run the corrected KPI 8 query as a weekly collections list, sorted by unpaid amount descending, and prioritize outreach to whoever's at the top rather than working invoices in the order they happened to be billed. Given that failed payments are running above 20%, I'd also push for automatic payment retry logic (most billing platforms support retrying a failed card charge two or three times over a week before flagging it as truly failed) since a meaningful chunk of that 20% is likely expired cards and temporary declines rather than customers actively refusing to pay.

Second, treat this project's KPI 8 output and project 1's Past Due subscription list as the same underlying signal viewed from two different tables, and make sure whoever owns collections is looking at both together rather than each team working from a different partial picture.

### Business impact

The direct fix here is visibility: before correcting the NULL handling, the customers with the worst payment history in the dataset, complete non-payment, were invisible to the collections risk report. Surfacing them is the difference between a collections process that chases whoever's easiest to find and one that chases the accounts actually worth the most. On the roughly $144,000 in estimated outstanding invoice value, even a modest improvement in collection rate from better-targeted follow-up (say, recovering an extra 15 to 20% of that through active outreach instead of letting it sit) is real cash, not a reporting exercise.

### What was done

Reviewed every KPI in the script for how it handles NULL payment values specifically, found that two of nine KPIs were silently dropping the worst-case customers and invoices due to NULL arithmetic, applied `COALESCE` consistently across every affected query, and confirmed the fix against the one KPI in the file that already had the pattern right.

### Tools used and how they helped

T-SQL (SQL Server), with `COALESCE()` doing the heavy lifting throughout, `DATEDIFF()` for measuring payment delay in days, and a single reusable view (`v_billing_master`) joining subscriptions through to payments. The `COALESCE` fix is a small change syntactically, one function wrapped around one column, but it's the difference between a leakage report that works and one that quietly exempts the accounts it most needs to catch.

### Results

A nine-KPI billing and collections layer covering billed-versus-collected revenue, unpaid invoices, partial payments, payment success rate, revenue by plan, customer payment behavior, payment delay, high-risk customer identification, and a full revenue leakage classification. One serious NULL-handling bug found and fixed across two KPIs, both now consistent with the one query in the file that already handled it correctly.
