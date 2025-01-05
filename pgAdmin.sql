--Temp Table
CREATE TABLE TempRegion (
	Region CHAR(35) NOT NULL
);
--Real Table
CREATE TABLE Region (
	Region_ID SERIAL PRIMARY KEY NOT NULL,
	Region CHAR(35) UNIQUE NOT NULL
);

--Temp Copy
COPY TempRegion(Region)
FROM 'C:\Program Files\PostgreSQL\17\test.csv'
DELIMITER ',' CSV HEADER;

--Clean up for Region
INSERT INTO Region(Region)
SELECT DISTINCT Region
FROM TempRegion
ON CONFLICT (Region) DO NOTHING;

--Check and delete whats not needed
SELECT * from TempRegion;
SELECT * from Region;
DROP TABLE TempRegion;

--COUNTRY NEXT temp table
CREATE TABLE TempCountry (
	Region Char(35) NOT NULL,
	Country CHAR(35) NOT NULL
);

--Country Table
CREATE TABLE Country (
	Country_ID SERIAL PRIMARY KEY  NOT NULL,
	COUNTRY CHAR(35) UNIQUE NOT NULL,
	Region_FK INT,
	FOREIGN KEY(Region_FK) REFERENCES Region(Region_ID)
);

--Temp Copy
COPY TempCountry(Region, Country)
FROM 'C:\Program Files\PostgreSQL\17\country.csv'
DELIMITER ',' CSV HEADER;

--Clean up for RealTable
INSERT INTO Country(Country, Region_FK)
SELECT DISTINCT t.Country, r.Region_ID
FROM TempCountry t
JOIN Region r ON t.region = r.Region
ON CONFLICT (Country) DO NOTHING;
--check and delete
SELECT * from TempCountry;
SELECT * from Country;
--Double Check all data is maintained!
SELECT COUNT(DISTINCT Country), COUNT(DISTINCT Region)
FROM TempCountry;
--Delete unnecessary
DROP TABLE TempCountry;

--ItemType
CREATE TABLE ItemType (
	ItemType_ID SERIAL PRIMARY KEY NOT NULL,
	ItemType char(16) UNIQUE NOT NULL
);
CREATE TABLE TempItemType (
	ItemType CHAR(16) NOT NULL
);

--Copy to Temp
COPY TempItemType(ItemType)
FROM 'C:\Program Files\PostgreSQL\17\ItemTypes.csv'
DELIMITER ',' CSV HEADER;
SELECT* from TempItemType;
--ItemType time Clean up
INSERT INTO ItemType(ItemType)
SELECT DISTINCT ItemType
FROM TempItemType
ON CONFLICT (ItemType) DO NOTHING;
--Check and Clean Up
SELECT * FROM ItemType;
Drop table TempItemType;

--Sales channel process
CREATE TABLE SalesChannel (
	SalesChannel_ID SERIAL PRIMARY KEY NOT NULL,
	SalesChannel char(7) UNIQUE NOT NULL
);
CREATE TABLE TempSalesChannel (
	SalesChannel CHAR(7) NOT NULL
);
--Copy to Temp
COPY TempSalesChannel(SalesChannel)
FROM 'C:\Program Files\PostgreSQL\17\SalesChannel.csv'
DELIMITER ',' CSV HEADER;
SELECT* from TempSalesChannel;
--clean up
INSERT INTO SalesChannel(SalesChannel)
SELECT DISTINCT SalesChannel
FROM TempSalesChannel
ON CONFLICT (SalesChannel) DO NOTHING;
--check and clean up
SELECT * FROM SalesChannel;
Drop Table TempSalesChannel;

--Order priority Next
CREATE TABLE OrderPriority (
	OrderPriority_ID SERIAL PRIMARY KEY NOT NULL,
	OrderPriority CHAR(1) UNIQUE NOT NULL
);
CREATE TABLE TempPriority (
	OrderPriority CHAR(1) NOT NULL
);
--Copy into Temp
--Copy to Temp
COPY TempPriority(OrderPriority)
FROM 'C:\Program Files\PostgreSQL\17\Priority.csv'
DELIMITER ',' CSV HEADER;
SELECT* from TempPriority;
--OrderPriority cleanup
INSERT INTO OrderPriority(OrderPriority)
SELECT DISTINCT OrderPriority
FROM TempPriority
ON CONFLICT (OrderPriority) DO NOTHING;
SELECT * FROM OrderPriority;

