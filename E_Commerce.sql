Rohith Jijina
select COUNT(*) from order_item_refunds
select COUNT(*) from order_items 
select COUNT(*) from orders  
select COUNT(*) from products 
select COUNT(*) from website_pageviews  
select COUNT(*) from website_sessions  

select top 1 * from order_item_refunds
select top 1 * from order_items
select top 1 * from orders
select top 1 * from products
select top 1 * from website_pageviews
select top 1 * from website_sessions

select * from [dbo].[w_sessions]

select * from order_item_refunds
select * from order_items
select * from orders
select * from products
select * from website_pageviews
select * from website_sessions


-------------------------------------Orders Item Refunds Table Data checks-----------------------------------------
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

-----------------------------------website page views table Data checks-------------------------------------------
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

-----web sessions------------
SELECT *
FROM website_sessions
WHERE LOWER(utm_source) = 'null'
   OR LOWER(utm_campaign) = 'null'
   OR LOWER(utm_content) = 'null'
   OR LOWER(http_referer) = 'null';

--Copy Data from website_sessions to w_sessions
SELECT *
INTO w_sessions
FROM website_sessions;

--updating nulls to unknown
UPDATE w_sessions
SET utm_source = 'unknown'
WHERE LOWER(utm_source) = 'null';

UPDATE w_sessions
SET utm_campaign = 'unknown'
WHERE LOWER(utm_campaign) = 'null';

UPDATE w_sessions
SET utm_content = 'unknown'
WHERE LOWER(utm_content) = 'null';

UPDATE w_sessions --(39917 rows affected)
SET http_referer = 'unknown'
WHERE LOWER(http_referer) = 'null';

--Verify the Update:
SELECT *
FROM w_sessions
WHERE utm_source = 'unknown'
   OR utm_campaign = 'unknown'
   OR utm_content = 'unknown'
   OR http_referer = 'unknown';

--------------------------------------DASHBOARD FOR MARKETING MANAGER----------------------------------------
select * from w_sessions

---1. Gsearch conversion rate -Out of all visitors who came from Google Search (Gsearch),
--how many ended up placing an order

--Total Gsearch Sessions
SELECT COUNT(*) AS total_gsearch_sessions
FROM w_sessions
WHERE utm_source = 'gsearch';

--Gsearch Sessions with Orders
SELECT COUNT(DISTINCT ws.website_session_id) AS gsearch_sessions_with_orders
FROM w_sessions ws
JOIN orders o ON ws.website_session_id = o.website_session_id
WHERE ws.utm_source = 'gsearch';

--Gsearch Conversion Rate
SELECT 
  ROUND(
    COUNT(DISTINCT o.order_id) * 100.0 / COUNT(DISTINCT ws.website_session_id), 
    2
  ) AS gsearch_conversion_rate
FROM w_sessions ws
LEFT JOIN orders o 
  ON ws.website_session_id = o.website_session_id
WHERE ws.utm_source = 'gsearch';

--2. Gsearch Volume -Trends show how the number of sessions coming from Google Search
--changes over time — daily, weekly, or monthly.
SELECT 
    YEAR(created_at) AS year,
    DATENAME(MONTH, created_at) AS month_name,
    MONTH(created_at) AS month_number,
    COUNT(*) AS gsearch_sessions
FROM w_sessions
WHERE LOWER(utm_source) = 'gsearch'
GROUP BY YEAR(created_at), DATENAME(MONTH, created_at), MONTH(created_at)
ORDER BY year, month_number;

--3. Repeat Visitors- someone who visits the website more than once.
--Counts how many unique users (user_id) came to the site more than once.
SELECT COUNT(*) AS repeat_visitor_count
FROM (
    SELECT user_id
    FROM w_sessions
    WHERE user_id IS NOT NULL
    GROUP BY user_id
    HAVING COUNT(*) > 1
) AS repeat_users;

--4. Repeat Sessions Rate - Repeat Sessions/Total sessions * 100
SELECT 
    ROUND(
        COUNT(CASE WHEN is_repeat_session = 1 THEN 1 END) * 1.0 / COUNT(*) * 100, 2
    ) AS repeat_session_rate_percentage
FROM w_sessions;

--5. Min, Max, Average Time Between First and Second Session (for Repeat Visitors)
-- helps the Marketing Manager understand how quickly returning users come back for their second visit
WITH ranked_sessions AS (
    SELECT 
        user_id,
        created_at,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS session_rank
    FROM w_sessions
),
first_second_sessions AS (
    SELECT 
        user_id,
        MAX(CASE WHEN session_rank = 1 THEN created_at END) AS first_session,
        MAX(CASE WHEN session_rank = 2 THEN created_at END) AS second_session
    FROM ranked_sessions
    WHERE session_rank <= 2
    GROUP BY user_id
),
session_differences AS (
    SELECT 
        CAST(DATEDIFF(MINUTE, first_session, second_session) AS BIGINT) AS time_diff_minutes
    FROM first_second_sessions
    WHERE second_session IS NOT NULL
)
SELECT
    MIN(time_diff_minutes) AS min_time_between_sessions_minutes,
    MAX(time_diff_minutes) AS max_time_between_sessions_minutes,
    AVG(CAST(time_diff_minutes AS FLOAT)) AS avg_time_between_sessions_minutes
FROM session_differences;

--6. Traffic Conversion Rate- Sessions with Orders/Total Sessions
-- measuring how many sessions resulted in an order compared to the total number of sessions 
SELECT 
    s.utm_source,
    COUNT(DISTINCT s.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.website_session_id) AS sessions_with_orders,
    CAST(COUNT(DISTINCT o.website_session_id) * 100.0 / COUNT(DISTINCT s.website_session_id) AS DECIMAL(5,2)) AS conversion_rate_percent
FROM 
    w_sessions s
LEFT JOIN 
    orders o 
    ON s.website_session_id = o.website_session_id
GROUP BY 
    s.utm_source
ORDER BY 
    conversion_rate_percent DESC;

--Traffic source trending
--To analyze how different traffic sources (like gsearch, bsearch, email, etc.) perform over time,
-- Monthly Traffic Source Trends (Sessions + Conversion Rate)
SELECT 
    YEAR(ws.created_at) AS year,
    MONTH(ws.created_at) AS month,
    DATENAME(MONTH, ws.created_at) AS month_name,
    ws.utm_source,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.website_session_id) AS converted_sessions,
    CAST(COUNT(DISTINCT o.website_session_id) * 100.0 / COUNT(DISTINCT ws.website_session_id) AS DECIMAL(5,2)) AS conversion_rate_percent
FROM 
    w_sessions ws
LEFT JOIN 
    orders o ON ws.website_session_id = o.website_session_id
WHERE 
    ws.utm_source IS NOT NULL
GROUP BY 
    YEAR(ws.created_at),
    MONTH(ws.created_at),
    DATENAME(MONTH, ws.created_at),
    ws.utm_source
ORDER BY 
    year, month, ws.utm_source;

--distinct sources
select distinct utm_source,COUNT(utm_source) as countt
from w_sessions
group by utm_source