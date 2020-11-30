--Seiten und Bl�cke

use northwind;
GO


create table t1 (id int identity, spx char(4100));
GO


insert into t1 
select 'XY'
GO 20000
--Zeit Messen




--Testtabelle f�r weitere Spielereien
SELECT        Customers.CustomerID, Customers.CompanyName, Customers.ContactName, Customers.ContactTitle, Customers.City, Customers.Country, Orders.EmployeeID, Orders.OrderDate, Orders.Freight, Orders.ShipCity, 
                         Orders.ShipCountry, [Order Details].OrderID, [Order Details].ProductID, [Order Details].UnitPrice, [Order Details].Quantity, Employees.LastName, Employees.FirstName, Employees.BirthDate, Products.ProductName, 
                         Products.UnitsInStock
INTO KuUm
FROM            Customers INNER JOIN
                         Orders ON Customers.CustomerID = Orders.CustomerID INNER JOIN
                         Employees ON Orders.EmployeeID = Employees.EmployeeID INNER JOIN
                         [Order Details] ON Orders.OrderID = [Order Details].OrderID INNER JOIN
                         Products ON [Order Details].ProductID = Products.ProductID;
GO


insert into kuUm
select * from KuUm
GO
--bsi ca 1 Mio DS vorhanden...

select * into kuum2 from kuum


select top 3 * from kuum2



select top 1 city , sum(unitprice*quantity) from kuum2 group by city;
GO

select top 10 * from kuum2




create table t1 (id int identity, spx char(4100));
GO


set statistics io, time off

insert into t1
select 'XY'
GO 30000

--wie lange dauert der insert von 30000 Zeilen:  26

---wie gro� war der Aufwand zum vergr��ern der DB

--wie gro� ist die Tabelle t1 eigtl...

select 30000*4-- eigtl 120MB aber hat 240MB

--viele Vergr��erungen pro Sekunde --siehe Bericht (DB Eigenschaft--Berichte--Datentr�gerverwendung)
--im bereich 10 ms (HDD dann eher 70ms)
--aber in Summe erkl�ren die ms nicht die Dauer..
--Aufwand ist zum gro�en Teile : �die ANzahl der Batches und Transactions (30000 Batches mit je einer Transaktion)


--Ph�nomen : Seiten



--Seite hat immer 8192bytes
--davon sind 8060 bytes Nutzlast.. 
--pro Seite max 700 Slots
--Ziel sollte sein: Seiten so voll wie m�glich


--8 Seiten am St�ck nennt sich Extent / Block
--SQL Server liest nie einen DS sondern Seiten bzw Bl�cke


-- das erkl�rt auch die 240 MB
--1 DS > 50% einer Seiten dann ist die Seite voll...
--bei Datentypen wie varchar kann seiten�bergreifend weggeschrieben werden

--Datentyp image/text/ntext--> 2GB sind seit 2005 depricated
--was w�re die Alternative: Filetable, varchar(max) .. 2GB

--wie kann ich messen, dass eine Seite rel voll ist...?

--rel Tabellen sind: die gr��ten, gr��te Traffic
dbcc showcontig('t1')
-- Gescannte Seiten.............................: 30000
--- Mittlere Seitendichte (voll).....................: 50.79%

--das ist irre!!
--aber wie kommen wir auf h�here Dichten..?


--statt fixe Datentypen eher flexibel: char und varchar
--datetime...! eigtl ms aber eigtl auch nicht 


--SEITEN KOMMEN 1:1! IN RAM

--logische Design:
--DB f�r einen BIB:

--Wie kann man den F�llgrad einer Seite beeinflussen:

--Datentypen--> APP Redesign
--Auslagern in andere zus. Tabellen --> APP Redesign
--Luft rausnehmen: --> Kompression

use testdbx

set statistics io, time on


select * from t1

dbcc showcontig('t1')

/*
Die TABLE-Ebene wurde gescannt.
- Gescannte Seiten.............................: 35574
- Gescannte Bl�cke..............................: 4448
- Blockwechsel..............................: 4447
- Seiten pro Block (Durchschnitt)......: 8.0
- Scandichte [Bester Wert:Tats�chlicher Wert].......: 99.98% [4447:4448]
- Blockscanfragmentierung...................: 0.13%
- Bytes frei pro Seite (Durchschnitt).....................: 3983.0
- Mittlere Seitendichte (voll).....................:


*/


--Kompression: Seitenkompression und Zeilenkompression

--240MB-->300kb



--

dbcc shwocontig('')



select * from sys.dm_db_index_physical_stats(db_id(), object_id(''), NULL, NULL, 'detailed')
GO

