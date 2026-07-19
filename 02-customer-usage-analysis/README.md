# Customer Health Intelligence & Churn Prevention Framework

## Project Overview

Customer churn rarely happens overnight. Long before customers cancel their subscriptions, they typically exhibit behavioral warning signs such as declining engagement, reduced feature adoption, prolonged inactivity, or deteriorating product usage patterns.

Unfortunately, traditional SaaS reporting often identifies churn after it has already occurred.

A customer may:

> - Pay their invoices on time.
> - Maintain an active subscription.
> - Appear healthy within billing reports.
> - Quietly stop receiving value from the product.

By the time declining engagement appears in monthly churn metrics, the opportunity for intervention has frequently passed.

This project builds a Customer Health Intelligence framework designed to identify early warning indicators of customer disengagement before customers become churn statistics.

The framework enables Product, Customer Success, and Leadership teams to answer critical business questions such as:

> - Which customers are most likely to churn?
> - Which accounts require immediate Customer Success intervention?
> - Which features drive long-term engagement?
> - How healthy is our customer base?
> - Which customers are active but quietly disengaging?
> - What behavioral patterns distinguish retained customers from churned customers?

Rather than measuring churn after it occurs, the objective of this project is to identify customers at risk while they are still paying customers.

---

## Business Problem

Customer retention is one of the most important growth drivers within subscription businesses.

Acquiring new customers is frequently more expensive than retaining existing ones, making proactive churn prevention essential for sustainable growth.

Traditional churn reporting provides answers to questions such as:

- How many customers cancelled?
- How much revenue was lost?
- What was our monthly churn rate?

These metrics are valuable but largely retrospective.

They do not explain:

- Why customers are disengaging.
- Which customers are likely to leave next.
- Which behaviors signal declining customer health.
- Which product experiences contribute most to retention.

This project addresses these limitations by combining customer, subscription, and product usage data to provide an early warning system for customer disengagement and churn risk.

---

## Dataset

This project uses a synthetic SaaS dataset consisting of three related tables.

| Table | Description |
|-------|------------|
| customers | Customer information |
| subscriptions | Subscription information |
| usage_logs | Product usage events |

### Portfolio Composition

- 5,000 Customers
- 5,000 Subscription Records
- 7,000+ Usage Events
- Five Product Features
- Subscription Lifecycle Monitoring
- Customer Engagement Tracking

### Product Features Tracked

- Automation Runs
- API Calls
- Integration Syncs
- Workflow Edits
- Error Events

> **Note:** Revenue and billing-related analyses are intentionally excluded from this project and are addressed separately within the Revenue Intelligence Framework.

---

## Project Architecture

```


                    CUSTOMERS
                         |
                         |
                   SUBSCRIPTIONS
                         |
                         |
                     USAGE LOGS
                         |
                         |
                         ↓
                 Data Validation Layer
                         |
                         |
                         ↓
                  Subscription Resolution
                   (Current Subscription)
                         |
                         |
                         ↓
                    v_usage_master
                     (Master View)
                         |
        ----------------------------------------------------
        |                 |                 |               |
        ↓                 ↓                 ↓               ↓
   Engagement         Product Usage       Customer        Churn Risk
    Analytics          Intelligence       Health          Monitoring
        |                 |                 |               |
        -----------------------------------------------------
                         |
                         ↓
                  Customer Segmentation
                         |
                         ↓
                   Early Warning Alerts
                         |
                         ↓
                 Customer Success Actions



```

---

## Technologies Used

- SQL Server (T-SQL)
- SQL Views
- Window Functions
- ROW_NUMBER()
- Common Table Expressions (CTEs)
- Aggregate Functions
- Customer Analytics
- Product Analytics
- Churn Analytics
- Business Intelligence Reporting

---

## Methodology

The framework follows a layered customer health monitoring approach.

### Data Validation

The dataset was validated for:

- Missing Customer IDs
- Missing Usage Dates
- Duplicate Usage Records
- Subscription Consistency
- Customer-Level Relationship Integrity

### Subscription Resolution

Customers may possess multiple subscription records over time.

Before any usage analysis was performed, customer subscriptions were resolved to their current subscription using:

```sql
ROW_NUMBER()
```

This guarantees:

- Accurate customer-level reporting.
- Consistent churn calculations.
- Fan-out-safe usage analytics.

### Customer Health Monitoring

