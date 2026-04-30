# 📊 RFM Analysis
RFM Analysis is an end-to-end data analytics project that segments customers based on 
their purchasing behaviour using RFM scoring. Built entirely in BigQuery (GCP) with 
results visualized in an interactive Power BI dashboard.

## 🧠 What is RFM?
RFM is a behaviour-based customer segmentation framework built on 3 metrics:
- 📅 **Recency** — How recently did a customer make their last purchase (days since last order)
- 🔁 **Frequency** — Number of orders placed
- 💰 **Monetary** — Sum of total purchases made by the customer

This analysis helps identify:
- 🏆 Top customers (Champions, Loyal VIPs)
- ⚠️ At Risk customers
- 👀 Customers that Require Attention

## ⚙️ How RFM Scoring Works
1. Upload monthly sales data to BigQuery.
2. Calculate RFM values per customer.
3. Assign decile ranks using NTILE(10) — scores range from 1 (worst) to 10 (best).
4. Sum R + F + M into a single aggregate score (min = 3, max = 30).
5. Map scores into customer segments.
6. Visualize in Power BI.

## 🛠️ Tech Stack
- Google BigQuery (GCP)
- SQL — CTEs, Window Functions (ROW_NUMBER, NTILE), Views
- Power BI
