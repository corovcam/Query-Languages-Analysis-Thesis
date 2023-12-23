tracing on;
capture '/dev/null';

-- 2.1 COUNT

-- Count the number of products per brand
SELECT brand, COUNT(*) AS productCount
FROM Products_By_Brand
GROUP BY brand;