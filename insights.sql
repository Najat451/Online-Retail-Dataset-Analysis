-- Who are the top five customers with the highest number of purchases made?
    SELECT rank() OVER (ORDER BY Total_Invoices DESC) AS Rank, Customer_ID, Total_Invoices
    FROM (
       SELECT DISTINCT Customer_ID, COUNT(Invoice) OVER (PARTITION BY Customer_ID) AS Total_Invoices
        FROM tableRetail 
    ) 
    ORDER BY Total_Invoices DESC;
 --------------------------------------------
 --2-What are the top five STOCK codes sold in terms of quantity?
     SELECT STOCKCODE, sum(QUANTITY) AS Total_QUANTITY, RANK() OVER (ORDER BY sum(QUANTITY) desc ) AS Rank
    FROM tableRetail
    GROUP BY STOCKCODE
    ORDER BY Rank;
    ---------------------------------------
 --  3-How many stocks were purchased only once?
     SELECT  COUNT(*) AS Num_Stocks
    FROM (
        SELECT StockCode, SUM(Quantity) OVER (PARTITION BY StockCode) AS Total_Quantity
        FROM tableRetail
       
    ) 
    WHERE Total_Quantity = 1;
 ------------------------------------------------------
--4-Sample of these Stocks
    SELECT StockCode, COUNT(*) AS Num_Stocks
    FROM (
        SELECT StockCode, SUM(Quantity) OVER (PARTITION BY StockCode) AS Total_Quantity
        FROM tableRetail
    ) 
    WHERE Total_Quantity = 1
  GROUP BY StockCode;
  -----------------------------------------
  --5- What is the top 5 highest-priced invoices in the "tableRetail" table?
  SELECT StockCode, COUNT(*) AS Num_Stocks
FROM (
    SELECT StockCode, SUM(Quantity) OVER (PARTITION BY StockCode) AS Total_Quantity
    FROM tableRetail
) 
WHERE Total_Quantity = 1
GROUP BY StockCode;
----------------------------------------
--6-Which invoicedates have the highest revenue?
SELECT distinct(INVOICEDATE),sum( Price*QUANTITY) OVER (partition by INVOICEDATE) As Total_Revenue
FROM tableRetail
order by Total_Revenue desc;





