--TempTable
CREATE TEMP TABLE TempData (
    Region CHAR(35),
    Country CHAR(35),
    ItemType CHAR(16),
    SalesChannel CHAR(7),
    OrderPriority CHAR(1),
    OrderDate DATE,
    OrderID INT,
    ShipDate DATE,
    UnitsSold INT,
    UnitPrice NUMERIC(15, 2),
    UnitCost NUMERIC(15, 2),
    TotalRevenue NUMERIC(15, 2),
    TotalCost NUMERIC(15, 2),
    TotalProfit NUMERIC(15, 2)
);
--load data
COPY TempData (Region, Country, ItemType, SalesChannel, OrderPriority, 
               OrderDate, OrderID, ShipDate, UnitsSold, UnitPrice, 
               UnitCost, TotalRevenue, TotalCost, TotalProfit)
FROM 'C:\Program Files\PostgreSQL\17\100000 Sales Records.csv'
DELIMITER ',' CSV HEADER;
--Check Temp
SELECT * FROM TempData;

--Region
INSERT INTO Region (Region)
SELECT DISTINCT Region
FROM TempData
ON CONFLICT (Region) DO NOTHING;
--Check
SELECT * FROM Region;

--country
INSERT INTO Country (Country, Region_FK)
SELECT DISTINCT t.Country, r.Region_ID
FROM TempData t
JOIN Region r ON t.Region = r.Region
ON CONFLICT (Country) DO NOTHING;
--Check
SELECT * FROM Country;

--ItemType
INSERT INTO ItemType (ItemType)
SELECT DISTINCT ItemType
FROM TempData
ON CONFLICT (ItemType) DO NOTHING;
--Check
SELECT * FROM ItemType;

--sales channel
INSERT INTO SalesChannel (SalesChannel)
SELECT DISTINCT SalesChannel
FROM TempData
ON CONFLICT (SalesChannel) DO NOTHING;
--Check
SELECT * FROM SalesChannel;

--Order priority
INSERT INTO OrderPriority (OrderPriority)
SELECT DISTINCT OrderPriority
FROM TempData
ON CONFLICT (OrderPriority) DO NOTHING;
--Check
SELECT * FROM OrderPriority;

--Orders
INSERT INTO Orders (OrderDate, OrderID, ShipDate, UnitsSold, UnitPrice, UnitCost, TotalRevenue, TotalCost, TotalProfit, OrderPriority_FK, Country_FK, SalesChannel_FK, ItemType_FK)
SELECT 
    o.OrderDate,
    o.OrderID,
    o.ShipDate,
    o.UnitsSold,
    o.UnitPrice,
    o.UnitCost,
    o.TotalRevenue,
    o.TotalCost,
    o.TotalProfit,
    op.OrderPriority_ID,
    c.Country_ID,
    sc.SalesChannel_ID,
    it.ItemType_ID
FROM TempData o
JOIN OrderPriority op ON o.OrderPriority = op.OrderPriority
JOIN Country c ON o.Country = c.Country
JOIN SalesChannel sc ON o.SalesChannel = sc.SalesChannel
JOIN ItemType it ON o.ItemType = it.ItemType
ON CONFLICT (OrderID) DO NOTHING;

--Drop Temp
DROP TABLE TempData;
--Check Orders
SELECT * FROM Orders;
