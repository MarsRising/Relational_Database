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

DROP INDEX idx_orders_totalrevenue;