--SQL Advance Case Study

CREATE DATABASE DB_RETAIL_DATA
USE DB_RETAIL_DATA
SELECT* FROM CUSTOMER
SELECT* FROM PROD_CAT_INFO
SELECT* FROM TRANSACTIONS


--DATA UNDERSTANDING AND PREPARATION 

--Q1--BEGIN 

--1.What is the total number of rows in each of the 3 tables in the database?

SELECT 'CUSTOMER' AS TABLE_NAME, COUNT (*)  AS NO_OF_RECORDS  FROM CUSTOMER
UNION
SELECT 'PROD_CAT_INFO' AS TABLE_NAME , COUNT (*)  AS NO_OF_RECORDS FROM PROD_CAT_INFO 
UNION
SELECT 'TRANSACTIONS' , COUNT (*)   AS NO_OF_RECORDS FROM TRANSACTIONS

--Q1--END

--Q2--BEGIN

--2.What is the total number of transactions that have a return?

SELECT COUNT(transaction_id) AS NO_OF_TRANSACTION
 FROM TRANSACTIONS
WHERE total_amt< 0 AND Qty < 0


--Q2--END

--Q3--BEGIN     

--3. As you would have noticed, the dates provided across the datasets are not in a correct format. As first steps, pls convert the date variables into valid date formats before proceeding ahead. 
SELECT DOB AS DATE_OF_BIRTH
FROM Customer	
SELECT tran_date
FROM Transactions

--Q3--END

--Q4--BEGIN

--4. What is the time range of the transaction data available for analysis? Show the output in number of days, months and years simultaneously in different columns. 


SELECT DATEDIFF((DAY), MIN(TRAN_DATE),MAX(TRAN_DATE)) AS N0_OF_DAY,DATEDIFF((MONTH), MIN(TRAN_DATE),MAX(TRAN_DATE)) AS N0_OF_MONTH,
DATEDIFF((YEAR), MIN(TRAN_DATE),MAX(TRAN_DATE)) AS N0_OF_YEAR
FROM Transactions


--Q4--END

--Q5--BEGIN
--5. Which product category does the sub-category “DIY” belong to? 

SELECT prod_cat,prod_subcat
FROM prod_cat_info
WHERE prod_subcat = 'DIY'


--Q5--END
----------------------------------------------------------------
--DATA ANALYSIS 

--Q1--BEGIN

--1. Which channel is most frequently used for transactions?

SELECT  TOP 1 Store_type, COUNT(Store_type) COUNT
FROM Transactions
GROUP BY Store_type
ORDER BY COUNT(Store_type) DESC


--Q1--END
	
--Q2--BEGIN  

--2. What is the count of Male and Female customers in the database? 
SELECT Gender, COUNT(customer_Id) AS COUNT 
FROM Customer
WHERE Gender IN ('F','M')
GROUP BY Gender


--Q2--END	

--Q3--BEGIN

--3. From which city do we have the maximum number of customers and how many?
SELECT  TOP 1 CITY_CODE, COUNT(city_code) AS COUNT
FROM Customer
GROUP BY city_code
ORDER BY  COUNT(city_code)  DESC

--Q3--END

--Q4--BEGIN

--4. How many sub-categories are there under the Books category?

SELECT prod_cat,count(prod_subcat) as NO_OF_SUB_CATEGORY
FROM prod_cat_info
WHERE prod_cat = 'Books'
GROUP BY prod_cat

	
--Q4--END

--Q5--BEGIN

--5. What is the maximum quantity of products ever ordered? 

SELECT prod_cat,prod_subcat,MAX(Qty) QUANTITY
FROM Transactions T1 
LEFT JOIN  prod_cat_info T2
ON T1.prod_cat_code = T2.prod_cat_code
GROUP BY prod_cat,prod_subcat


--Q5--END


--Q6--BEGIN

--6. What is the net total revenue generated in categories Electronics and Books?

SELECT prod_cat,SUM(total_amt) AS TOTAL_REVENUE
FROM Transactions T1 
LEFT JOIN  prod_cat_info T2
ON T1.prod_subcat_code = T2.prod_sub_cat_code
WHERE prod_cat IN ('Electronics' , 'BookS')
GROUP BY prod_cat


--Q6--END


--Q7--BEGIN

--7. How many customers have >10 transactions with us, excluding returns? 

SELECT cust_id, COUNT( transaction_id) NO_OF_TRANSACTIONS
FROM Transactions
WHERE QTY > 0
GROUP BY cust_id
HAVING  COUNT( transaction_id) > 10 


