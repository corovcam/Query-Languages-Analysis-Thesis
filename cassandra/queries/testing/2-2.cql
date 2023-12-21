tracing on;
capture '/dev/null';

-- 2.2 MAX

-- Find the most expensive product per brand
SELECT brand, MAX(price) AS maxPrice
FROM Products_By_Brand
GROUP BY brand;