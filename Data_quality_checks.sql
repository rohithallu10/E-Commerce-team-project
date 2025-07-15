CREATE DATABASE E_COMMERCE
USE E_COMMERCE

select * from orders  ---32,313
select * from order_item_refunds  ---1,731
select * from order_items ---40,025
select * from products  ---4
select * from website_pageviews ---11,88,124
select * from website_sessions ---4,72,871


----------------------------------------------------DATA CHECKS-----------------------------------------

------------------------------------------Order items table-----------------------------------------
---Checking for Primary key columns for nulls and duplicates
--Checking for nulls
SELECT COUNT(*) AS NullCount
FROM order_items
WHERE order_item_id IS NULL;

--checking for duplicates
SELECT order_item_id, COUNT(*) AS Cnt
FROM order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;


-- 1. Check if order_item_id is unique and not null
SELECT 
    COUNT(*) AS TotalRows,							
    COUNT(DISTINCT order_item_id) AS UniqueOrderItemIDs, 
    COUNT(*) - COUNT(order_item_id) AS NullOrderItemIDs
FROM order_items;

-- 2. Check if product_id in order_items exists in products
SELECT 
    COUNT(*) AS OrphanedProductIDs
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 3. Check if price_usd and cogs_usd are non-negative
SELECT 
    COUNT(*) AS NegativePrices
FROM order_items
WHERE price_usd < 0;

SELECT COUNT(*) AS NegativeCosts
FROM order_items
WHERE cogs_usd < 0;

-- 4. Check if is_primary_item has only allowed values (0 or 1)
SELECT 
    is_primary_item, COUNT(*) AS Count
FROM order_items
GROUP BY is_primary_item
HAVING is_primary_item NOT IN (0, 1) OR is_primary_item IS NULL;

-- 5. Check for NULLs in created_at
SELECT 
    COUNT(*) AS NullCreatedAt
FROM order_items
WHERE created_at IS NULL;

-- 6. Check if price is greater than or equal to cost
SELECT COUNT(*) AS PriceLessThanCost
FROM order_items
WHERE price_usd < cogs_usd;


---Order items should be created after order id’s
SELECT oi.*
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

--Ensure order_items.created_at Is After Corresponding orders.created_at
SELECT oi.order_item_id, oi.created_at AS order_item_created_at, 
		o.created_at AS order_created_at
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE oi.created_at < o.created_at;


------------------------------Orders Item Refunds Table -----------------------------------------
select * from order_item_refunds

--checking Null Values
SELECT *
FROM order_item_refunds
WHERE order_item_refund_id IS NULL 
   OR created_at IS NULL 
   OR order_item_id IS NULL 
   OR order_id IS NULL 
   OR refund_amount_usd IS NULL

--checking rows with negative refund amounts
SELECT *
FROM order_item_refunds
WHERE refund_amount_usd < 0

-- Find refund records that are not in Order Items Table
select *
from order_item_refunds r
left join order_items i
on r.order_item_id = i.order_item_id
where i.order_item_id is null

-- Find refund records that are not in Order Table
select *
from order_item_refunds r
left join orders o
on r.order_id = o.order_id
where o.order_id is null

-- Check for duplicate refunds (same order_item_id refunded more than once)
SELECT order_item_id, COUNT(*) AS refund_count
FROM order_item_refunds
GROUP BY order_item_id
HAVING COUNT(*) > 1

--Check if refund is greater than product price
select *
from order_item_refunds o
join order_items i
on o.order_item_id = i.order_item_id
where refund_amount_usd > price_usd

--Check if refund dates are before order dates
select i.created_at as refund_date,o.created_at as ordered_date
from order_item_refunds i
join orders o
on o.order_id = i.order_id
where i.created_at < o.created_at

---------------------------------------website page views table-------------------------------------------
select * from website_pageviews

-- Check table schema and data types
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'website_pageviews';

-- Check for NULL values in critical columns
SELECT *
FROM website_pageviews
WHERE website_pageview_id IS NULL
   OR created_at IS NULL
   OR website_session_id IS NULL
   OR pageview_url IS NULL

-- Check for invalid/malformed URLs
SELECT *
FROM website_pageviews
WHERE pageview_url NOT LIKE '/%'
   OR pageview_url = ''
   OR pageview_url LIKE '% %';

