-- 1
SELECT 
    brand, 
    COUNT(B.product_id) AS products_per_brand,
    ROUND(AVG(listing_price), 2) AS avg_price,
    MIN(listing_price) AS lowest_price,
    MAX(listing_price) AS highest_price
FROM brands B
JOIN finance F ON B.product_id = F.product_id
WHERE listing_price > 0 AND brand IS NOT NULL
GROUP BY brand
ORDER BY brand



-- 2 
SELECT
    brand,
    sale_price,
    CASE
        WHEN sale_price BETWEEN 0 AND 50 THEN 'Low'
        WHEN sale_price BETWEEN 51 AND 100 THEN 'Medium'
        WHEN sale_price BETWEEN 101 AND 250 THEN 'High'
        ELSE 'Very High'
    END AS price_range_label
FROM finance F
JOIN brands B ON F.product_id = B.product_id
WHERE brand IS NOT NULL


-- 3
