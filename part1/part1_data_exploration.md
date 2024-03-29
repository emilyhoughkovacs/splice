For clarity, I have lettered each bullet point, so Question 1 comprises of 1a, 1b and 1c and Question 2 comprises of 2a and 2b.

1.
   a. `hits.hitNumber` - numbered individual hits<br>
`totals.hits` - total number of hits within session

gutcheck: count(hits.hitNumber) should equal sum(totals.hits)

```-- get total number of hits by summing total hits across all sessions
SELECT 
sum(totals.hits)
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
``` 

```
-- get total number of hits by counting unnested individual hits within all sessions
SELECT 
COUNT(h.hitNumber)
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`, UNNEST(hits) h
```

result: 13,233

   b. gutcheck: 2,556 rows, each row within a table corresponds to a unique session in Analytics 360, hence 2,556 sessions. assuming the data is clean, there should be no duplicates as the provided documentation states "Each row within a table corresponds to a session in Analytics 360." However, let's double check by counting distinct `fullVisitorId`-`visitID` pairs:

```
-- get number of unique sessions by using COUNT(distinct)
SELECT 
COUNT(distinct CONCAT(fullVisitorId, "-", visitId))
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
```

```
-- get number of unique sessions by using CTE and grouping by, which can be less computationally heavy than COUNT(distinct) 
WITH unique_sessions as (SELECT 
  CONCAT(fullVisitorId, "-", visitId) as sessionId
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
GROUP BY 1)
SELECT
  COUNT(*)
FROM 
  unique_sessions
```

result: 2,556

   c. Let's take the same approach as above for 1b, finding uniqueness in two different ways

```
-- unique fullVisitorIds using COUNT(distinct)
SELECT 
COUNT(distinct fullVisitorId)
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
```

```
-- potentially less computationally heavy but works just as well
WITH unique_visitors as (
SELECT 
  fullVisitorId
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
GROUP BY 1)
SELECT
  COUNT(*)
FROM
  unique_visitors
```

result: 2,293


2.
   a. With 1273 hits, `'/home'` is the pagePath of the page with the most landing page hits, making up 49.8% of landing page hits.

```
WITH landing_page_hit_counts as (SELECT 
  h.page.pagePath,
  COUNT(h.page.pagePath) as num_page_hits,
  1 as joinKey -- used to join all rows
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`, UNNEST(hits) h
WHERE h.isEntrance = true --landing pages only
GROUP BY 1),
total_landing_page_hits as (
  SELECT
    COUNT(h.page.pagePath) as num_total_page_hits,
    1 as joinKey -- used to join all rows
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`, UNNEST(hits) h
  WHERE h.isEntrance = true --landing pages only
)
SELECT
  pagePath,
  num_page_hits,
  num_page_hits/num_total_page_hits * 100 as proportion_landing_page_hits
FROM
  landing_page_hit_counts JOIN total_landing_page_hits USING (joinKey)
ORDER BY 2 desc
```

**See "Investigation: hit numbers" for a discovery about a bug in the dataset relating to hit numbers**

   b. Only 1.96% of all sessions with `'/home'` as a landing page resulted in a purchase.

```
-- count '/home' LP sessions grouped by is_transaction
with num_transactions as (SELECT 
  if(totals.transactions is null, false, true) as is_transaction,
  count(*) as num,
  1 as joinkey
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`, UNNEST(hits) h
WHERE h.isEntrance = true and h.page.pagePath = '/home'
group by 1),
-- count all '/home' LP sessions
total_home_transactions as (SELECT 
  count(*) as num,
  1 as joinkey
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`, UNNEST(hits) h
WHERE h.isEntrance = true and h.page.pagePath = '/home'
)
SELECT
  is_transaction,
  num_transactions.num/total_home_transactions.num * 100 as pct_purchases
FROM
num_transactions JOIN total_home_transactions USING (joinkey)
WHERE
is_transaction = true
```
