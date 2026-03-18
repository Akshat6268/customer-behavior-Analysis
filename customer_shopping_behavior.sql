
select * from customer_shopping_behavior;

--1 what is the total revenue genrated by male vs female customers?
select gender, Sum(purchase_amount) as revenue
from customer_shopping_behavior
group by gender

--2 Which customers used a discount but still spent more than the average purchase amount ?
select customer_id, purchase_amount
from customer_shopping_behavior
where discount_applied = 'Yes' and purchase_amount >=(select AVG(purchase_amount) from customer_shopping_behavior)

--3 Which are the top 5 product with the highest average review ratings?
select item_purchased,ROUND(AVG(review_rating::numeric),2) as "Average Product Rating"
from customer_shopping_behavior
group by item_purchased
order by avg(review_rating) desc
limit 5;

--4 Compare the average/total Purchase amount between standard and Express shipping
select shipping_type,
ROUND(AVG(purchase_amount),2) as "Average Value",
sum(purchase_amount) as "Total amount"
from customer_shopping_behavior
where shipping_type in ('Standard','Express')
group by shipping_type

--5 DO suscribed customers spend more? Compare average spend and Total revenue-- between suscribers and non-suscribers
select subscription_status,
count(customer_id)as "Total_customers",
ROUND(AVG(purchase_amount),2) as "ave_spend",
ROUND(sum(purchase_amount),2) as "Total Revenue"
from customer_shopping_behavior
group by subscription_status
order by "Total Revenue","ave_spend" desc


--6 Which 5 products have the highest percentage of purchase with discounts applied?
select item_purchased,
ROUND(100 * SUM(case when discount_applied = 'Yes' THEN 1 ELSE 0 end)/Count(*),2) as discount_rate
from customer_shopping_behavior
group by item_purchased
order by discount_rate desc
limit 10;

-- 7 Segment customers into new,Returning, and  Loyal based on their total -- number of previous purchase
-- ,and the count of  eeach segment

with customer_type as (
select customer_id, previous_purchases,
CASE
	WHEN previous_purchases = 1 THEN 'New'
	WHEN previous_purchases Between 2 and 10 THEN 'Returning'
	ELSE 'Loyal'
	END AS customer_segment
from customer_shopping_behavior
)
select customer_segment,count(*) as "Number of Customers"
from customer_type
group by customer_segment

--What are the top most purchased products within each category?
with item_counts as (
select category,item_purchased,
Count(customer_id) as total_orders,
ROW_number() over(partition by category order by  count(customer_id)DESC) as item_rank
from customer_shopping_behavior
group by category, item_purchased
)
select item_rank, category, item_purchased,total_orders
from item_counts
where item_rank <=3;

--09 Are customers who are repeat buyers(more than 5 previous purchases also likely to subcribe?)

SELECT subscription_status, COUNT(customer_id) AS repeat_buyers 
FROM customer_shopping_behavior
WHERE previous_purchases > 5 
GROUP BY subscription_status;

10. --Age Group ke hisaab se total revenue
-- Kaunsa age group business ke liye sabse zyada valuable hai.
SELECT age_group, SUM(purchase_amount) AS total_revenue 
FROM customer_shopping_behavior
GROUP BY age_group 
ORDER BY total_revenue DESC;