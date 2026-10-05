-- ============================================================
-- AMEX OFFERS ANALYTICS & REDEMPTION OPTIMIZATION
-- ============================================================
--
-- Business Objective:
-- Analyze customer, merchant and offer-level data to identify
-- redemption drivers, customer targeting opportunities and
-- merchant/industry performance.
--
-- Database: PostgreSQL
-- Author: Ashish Rawat
-- ============================================================


-- ============================================================
-- 1. DATABASE TABLES
-- ============================================================
--
-- Core tables used in the analysis:
--
-- customers
-- transactions
-- products
-- merchants
-- offers
-- targeting
-- redemptions
-- rfm
--
-- ============================================================


-- ============================================================
-- 2. DATA VALIDATION
-- ============================================================

-- Check row counts

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT 'transactions', COUNT(*)
FROM transactions

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'merchants', COUNT(*)
FROM merchants

UNION ALL

SELECT 'offers', COUNT(*)
FROM offers

UNION ALL

SELECT 'targeting', COUNT(*)
FROM targeting

UNION ALL

SELECT 'redemptions', COUNT(*)
FROM redemptions

UNION ALL

SELECT 'rfm', COUNT(*)
FROM rfm;


-- ============================================================
-- 3. OVERALL OFFER PERFORMANCE
-- ============================================================

SELECT
    COUNT(*) AS total_targeted,
    SUM(redeemed) AS total_redeemed,

    ROUND(
        100.0 * SUM(redeemed) / NULLIF(COUNT(*), 0),
        2
    ) AS redemption_rate,

    ROUND(
        AVG(redemption_probability),
        4
    ) AS avg_predicted_probability,

    ROUND(
        AVG(discount_pct),
        2
    ) AS avg_discount_pct,

    ROUND(
        AVG(min_spend),
        2
    ) AS avg_min_spend

FROM targeting;


-- ============================================================
-- 4. REDEMPTION PERFORMANCE BY OFFER TYPE
-- ============================================================

SELECT
    offer_type,

    COUNT(*) AS targeted_customers,

    SUM(redeemed) AS redemptions,

    ROUND(
        100.0 * SUM(redeemed) / NULLIF(COUNT(*), 0),
        2
    ) AS redemption_rate,

    ROUND(
        AVG(discount_pct),
        2
    ) AS avg_discount_pct,

    ROUND(
        AVG(min_spend),
        2
    ) AS avg_min_spend

FROM targeting

GROUP BY offer_type

ORDER BY redemption_rate DESC;


-- ============================================================
-- 5. REDEMPTION PERFORMANCE BY INDUSTRY
-- ============================================================

SELECT
    industry,

    COUNT(*) AS targeted_customers,

    SUM(redeemed) AS redemptions,

    ROUND(
        100.0 * SUM(redeemed) / NULLIF(COUNT(*), 0),
        2
    ) AS redemption_rate,

    ROUND(
        AVG(discount_pct),
        2
    ) AS avg_discount_pct,

    ROUND(
        AVG(category_spend),
        2
    ) AS avg_category_spend

FROM targeting

GROUP BY industry

ORDER BY redemption_rate DESC;


-- ============================================================
-- 6. MERCHANT PERFORMANCE
-- ============================================================

SELECT
    merchant_id,
    merchant_name,
    industry,

    COUNT(*) AS targeted_customers,

    SUM(redeemed) AS redemptions,

    ROUND(
        100.0 * SUM(redeemed) / NULLIF(COUNT(*), 0),
        2
    ) AS redemption_rate,

    ROUND(
        AVG(discount_pct),
        2
    ) AS avg_discount_pct,

    ROUND(
        AVG(category_spend),
        2
    ) AS avg_category_spend

FROM targeting

GROUP BY
    merchant_id,
    merchant_name,
    industry

HAVING COUNT(*) >= 100

ORDER BY redemption_rate DESC

LIMIT 20;


-- ============================================================
-- 7. CUSTOMER SPENDING SEGMENT PERFORMANCE
-- ============================================================

