# Revenue Growth, Retention & Subscription Intelligence Framework

## Project Overview

Recurring revenue is the foundation of every SaaS business, but sustainable growth requires more than simply acquiring new customers. Companies must continuously monitor revenue performance, customer retention, payment collection, and subscription health to understand whether the business is growing efficiently or quietly accumulating risk.

A company may report growing Monthly Recurring Revenue (MRR) while simultaneously experiencing rising churn rates, deteriorating payment performance, or increasing numbers of past-due subscriptions. Without continuous monitoring, these risks often remain hidden behind headline growth metrics.

This project builds an enterprise-level Revenue Intelligence framework designed to provide executive visibility into:

> - Revenue growth and collection performance
> - Customer churn and retention trends
> - Subscription portfolio health
> - Customer Lifetime Value (CLV)
> - Revenue leakage through unpaid invoices
> - Customer segmentation and subscription performance
> - Early warning indicators of declining customer health

Rather than focusing solely on how much revenue the business generates, the objective of this project is to understand the quality, sustainability, and risks associated with that revenue.

---

## Business Problem

Leadership teams regularly ask questions such as:

> - Is Monthly Recurring Revenue growing sustainably?
> - How much revenue is being lost through customer churn?
> - Which subscription plans contribute most to business performance?
> - How much revenue remains uncollected?
> - Which customers are most valuable to the business?
> - Are payment issues becoming an early indicator of customer churn?
> - Which customer segments require proactive retention efforts?

These questions are frequently answered across multiple systems including:

- Billing Platforms
- CRM Systems
- Payment Systems
- Customer Databases
- Financial Reports

This project centralizes those insights into a single reporting framework capable of monitoring both revenue performance and subscription health.

---

## Dataset

This project uses a synthetic SaaS subscription dataset consisting of five related tables.

| Table | Description |
|-------|------------|
| customers | Customer information |
| subscriptions | Subscription details and statuses |
| subscription_plans | Pricing plan information |
| invoices | Customer billing records |
| payments | Payment collection information |

### Portfolio Composition

- 5,000 Customers
- 5,000 Subscription Records
- 6,000 Invoices
- 6,000 Payment Records
- Five Pricing Plans
- Subscription Prices ranging from \$29.99 to \$199.99

> **Note:** Product usage data is intentionally excluded from this project and is analyzed separately within the Customer Behavior & Product Intelligence Framework.

---

## Project Architecture

```


                   CUSTOMERS
                        |
                        |
                  SUBSCRIPTIONS
                        |
                        |
                SUBSCRIPTION PLANS
                        |
                        |
                        ↓
                    INVOICES
                        |
                        |
                     PAYMENTS
                        |
                        |
                        ↓
                 Data Validation Layer
                        |
                        |
                        ↓
                  v_saas_master
                  (Master View)
                        |
        ----------------------------------------------------
        |                |                 |               |
        ↓                ↓                 ↓               ↓
    Revenue          Churn &            Payment          Customer
   Monitoring       Retention          Performance      Intelligence
        |                |                 |               |
        ----------------------------------------------------
                        |
                        ↓
                 Subscription Health
                      Monitoring
                        |
                        ↓
               Revenue Leakage Detection
                        |
                        ↓
                 Executive Business Insights



```

---

## Technologies Used

- SQL Server (T-SQL)
- SQL Views
- Common Table Expressions (CTEs)
- Aggregate Functions
- CASE Statements
- Customer Analytics
- Revenue Analytics
- Financial Analytics
- Subscription Intelligence
- Business Intelligence Reporting

---

## Methodology

The framework follows a layered revenue monitoring approach.

### Data Validation

The dataset was validated for:

- Missing Customer IDs
- Missing Invoice Amounts
- Invalid Subscription Dates
- Negative Payment Values
- Inconsistent Subscription Records

### Reporting Framework

A reusable reporting view (`v_saas_master`) was developed to serve as the single source of truth for all downstream analyses.

This approach ensures:

- Consistent KPI calculations
- Improved maintainability
- Reduced query duplication
- Reliable business reporting

### Revenue Intelligence Analysis

The project monitors:

- Monthly Revenue Performance
- Customer Retention
- Subscription Health
- Customer Lifetime Value
- Revenue Leakage
- Collection Performance
- Customer Segmentation
- Subscription Portfolio Performance

