-- 3.1 Non-Indexed Columns

-- Join Vendor_Contacts and Order_Contacts on the type of contact (non-indexed column)
SELECT *
FROM Order_Contacts OC
         INNER JOIN Vendor_Contacts VC on VC.typeId = OC.typeId;