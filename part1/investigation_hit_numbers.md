# Investigation: hit numbers

During the course of answering question 2a, I became curious as to whether the hit where `hit.isEntrance=true` would always be the first hit of the session. To answer this question, I ran the following query:

```
SELECT 
  h.hitNumber,
  COUNT(h.page.pagePath) as num_page_hits
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`, UNNEST(hits) h
WHERE h.isEntrance = true
GROUP BY 1
ORDER BY 2 desc
```

The above results indicate that the vast majority of the time (98.9%), the isEntrance hit event is indeed always the first hit of the session. This led me to investigate the outliers where this was not the case. In the following query, I find the visitIds corresponding to when the isEntrance event is hitNumber 3 or 4.

```
-- results in visitIds 1501614812 and 1501570398
SELECT 
  visitId,
  h.*
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`, UNNEST(hits) h
WHERE h.isEntrance = true and h.hitNumber > 2
```

By hardcoding the resulting visitIds, I was able to investigate further and examine what the hit sequence looked like for those anomolies where the `isEntrance` event was not occuring on `hitNumber` = 1.

```
SELECT 
  visitId,
  h.*
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`, UNNEST(hits) h
WHERE visitId in (1501614812, 1501570398)
order by visitId, hitNumber
```

The results of the above query show that for those events where the `isEntrance` event is not occuring on hitNumber 1 or 2, there actually *is* no hit events #1 or #2 within the given session. That is, when `isEntrance` occurs on `hitNumber` = 3, 3 is the lowest `hitNumber` within that session. Likewise, when `isEntrance` occurs on `hitNumber` = 4, 4 is the lowest `hitNumber` within that session.

This directly contradicts the definition of `hits.hitNumber` as given in the provided documentation. There, the definition for `hits.hitNumber` is stated as "The sequenced hit number. For the first hit of each session, this is set to 1." These anomolies demonstrate that occasionally, but rarely, the `hitNumber`s for a session are improperly calculated leading to the hit events being misnumbered. Aside from this anomoly, it seems that it is indeed the case that `isEntrance = true` should be equivalent to `hitNumber` = 1.