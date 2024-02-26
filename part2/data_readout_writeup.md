<div style="text-align: right">
Emily Hough-Kovacs<br>
Splice Take-Home Part 2<br>
February 26, 2024<br><br>
</div>

# Objective
Using Google Analytics 360 data, determine which session-level factors predict whether a transaction is likely to occur. Use these factors to help increase the likelihood of visitors making a purchase.

# Key Insights
Of the key factors evaluated - country, pageviews, hits, traffic source medium, browser, operating system, and landing page - few of these are able to be directly impacted by our team. For instance, we can’t control what browser or country a user is visiting from. However, using these factors, we can determine which segments of our audience are more likely to convert. Based on these segments, we can focus our product design and marketing efforts on those segments who are already likely to convert, as they are our most valuable users. Alternatively, we could focus our efforts on improving conversion rate in less performative segments by targeting them directly. For the purpose of simplicity we will focus on the first approach.<br><br>

Given my analysis, some of the key indicators of whether a user will convert are
1. Number of pageviews in the session
   - More is generally better
2. Country of origin
   - United States outperforms other regions
3. Landing page
   - The closer to checkout, the better - for example, those landing on `/basket.html` are more likely to convert than those landing on `/home.html`


These factors are ordered by importance, with pageviews being roughly 0.75-2.5 times more important than country, and country 1.5-4.5 times more important than landing page. Let’s look at each of these factors in turn.
