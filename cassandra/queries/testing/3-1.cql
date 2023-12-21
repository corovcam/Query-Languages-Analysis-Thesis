tracing on;
capture '/dev/null';

-- 3.1

-- Return all Orders and Vendors sharing the same Contact typeId
SELECT *
FROM Vendor_Contacts_By_Order_Contact;