.timer on

-- 2.2 MAX

SELECT brand, MAX(price) AS maxPrice
FROM Product
GROUP BY brand;