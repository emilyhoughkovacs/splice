-- Below is my SQL code to bring in the features and target for modeling in Part 2. 
-- I chose to limit the number of categorical variables by taking the top 3-10 items
-- in the following categories: 
-- browser, operatingSystem, country, landing_page
-- I also included the categorical variable trafficSource.medium, which only had 7 categories

-- get top browsers
with browsers as (SELECT 
  device.browser,
  count(*)
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
group by 1
order by 2 desc
limit 3),
-- get top oses
oses as (SELECT 
  device.operatingSystem,
  count(*)
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
group by 1
order by 2 desc
limit 5),
-- get top countries
countries as (SELECT 
  geoNetwork.country,
  count(*)
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
group by 1
order by 2 desc
LIMIT 10),
-- get top landing pages
lp as (SELECT 
  if(h.page.pagePath LIKE '/google+redesign/apparel%', '/google+redesign/apparel', h.page.pagePath) as landing_page,
  count(*)
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`, unnest(hits) h
where isEntrance is true
group by 1
order by 2 desc
LIMIT 5
),
-- get unique landing page per unique session
visits_landing_page as (SELECT
  CONCAT(fullVisitorId, "-", visitId, "-", date) as unique_session_id,
  if(h.page.pagePath LIKE '/google+redesign/apparel%', '/google+redesign/apparel', h.page.pagePath) as landing_page
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`, unnest(hits) h
where isEntrance is true
)

--bring it all together
SELECT
  ga.unique_session_id, -- not to be used as a feature, we will drop this column in preprocessing
  totals.hits,
  totals.pageviews,
  trafficSource.medium,
  CASE
    WHEN device.browser in (select browser from browsers) THEN device.browser
    ELSE 'Other'
  END as browser,
  CASE
    WHEN device.operatingSystem in (select operatingSystem from oses) THEN device.operatingSystem
    ELSE 'Other'
  END as operatingSystem,
  CASE
    WHEN geoNetwork.country in (select country from countries) THEN geoNetwork.country
    ELSE 'Other'
  END as country,
  CASE
    WHEN landing_page in (select landing_page from lp) THEN landing_page
    ELSE 'Other'
  END as landing_page,
  if(totals.transactions > 0, 1, 0) as is_transaction -- target variable
FROM 
(SELECT CONCAT(fullVisitorId, "-", visitId, "-", date) as unique_session_id, * FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`) ga
JOIN visits_landing_page USING(unique_session_id)
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9