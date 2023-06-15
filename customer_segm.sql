
-- This  query selects distinct customer IDs from a table  and calculates the recency of each customer's last transaction in number of days.

SELECT distinct(customer_id),round(MONTHS_BETWEEN((SELECT MAX(TO_DATE(InvoiceDate, 'MM/DD/YYYY HH24:MI:SS')) FROM tableRetail),MAX(TO_DATE(InvoiceDate, 'MM/DD/YYYY HH24:MI:SS'))over(partition by customer_id))*30) AS Recency
FROM tableRetail;
-----------------------------------------------------------------------
---Calculate the frequency
SELECT 
   distinct(customer_id),
  COUNT(distinct (INVOICEDATE))  over(partition by customer_id) as frequency
FROM  tableRetail
Order by    customer_id;
---------------------------------------------------------
--- Monetary Column:
SELECT distinct(Customer_ID), SUM(Price * Quantity)over(partition by customer_id) AS Monetary
FROM tableRetail
order by  Customer_ID;
-----------------------------------------
----Final Step if calculate the Recency,frequency,Monetary
WITH rfm_customers AS (
SELECT distinct(customer_id),round(MONTHS_BETWEEN((SELECT MAX(TO_DATE(InvoiceDate, 'MM/DD/YYYY HH24:MI:SS')) FROM tableRetail),MAX(TO_DATE(InvoiceDate, 'MM/DD/YYYY HH24:MI:SS'))over(partition by customer_id))*30) AS Recency,
COUNT(distinct (INVOICEDATE))  over(partition by customer_id) as frequency,
 SUM(Price * Quantity)over(partition by customer_id) AS Monetary
FROM tableRetail

),
--Calculate the R_Score and fm_score
rfm_scores AS (
  SELECT customer_id, Recency, frequency, Monetary,
         NTILE(5) OVER(ORDER BY Recency DESC) AS R_Score,
         (NTILE(5) OVER(ORDER BY AVG(frequency) DESC) + NTILE(5) OVER(ORDER BY AVG(Monetary) DESC))/2 AS FM_Score
          
  FROM rfm_customers
  group by  Recency, frequency, Monetary, customer_id
)
select  customer_id, Recency, frequency, Monetary,R_Score,FM_Score,
 
    CASE
     WHEN R_Score >=4 AND FM_Score >=4 THEN 'Champions'
    WHEN R_Score >=3 AND FM_Score >=2 THEN 'Potential Loyalists'
    WHEN R_Score >=3 AND FM_Score >=3 THEN 'Loyal Customers'
    WHEN R_Score =5 AND FM_Score >1 THEN 'Recent Customers'
    WHEN R_Score >=3 AND FM_Score >=1 THEN 'Promising'
    WHEN R_Score >=2 AND FM_Score >=2 THEN 'Customers Needing Attention'
    WHEN R_Score >=1 AND FM_Score >=3 THEN 'At Risk'
    WHEN R_Score >=1 AND FM_Score >=4 THEN 'Cant Lose Them'
    WHEN R_Score =1 AND FM_Score =2 THEN 'Hibernating'
    WHEN R_Score =1 AND FM_Score =1 THEN 'Lost'
    
    END AS Cust_segment
   
FROM rfm_scores
order by customer_id ;
------------------------------------------------------