--Q7--END


--Q8--BEGIN

--8. What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”? 
SELECT SUM(total_amt) AS TOTAL_REVENUE
FROM Transactions T1 
LEFT JOIN  prod_cat_info T2
ON T1.prod_subcat_code = T2.prod_sub_cat_code
WHERE Store_type = 'Flagship stores'AND prod_cat IN ('Electronics', 'Clothing') 

--Q8--END


--Q9--BEGIN

--9. What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat. 


SELECT T3.prod_subcat, T2.Gender, SUM(T1.total_amt) AS total_revenue
FROM Transactions T1 LEFT JOIN Customer T2
ON T1.cust_id = T2.customer_Id
LEFT JOIN prod_cat_info T3
ON T1.prod_subcat_code = T3.prod_sub_cat_code
WHERE prod_cat = 'Electronics' AND T2.Gender = 'M'
GROUP BY T3.prod_subcat, T2.Gender

--Q9--END


--Q10--BEGIN

--10.What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales? 

SELECT t1.prod_cat,t1.prod_subcat,
SUM(qty)/(SELECT SUM(qty)*100 FROM Transactions WHERE Qty<0) AS '%_of_return',
SUM(total_amt)/(SELECT SUM(total_amt) FROM Transactions)*100 AS '%_of_sales' 
FROM Transactions t2 join prod_cat_info t1 ON t2.prod_cat_code=t1.prod_cat_code and
t1.prod_sub_cat_code=t2.prod_subcat_code
where prod_cat in 
(select  top 5 t2.prod_cat
from Transactions T1  left join prod_cat_info T2
on t1.prod_subcat_code = t2.prod_sub_cat_code
group by t2.prod_cat
order by sum(qty) desc)
GROUP BY t1.prod_cat, prod_subcat 
ORDER BY sum(total_amt) DESC; 


--Q10--END


--Q11--BEGIN

--11. For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 30 days of transactions from max transaction date available in the data?

SELECT  SUM(total_amt) AS NET_REVENUE
FROM Customer T1 right JOIN Transactions T2
ON T1.customer_Id = T2.cust_id
WHERE DATEDIFF(YEAR,T1.DOB ,GETDATE()) BETWEEN  25 AND 35 and tran_date  = (DATEADD(day,-30,(select max(tran_date) from Transactions)));
--Q11--END


--Q12--BEGIN

---12.Which product category has seen the max value of returns in the last 3 months of transactions? 

SELECT TOP 1  prod_cat, Qty
FROM Transactions T1 LEFT JOIN prod_cat_info T2
ON T1.prod_subcat_code = T2.prod_sub_cat_code
WHERE tran_date BETWEEN (DATEADD(MONTH,-3,(SELECT MAX(tran_date) FROM Transactions))) AND (SELECT MAX(tran_date) FROM Transactions)  AND QTY < 0
GROUP BY prod_cat, QTY
ORDER BY QTY ASC;

--Q12--END


--Q13--BEGIN

---13.Which store-type sells the maximum products; by value of sales amount and by quantity sold? 

SELECT  Store_type,SUM(total_amt) AS SALES, SUM(QTY) AS QUANTITY
FROM Transactions
GROUP BY Store_type
ORDER BY SUM(total_amt) DESC,SUM(QTY) DESC;

--Q13--END


--Q14--BEGIN

--14.What are the categories for which average revenue is above the overall average. 

SELECT T2.prod_cat, AVG(total_amt) AS AVG_REVENUE
FROM Transactions T1 LEFT JOIN prod_cat_info T2
ON T1.prod_cat_code= T2.prod_cat_code
GROUP BY T2.prod_cat
HAVING AVG(total_amt) > ( SELECT AVG(total_amt) from Transactions);


--Q14--END


--Q15--BEGIN

--15. Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.

SELECT T2.prod_subcat, AVG(total_amt) AS AVG_REVENUE, SUM(total_amt) AS TOTAL_REVENUE  
FROM Transactions T1 LEFT JOIN prod_cat_info T2
ON T1.prod_cat_code = T2.prod_cat_code
WHERE T2.prod_cat IN (SELECT TOP 5 T2.prod_cat FROM Transactions T1 LEFT JOIN prod_cat_info T2 ON T1.prod_cat_code = T2.prod_cat_code
GROUP BY T2.prod_cat ORDER BY   SUM(QTY) DESC)
GROUP BY T2.prod_subcat;
