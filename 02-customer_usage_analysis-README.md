## Customer Behavior & Product Usage Intelligence

*(This README goes in `saas-analytics-portfolio/02-customer-usage-analysis/README.md`, alongside `customer_usage_analysis.sql`.)*

### Business problem

Billing status tells you whether someone is paying. It doesn't tell you whether they're actually getting value out of the product, and those two things drift apart more often than people expect. A customer can be current on their invoice and completely disengaged, quietly counting down to the moment they cancel. By the time that shows up in the churn numbers from project 1, it's already too late to do anything about it.

This project builds a usage-based early warning system instead: who's using the product daily, who's gone quiet, which features people actually adopt, and a churn risk score based on behavior rather than payment status. This is the view a product or customer success team would use to intervene before a customer becomes a churn statistic.

### Data source

Three tables: `customers`, `subscriptions`, and `usage_logs`. Same synthetic SaaS dataset as the other two projects in this repo, documented fully in `data/README.md`. The usage side of things is 7,000 logged interactions across 5,000 customers, tagged by feature (Automation Run, API Call, Integration Sync, Workflow Edit, Error Event) with a count and a date for each.

### Methodology

Same shape as the other two projects: validate, clean, build one reporting view, then run the KPIs against it. The difference here is that usage data tends to be messier than billing data in real companies, duplicate event logs, missing timestamps from a flaky tracking pixel, that kind of thing, so the cleaning steps in this script matter more than they do in the billing-focused ones.

I built a single view, `v_usage_master`, that resolves each customer down to one current subscription before joining to their usage history. That resolution step turned out to matter more than I expected, more on that below.

### Analysis & error check

Three real issues came up in review, and they're all the kind that don't throw an error, they just quietly give you a wrong number that looks plausible.

The cleaning step (Step 2) only deleted rows with a missing customer ID, even though the validation step just above it (Step 1) also flags rows with a missing usage date. Anything that had a valid customer ID but no date would sail through cleaning untouched and then land in an undefined bucket once the DAU and MAU queries tried to group by date, quietly understating both metrics. Fixed by deleting on either condition, matching what the validation step actually checks for.

The deduplication step (Step 3) removes duplicate usage records by partitioning on customer ID and usage date. That sounds right until you realize a customer can legitimately use two different features on the same day, an API call in the morning and a workflow edit in the afternoon, and the original query would treat the second one as a duplicate of the first and delete it. That's not deduplication, that's data loss dressed up as cleaning. I added `FeatureUsed` to the partition so a row only gets removed if it's a true duplicate: same customer, same feature, same day.

The bigger one: the view (and two of the KPIs, the usage-vs-churn comparison and the churn risk model) joined customers straight to subscriptions on customer ID. In this dataset, a customer can have more than one subscription record over time, a cancellation followed by a resubscribe shows up as two separate rows. Joining straight on customer ID means that customer's usage events get matched against both subscription rows, doubling up in the GROUP BY and skewing the average usage and risk score for anyone who has re-subscribed. I fixed this by resolving each customer down to a single current subscription (the most recently started one, via `ROW_NUMBER()`) before joining to usage. This is the kind of bug that's easy to miss in testing with small sample data, because you need someone with an actual repeat subscription history to notice it's happening.

### Insight

Feature adoption is close to perfectly even. Across the five tracked feature categories, usage ranges from 1,385 to 1,434 events, meaning every feature sits within about a percentage point and a half of a fifth of total usage. Nothing dominates and nothing is neglected. That's actually a useful finding on its own: if this were a real product, it would mean the team hasn't over-invested in one flashy feature while others go untouched, or it means the usage logging is coarse enough that it can't tell a genuinely sticky feature from a rarely-used one. Either way, it's worth knowing before making a roadmap decision based on "our most popular feature."

The one category worth calling out specifically is Error Event, at 1,385 occurrences, essentially tied for the lowest count but still representing nearly a fifth of everything logged. If this system is treating error events as a first-class usage category alongside productive actions like API calls and workflow edits, that's worth a second look. A high rate of logged errors sitting inside your engagement numbers can quietly make usage look healthier than it is, since a customer hitting the product and immediately hitting an error is being counted the same way as a customer who successfully finished a workflow.

### Recommendation

Split error events out from the other four categories in reporting, and track an error rate (error events divided by total events) per customer rather than folding it into a single undifferentiated usage count. A customer with a high total usage number driven mostly by error events should be flagged very differently from a customer with the same usage number driven by successful automation runs.

Second, use the churn risk model from this script (KPI 10) as a trigger for customer success outreach, specifically for anyone landing in "High Churn Risk" who is still on an Active subscription. That's the exact combination this project was built to catch: paying, but not engaged, and not yet visible in the billing-side churn numbers from project 1.

### Business impact

Catching disengagement before it shows up as a cancellation is the whole value case here. Project 1 measured a 29% cancellation rate after the fact. This project is designed to shrink that number by giving customer success a list of at-risk accounts while they're still paying customers, not after they've already left. Even a modest lift in retention among the "High Churn Risk but still Active" segment compounds directly into the MRR numbers from project 1, since retaining an existing customer is consistently cheaper than acquiring a replacement one.

### What was done

Reviewed the script for logic errors rather than just syntax, found and fixed a cleaning gap, a deduplication bug that was silently deleting legitimate data, and a join fan-out issue affecting two of the ten KPIs, then rebuilt the reporting view so both affected KPIs read from a fan-out-safe source.

### Tools used and how they helped

T-SQL (SQL Server), using `ROW_NUMBER()` twice, once inside the corrected deduplication CTE and once to resolve each customer down to a single current subscription, `FORMAT()` for monthly grouping, and a `CASE` statement for the churn risk classification. The `ROW_NUMBER()` pattern is doing real work in both places: it's the difference between "delete anything that looks like a duplicate" and "delete only the rows that are actually duplicates," and between "join every subscription a customer has ever had" and "join the one subscription that currently applies."

### Results

A ten-KPI usage analytics layer covering engagement level, daily and monthly active users, usage-versus-churn comparison, feature adoption, power users, inactive customers, usage segmentation, retention drivers, and a churn risk score, all fan-out-safe. Three real bugs found and fixed: a cleaning gap, a deduplication bug that was destroying legitimate records, and a join issue that was silently double-counting usage for any customer with more than one subscription record.
