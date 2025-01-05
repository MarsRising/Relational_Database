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

DROP INDEX idx_orderdate;