SELECT
    CASE
        WHEN category_spend < 500
            THEN 'Low Spend'

        WHEN category_spend < 2000
            THEN 'Medium Spend'

        WHEN category_spend < 5000
            THEN 'High Spend'

        ELSE 'Very High Spend'
    END AS customer_segment,

    COUNT(*) AS targeted_customers,

    SUM(redeemed) AS redemptions,

    ROUND(
        100.0 * SUM(redeemed) / NULLIF(COUNT(*), 0),
        2
    ) AS redemption_rate,

    ROUND(
        AVG(category_spend),
        2
    ) AS avg_category_spend

FROM targeting

GROUP BY customer_segment

ORDER BY redemption_rate DESC;


-- ============================================================
-- 8. DISCOUNT OPTIMIZATION
-- ============================================================

SELECT
    CASE
        WHEN discount_pct < 10
            THEN '<10%'

        WHEN discount_pct < 20
            THEN '10%-20%'

        WHEN discount_pct < 30
            THEN '20%-30%'

        ELSE '30%+'
    END AS discount_bucket,

    COUNT(*) AS targeted_customers,

    SUM(redeemed) AS redemptions,

    ROUND(
        100.0 * SUM(redeemed) / NULLIF(COUNT(*), 0),
        2
    ) AS redemption_rate,

    ROUND(
        AVG(category_spend),
        2
    ) AS avg_category_spend

FROM targeting

GROUP BY discount_bucket

ORDER BY redemption_rate DESC;


-- ============================================================
-- 9. MINIMUM SPEND OPTIMIZATION
-- ============================================================

SELECT
    CASE
        WHEN min_spend < 50
            THEN '< $50'

        WHEN min_spend < 100
            THEN '$50-$100'

        WHEN min_spend < 200
            THEN '$100-$200'

        ELSE '$200+'
    END AS minimum_spend_bucket,

    COUNT(*) AS targeted_customers,

    SUM(redeemed) AS redemptions,

    ROUND(
        100.0 * SUM(redeemed) / NULLIF(COUNT(*), 0),
        2
    ) AS redemption_rate,

    ROUND(
        AVG(category_spend),
        2
    ) AS avg_category_spend

FROM targeting

GROUP BY minimum_spend_bucket

ORDER BY redemption_rate DESC;


-- ============================================================
-- 10. REDEMPTION VALUE / DISCOUNT ANALYSIS
-- ============================================================

SELECT
    COUNT(*) AS total_redemptions,

    ROUND(
        SUM(discount_amount),
        2
    ) AS total_discount_given,

    ROUND(
        AVG(discount_amount),
        2
    ) AS avg_discount_amount,

    ROUND(
        MAX(discount_amount),
        2
    ) AS maximum_discount

FROM redemptions;


-- ============================================================
-- 11. MERCHANT DISCOUNT ANALYSIS
-- ============================================================

SELECT
    merchant_id,
    merchant_name,
    industry,

    COUNT(*) AS redemptions,

    ROUND(
        SUM(discount_amount),
        2
    ) AS total_discount,

    ROUND(
        AVG(discount_amount),
        2
    ) AS avg_discount

FROM redemptions

GROUP BY
    merchant_id,
    merchant_name,
    industry

ORDER BY total_discount DESC

LIMIT 20;


-- ============================================================
-- 12. INDUSTRY REDEMPTION VALUE
-- ============================================================

SELECT
    industry,

    COUNT(*) AS redemptions,

    ROUND(
        SUM(discount_amount),
        2
    ) AS total_discount,

    ROUND(
        AVG(discount_amount),
        2
    ) AS avg_discount

FROM redemptions

GROUP BY industry

ORDER BY total_discount DESC;


-- ============================================================
-- 13. PREDICTED VS ACTUAL REDEMPTION
-- ============================================================

SELECT
    CASE
        WHEN redemption_probability < 0.05
            THEN '<5%'

        WHEN redemption_probability < 0.10
            THEN '5%-10%'

        WHEN redemption_probability < 0.20
            THEN '10%-20%'

        WHEN redemption_probability < 0.30
            THEN '20%-30%'

        ELSE '30%+'
    END AS probability_bucket,

    COUNT(*) AS targeted_customers,

    SUM(redeemed) AS actual_redemptions,

    ROUND(
        100.0 * SUM(redeemed) / NULLIF(COUNT(*), 0),
        2
    ) AS actual_redemption_rate,

    ROUND(
        AVG(redemption_probability),
        4
    ) AS avg_predicted_probability

