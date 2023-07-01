SELECT * FROM bank_data_marketing;

--Supossing there are only three possible values on marital column (married, single and divorced) exploring unique
--values:
SELECT DISTINCT(campaign)
FROM bank_data_marketing;

SELECT DISTINCT(job)
FROM bank_data_marketing;

SELECT DISTINCT(previous)
FROM bank_data_marketing;

--Looking to evaluate the whole dataset with a range of ages
--Exploring the maxima and minima (which results show that max is 95 and min is 18)
SELECT MAX(balance),
       MIN(balance),
       avg(balance)
FROM bank_data_marketing
WHERE poutcome = 'success';

SELECT age,
       CASE WHEN age <= 28 AND age >= 18 THEN '18-28 years'
            WHEN age > 28 AND age <= 35 THEN '28-35 years'
            WHEN age > 35 AND age <= 45 THEN '35-45 years'
            WHEN age > 45 AND age <= 55 THEN '45-55 years'
            WHEN age > 55 AND age <= 65 THEN '55-65 years'
            WHEN age > 65 THEN '65 years < ' END AS categorized_age_range,

       decision
FROM bank_data_marketing;

--Inspect the top 3 group age in which marketing campaigns are focused on

WITH categorized_age_table AS (
    SELECT age,
            CASE WHEN age <= 28 AND age >= 18 THEN '18-28 years'
                 WHEN age > 28 AND age <= 35 THEN '28-35 years'
                 WHEN age > 35 AND age <= 45 THEN '35-45 years'
                 WHEN age > 45 AND age <= 55 THEN '45-55 years'
                 WHEN age > 55 AND age <= 65 THEN '55-65 years'
                 WHEN age > 65 THEN '65 years < ' END AS categorized_age_range,
            decision
    FROM bank_data_marketing),

    grouped_age_table AS (SELECT categorized_age_range,
            COUNT(categorized_age_range) AS number_of_prospects
     FROM categorized_age_table
     WHERE decision = 'yes'
     GROUP BY categorized_age_range)

SELECT *,
       ROUND((number_of_prospects) / SUM(number_of_prospects) OVER (),4) AS percent_of_total
FROM grouped_age_table
ORDER BY number_of_prospects DESC
LIMIT 5;

--Professions where the marketing campaign has been focused

SELECT *,
       ROUND((count_job)/SUM(count_job) OVER (), 4) AS percent_total_job
FROM(SELECT job,
       COUNT(job) AS count_job
     FROM bank_data_marketing
     GROUP BY job) AS job_interm_table
ORDER BY job_interm_table.count_job DESC
LIMIT 5;

--Civil status where the marketing campaign has been focused

SELECT *,
       ROUND((count_marital)/SUM(count_marital) OVER (), 4) AS percent_total_marital
FROM(SELECT marital,
       COUNT(marital) AS count_marital
     FROM bank_data_marketing
     GROUP BY marital) AS marital_interm_table
ORDER BY marital_interm_table.count_marital DESC
LIMIT 3;

--Finding patterns between age groups and

WITH categorized_age_table AS (
    SELECT age,
            CASE WHEN age <= 28 AND age >= 18 THEN '18-28 years'
                 WHEN age > 28 AND age <= 35 THEN '28-35 years'
                 WHEN age > 35 AND age <= 45 THEN '35-45 years'
                 WHEN age > 45 AND age <= 55 THEN '45-55 years'
                 WHEN age > 55 AND age <= 65 THEN '55-65 years'
                 WHEN age > 65 THEN '65 years < ' END AS categorized_age_range,
            job,
            decision
    FROM bank_data_marketing
    WHERE job <> 'unknown' AND decision = 'yes')

SELECT categorized_age_range,
       job,
       COUNT(categorized_age_range) AS number_of_prospects
FROM categorized_age_table
GROUP BY categorized_age_range, job
ORDER BY number_of_prospects DESC
LIMIT 5;

