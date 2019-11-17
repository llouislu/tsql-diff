WITH
    cte1
    AS
    (
        -- collecting basic data
        SELECT ADR.City, PC.Name, SUM(OrderQty*UnitPrice) AS SaleSum
        FROM SalesLT.ProductCategory PC
            JOIN SalesLT.Product PAW ON PC.ProductCategoryID = PAW.ProductCategoryID
            JOIN SalesLT.SalesOrderDetail SOD ON SOD.ProductID = PAW.ProductID
            JOIN SalesLT.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
            JOIN SalesLT.Customer CAW ON SOH.CustomerID = CAW.CustomerID
            JOIN SalesLT.CustomerAddress CA ON CAW.CustomerID = CA.CustomerID
            JOIN SalesLT.Address ADR ON CA.AddressID = ADR.AddressID
        --WHERE  CA.AddressType = 'Shipping'
        GROUP BY City, PC.Name
    ),
    cte2
    AS
    (
        -- three most important cities
        SELECT TOP 3
            City, SaleSum
        FROM cte1
        ORDER BY SaleSum
    ),
    cte3
    AS
    (
        -- max product category per city
        SELECT City, MAX(Salesum) as maxSaleSum
        FROM cte1
        GROUP BY City
    )
SELECT cte3.City, Name AS ProductCat, maxSaleSum
FROM cte2 JOIN cte3 ON cte2.City = cte3.City
    JOIN cte1 ON cte2.City = cte1.City
WHERE cte1.SaleSum = maxSaleSum ;