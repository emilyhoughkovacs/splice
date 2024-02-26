<div style="text-align: right">
Emily Hough-Kovacs<br>
Splice Take-Home Part 2<br>
February 26, 2024<br>
</div>

# Objective
Using Google Analytics 360 data, determine which session-level factors predict whether a transaction is likely to occur. Use these factors to help increase the likelihood of visitors making a purchase.

# Key Insights
Of the key factors evaluated - country, pageviews, hits, traffic source medium, browser, operating system, and landing page - few of these are able to be directly impacted by our team. For instance, we can’t control what browser or country a user is visiting from. However, using these factors, we can determine which segments of our audience are more likely to convert. Based on these segments, we can focus our product design and marketing efforts on those segments who are already likely to convert, as they are our most valuable users. Alternatively, we could focus our efforts on improving conversion rate in less performative segments by targeting them directly. For the purpose of simplicity we will focus on the first approach.

Given my analysis, some of the key indicators of whether a user will convert are
1. Number of pageviews in the session
   - More is generally better
2. Country of origin
   - United States outperforms other regions
3. Landing page
   - The closer to checkout, the better - for example, those landing on `/basket.html` are more likely to convert than those landing on `/home.html`


These factors are ordered by importance, with pageviews being roughly 0.75-2.5 times more important than country, and country 1.5-4.5 times more important than landing page. Let’s look at each of these factors in turn.

## Pageviews
The average converting session has approximately 28 pageviews, whereas the average non-converting session has a statistically significant difference of less than 4 pageviews. Quite intuitively, the number of pageviews in a session is a leading indicator for whether a user will complete a transaction. Meaningful sessions require time and engagement, and more pageviews demonstrate high intent and deep engagement. This doesn’t mean we should attempt to increase pageviews at all cost, by, for instance, adding unnecessary steps to complete the checkout flow. Rather, we should use this metric as a proxy for a deeply engaging session. In order to increase the likelihood of a transaction to occur, **we should focus our product development efforts on creating meaningful moments on our site through engaging content.** This should be a guiding principle for all of our product development work.

## Country of Origin (United States)
Sessions originating from the United States convert at a rate of 3%, a statistically significant difference to around 0.1% for non-US sessions. Although we cannot directly influence the country of origin, we can pay closer attention to the United States as it is a region that is much more likely to complete a transaction. Using this insight, **we can focus our product design or marketing efforts to appeal to a United States customer**, given that this is the most high-value segment when comparing across countries.

## Landing Page (`home.html`)
Sessions where the landing page is `/home.html` convert at a slightly lower, though statistically significant, rate than those with other landing pages. `/home.html` landing page sessions convert at a rate of 1.12%, compared to those with other landing pages at a rate of 1.61%. As a short-term solution, we could spend more ad money on landing pages other than `/home.html`. Part of the reason this page may convert worse than others is because other pages (such as `/google+redesign/apparel` or `basket.html`) are further along in the checkout funnel, demonstrating a higher intent. However, further investigation is needed to understand this difference. As a next step, it would be useful to evaluate the content of the home page to understand if something on that page discourages conversion. **Perhaps running some A/B tests on redesigning several aspects of the home page could improve conversion for sessions that have that page as a landing page.**

# Methodology
The question of conversion is a binary classification problem. Many models exist to approach such a problem, but I wanted to focus on those with the most amount of interpretability of the importance of each feature. For this problem, I used two models, a random forest classifier that handles categorical variables without prior encoding called CatBoostClassifier, and a simpler logistic regression that did require some preprocessing. My analysis was based on a synthesis of the results of these models as well as some further exploratory data analysis.

<p style="text-indent: 25px;">
## CatBoostClassifier
I ran this model two different ways. First, I didn’t encode any of the categorical variables in order to get feature importance of each factor, leading me to identify pageviews, country, and landing page as the top three contributors.

Then, I re-ran this classifier after one-hot encoding each categorical variable. This allowed me to draw out that United States and `/home.html` were the most significant classes of the categorical variables that influence conversion.

After identifying the top three important features and classes within those features, I used some simple statistical tests to determine how converting versus non-converting sessions varied across those three features. For the numerical category of pageviews, I ran a t-test to determine if the number of pageviews for converting versus non-converting sessions was statistically significant. For a test of proportions across the categorical variables of country (United States) and landing page (`/home.html`), I calculated the z-score. In all three cases, the differences between the converting and non-converting class of sessions were statistically significant.

## Logistic Regression
For a logistic regression, I had to preprocess the data a bit more. In addition to one-hot encoding categorical values, I had to normalize the numerical data. Normalizing the numerical values puts it on a scale from zero to one, so the magnitude of the value does not cause the feature to have outsize importance to the categorical features.

Then, I scaled the data so each feature was normally distributed with a mean of 0 and standard deviation of 1. This is to ensure the model works properly and is able to converge.

Finally, I trained the logistic regression model and evaluated the feature importances using built-in functions. 
</p>

# Conclusion
Ultimately, **the three factors identified each provide unique perspectives to understanding of our audience and how they convert.**

Considering pageviews as a proxy for deep, meaningful connection, we can use this metric as a numerical measure of how engaged with our site users are. This fuels a user-centric experience that informs our product development cycle.

By paying attention to the country of origin of our sessions, especially those from the United States, we can segment the behavior of our users by demographic information. This allows us to take a bespoke approach to certain customers who we believe have an intrinsic higher likelihood to convert.

Finally, by drilling down into specific pages, we can experiment with ad budget as well as product tweaks that will guide users to a transaction event.

All three of these factors - numerical measurement of engagement, segmentation analysis, and experimentation - can be combined to further the user experience and lead to better outcomes for ourselves and our users.

# Further Consideration
* **One way to improve the reliability of feature importance is to improve the predictive power of the model used.** To do this, we would hold out cross-validation sets and use these to iterate through several values of the hyperparameter(s) of the models, using a grid search. Better model performance would give us more confidence in the results of the feature importance. For the sake of time, I did not investigate this but it’s an important step that we should take before making any decisions.
* Building a predictive model is useful not just for evaluating feature importance, but to predict future behavior. With the trained models, we can now predict whether future sessions will result in a transaction based on the given features.
* Technical note: An important aspect of this dataset is that there exists a huge class imbalance. Less than 13 in 1000 sessions in the dataset have a transaction event, which could lead logistic regression models to correctly predict that a session will not convert without regard for the features at all. In order to fully evaluate the strength of the model, we should also consider precision (percent of predicted conversions that actually convert) and recall (percent of conversions that are correctly predicted) in addition to accuracy. To handle this, we can use a combination of oversampling and undersampling.
  * Tree-based methods as well as ensemble methods such as CatBoostClassifier are better suited to handle class imbalance so I focused my analysis more heavily on this. 
* More or different data may be needed to conduct further investigation.
  * For instance, when segmenting based on demographic information, it may be preferable to consider datasets aggregated at the user level. For instance, number of conversions per customer within a given time period or rate of conversion per user.
  * More detailed information about the different product pages will help us learn more about why sessions with `/home.html` as a landing page perform poorly compared to other sessions.
  * We may want to consider the value of transactions - change this to a regression problem by evaluating transaction revenue per session rather than a binary conversion event.
