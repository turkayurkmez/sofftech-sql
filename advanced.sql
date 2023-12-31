﻿/*
* 1. Ne yapacağınıza karar verin (SELECT, INSERT, UPDATE, DELETE)
* 2. Hangi tablo (ya da result set) ile çalışacağına karar ver
* 3. Hangi kolonlar ile çalışacağına karar ver
* 4. Varsa kritere karar ver
* 5. Sıralama veya Gruplama gibi son işlemleri ekle.
*/

-- Group by:
-- Hangi ülkede kaç tedarikçi firma var?

   -- Türkiye    0
   -- UK        10
SELECT 
  Country, COUNT(SupplierID) as 'Total'
FROM Suppliers
GROUP BY Country
ORDER BY Total DESC

-- 1000 adetten fazla satan ürünlerim hangileri? (tek tablo):
SELECT 
    ProductId, SUM(Quantity) as ToplamAdet
FROM [Order Details]
GROUP BY ProductId
HAVING SUM(Quantity) > 1000
ORDER BY ToplamAdet DESC

-- JOIN 
SELECT 
    ProductName, 
	SUM(Quantity) as ToplamAdet,
	SUM([Order Details].UnitPrice * Quantity)  OdenenTutar
FROM [Order Details] JOIN Products 
ON [Order Details].ProductId = Products.ProductID
GROUP BY ProductName
HAVING SUM(Quantity) > 1000
ORDER BY OdenenTutar DESC

--Hangi ürünü, hangi tedarikçi firma getiriyor?
SELECT
  ProductName, CompanyName, Country
FROM Products JOIN Suppliers
ON Products.SupplierID = Suppliers.SupplierID


/*
  Hangi sipariş
     * Hangi çalışan tarafından
	 * Hangi müşteriden alınmış,
	 * Hangi kargo şirketiyle gönderilmiş
	  Bu siparişte;
	  * Hangi kategoride bulunan
	  * Hangi tedarikçinin sağladığı
	  * Hangi üründen 
	  * kaç adet alınmış 
	  * ve ne kadar ödenmiştir?
*/
SELECT 
   o.OrderID, 
   o.OrderDate,
   e.FirstName + ' ' + e.LastName 'Employee',
   c.CompanyName 'Customer',
   s.CompanyName 'Shipper',
   sp.CompanyName 'Supplier',
   ca.CategoryName,
   p.ProductName,
   od.Quantity,
   od.Quantity * od.UnitPrice,
   o.ShipAddress +' / ' + o.ShipCountry 
FROM Employees e JOIN Orders o
ON e.EmployeeID = o.EmployeeID
JOIN Customers c
on o.CustomerID = c.CustomerID
JOIN Shippers s
ON o.ShipVia = s.ShipperID
JOIN [Order Details] od
ON od.OrderID = o.OrderID
JOIN Products p
ON od.ProductID = p.ProductID
JOIN Categories ca
ON p.CategoryID = ca.CategoryID
JOIN Suppliers sp
ON sp.SupplierID = p.SupplierID


SELECT * FROM Categories
INSERT into Categories (CategoryName) values ('Unlu Mamüller')

INSERT into Products (ProductName,UnitPrice) values ('Simit',7.5)

-- INNER JOIN : Kesişim
-- LEFT JOIN: Join kelimesinin solundaki Tablonun tamamı...
-- RIGHT    : Join kelimesinin sağındaki...................
-- FULL JOIN: Her iki tablonun da tüm satırları
SELECT 
    ProductName,CategoryName
FROM Categories FULL JOIN Products
ON Categories.CategoryID = Products.CategoryID
WHERE CategoryName is NULL OR 
      ProductName is NULL


SELECT COUNt(*) FROM Customers
SELECT COUNT(DISTINCT CustomerID) FROM Orders

--Sipariş vermeyen müşterilerim kimler.
SELECT
    CompanyName,OrderID
FROM Customers LEFT JOIN Orders
ON Customers.CustomerID = Orders.CustomerID
WHERE OrderID is NULL

-- Çalışanlar ve Müdürleri
SELECT 
   Calisan.FirstName+ ' ' + Calisan.LastName 'Çalışan',
   Mudur.FirstName + ' ' + Mudur.LastName 'Müdür'
