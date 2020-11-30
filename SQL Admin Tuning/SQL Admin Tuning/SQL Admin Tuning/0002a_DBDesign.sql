--DB Design

--Normalisierung ist ok.. aber Redundanz ist schnell
--#tabellen sind Redundanz, 
--zusätzlich Spalten wie Rechnugssumme.. aber wie pflegen ? Trigger ..schlechte performance

--auschlaggeben ist allerdings auch das Verhalten beim Speichern von Daten in den Datendateien
--siehe Seiten und Blöcke

--Prüfe im Diagram ob alle PK auf eine Beziehung zu anderen Tabellen (FK) haben

--Sind die Datentypen apssend?


--Beim Erstellen einer DB: Initialgrößen der Dateien anpassen.. wie groß in 3 Jahren
--Wachstumsraten festlegen: selten aber nicht aufwendig? 1000 MB zB

--Überlegungen:
--Wiederherstellungsmodell wähen.. Voll ...auf Sek restoren
			--.....                  massenprotkolliert
			-- Einfach .. Testumgebungen etwa

--Zeilenversionierung.. aber Achtung-- Traffic auf tempdb.. Vermeidung von Sperren


--ab SQL 2019 Accelerated Data recovery
ALTER DATABASE [DB] SET ACCELERATED_DATABASE_RECOVERY = {ON | OFF}