FROM targeting

GROUP BY probability_bucket

ORDER BY avg_predicted_probability;


-- ============================================================
-- 14. HIGH-VALUE NON-REDEEMERS
-- ============================================================
--
-- Customers with high predicted redemption probability who
-- have not redeemed their offer.
--
-- These customers represent potential targeting opportunities.
-- ============================================================

SELECT
    customer_id,
    category,
    category_spend,
    category_transactions,
    merchant_name,
    offer_id,
    offer_type,
    discount_pct,
    min_spend,
    redemption_probability

FROM targeting

WHERE redeemed = 0

  AND redemption_probability >= 0.20

ORDER BY
    redemption_probability DESC,
    category_spend DESC

LIMIT 100;


-- ============================================================
-- 15. INDUSTRY EXECUTIVE PERFORMANCE
-- ============================================================

SELECT
    industry,

    COUNT(*) AS targeted_customers,

    SUM(redeemed) AS redemptions,

    ROUND(
        100.0 * SUM(redeemed) / NULLIF(COUNT(*), 0),
        2
    ) AS redemption_rate,

    ROUND(
        AVG(category_spend),
        2
    ) AS avg_category_spend,

    ROUND(
        AVG(discount_pct),
        2
    ) AS avg_discount,

    ROUND(
        AVG(redemption_probability),
        4
    ) AS avg_predicted_probability

FROM targeting

GROUP BY industry

HAVING COUNT(*) >= 100

ORDER BY redemption_rate DESC;


-- ============================================================
-- 16. TOP CUSTOMERS BY SPENDING
-- ============================================================

SELECT
    customer_id,

    ROUND(
        SUM(category_spend),
        2
    ) AS total_category_spend,

    SUM(category_transactions) AS total_transactions,

    COUNT(DISTINCT offer_id) AS offers_targeted,

    SUM(redeemed) AS offers_redeemed,

    ROUND(
        100.0 * SUM(redeemed) /
        NULLIF(COUNT(*), 0),
        2
    ) AS redemption_rate

FROM targeting

GROUP BY customer_id

ORDER BY total_category_spend DESC

LIMIT 20;


-- ============================================================
-- 17. CUSTOMER OFFER ENGAGEMENT
-- ============================================================

SELECT
    customer_id,

    COUNT(*) AS offers_targeted,

    SUM(redeemed) AS offers_redeemed,

    ROUND(
        100.0 * SUM(redeemed) /
        NULLIF(COUNT(*), 0),
        2
    ) AS redemption_rate,

    ROUND(
        AVG(redemption_probability),
        4
    ) AS avg_predicted_probability

FROM targeting

GROUP BY customer_id

HAVING COUNT(*) >= 2

ORDER BY redemption_rate DESC;


-- ============================================================
-- 18. OFFER PERFORMANCE
-- ============================================================

SELECT
    offer_id,

    offer_type,

    discount_pct,

    min_spend,

    COUNT(*) AS targeted_customers,

    SUM(redeemed) AS redemptions,

    ROUND(
        100.0 * SUM(redeemed) /
        NULLIF(COUNT(*), 0),
        2
    ) AS redemption_rate,

    ROUND(
        AVG(redemption_probability),
        4
    ) AS avg_predicted_probability

FROM targeting

GROUP BY
    offer_id,
    offer_type,
    discount_pct,
    min_spend

ORDER BY redemption_rate DESC;


-- ============================================================
-- 19. HIGH-SPEND CUSTOMERS WITH LOW ENGAGEMENT
-- ============================================================
--
-- Potential retention / engagement opportunity.
-- ============================================================

SELECT
    customer_id,

    ROUND(
        SUM(category_spend),
        2
    ) AS total_spend,

    COUNT(*) AS offers_targeted,

    SUM(redeemed) AS offers_redeemed,

    ROUND(
        100.0 * SUM(redeemed) /
        NULLIF(COUNT(*), 0),
        2
    ) AS redemption_rate

FROM targeting

GROUP BY customer_id

HAVING SUM(category_spend) >= 5000

   AND
   100.0 * SUM(redeemed) /
   NULLIF(COUNT(*), 0) < 20

ORDER BY total_spend DESC;