FROM  Employees as Calisan LEFT JOIN Employees as Mudur
ON Calisan.ReportsTo = Mudur.EmployeeID

SELECT Count(*) FROM Orders
SELECT COUNt(*) FROM [Order Details]

SELECT * FROM Orders CROSS JOIN [Order Details]

--SUB-QUERY:
-- Hangi kategoride kaç ürün var?
SELECT
   CategoryName, COUNT(ProductID) as 'Toplam'
FROM Categories LEFT JOIN Products
ON Categories.CategoryID = Products.CategoryID
GROUP BY CategoryName
ORDER BY Toplam DESC

-- Aynı sorgunun sub-query karşılığı:
SELECT CategoryName,
     (
	    SELECT COUNT(*)
        FROM Products WHERE CategoryID = c.CategoryID
	 ) AS 'Toplam'
FROM Categories as c
ORDER BY Toplam DESC

--En pahalı ürünüm hangisi?
SELECT ProductName, UnitPrice, UnitsInStock
FROM Products
WHERE UnitPrice =( SELECT MAX(UnitPrice) FROM Products )

SELECT TOP 1
ProductName, UnitPrice, UnitsInStock
FROM Products
ORDER BY UnitPrice DESC

-- 
-- En çok para aldığımız sipariş hangisi?
SELECT O.OrderID, CompanyName
FROM [Order Details] od
JOIN Orders o
ON o.OrderID = od.OrderID
JOIN Customers C
on O.CustomerID = C.CustomerID
WHERE  od.UnitPrice * od.Quantity =
(SELECT 
    MAX(UnitPrice * Quantity) 
FROM [Order Details])


CREATE PROC searchProduct
  @name nvarchar(10)
AS
SELECT *
FROM Products WHERE ProductName LIKE '%'+@name+'%'


searchProduct 'Anton'
-- Bir ürünü satın alan müşteri, yanında bunları aldı:
-- Sadece X (1) ürününü alan fişlerin içinden; DİĞER ürünleri saymam gerek.

CREATE PROC recommendedProducts 
  @productId int
AS
SELECT TOP 5
   ProductName, SUM(Quantity) as TotalQuantity
FROM 
[Order Details] JOIN Products p
ON [Order Details].ProductID = p.ProductID
WHERE OrderID IN
( 
   SELECT  OrderID 
   FROM [Order Details]  WHERE ProductID =@productId
)
AND [Order Details].ProductId != @productId
GROUP BY ProductName
ORDER BY TotalQuantity DESC

recommendedProducts 25
 

GO

CREATE PROC CreateNewOrder
 @customer nchar(5),
 @employee int
AS  
INSERT into Orders (CustomerID,EmployeeID,OrderDate)
            values (@customer, @employee, GETDATE())            

RETURN Scope_Identity()

--Deniyoruz:
DECLARE @lastOrderId int;
EXECUTE @lastOrderId = CreateNewOrder 'ALFKI',4

SELECT @lastOrderId
SELECT * FROM Orders WHERE OrderID=12078

--A1. Sadece 1 ürün alan ve yeni sipariş veren business:

CREATE PROC CreateNewOrderWithOneProduct
   @customer nchar(5),
   @employee int,
   @product int,
   @price money,
   @qty smallint,
   @disc real
AS
DECLARE @paramlastOrderId int;
--1. prosedürü çalıştır:
EXECUTE @paramlastOrderId = CreateNewOrder @customer,@employee
INSERT into [Order Details] (OrderID, ProductID, UnitPrice,Quantity, Discount)
                    values  (@paramlastOrderId, @product,@price,@qty,@disc)

--1 ürün alan müşteri:
EXEC CreateNewOrderWithOneProduct 'ANTON',6,14,25,1,0

SELECT * FROM Orders order by OrderID desc
SELECT * FROM [Order Details] WHERE OrderID = 12079

--alternatif: aynı siparişte çok ürün alan müşteri ise,
 CREATE PROC CreateOrderDetail
    @order int,
	@product int,
	@price money,
	@qty smallint,
	@disc real
AS
   INSERT into [Order Details] (OrderID, ProductID, UnitPrice,Quantity, Discount)
                       values  (@order, @product,@price,@qty,@disc)
