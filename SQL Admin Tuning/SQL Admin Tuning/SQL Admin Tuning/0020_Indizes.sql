-----Tabelle für Indizes

create database IXDemo
Go

use IXdemo;
GO

select * into orders from nwindbig..orders,
Go


create nonclustered Index IXID On orders (orderid asc)
Go

set statistics io, time on
select orderid from orders where orderid = 111


--
CREATE TABLE sp_DBCCINDIZES
(
    PageFID         tinyint,
    PagePID         int,
    IAMFID          tinyint,
    IAMPID          int,
    ObjectID        int,
    IndexID         tinyint,
    PartitionNumber tinyint,
    PartitionID     bigint,
    iam_chain_type  varchar(30),
    PageType        tinyint,
    IndexLevel      tinyint,
    NextPageFID     tinyint,
    NextPagePID     int,
    PrevPageFID     tinyint,
    PrevPagePID     int
);
go

insert into sp_DBCCINDIZES
exec ('DBCC IND (IXdemo, orders,3)') --1 = IndexID
go

select * from sp_dbccindizes
where indexlevel=0
order by IndexLevel desc, PrevPagePID

select * from sp_dbccindizes
where indexlevel=1
order by IndexLevel desc, PrevPagePID

select * from sp_dbccindizes
where indexlevel=2
order by IndexLevel desc, PrevPagePID


--Root: 44082

DBCC PAGE (IXdemo, 1, 44082, 3)
DBCC PAGE (IXdemo, 1, 44080, 3)
DBCC PAGE (IXdemo, 1, 41904, 3)


--Zusammengesetzter IX
create nonclustered index nix_id_freight on orders(orderid, freight)

insert into sp_DBCCINDIZES
exec ('DBCC IND (IXdemo, orders,3)') --1 = IndexID
go

select * from sp_dbccindizes
where indexlevel=2
order by IndexLevel desc, PrevPagePID

--Root: 52666
DBCC PAGE (IXdemo, 1, 52666, 3)
DBCC PAGE (IXdemo, 1, 52664, 3)
DBCC PAGE (IXdemo, 1, 52600, 3)



--IX mit eingeschl Spalten

create nonclustered index nix_id_incl_Fright on orders(orderid)
include (freight)



insert into sp_DBCCINDIZES
exec ('DBCC IND (IXdemo, orders,4)') --1 = IndexID
go

select * from sp_dbccindizes
where indexlevel=2
order by IndexLevel desc, PrevPagePID

--Root: 52666
DBCC PAGE (IXdemo, 1, 58506, 3)
DBCC PAGE (IXdemo, 1, 58504, 3)
DBCC PAGE (IXdemo, 1, 58472, 3)




-------------------SCAN to SEEK-------------

select shipcity, shipcountry from orders where freight between 6 and 7
--Table Scan

create nonclustered index nix_Fr on orders (freight);
GO

select shipcity, shipcountry from orders where freight between 6 and 7
--SEEK mit Lookup



--Tipping Point
create nonclustered index NIX_Oid on orders(orderid)
dbcc showcontig('orders')
select 45514*0.25
select 45514*0.33
select 11378.50/2000000.00

select * from orders where orderid < 11868 
select * from orders where orderid < 11869

select 11868.00/2000000.00



--Index Varianten
create nonclustered index nix_Fr_Ci_CY_Cid_Sn on orders 
(freight,shipcity,shipcountry, customerid,shipname);
GO


select shipcity, shipcountry, customerid, shipname
from orders 
			where freight between 6 and 7


create nonclustered index nix_Fr_incl_SCi_SCy_Cid_Sn on orders (freight) 
	include (shipcity,shipcountry,customerid, shipname);
GO


select shipcity, shipcountry, customerid, shipname
from orders 
			where freight between 6 and 7



--Gefilterter Index

create nonclustered index nix_Fr_incl_SCi_SCy_Cid_Sn_Filter_6_7 
on orders (freight)
	include (shipcity,shipcountry,customerid, shipname) 
	WHERE freight 6.4
GO


select shipcity, shipcountry, customerid, shipname
from orders 
			where freight = 6.4



--ungefiltert
select shipcity, shipcountry, customerid, shipname, freight
from orders with (index=nix_Fr_incl_SCi_SCy_Cid_Sn)
			where freight = 6.4

--aktueller Status: Ebenen, Seiten....
select 
		index_id, index_depth, 
		page_count,index_type_desc, record_count
from sys.dm_db_index_physical_stats
	(db_id(), object_id('orders'),NULL,NULL, 'detailed')



--Indizierte Sicht

select shipcountry, count(*) from orders group by shipcountry

create view v1 with schemabinding
as 
select shipcountry, count_big(*) as Anz from dbo.orders group by shipcountry;
GO


create unique clustered index CLIX_v1 on V1(shipcountry) ;
GO

select * from v1
select shipcountry, count(*) from orders group by shipcountry


--Columnstore
select * into orders2 from orders

--perfekter Index:
create nonclustered index NIX on orders (shipvia) 
include (freight)


select shipcity , sum(freight) from orders 
where Shipvia = 29
Group by shipcity;
GO
	
--Columnstore
create clustered columnstore index csix on orders2 ;
GO

select shipcity , sum(freight) from orders2 
where Shipvia = 29
Group by shipcity

 
select * from sys.dm_db_column_store_row_group_physical_stats


update orders2 set freight = freight *1.1 where freight < 2000


select * from sys.dm_db_column_store_row_group_physical_stats