--ORDERS
CREATE TABLE Orders (
	OrderDate DATE NOT NULL,
	OrderID INT PRIMARY KEY NOT NULL,
	ShipDate DATE NOT NULL,
	UnitsSold INT NOT NULL,
	UnitPrice NUMERIC(15,2) NOT NULL,
	UnitCost NUMERIC(15, 2) NOT NULL,
	TotalRevenue NUMERIC(15, 2) NOT NULL,
	TotalCost NUMERIC(15, 2) NOT NULL,
	TotalProfit NUMERIC(15, 2) NOT NULL,
    OrderPriority_FK INT,
    Country_FK INT,
    SalesChannel_FK INT,
    ItemType_FK INT,
	FOREIGN KEY (OrderPriority_FK) REFERENCES OrderPriority(OrderPriority_ID),
	FOREIGN KEY (Country_FK) REFERENCES Country(Country_ID),
	FOREIGN KEY (SalesChannel_FK) REFERENCES SalesChannel(SalesChannel_ID),
	FOREIGN KEY (ItemType_FK) REFERENCES ItemType(ItemType_ID)
);
DROP TABLE Orders;
CREATE TABLE TempOrders (
	Region CHAR(35) NOT NULL,
	Country CHAR(35) NOT NULL,
	ItemType CHAR(16) NOT NULL,
	SalesChannel CHAR(7) NOT NULL,
	OrderPriority CHAR(1) NOT NULL,
	OrderDate DATE NOT NULL,
	OrderID INT NOT NULL,
	ShipDate DATE NOT NULL,
	UnitsSold INT NOT NULL,
	UnitPrice Numeric(15,2) NOT NULL,
	UnitCost NUMERIC(15, 2) NOT NULL,
	TotalRevenue NUMERIC(15, 2) NOT NULL,
	TotalCost NUMERIC(15, 2) NOT NULL,
	TotalProfit NUMERIC(15, 2) NOT NULL,
);
DROP TABLE TempOrders;
--Copy to Temp
COPY TempOrders(Region, Country, ItemType, SalesChannel, OrderPriority, OrderDate, OrderID, ShipDate, UnitsSold, UnitPrice,UnitCost, TotalRevenue, TotalCost, TotalProfit)
FROM 'C:\Program Files\PostgreSQL\17\100000 Sales Records.csv'
DELIMITER ',' CSV HEADER;
SELECT* from TempOrders;

--Orders Finally!
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
FROM TempOrders o
JOIN OrderPriority op ON o.OrderPriority = op.OrderPriority
JOIN Country c ON o.Country = c.Country
JOIN SalesChannel sc ON o.SalesChannel = sc.SalesChannel
JOIN ItemType it ON o.ItemType = it.ItemType;
--Check it
SELECT * FROM Orders;


--Total Revenue by Country
SELECT C.Country, SUM(O.TotalRevenue) AS TotalRevenue
FROM Orders O
JOIN Country C ON O.Country_FK = C.Country_ID
JOIN Region R ON C.Region_FK = R.Region_ID
GROUP BY C.Country
ORDER BY TotalRevenue DESC;

--Customer View. They see only their info and the renaming comes to CustomerTotal
SELECT OrderID, OrderDate, ShipDate, UnitsSold, TotalProfit AS CustomerTotal, I.ItemType
FROM Orders O
JOIN ItemType I ON O.ItemType_FK = I.ItemType_ID
WHERE OrderID = 753652942;

--Sum of Total Profit per Year from Most Profitable Down
SELECT
	EXTRACT(YEAR FROM OrderDate) AS Year,
	SUM(TotalProfit) AS TotalProfit
FROM Orders
GROUP BY EXTRACT(YEAR FROM OrderDate)
ORDER BY Year Desc;


--OPTIMIZATION

--Explain Analyze
EXPLAIN ANALYZE
SELECT C.Country, SUM(O.TotalRevenue) AS TotalRevenue
FROM Orders O
JOIN Country C ON O.Country_FK = C.Country_ID
JOIN Region R ON C.Region_FK = R.Region_ID
GROUP BY C.Country
ORDER BY TotalRevenue DESC;

--INDEX
CREATE INDEX idx_orders_totalrevenue ON Orders(TotalRevenue);

--Explain Analyze
EXPLAIN ANALYZE
SELECT C.Country, SUM(O.TotalRevenue) AS TotalRevenue
FROM Orders O
JOIN Country C ON O.Country_FK = C.Country_ID
JOIN Region R ON C.Region_FK = R.Region_ID
GROUP BY C.Country
ORDER BY TotalRevenue DESC;

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


--ANALYZE
EXPLAIN ANALYZE
SELECT
	EXTRACT(YEAR FROM OrderDate) AS Year,
	SUM(TotalProfit) AS TotalProfit
FROM Orders
GROUP BY EXTRACT(YEAR FROM OrderDate)
ORDER BY Year Desc;

--Index OrderDate for Speed on Year's Extraction
CREATE INDEX idx_orderdate ON Orders(OrderDate);

--ANALYZE
EXPLAIN ANALYZE
SELECT
	EXTRACT(YEAR FROM OrderDate) AS Year,
	SUM(TotalProfit) AS TotalProfit
FROM Orders
GROUP BY EXTRACT(YEAR FROM OrderDate)
ORDER BY Year Desc;
