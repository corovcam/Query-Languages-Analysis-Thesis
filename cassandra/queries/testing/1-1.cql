tracing on;
capture '/dev/null';

-- 1.1 Non-Indexed Columns

-- Select vendor with the name 'Bauch - Denesik'
SELECT vendorId, name
FROM Vendor
WHERE name = 'Bauch - Denesik'
    ALLOW FILTERING;