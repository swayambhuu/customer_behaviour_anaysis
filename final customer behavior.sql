select * from customer limit 20

--Q1 total as reve revenue generated male vs female customer ?
SELECT "Gender", SUM("Purchase Amount (USD)") AS revenue
FROM customer
GROUP BY "Gender";

--Q2 customer used a discount but still spend more than the average purchase?
SELECT "Customer ID", "Purchase Amount (USD)"
FROM customer
WHERE "Discount Applied" = 'Yes'
  AND "Purchase Amount (USD)" >= (
    SELECT AVG("Purchase Amount (USD)") FROM customer
  );
--Q3 which are the top 5 products with the highest average review rating
SELECT "Item Purchased", AVG("Review Rating") AS avg_rating
FROM customer
GROUP BY "Item Purchased"
ORDER BY avg_rating DESC
LIMIT 5;


--Q4 Compare the average purchase amount between standard and express shipping.
SELECT "Shipping Type", AVG("Purchase Amount (USD)") AS avg_purchase
FROM customer
WHERE "Shipping Type" IN ('Standard', 'Express')
GROUP BY "Shipping Type";

--Q5 Do subscribed customer spend more? 
--compare average spend and total revenue between scbscribes and non-subscribes.
SELECT "Subscription Status",
       AVG("Purchase Amount (USD)") AS avg_spend,
       SUM("Purchase Amount (USD)") AS total_revenue
FROM customer
GROUP BY "Subscription Status";

--Q6 Which 5 Proudct have the highest percentage of purchase with discount applied?
SELECT "Item Purchased",
       COUNT(*) FILTER (WHERE "Discount Applied" = 'Yes') * 100.0 / COUNT(*) AS discount_percentage
FROM customer
GROUP BY "Item Purchased"
ORDER BY discount_percentage DESC
LIMIT 5;

--Q7--Segment customer into new , returning and loyal based on their total number of previous purchases, 
--and show the count of each segment.
SELECT customer_segment, COUNT(*) AS total_customers
FROM (
    SELECT CASE
             WHEN "Previous Purchases" = 0 THEN 'New'
             WHEN "Previous Purchases" BETWEEN 1 AND 5 THEN 'Returning'
             ELSE 'Loyal'
           END AS customer_segment
    FROM customer
) sub
GROUP BY customer_segment;
--Q8-- What are the top 3 most purchased products within each category?
SELECT "Category", "Item Purchased", purchase_count
FROM (
    SELECT "Category",
           "Item Purchased",
           COUNT(*) AS purchase_count,
           RANK() OVER (PARTITION BY "Category" ORDER BY COUNT(*) DESC) AS rank
    FROM customer
    GROUP BY "Category", "Item Purchased"
) ranked
WHERE rank <= 3;
--Q9-- Are customers who are repeat buyers (more than 5 previous purchases ) also likely to subscribes?
SELECT repeat_status,
       "Subscription Status",
       COUNT(*) AS customer_count
FROM (
    SELECT CASE
             WHEN "Previous Purchases" > 5 THEN 'Repeat Buyer'
             ELSE 'Not Repeat'
           END AS repeat_status,
           "Subscription Status"
    FROM customer
) sub
GROUP BY repeat_status, "Subscription Status";
--Q10-- What is the revenue contribution of each age group?  
SELECT age_group,
       SUM("Purchase Amount (USD)") AS total_revenue
FROM (
    SELECT CASE
             WHEN "Age" < 20 THEN 'Teen'
             WHEN "Age" BETWEEN 20 AND 35 THEN 'Young Adult'
             WHEN "Age" BETWEEN 36 AND 55 THEN 'Adult'
             ELSE 'Senior'
           END AS age_group,
           "Purchase Amount (USD)"
    FROM customer
) sub
GROUP BY age_group
ORDER BY total_revenue DESC;