-- ============================================================
-- 20. MERCHANT OPPORTUNITY ANALYSIS
-- ============================================================
--
-- Find merchants with significant targeting volume but
-- relatively low redemption.
-- ============================================================

SELECT
    merchant_id,
    merchant_name,
    industry,

    COUNT(*) AS targeted_customers,

    SUM(redeemed) AS redemptions,

    ROUND(
        100.0 * SUM(redeemed) /
        NULLIF(COUNT(*), 0),
        2
    ) AS redemption_rate,

    ROUND(
        AVG(discount_pct),
        2
    ) AS avg_discount_pct

FROM targeting

GROUP BY
    merchant_id,
    merchant_name,
    industry

HAVING COUNT(*) >= 100

ORDER BY redemption_rate ASC;


-- ============================================================
-- 21. OFFER TARGETING OPPORTUNITY SCORE
-- ============================================================
--
-- Identify non-redeemed customers with:
-- 1. High spending
-- 2. High predicted redemption probability
--
-- The score combines both dimensions.
-- ============================================================

WITH customer_opportunities AS (

    SELECT
        customer_id,
        merchant_name,
        industry,
        offer_id,
        category_spend,
        redemption_probability,

        category_spend *
        redemption_probability AS opportunity_score

    FROM targeting

    WHERE redeemed = 0
)

SELECT
    customer_id,
    merchant_name,
    industry,
    offer_id,

    ROUND(
        category_spend,
        2
    ) AS category_spend,

    ROUND(
        redemption_probability,
        4
    ) AS redemption_probability,

    ROUND(
        opportunity_score,
        2
    ) AS opportunity_score

FROM customer_opportunities

ORDER BY opportunity_score DESC

LIMIT 100;


-- ============================================================
-- 22. RFM CUSTOMER SEGMENT PERFORMANCE
-- ============================================================

SELECT
    segment,

    COUNT(*) AS customers,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_monetary_value,

    ROUND(
        AVG(frequency),
        2
    ) AS avg_frequency,

    ROUND(
        AVG(recency),
        2
    ) AS avg_recency

FROM rfm

GROUP BY segment

ORDER BY avg_monetary_value DESC;


-- ============================================================
-- 23. RFM SEGMENT + OFFER ENGAGEMENT
-- ============================================================

SELECT
    r.segment,

    COUNT(DISTINCT r.customer_id) AS customers,

    COUNT(t.offer_id) AS offers_targeted,

    SUM(t.redeemed) AS offers_redeemed,

    ROUND(
        100.0 * SUM(t.redeemed) /
        NULLIF(COUNT(t.offer_id), 0),
        2
    ) AS redemption_rate

FROM rfm r

LEFT JOIN targeting t
    ON r.customer_id = t.customer_id

GROUP BY r.segment

ORDER BY redemption_rate DESC;


-- ============================================================
-- 24. FINAL BUSINESS INSIGHT TABLE
-- ============================================================

SELECT
    industry,

    COUNT(*) AS targeted_customers,

    SUM(redeemed) AS redemptions,

    ROUND(
        100.0 * SUM(redeemed) /
        NULLIF(COUNT(*), 0),
        2
    ) AS redemption_rate,

    ROUND(
        AVG(category_spend),
        2
    ) AS avg_customer_spend,

    ROUND(
        AVG(discount_pct),
        2
    ) AS avg_discount,

    ROUND(
        AVG(min_spend),
        2
    ) AS avg_min_spend,

    ROUND(
        AVG(redemption_probability),
        4
    ) AS avg_predicted_probability

FROM targeting

GROUP BY industry

ORDER BY redemption_rate DESC;


-- ============================================================
-- END OF ANALYSIS
-- ============================================================
--
-- Key business areas covered:
--
-- 1. Overall offer performance
-- 2. Offer type analysis
-- 3. Industry performance
-- 4. Merchant performance
-- 5. Customer segmentation
-- 6. Discount optimization
-- 7. Minimum-spend optimization
-- 8. Redemption economics
-- 9. Predicted vs actual redemption
-- 10. High-value non-redeemers
-- 11. Customer engagement
-- 12. Offer ranking
-- 13. RFM analysis
-- 14. Targeting opportunity identification
--
-- ============================================================