--Finding patterns between

WITH categorized_age_table AS (
    SELECT age,
            CASE WHEN age <= 28 AND age >= 18 THEN '18-28 years'
                 WHEN age > 28 AND age <= 35 THEN '28-35 years'
                 WHEN age > 35 AND age <= 45 THEN '35-45 years'
                 WHEN age > 45 AND age <= 55 THEN '45-55 years'
                 WHEN age > 55 AND age <= 65 THEN '55-65 years'
                 WHEN age > 65 THEN '65 years < ' END AS categorized_age_range,
            marital,
            decision
    FROM bank_data_marketing
    WHERE decision = 'yes')

SELECT categorized_age_range,
       marital,
       COUNT(categorized_age_range) AS number_of_prospects,
       ROUND(COUNT(categorized_age_range)/SUM(COUNT(categorized_age_range)) OVER() , 4) AS percent_pattern_marital
FROM categorized_age_table
GROUP BY categorized_age_range, marital
ORDER BY number_of_prospects DESC
LIMIT 5;

--Visualizing rate of decision change in age groups

WITH categorized_age_evaluation_table AS (
    SELECT age,
            CASE WHEN age <= 28 AND age >= 18 THEN '18-28 years'
                 WHEN age > 28 AND age <= 35 THEN '28-35 years'
                 WHEN age > 35 AND age <= 45 THEN '35-45 years'
                 WHEN age > 45 AND age <= 55 THEN '45-55 years'
                 WHEN age > 55 AND age <= 65 THEN '55-65 years'
                 WHEN age > 65 THEN '65 years < ' END AS categorized_age_range,
            default_state,
            decision,
            CASE WHEN default_state = 'no' AND decision = 'yes' THEN 'positive'
                 WHEN default_state = 'yes' AND decision = 'no' THEN 'negative'
            END AS evaluation
    FROM bank_data_marketing
    WHERE default_state <> decision)

SELECT categorized_age_range,
       evaluation,
       COUNT(evaluation) AS number_of_changes,
       ROUND(COUNT(evaluation)/SUM(COUNT(evaluation)) OVER(), 4) AS percent_changes
FROM categorized_age_evaluation_table
GROUP BY categorized_age_evaluation_table.categorized_age_range, categorized_age_evaluation_table.evaluation
ORDER BY number_of_changes DESC;

--Visualizing rate of success and failure on conversion to client

SELECT *
FROM(SELECT bank_data_marketing.poutcome,
            COUNT(poutcome) AS poutcome_count,
            ROUND(COUNT(poutcome)/SUM(COUNT(poutcome)) OVER(), 4) AS percent_conversion
     FROM bank_data_marketing
     WHERE decision = 'yes'
     GROUP BY bank_data_marketing.poutcome) AS table_1
WHERE table_1.poutcome NOT IN ('other', 'unknown');

SELECT*
FROM(SELECT month,
       'General Public' AS public_classification,
       COUNT(month) AS n_prospects
FROM bank_data_marketing
GROUP BY month
UNION ALL
SELECT *,
       COUNT(intermediate_table_1.public_classification)
FROM(SELECT month,
       CASE WHEN decision = 'yes' THEN 'Objective Public' ELSE 'other' END AS public_classification
FROM bank_data_marketing) AS intermediate_table_1
WHERE intermediate_table_1.public_classification <> 'other'
GROUP BY intermediate_table_1.month, intermediate_table_1.public_classification
UNION ALL
SELECT *,
       COUNT(intermediate_table_2.public_classification)
FROM(SELECT month,
       CASE WHEN poutcome = 'success' THEN 'Client' ELSE 'other' END AS public_classification
FROM bank_data_marketing) AS intermediate_table_2
WHERE intermediate_table_2.public_classification <>'other'
GROUP BY intermediate_table_2.month, intermediate_table_2.public_classification) AS final_table
ORDER BY final_table.month;










