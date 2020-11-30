--DB Setting

create database testdb

/*
Initialgr��e: bis 2014 5MB DB
Wachstum: Daten 1 MB; LOG 10%

ab 2016:
DB 8MB ..Anfangsgr��e sollte das sein, wie gro� die DB in ca 3 Jahren sein wird
Wachstum 64MB
LOGFile  64MB


VLF (Restore)..LogFile sollte nie wachsen --siehe VLF Script!


*/


--recoveryModel:

/*

simple
I,UP, DEL,  BULK nur rudiment�r
Logfile wird automatisch geleert, sp. durch VollSicherung

keine LogSicherung m�glich (keine Restore auf beliebigen zeitpunkt)
weniger!

bulk
I, UP, DEL, BULK nur rudiment�r
Logfile wird nicht automatisch geleert
Erst duch Sicherung des Logfiles



full
ausf�hrlich auch Bulk protokolliert
IX
auf sek restore m�glich
aufwendiger


*/

--default: FULL, weil die model auch auf full steht!



select * from fn_virtualfilestats(db_id(), 2)



Tabelle: Seite 1000
beim Lesen: 1600!!!


/*
Diagramm.. sehr gut um Datentypen, Referenzen, PK-FK,zu beobachten

PKs, dann auch Referenzen
datetime beim GebTag??
varchar bei flexiblen L�ngen !
---
Was ist besser:
Sichten , Prozeduren , F() oder adhoc Abfrage


Sicht:
= eine Abfrage
keine Daten

Performance:
egal.. gleich schnell wie adhoc

Anwendungsgebiet:
komplexe abfragen vereinfachen
wiedervendbar
Security
werden wie Tabellen behandelt


nie mit Select *
am besten immer mit schemabinding


--Prozeduren
wie batch
Performance: i.d.R schneller
nie benutzerfreundlich !
--der Plan wird zu Beginn erstellt .. der erste Prameter entschiedet also �ber den Plan...!

F()
sind fast immer schei****
nur die Tabelleinlinef()
verwenden nur eine CPU
machen fast immer einen SCAN
f() im Where um eine Spalte  where f(spa) = 10 !!!!! GRRRRR.. schlechte Idee


Trigger k�nnen massiv Datentransfer ausl�sen..

Inserted und Deleted Tabellen f�r die Daten, die entweder INS, UP, DEL werden














--