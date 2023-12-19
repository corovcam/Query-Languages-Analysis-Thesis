.timer on

-- 6. UNION

-- Get a list of contacts (email and phone) for both vendors and customers
-- Vendor contacts
SELECT 'Vendor'        AS entityType,
       Vendor.vendorId AS entityId,
       Vendor.name     AS entityName,
       Type.value      AS contactType,
       Vendor_Contacts.value
FROM Vendor
         JOIN Vendor_Contacts ON Vendor.vendorId = Vendor_Contacts.vendorId
         JOIN Type ON Vendor_Contacts.typeId = Type.typeId
UNION
-- Customer contacts
SELECT 'Order'                                    AS entityType,
       Customer.customerId                        AS entityId,
       Person.firstName || ' ' || Person.lastName AS entityName,
       Type.value                                 AS contactType,
       Order_Contacts.value
FROM Customer
         JOIN `Order` ON Customer.customerId = `Order`.customerId
         JOIN Order_Contacts ON `Order`.orderId = Order_Contacts.orderId
         JOIN Person ON Customer.personId = Person.personId
         JOIN Type ON Order_Contacts.typeId = Type.typeId
ORDER BY entityId, contactType;