The framework monitors:

- Daily Active Users (DAU)
- Monthly Active Users (MAU)
- Customer Engagement Levels
- Feature Adoption Rates
- Power User Identification
- Customer Inactivity
- Churn Risk Scores
- Customer Segmentation
- Product Usage Trends

---

## KPIs Developed

This project includes:

- Daily Active User Analysis
- Monthly Active User Analysis
- Customer Engagement Monitoring
- Product Feature Adoption Analysis
- Customer Usage Segmentation
- Power User Identification
- Customer Inactivity Monitoring
- Retention Driver Analysis
- Usage versus Churn Analysis
- Customer Churn Risk Analysis

---

## Data Quality Challenges Solved

### Usage Data Cleaning

The original implementation failed to remove usage records containing missing usage dates.

#### Solution

The cleaning procedures were expanded to validate both:

- Missing Customer IDs
- Missing Usage Dates

This guarantees more reliable engagement metrics across all KPIs.

---

### Deduplication Improvements

Duplicate usage events were originally identified using:

```sql
Customer ID + Usage Date
```

However, customers may legitimately use multiple features on the same day.

#### Solution

Deduplication logic now includes:

```sql
Customer ID
+ Usage Date
+ Feature Used
```

This preserves legitimate product interactions while removing only true duplicates.

---

### Customer-Level Join Integrity

Customers may subscribe, cancel, and subsequently resubscribe over time.

Joining usage records directly to subscription histories introduced fan-out issues capable of inflating:

- Usage Metrics
- Engagement Scores
- Churn Risk Calculations

#### Solution

Customer subscriptions are first resolved using:

```sql
ROW_NUMBER()
```

before being joined to usage histories.

This guarantees accurate customer-level reporting throughout the framework.

---

## Key Insights

Product feature adoption remains relatively balanced across all tracked features.

However, one important finding emerged during the analysis:

> Error Events account for nearly one-fifth of all recorded product interactions.

Although error events are legitimate system events, they do not necessarily represent successful customer engagement.

Customers experiencing:

> - High usage volumes
> - High error rates
> - Declining productive interactions

may represent significantly different retention risks than customers demonstrating healthy engagement patterns.

This highlights the importance of measuring:

> **Customer Health**

rather than simply measuring:

> **Customer Activity**

---

## Business Recommendations

- Implement Customer Success outreach workflows for High Churn Risk customers.
- Monitor declining engagement trends continuously.
- Track productive product interactions separately from error events.
- Establish customer health scoring frameworks using behavioral indicators.
- Prioritize proactive retention initiatives over reactive churn reporting.

---

## Business Impact

The greatest value of this framework lies in identifying customers at risk before they cancel their subscriptions.

Rather than asking:

> **"Which customers left?"**

the framework enables leadership teams to ask:

> **"Which customers are likely to leave next?"**

Even modest improvements in customer retention can compound directly into:

- Higher Monthly Recurring Revenue.
- Improved Customer Lifetime Value.
- Reduced acquisition costs.
- Greater subscription stability.
- Improved Customer Success outcomes.

More importantly, the framework transforms customer analytics from historical reporting into proactive churn prevention.

---

## Skills Demonstrated

This project demonstrates proficiency in:

- Advanced SQL
- Customer Analytics
- Product Analytics
- Churn Analytics
- Customer Health Monitoring
- Window Functions
- Data Modeling
- Data Validation
- Business Intelligence Reporting
- Decision Support Systems

---

## Project Deliverables

- Customer Health Intelligence Framework
- Product Engagement Monitoring
- Churn Risk Detection
- Customer Segmentation Analysis
- Product Adoption Intelligence
- Early Warning Indicators
- Customer Success Recommendations
- Executive-Level Customer Reporting

---

## Results

The final solution delivers a Customer Health Intelligence framework capable of monitoring customer engagement, identifying churn risks, and supporting proactive retention initiatives.

By combining behavioral analytics, product intelligence, and customer health monitoring, the framework provides:

- Earlier identification of churn risks.
- Improved Customer Success interventions.
- Better visibility into customer engagement.
- More reliable product usage reporting.
- A scalable foundation for predictive customer retention analytics.

---

> **Disclaimer:** This project uses a synthetic SaaS dataset designed for analytical and portfolio purposes. All customer and product interactions are representative business scenarios and do not contain real customer information.
