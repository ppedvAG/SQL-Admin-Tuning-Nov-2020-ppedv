--problem der Prozeduren



--Objekte: cusomerid char(5)
exec gpKundensuche 'ALFKI' -- aus Customers der ALFKI gefunden  (Customerid)

exec gpKundensuche 'A' -- aus Customers alle mit A beginnend

exec gpKundensuche  -- alle Kunden (Customerid)


create proc gpKundenSuche @kdid varchar(5) = '%'
as
select * from customers where customerid like @kdid + '%'

--Prozeduren sollten nicht benutzerfreundlich sein
-

--fazit.. verwende bei variablen Längen bei Varibalen  od Parametern immer etwas mehr.



--Aktivieren des QUeryStore..
--perfektes Instrument zum Auffinden schlecht performender Abfragen
--Ideal auch für Suche nach "verrückten" prozeduren...


create proc gpSuche @ID int
as
select * from ku4 where id < @id
GO

--erste Aufruf legt Plan fest

set statistics io, time on

select * from ku4 where id < 1 --IX Seek

exec gpSuche1 100000 --Seek mit > 1 Million Seiten!!!!!!



dbcc freeeproccache--leert den kompletten ProzCache
--beeer: ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
--nur aktuell verwendete DB


exec gpSuche1 1000000 --Scan... IX Scan oder Table Scan .. max 40000 Seiten
exec gpSuche1 2 --immer noch SCAN

--Suche den besten Kompromiß (oder Proc umschreieben in 2 weitere Proc zB)

--Fazit: mach nicht beutzerfreundlich


--FUnktionen sind schlecht...

select * from customers where customerid like 'A%' --> Seek
select * from customers where left(customerid,1) ='A' --> SCAN


--Alle datensätze aus dem Jahr 1996

select * into ku5 from ku4




select * from ku5 where id = 100--einmal


select * from ku5 where city = 'berlin'--puuhh.. ka
select * from ku5 where freight < 1 -- pfff oft oder wenig weiss der Kuckuck

--woher weiss der das..?

--Statistiken.. werden erst erstellt , wenn die Abfrage eine Where Bediungn auf die Spalte nethält


--ProdServer: Abfrage langsam.. Testrechner.... schneller

--Stats sind falsch: Aktualisierung...20% +500+Abfrage 


---Logischer Fluss
--Planwiederverwendung

--Statistiken müssen korrekt sein. Akteulle Statsistiken sind meist korrekter als alte;-)
--tägliche Statsístikaktualisierung!

--sp_updatestats

--SQL macht per default nur Einzelspaltenstatistik, aber keine kombinierten Statistiken..

--Stat oft Grund für schlechte leistung, da falscher Plan entwicklet wird...


















--In der PROC auf ander verzweigen
create proc godemo3 var1 
as
If @var = 1 
select * from orders
ELSE
select * from customers...


dbcc freeproccache
