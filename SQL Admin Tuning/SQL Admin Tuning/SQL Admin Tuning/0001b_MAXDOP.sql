--SQL Verwendet per default ab 5 SQL Dollar alle CPUS..
--ab SQL 2019 : ab 5 SQL Dollar alle Kerne max 8

--Sollen wirklích 8 Maler einen Raum weiß streichen..????

USE Northwind;


SELECT        Customers.CustomerID, Customers.CompanyName, Customers.ContactName, Customers.ContactTitle, Customers.City, Customers.Country, Orders.EmployeeID, Orders.OrderDate, Orders.Freight, Orders.ShipName, 
                         Orders.ShipCity, Orders.ShipCountry, Employees.LastName, Employees.FirstName, Employees.BirthDate, [Order Details].ProductID, [Order Details].UnitPrice, [Order Details].Quantity, [Order Details].OrderID, 
                         Products.ProductName, Products.UnitsInStock
INTO KU
FROM            Customers INNER JOIN
                         Orders ON Customers.CustomerID = Orders.CustomerID INNER JOIN
                         Employees ON Orders.EmployeeID = Employees.EmployeeID INNER JOIN
                         [Order Details] ON Orders.OrderID = [Order Details].OrderID INNER JOIN
                         Products ON [Order Details].ProductID = Products.ProductID


insert into ku
select * from ku

--Solange asuführen bis 1, 1 mIO DS in KU sind

--Frachtkosten pro Land
select country, sum(freight) from ku group by country

--Kosten für den Plan: 35,2 

--2 Pfe le.. mehr CPUS werden verwendet


--Frachtkosten pro Land
select country,count(*) from customers group by country

--SQL verwendet mal mehr CPUs mal nicht

--Sind mehr CPUs sinnvoll?.. Jaaahh ???

--soll er alle nehmen? ..Jaaahh???


set statistics io, time on --ANzahl der IO Zugriffe, Dauer der CPU Zeit und gesamte Dauer

select country, sum(freight) from ku group by country
option  (maxdop 8)
--10 min Dauer

--RUNNING .. RUNNABLE .. SUSPENDED


--, CPU-Zeit = 486 ms, verstrichene Zeit = 284 ms... mehr Cpus haben sich gelohnt

--was ist default:


--Resultat: mit der Hälfte der CPUs bin ich fast genauo schnell, verbrauche aber deutlich 
--weniger CPU Zet.. auch weniger CPU (4 CPUs langweilen sich)

--Einstellung : eher 50% CPU Kerne 
--Kostenschwellwert auf 25 oder 50


--Maxdop ist mittlerweile auch pro DB (Erweitert Eigenschaften) einstellbar


set statistics io, time on -- Anzahl der Seiten , Dauer in ms der CPU Arbeit und Gesamtdauer und Kompilier/Analysezeit
--nur bei Bedarf

--41613  , CPU-Zeit = 1156 ms, verstrichene Zeit = 169 ms.

--Plan: der tats. ist fast immer identisch mit dem geplanten (ausser bei f())



--Symbole: Gather Stream   Repartition Stream.. oft ein Indiz für schlechten MAXDOP

