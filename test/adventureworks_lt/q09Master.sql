SELECT
  SalesLT.Customer.CompanyName,
  SalesLT.SalesOrderHeader.SubTotal,
  SUM(SalesLT.SalesOrderDetail.OrderQty * SalesLT.Product.weight) as totalWeight
FROM
  SalesLT.Product
  JOIN
  SalesLT.SalesOrderDetail
  ON SalesLT.Product.ProductID = SalesLT.SalesOrderDetail.ProductID
  JOIN
  SalesLT.SalesOrderHeader
  ON SalesLT.SalesOrderDetail.SalesOrderID = SalesLT.SalesOrderHeader.SalesorderID
  JOIN
  SalesLT.Customer
  ON SalesLT.SalesOrderHeader.CustomerID = SalesLT.Customer.CustomerID
GROUP BY
  SalesLT.SalesOrderHeader.SalesOrderID, SalesLT.SalesOrderHeader.SubTotal, SalesLT.Customer.CompanyName
ORDER BY
  SalesLT.SalesOrderHeader.SubTotal DESC;