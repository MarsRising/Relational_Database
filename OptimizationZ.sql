--Analyze for Optimization
EXPLAIN ANALYZE
SELECT OrderID, OrderDate, ShipDate, UnitsSold, TotalProfit AS CustomerTotal, I.ItemType
FROM Orders O
JOIN ItemType I ON O.ItemType_FK = I.ItemType_ID
WHERE OrderID = 753652942;

--Index on Orders for ItemType to help boost speed
CREATE INDEX idx_itemtype_fk ON Orders(ItemType_fk);

--Analyze for Optimization
EXPLAIN ANALYZE
SELECT OrderID, OrderDate, ShipDate, UnitsSold, TotalProfit AS CustomerTotal, I.ItemType
FROM Orders O
JOIN ItemType I ON O.ItemType_FK = I.ItemType_ID
WHERE OrderID = 753652942;

DROP INDEX idx_itemtype_fk