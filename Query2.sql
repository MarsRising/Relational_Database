--Customer View. They see only their info and the renaming comes to CustomerTotal
SELECT OrderID, OrderDate, ShipDate, UnitsSold, TotalProfit AS CustomerTotal, I.ItemType
FROM Orders O
JOIN ItemType I ON O.ItemType_FK = I.ItemType_ID
WHERE OrderID = 753652942;