---

## KPIs Developed

This framework includes:

- Monthly Revenue Analysis
- Active Customer Monitoring
- Customer Churn Analysis
- Revenue by Subscription Plan
- Customer Lifetime Value Analysis
- Churned Revenue Monitoring
- Customer Growth Analysis
- Unpaid Invoice Analysis
- Customer Value Segmentation

---

## Data Quality Challenges Solved

### Churn Rate Logic

The original churn analysis depended upon subscription statuses being standardized before execution.

#### Solution

Status comparisons were standardized using:

```sql
LOWER(status)
```

This guarantees that churn metrics remain accurate regardless of case formatting inconsistencies.

---

### Customer Segmentation Logic

Customer segmentation logic relied upon SQL's implicit NULL-handling behaviour.

#### Solution

NULL handling was made explicit within the CASE statement to improve:

- Readability
- Maintainability
- Reporting accuracy

---

### Revenue Classification Improvements

The original implementation labelled collected payments as:

> Monthly Recurring Revenue (MRR)

However, the metric only represented:

> Revenue that had actually been collected.

#### Solution

The metric was renamed:

> `Collected Revenue`

This distinction provides clearer financial reporting by separating:

- Revenue Earned
- Revenue Billed
- Revenue Collected

---

## Key Insights

Portfolio-level analysis revealed several significant trends.

### Subscription Health Monitoring

The analysis identified:

> - 35.5% Active Subscriptions
> - 35.4% Past Due Subscriptions
> - 29.0% Cancelled Subscriptions

The most significant finding was not the churn rate itself but the size of the Past Due portfolio.

For every active subscription within the business, there is nearly one subscription currently behind on payment.

Past Due subscriptions represent an important early warning indicator because they frequently precede customer churn and revenue loss.

### Revenue Leakage

The analysis also revealed:

> - 1,471 unpaid invoices
> - Approximately 24.5% of all invoices remain uncollected

This highlights a substantial opportunity for improving both cash flow performance and customer retention strategies.

---

## Business Recommendations

- Implement automated dunning workflows for Past Due subscriptions.
- Establish proactive customer retention programs before cancellations occur.
- Monitor subscription health alongside traditional revenue metrics.
- Separate billed revenue from collected revenue during executive reporting.
- Continuously monitor unpaid invoice trends and collection performance.

---

## Business Impact

Past Due subscriptions should not be viewed as administrative issues—they are leading indicators of future revenue loss.

If only half of the Past Due subscriptions are successfully recovered through proactive intervention, the business could retain approximately:

> **880 subscriptions**

At an average subscription value of approximately:

> **\$98 per month**

This represents roughly:

> **\$86,000 in retained Monthly Recurring Revenue**

before accounting for improvements in invoice collections and customer lifetime value.

More importantly, this framework shifts leadership conversations from:

> **"How much revenue did we make?"**

to

> **"How healthy, sustainable, and recoverable is our revenue portfolio?"**

---

## Skills Demonstrated

This project demonstrates proficiency in:

- Advanced SQL
- Revenue Analytics
- SaaS Analytics
- Financial Analytics
- Customer Retention Analysis
- Subscription Intelligence
- Data Modeling
- Data Validation
- KPI Development
- Business Intelligence Reporting
- Decision Support Systems

---

## Project Deliverables

- Revenue Intelligence Framework
- Subscription Health Monitoring
- Customer Retention Analytics
- Revenue Leakage Detection
- Customer Lifetime Value Analysis
- Customer Segmentation Analysis
- Executive-Level Revenue Reporting
- Business Recommendations

---

## Results

The final solution delivers an enterprise-level Revenue Intelligence framework capable of monitoring revenue performance, customer retention, and subscription portfolio health simultaneously.

By combining revenue analytics, subscription monitoring, and customer intelligence, the framework provides:

- Improved visibility into revenue performance.
- Earlier identification of churn risks.
- Better collection and retention strategies.
- Reliable executive-level business reporting.
- A scalable foundation for predictive churn and revenue analytics.

---

> **Disclaimer:** This project uses a synthetic SaaS dataset designed for analytical and portfolio purposes. All business scenarios are representative of real-world SaaS analytics challenges and do not contain real customer information.
