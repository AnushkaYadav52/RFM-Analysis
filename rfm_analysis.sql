-- Step 1: Append all monthly sales tables togther. 
CREATE OR REPLACE TABLE `rfm-analysis-494801.sales.sales_2025` AS
SELECT * FROM `rfm-analysis-494801.sales.sales202501`
UNION ALL SELECT * FROM `rfm-analysis-494801.sales.sales202502`
UNION ALL SELECT * FROM `rfm-analysis-494801.sales.sales202503`
UNION ALL SELECT * FROM `rfm-analysis-494801.sales.sales202504`
UNION ALL SELECT * FROM `rfm-analysis-494801.sales.sales202505`
UNION ALL SELECT * FROM `rfm-analysis-494801.sales.sales202506`
UNION ALL SELECT * FROM `rfm-analysis-494801.sales.sales202507`
UNION ALL SELECT * FROM `rfm-analysis-494801.sales.sales202508`
UNION ALL SELECT * FROM `rfm-analysis-494801.sales.sales202509`
UNION ALL SELECT * FROM `rfm-analysis-494801.sales.sales202510`
UNION ALL SELECT * FROM `rfm-analysis-494801.sales.sales202511`
UNION ALL SELECT OrderID, CustomerID, OrderDate, ProductType, OrderValue FROM `rfm-analysis-494801.sales.sales202512`;

-- Step 2: Calculate Recency, Frequency, Monetary and RFM Ranks. 
-- Combine views with CTEs.
CREATE OR REPLACE VIEW `rfm-analysis-494801.sales.metrics` 
AS
WITH current_date AS(   
  SELECT DATE('2026-03-06') AS analysis_date -- Today's Date
), 
rfm AS(
  SELECT CustomerID, 
  MAX(OrderDate) AS last_order_date, 
  date_diff((SELECT analysis_date FROM current_date), MAX(OrderDate), DAY) AS recency,
  COUNT(*) as frequency, 
  SUM(OrderValue) as monetary
  FROM `rfm-analysis-494801.sales.sales_2025`
  GROUP BY CustomerID
)
SELECT 
  rfm.*, 
  ROW_NUMBER() OVER(ORDER BY rfm.recency ASC) AS r_rank, 
  ROW_NUMBER() OVER(ORDER BY rfm.frequency DESC) AS f_rank,
  ROW_NUMBER() OVER(ORDER BY rfm.monetary DESC) AS m_rank,
FROM rfm;


-- Step 3: Assign deciles (10 = Best, 1 = Worst)
-- Use NTILE(10)
CREATE OR REPLACE VIEW `rfm-analysis-494801.sales.rfm_scores` 
AS
SELECT 
  *, 
  NTILE(10) OVER(ORDER BY r_rank DESC) AS r_score, 
  NTILE(10) OVER(ORDER BY f_rank DESC) AS f_score,
  NTILE(10) OVER(ORDER BY m_rank DESC) AS m_score
FROM `rfm-analysis-494801.sales.metrics`;


-- Step 4: Find total RFM score. 
CREATE OR REPLACE VIEW `rfm-analysis-494801.sales.rfm_total_scores`  
AS 
SELECT 
  CustomerID, 
  recency, 
  frequency, 
  monetary, 
  r_score, 
  f_score, 
  m_score, 
  (r_score + f_score + m_score) AS rfm_total_score 
FROM `rfm-analysis-494801.sales.rfm_scores` 
ORDER BY rfm_total_score DESC;

-- Step 5: BI ready RFM segments table.
CREATE OR REPLACE TABLE `rfm-analysis-494801.sales.rfm_segements_final`  
AS
SELECT 
  CustomerID, 
  recency, 
  frequency, 
  monetary, 
  r_score, 
  f_score, 
  m_score, 
  rfm_total_score, 
  CASE 
    WHEN (rfm_total_score >= 28) THEN 'Champions' -- (28-30)
    WHEN (rfm_total_score >= 24) THEN 'Loyal VIPs'
    WHEN (rfm_total_score >= 20) THEN 'Potential Loyalists'
    WHEN (rfm_total_score >= 16) THEN 'Promising'
    WHEN (rfm_total_score >= 12) THEN 'Engaged'
    WHEN (rfm_total_score >= 8) THEN 'Require Attention'
    WHEN (rfm_total_score >= 4) THEN 'At Risk'
    ELSE 'Lost/Inactive'
  END AS rfm_segment
FROM `rfm-analysis-494801.sales.rfm_total_scores`  
ORDER BY rfm_total_score DESC;
