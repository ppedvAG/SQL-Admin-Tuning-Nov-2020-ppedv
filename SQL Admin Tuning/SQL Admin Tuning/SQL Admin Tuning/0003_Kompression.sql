
--Kompression

--t1
--Neustart

--RAM SQL Server: 492--steigt auf 615  (inkl read ahead)--> 160MB in RAM

set statistics io, time on
select * from tuningDB..t1

--Seiten: 20000  CPU:  250 ms    Dauer:  2536 ms

--Neustart: T1 ist komprimiert-- statt 160MB nun 0,6 MB im RAM.. 


--RAM SQL Server: bei Start weniger ca identisch
--er liest in den RAM komprimierte Seiten

set statistics io, time on
select * from t1

--Seiten: 32  , die 1:1 in RAM geschoben werden 
--CPU:       Dauer: meist höher

--Client bekommt aber 160MB

--Kompression eher zu Gunsten anderer: Archivtabellen
--Erwartung an Kompression: 40% bis 60%


--Wieso kann man nicht gleich alle Tabelle sprich die DB komprimieren?
--CPU würde vermutlich auf 100% hochgehen


