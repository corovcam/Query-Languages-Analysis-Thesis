.timer on

-- 3.1 Non-Indexed Columns

-- Join Vendor_Contacts and Order_Contacts on the type of contact (non-indexed column)
SELECT *
FROM Vendor_Contacts VC
         INNER JOIN Order_Contacts OC on VC.typeId = OC.typeId;