-- WEBSITE TRAFFIC ANALYSIS
-- 1. Monthly trends for gsearch sessions and orders
SELECT 
    YEAR(website_sessions.created_at) as year,
	MONTH(website_sessions.created_at) as month,
	COUNT(DISTINCT website_sessions.website_session_id) total_sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
FROM website_sessions
LEFT JOIN orders ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
GROUP BY 1,2;

-- 2. nonbrand and brand campaign monthly trend
SELECT 
    YEAR(website_sessions.created_at) as year,
	MONTH(website_sessions.created_at) as month,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign='brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign='brand' THEN orders.order_id ELSE NULL END) AS brand_orders,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign='nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign='nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders
FROM website_sessions
LEFT JOIN orders ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
GROUP BY 1,2;

-- 3. Monthly sessions and orders by device type from nonbrand campaign
SELECT 
    YEAR(website_sessions.created_at) as year,
	MONTH(website_sessions.created_at) as month,
	COUNT(DISTINCT CASE WHEN website_sessions.device_type='mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
	COUNT(DISTINCT CASE WHEN website_sessions.device_type='desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
	COUNT(DISTINCT CASE WHEN website_sessions.device_type='desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders,
	COUNT(DISTINCT CASE WHEN website_sessions.device_type='mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders

FROM website_sessions
LEFT JOIN orders ON orders.website_session_id = website_sessions.website_session_id

WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1,2;

-- 4. Monthly traffic trends for all channels
-- get a list of all sources and referers of the traffic
SELECT DISTINCT
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE created_at < '2012-11-27';
-- There are several sources of traffic: gsearch paid, bsearch paid, organic search, and direct type-in sessions.
SELECT 
    YEAR(website_sessions.created_at) as year,
	MONTH(website_sessions.created_at) as month,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_source='gsearch' 
		THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_source='bsearch' 
		THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_paid_sessions,	
	COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND http_referer IS NOT NULL 
		THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND http_referer IS NULL 
		THEN website_sessions.website_session_id ELSE NULL END) AS direct_typein_sessions
FROM website_sessions
LEFT JOIN orders ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

-- 5. Sessions to order conversion rates by month
SELECT
	YEAR(website_sessions.created_at) AS year,
    MONTH(website_sessions.created_at) AS month,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
	COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
FROM website_sessions
	LEFT JOIN orders ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27' 
GROUP BY 1,2;

-- 6. Estimate the revenue from gsearch lander test
-- find the first page view id for lander page
SELECT
	MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';

SELECT created_at
FROM website_pageviews
WHERE website_pageviews.website_pageview_id >= 23504;
-- gather a list of landing page id for each session
CREATE TEMPORARY TABLE first_page_viewed
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews 
	INNER JOIN website_sessions ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at < '2012-07-28'
	AND website_pageviews.website_pageview_id >= 23504
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY website_pageviews.website_session_id;

-- bring in landing page url for each session
CREATE TEMPORARY TABLE nonbrand_test_sessions_with_landingpages
SELECT 
	first_page_viewed.website_session_id,
    first_page_viewed.min_pageview_id,
    website_pageviews.pageview_url AS landing_page
FROM first_page_viewed
	LEFT JOIN website_pageviews ON first_page_viewed.min_pageview_id = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');

-- bring in orders to the table
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_orders
SELECT 
	nonbrand_test_sessions_with_landingpages.website_session_id,
    nonbrand_test_sessions_with_landingpages.landing_page,
    orders.order_id AS order_id
FROM nonbrand_test_sessions_with_landingpages
	LEFT JOIN orders ON orders.website_session_id = nonbrand_test_sessions_with_landingpages.website_session_id;

-- calculate the difference between conversion rates from 2 different landing pages
SELECT 
	landing_page,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS conversion_rate
FROM nonbrand_test_sessions_w_orders
GROUP BY 1;
    
-- find the most recent pageview for gsearch nonbrand where the traffic was sent to /home, then find the total sessions since the test with new landing page
SELECT
	MAX(website_sessions.website_session_id) AS most_recent_gsearch_nonbrand_home_pv
FROM website_sessions
	LEFT JOIN website_pageviews ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
    AND pageview_url = '/home'
    AND website_sessions.created_at < '2012-11-07';
	
SELECT 
	COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE created_at < '2012-11-27'
	AND website_session_id > 17145 -- the last home session calculated above
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand';
   
-- 7. Full conversional funnel from two different landing pages to orders (19th June - 28th July)
-- flag the page when clicked
CREATE TEMPORARY TABLE sessions_level_flagged
SELECT 
	website_session_id,
    MAX(homepage) AS homepage_click,
    MAX(lander_page) AS lander_click,
    MAX(products_page) AS product_click,
    MAX(fuzzy_page) AS fuzzy_click,
    MAX(cart_page) AS cart_click,
    MAX(delivery_page) AS delivery_click,
    MAX(billing_page) AS billing_click,
    MAX(thankyou_page) AS thankyou_click
FROM (
SELECT 
	website_sessions.website_session_id,
    website_pageviews.website_pageview_id,
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS fuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS delivery_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page

FROM website_sessions
LEFT JOIN website_pageviews ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-07-28'
	AND website_sessions.created_at > '2012-06-19'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
ORDER BY website_sessions.website_session_id
	AND website_pageviews.website_session_id
) AS flag_list
GROUP BY website_session_id;
-- count the click to certain page
CREATE TEMPORARY TABLE session_click_to_flagged
SELECT 
    CASE 
		WHEN homepage_click = 1 THEN 'saw_homepage'
		WHEN lander_click = 1 THEN 'saw_lander'
        ELSE 'error..check logic'
	END AS segment,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_click = 1 THEN website_session_id ELSE NULL END) AS to_product,
	COUNT(DISTINCT CASE WHEN fuzzy_click = 1 THEN website_session_id ELSE NULL END) AS to_mr_fuzzy,
    COUNT(DISTINCT CASE WHEN cart_click = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN delivery_click = 1 THEN website_session_id ELSE NULL END) AS to_delivery,
    COUNT(DISTINCT CASE WHEN billing_click = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_click = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM sessions_level_flagged
GROUP BY 1;

-- calculate the conversion rate
SELECT 
	segment,
    to_product/sessions AS product_clickthrough_rate,
    to_mr_fuzzy/to_product AS mr_fuzzy_clickthrough_rate,
    to_cart/to_mr_fuzzy AS cart_clickthrough_rate,
    to_delivery/to_cart AS delivery_clickthrough_rate,
    to_billing/to_delivery AS billing_clickthrough_rate,
    to_thankyou/to_billing AS thankyou_clickthrough_rate
	  
FROM session_click_to_flagged;


-- 8. The impact of the billing test 
SELECT
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
FROM(
SELECT
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id,
    orders.price_usd
FROM website_pageviews
	LEFT JOIN orders ON orders.website_session_id=website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10'
	AND website_pageviews.created_at < '2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')) AS billing_pageviews_and_order_data
GROUP BY 1;
    
-- calculate the total amount of billing sessions
SELECT
	COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews
WHERE website_pageviews.pageview_url IN ('/billing', '/billing-2')
	AND created_at BETWEEN '2012-10-27' AND '2012-11-27'

    
    
    