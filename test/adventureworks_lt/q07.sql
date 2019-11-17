-- column order not matched
SELECT
    SalesLT.Customer.CompanyName, SalesLT.Product.name
FROM
    SalesLT.ProductModel
    JOIN
    SalesLT.Product
    ON SalesLT.ProductModel.ProductModelID = SalesLT.Product.ProductModelID
    JOIN
    SalesLT.SalesOrderDetail
    ON SalesOrderDetail.ProductID = SalesLT.Product.ProductID
    JOIN
    SalesLT.SalesOrderHeader
    ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
    JOIN
    SalesLT.Customer
    ON SalesLT.SalesOrderHeader.CustomerID = SalesLT.Customer.CustomerID
WHERE
  SalesLT.ProductModel.Name = 'Racing Socks';