-- Finding Page view with no matching session
select *
from website_pageviews p
left join website_sessions s
on p.website_session_id = s.website_session_id
where s.website_session_id is null

-- Check for pageviews that occurred before their session started
select p.created_at as page_view_time,
       s.created_at as session_start_time
from website_pageviews p
join website_sessions s
on p.website_session_id = s.website_session_id
where p.created_at < s.created_at

-- Check for duplicate pageview IDs
SELECT website_pageview_id, COUNT(*) AS countt
FROM website_pageviews
GROUP BY website_pageview_id
HAVING COUNT(*) > 1


-----------------------------------------Website_Sessions Table----------------------------------
select * from [dbo].[website_sessions]

---No.of Rows
select count(*) as Total_Rows
from [dbo].[website_sessions]


---No.of Columns
select count(*) as Total_Columns
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='website_sessions'


---Ensure primary key is unique and not null
---Null
select count(website_session_id) as Total_count_Null
from [dbo].[website_sessions]
where website_session_id is null

---Duplicate
With CTE as(
select website_session_id,ROW_NUMBER() over (partition by website_session_id order by website_session_id asc) as Row_number
from [dbo].[website_sessions]) 

Select *
from CTE
where Row_number>1


---Null/Missing Values
select * from [dbo].[website_sessions]

select 
    sum(case when created_at IS NULL then 1 else 0 end) as created_at_nulls,
    sum(case when user_id IS NULL then 1 else 0 end) as user_id_nulls,
    sum(case when is_repeat_session IS NULL then 1 else 0 end) as is_repeat_session_nulls,
    sum(case when utm_source='NULL' then 1 else 0 end) as utm_source_nulls,
    sum(case when utm_campaign='NULL' then 1 else 0 end) as utm_campaign_nulls,
    sum(case when utm_content='NULL' then 1 else 0 end) as utm_content_nulls,
    sum(case when device_type='NULL' then 1 else 0 end) as device_type_nulls,
    sum(case when http_referer='NULL' then 1 else 0 end) as http_referer_nulls
from [dbo].[website_sessions]



----------------------------------------Website_pageviews table-------------------------------------
select * from [dbo].[website_pageviews]

---No.of Rows
select count(*) as Total_Rows
from [dbo].[website_pageviews]


---No.of Columns
select count(*) as Total_Columns
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='website_pageviews'


---Ensure primary key is unique and not null
---Null
select count(website_pageview_id) as Total_count_Null
from [dbo].[website_pageviews]
where website_pageview_id is null

---Duplicate
With CTE as(
select website_pageview_id,ROW_NUMBER() over (partition by website_pageview_id order by website_pageview_id asc) as Row_number
from [dbo].[website_pageviews])

Select *
from CTE
where Row_number>1


--------------------------------------------Orders Table------------------------------------------------------
-------------------------distinct record of each primary key record-----------all are unique-------------

select   count(distinct order_id) as no_of_records from  orders                                                                                           ------------32313
select   count(distinct order_item_id) as no_of_records from  order_items     ------------40025
select   count(distinct order_item_refund_id) as no_of_records from  order_item_refunds             ------1731
select   count(distinct product_id) as no_of_records from  products                  ---4
select   count(distinct website_pageview_id) as no_of_records from  website_pageviews            ---1188124
select   count(distinct website_session_id) as no_of_records from  website_sessions               ---472871


---------------------------------distinct fields in each table-----------------------------

select count(distinct order_id) no_of_orders,count(distinct created_at) no_of_timings,count(distinct website_session_id)no_of_sessions,count(distinct user_id) no_of_users,
count(distinct primary_product_id) no_of_products,count(distinct items_purchased) no_of_total_items ,count(distinct price_usd) no_of_prices,
count(distinct cogs_usd) no_of_costs from orders


----------------------------------------to count duplicates----------------

SELECT
  COUNT(*) - COUNT(distinct website_session_id) AS duplicate_website_session_id,
  COUNT(*) - COUNT(distinct created_at) AS duplicate_created_at,
  COUNT(*) - COUNT(distinct user_id) AS duplicate_user_id
FROM orders

-----------------------------(duplicate customer_id)-----------------

