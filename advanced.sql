/*
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

