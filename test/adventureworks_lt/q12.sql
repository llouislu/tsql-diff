SELECT
    SalesLT.SalesOrderHeader.SalesOrderID,
    SalesLT.SalesOrderHeader.SubTotal
    -- SUM(SalesLT.SalesOrderDetail.OrderQty * SalesLT.SalesOrderDetail.UnitPrice),
    -- SUM(SalesLT.SalesOrderDetail.OrderQty * SalesLT.Product.ListPrice)
FROM
    SalesLT.SalesOrderHeader
    JOIN
    SalesLT.SalesOrderDetail
    ON SalesLT.SalesOrderHeader.SalesOrderID = SalesLT.SalesOrderDetail.SalesOrderID
    JOIN
    SalesLT.Product
    ON SalesLT.SalesOrderDetail.ProductID = SalesLT.Product.ProductID
GROUP BY
  SalesLT.SalesOrderHeader.SalesOrderID,
  SalesLT.SalesOrderHeader.SubTotal;