SELECT
    CompanyName
FROM
    SalesLT.Customer
    JOIN
    SalesLT.CustomerAddress
    ON Customer.CustomerID = CustomerAddress.CustomerID
    JOIN
    SalesLT.Address
    ON CustomerAddress.AddressID = Address.AddressID
WHERE
  Address.City = 'Dallas';
