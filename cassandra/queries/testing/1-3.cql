tracing on;
capture '/dev/null';

-- 1.3 Indexed Columns

-- Select vendor with the ID 24
SELECT vendorId, name
FROM Vendor
WHERE vendorId = 24;