select * from (SELECT *
FROM orders
WHERE user_id IN (
    SELECT user_id
    FROM orders
    GROUP BY user_id
    HAVING COUNT(*) > 1
))as x

 --------to see which customer again logging on same website_session------no customer

select * from orders a               ---------1286 records of duplicate 617 customers)
 join
 orders b
 on 
 a.user_id=b.user_id and
 a.order_id<>b.order_id  


--------------------(to check nulls in order table)         no null value----------------------------------
SELECT *,
       (CASE WHEN order_id IS NULL THEN 1 ELSE 0 END +
        CASE WHEN created_at IS NULL THEN 1 ELSE 0 END +
        CASE WHEN website_session_id IS NULL THEN 1 ELSE 0 END +
        CASE WHEN user_id IS NULL THEN 1 ELSE 0 END +
        CASE WHEN primary_product_id IS NULL THEN 1 ELSE 0 END +
        CASE WHEN items_purchased IS NULL THEN 1 ELSE 0 END
       ) AS null_column_count
FROM orders
WHERE order_id IS NULL 
   OR created_at IS NULL 
   OR website_session_id IS NULL 
   OR user_id IS NULL 
   OR primary_product_id IS NULL 
   OR items_purchased IS NULL;

---------------------------TO CHECK NULL IN ORDER_ITEM----------(no null)-------------
SELECT *,
       (CASE WHEN order_ITEM_ID IS NULL THEN 1 ELSE 0 END +
        CASE WHEN created_at IS NULL THEN 1 ELSE 0 END +
        cASE WHEN order_id IS NULL THEN 1 ELSE 0 END +
       
        CASE WHEN product_id IS NULL THEN 1 ELSE 0 END +
        CASE WHEN is_primary_item IS NULL THEN 1 ELSE 0 END +
		CASE WHEN price_usd IS NULL THEN 1 ELSE 0 END +
        CASE WHEN cogs_usd IS NULL THEN 1 ELSE 0 END 
       ) AS null_column_count
FROM order_items
WHERE order_item_id IS NULL 
   OR created_at IS NULL 
   OR order_id IS NULL 
   OR product_id IS NULL 
   Or is_primary_item IS NULL 
   OR price_usd IS NULL
   or cogs_usd is null

--------------------------to count duplicates------(7726 timing,7712 order_id)----------------------------------------
SELECT
  COUNT(*) - COUNT(distinct created_at) AS duplicate_creted_timing,
  COUNT(*) - COUNT(distinct order_id) AS duplicate_order_id
   
FROM order_items

----------------------------------duplicate order_id--------
--(each order_id is repeatting twice due to primary or not and having diff order_item_id)
SELECT *
FROM order_items
WHERE order_id IN (
    SELECT order_id
    FROM order_items
    GROUP BY order_id
    HAVING COUNT(*) > 1
)
order by order_id

-----------------(to check duplicate record of created_at from order item-----------------------------------------
 SELECT *
FROM order_items
WHERE created_at IN (
    SELECT created_at
    FROM order_items
    GROUP BY created_at
    HAVING COUNT(*) > 1
)
order by created_at


--distinct of ech column in order_item----------------------
select count(distinct order_item_id) no_of_orders_item,count(distinct created_at) no_of_timings,count(distinct order_id)no_of_orders,
count(distinct product_id) no_of_products,count(distinct is_primary_item) no_of_primry_nonprimry ,count(distinct price_usd) no_of_prices,
count(distinct cogs_usd) no_of_costs from order_items

	
-----------to display distinct price & cost-----------------------------------
select distinct product_id, price_usd as price_list, cogs_usd as cost_list from order_items
order by product_id

--------------------------------------------DATA CLEANING--------------------------------------------------------
-----new table updated nulls with unknown
select * from website_sessions into w_sessions

---updating nulls with unknown
UPDATE w_sessions
SET                           
    utm_source        = ISNULL(utm_source, 'unknown'),
    utm_campaign      = ISNULL(utm_campaign, 'unknown'),
    utm_content       = ISNULL(utm_content, 'unknown'),
    device_type       = ISNULL(device_type, 'unknown'),
    http_referer      = ISNULL(http_referer, 'unknown')
WHERE
    is_repeat_session IS NULL OR
    utm_source IS NULL OR
    utm_campaign IS NULL OR
    utm_content IS NULL OR
    device_type IS NULL OR
    http_referer IS NULL;


