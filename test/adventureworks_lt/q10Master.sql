SELECT
    SUM(SalesLT.SalesOrderDetail.OrderQty)
FROM
    SalesLT.ProductCategory
    JOIN
    SalesLT.Product
    ON SalesLT.ProductCategory.ProductCategoryID = SalesLT.Product.ProductCategoryID
    JOIN
    SalesLT.SalesOrderDetail
    ON SalesLT.Product.ProductID = SalesLT.SalesOrderDetail.ProductID
    JOIN
    SalesLT.SalesOrderHeader
    ON SalesLT.SalesOrderDetail.SalesOrderID = SalesLT.SalesOrderHeader.SalesorderID
    JOIN
    SalesLT.Address
    ON SalesLT.SalesOrderHeader.ShipToAddressID = SalesLT.Address.AddressID
WHERE
  SalesLT.Address.City = 'London'
    AND SalesLT.ProductCategory.Name = 'Cranksets';