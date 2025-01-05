--Sum of Total Profit per Year from Most Profitable Down
SELECT
	EXTRACT(YEAR FROM OrderDate) AS Year,
	SUM(TotalProfit) AS TotalProfit
FROM Orders
GROUP BY EXTRACT(YEAR FROM OrderDate)
ORDER BY Year Desc;