--SETUP DATABSE
SET NOCOUNT ON
SET STATISTICS IO, TIME OFF
USE [master]
GO
--rollback
--ALTER DATABASE [PartDB] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DROP DATABASE IF EXISTS [PARTDB]
GO

CREATE DATABASE [PartDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'PartDB', FILENAME = N'C:\_SQLDBS\PartDB.mdf' , SIZE = 8192KB , FILEGROWTH = 65536KB ), 
 FILEGROUP [bis200] 
( NAME = N'bis200data', FILENAME = N'C:\_SQLDBS\bis200data.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB ), 
 FILEGROUP [bis5000] 
( NAME = N'bis5000data', FILENAME = N'C:\_SQLDBS\bis5000data.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB ), 
 FILEGROUP [COLD] 
( NAME = N'COLDdata', FILENAME = N'C:\_SQLDBS\COLDdata.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB ), 
 FILEGROUP [HOT] 
( NAME = N'HOTdata', FILENAME = N'C:\_SQLDBS\HOTdata.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'PartDB_log', FILENAME = N'C:\_SQLDBS\PartDB_log.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
GO


USE PARTDB
GO


--Monitor
create proc gpPartMonitor @tab varchar(50)
as
SELECT fg.name,p.partition_number,p.rows,ps.name, pf.name, prv.value,i.name
FROM    sys.partitions p
INNER JOIN sys.indexes i
    ON  p.object_id = i.object_id
INNER JOIN sys.partition_schemes ps
    ON  i.data_space_id = ps.data_space_id
INNER JOIN sys.partition_functions pf
    ON  ps.function_id = pf.function_id
INNER JOIN sys.destination_data_spaces dds
    ON  dds.partition_scheme_id = ps.data_space_id
    AND dds.destination_id = p.partition_number
INNER JOIN sys.filegroups fg
    ON  dds.data_space_id = fg.data_space_id
LEFT JOIN sys.partition_range_values prv
    ON  ps.function_id = prv.function_id
    AND p.partition_number = prv.boundary_id
LEFT JOIN sys.partition_range_values pprv
    ON  ps.function_id = prv.function_id
    AND p.partition_number - 1 = pprv.boundary_id
WHERE   p.object_id = OBJECT_ID( @tab )
--    AND rows <> 0;
GO

exec gpPartMonitor 'ptab';
GO

--Partitionsfunktion
create partition function fzahl(int)
as
RANGE LEFT FOR VALUES(100,200)  ---RIGHT

---------------100]-------------------200]--------------------------------
--    1					2						3


select $partition.fzahl(117) --2 

--Partitionsschema
create partition scheme schZahl
as
Partition fzahl to (HOT,bis200,COLD);
GO
---                   1      2     3

--Tabelle wird nicht auf eine Dateigruppe gelegt, sondern auf Schema
create table ptab (
					id int identity, 
					nummer int,
					spx char(4100)
				  ) 
				  ON schZahl(nummer);
GO


--Befüllen mit 20000 Datensätzen

declare @i as int = 1
begin tran
while @i <= 20000
	begin
		insert into ptab (nummer, spx) values (@i,'XY')
		set @i+=1
	end
commit;
GO

--Partitionsverteilung prüfen
exec gpPartMonitor 'ptab'
GO


----Grenzen hinzufügen

alter partition  scheme schZahl next used bis5000;
GO

exec gpPartMonitor 'ptab'
GO

alter partition function fZahl() split Range (5000);
GO

-----------100-----------200-------5000-----
--  1				2		   3		  4


exec gpPartMonitor 'ptab'
GO


--Grenzen entfernen ..100
alter partition function fzahl() merge range (100);
GO


exec gpPartMonitor 'ptab'
GO


---Daten ab ins Archiv

create table archiv (id int not null, nummer int, spx char(4100)) 
on COLD


alter table ptab switch partition 3 to archiv;
GO

--Daten wieder aus Archiv zurück.. oder auch andere Tabelle

--Zunächst Problem
/*
alter table archiv switch to ptab partition 3
*/

--Queltabellen müssen exakten Checkeinschränkungen aufweisen...
alter table dbo.archiv add CONSTRAINT
	CHK5000 CHECK (nummer >=5001 and nummer is not null)

exec gpPartMonitor 'ptab'
GO

alter table archiv switch  to ptab partition 3

select * from archiv


---Auch das klappt...


create partition scheme schZahl2 
as
partition fzahl to (COLD, COLD, COLD, COLD);
GO

--oder etwas kürzer
create partition scheme schZahl3 
as
partition fzahl ALL to (COLD);
GO


create table ptab2 (
					  id int identity
					, nummer int
					, spx char(4100)
					) 
			ON schZahl3(nummer);
GO

--Befüllen der Tabelle
declare @i as int = 1
begin tran
while @i <= 20000
	begin
		insert into ptab2 (nummer, spx) values (@i,'XY')
		set @i+=1
	end
commit;
GO

exec gpPartMonitor 'ptab2'

set statistics io on
select * from ptab2 where nummer =14

select * from ptab2 where nummer =5100


--Blocks----------------------------------------------
begin tran
update ptab2 set spx = 'XX' where nummer between 2 and 10
--rollback

--in a new Session:
select * from ptab2 where nummer = 50
select * from ptab2 where nummer = 500

--welcome back

--Locks finden:
--Blockierte Prozesse

select * from sysprocesses where blocked <>0 --Aktivitätsmonitor

--etwas genauer
SELECT  session_id ,blocking_session_id ,wait_time ,wait_type ,last_wait_type
 ,wait_resource ,transaction_isolation_level ,lock_timeout
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0
GO


--Der blockierte: SQL Text
select text,* from sysprocesses pr 
cross apply sys.dm_exec_sql_text(pr.sql_handle)
where blocked <>0

--der blockierende
select text,* from sysprocesses pr 
cross apply sys.dm_exec_sql_text(pr.sql_handle)
 where spid = 58



 
--Kompression
USE [PartDB]
ALTER TABLE [dbo].[ptab2] REBUILD PARTITION = 3 WITH(DATA_COMPRESSION = PAGE )

select * from ptab2 where nummer =14

select * from ptab2 where nummer =5100



--indizierung
CREATE NONCLUSTERED INDEX [NIX_Nummer_incl_id_spx] ON [dbo].[ptab2]
(	
		[nummer] ASC 
)
INCLUDE
		([id],[spx]) 
WITH (SORT_IN_TEMPDB = ON, ONLINE = ON )
	ON 
		[schZahl]([nummer])
GO

--IndexÜbersicht

select * from sys.dm_db_index_physical_stats
(db_id(), object_id('ptab2'),3,NULL,'detailed') 


select * from ptab2 where nummer =14
select * from ptab2 where nummer =5100
GO


Alter Index [NIX_Nummer_incl_id_spx]
ON ptab2
reorganize partition=2

Alter Index [NIX_Nummer_incl_id_spx]
ON ptab2
rebuild partition=3

------------------------------ENDE






 SELECT sys.fn_PhysLocFormatter(%%physloc%%) AS Location, * FROM ptab where nummer = 5010;


 SELECT Operation,
       Context,
       AllocUnitName,
       [Page ID],
       [Slot ID],
       SPID,
       COALESCE([Begin Time], [End Time]) AS [Time],
       [Transaction SID]
FROM   sys.fn_dblog(NULL, NULL)


--Wartung







--Sperren
--wer braucht die Sperre
--und welche Sperre möchte er haben
select * from sys.dm_tran_locks where request_session_id = 58 --GRANT ..72057594043760640
--KEY Sperre.. was macht der wartende damit
select * from sys.dm_tran_locks where request_session_id = 76 --WAIT

select * from sys.partitions where hobt_id =72057594043760640
select * from sys.partitions where object_id = object_id('ptab2')


rollback