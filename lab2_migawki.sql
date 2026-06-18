-- Zadania - MIGAWKI FAST:

-- Zadanie 1:
	-- Siedziba, baza 11a
CREATE MATERIALIZED VIEW LOG ON kursanci
WITH PRIMARY KEY;

	-- Filia, baza 11b
CREATE DATABASE LINK dblinkSiedziba
CONNECT TO student
IDENTIFIED BY start123
USING '(DESCRIPTION=
  (ADDRESS=(PROTOCOL=TCP)(HOST=192.168.0.12)(PORT=1521))
  (CONNECT_DATA=(SERVICE_NAME=baza11a))
)';

CREATE MATERIALIZED VIEW kursanci_rep
REFRESH FAST ON DEMAND
AS
SELECT *
FROM kursanci@dblinkSiedziba;


---------------------------------------------------------------------------------------------------------

-- Zadanie 2:
	-- Siedziba, baza 11a
CREATE MATERIALIZED VIEW rep_kursanci_lokalni
REFRESH FAST ON COMMIT
AS
SELECT *
FROM kursanci;


---------------------------------------------------------------------------------------------------------

-- Zadanie 3:
	-- Siedziba, baza 11a
CREATE MATERIALIZED VIEW rep_przychody_kursow
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT laczny_przychod,
       laczny_przychod * 0.19 AS podatek_19
FROM (
  SELECT SUM(przychod) AS laczny_przychod
  FROM (
    SELECT COUNT(u.umowa_id) * r.cena AS przychod
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r
      ON k.rodzaj_id = r.rodzaj_id
    LEFT JOIN umowy u
      ON k.kurs_id = u.kurs_id
    GROUP BY k.kurs_id, r.cena

    UNION ALL

    SELECT COUNT(u.umowa_id) * r.cena AS przychod
    FROM kursyFilia k
    JOIN rodzajeFilia r
      ON k.rodzaj_id = r.rodzaj_id
    LEFT JOIN umowy u
      ON k.kurs_id = u.kurs_id
    GROUP BY k.kurs_id, r.cena
  )
);


---------------------------------------------------------------------------------------------------------

-- Zadanie 4
	-- Siedziba, baza 11a
		-- Jednorazowo uruchomic jako STUDENT:
		-- @?/rdbms/admin/utlxmv.sql

DELETE FROM mv_capabilities_table;

EXEC DBMS_MVIEW.EXPLAIN_MVIEW('REP_PRZYCHODY_KURSOW');

SELECT capability_name,
       possible,
       msgtxt
FROM mv_capabilities_table
WHERE capability_name LIKE 'REFRESH_FAST%'
ORDER BY seq;

-- Zadania - MIGAWKI COMPLETE:

-- Zadanie 1:
	-- Siedziba, baza 11a
CREATE MATERIALIZED VIEW rep_wykladowcy
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT *
FROM wykladowcy@dblinkFilia;


---------------------------------------------------------------------------------------------------------

-- Zadanie 2:
	-- Filia, baza 11b
INSERT INTO wykladowcy (wykladowca_id, imie, nazwisko, stawka)
VALUES (9999, 'NOWY', 'WYKLADOWCA', 110);

COMMIT;


---------------------------------------------------------------------------------------------------------

-- Zadanie 3:
	-- Siedziba, baza 11a
SELECT *
FROM rep_wykladowcy;


---------------------------------------------------------------------------------------------------------

-- Zadanie 4:
	-- Siedziba, baza 11a
BEGIN
  DBMS_MVIEW.REFRESH(
    'REP_WYKLADOWCY',
    'C'
  );
END;
/


---------------------------------------------------------------------------------------------------------

-- Zadanie 5:
	-- Siedziba, baza 11a
SELECT *
FROM rep_wykladowcy;


---------------------------------------------------------------------------------------------------------

-- Zadanie 6:
	-- Siedziba, baza 11a
CREATE MATERIALIZED VIEW rep_godz_wykladowcy_godziny
BUILD DEFERRED
REFRESH COMPLETE ON DEMAND
START WITH LAST_DAY(SYSDATE)
NEXT SYSDATE + 1/24
AS
SELECT w.imie,
       w.nazwisko,
       SUM(r.godz) AS laczna_liczba_godzin
FROM wykladowcy@dblinkFilia w
JOIN kursy@dblinkFilia k
  ON w.wykladowca_id = k.wykladowca_id
JOIN rodzaje@dblinkFilia r
  ON k.rodzaj_id = r.rodzaj_id
GROUP BY w.wykladowca_id, w.imie, w.nazwisko;


---------------------------------------------------------------------------------------------------------

-- Zadanie 7:
	-- Siedziba, baza 11a
CREATE MATERIALIZED VIEW rep_kursy
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
START WITH SYSDATE
NEXT SYSDATE + 7
AS
SELECT r.nazwa AS nazwa_kursu,
       w.imie || ' ' || w.nazwisko AS prowadzacy,
       r.godz AS liczba_godzin,
       r.cena AS oplata
FROM kursy@dblinkFilia k
JOIN rodzaje@dblinkFilia r
  ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcy@dblinkFilia w
  ON k.wykladowca_id = w.wykladowca_id;


---------------------------------------------------------------------------------------------------------

-- Zadanie 8:
	-- Siedziba, baza 11a
CREATE OR REPLACE VIEW wszystkie_kursy AS
SELECT r.nazwa AS nazwa_kursu,
       w.imie || ' ' || w.nazwisko AS prowadzacy,
       r.godz AS liczba_godzin,
       r.cena AS oplata,
       'SIEDZIBA' AS lokalizacja
FROM kursy k
JOIN rodzaje r
  ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcy w
  ON k.wykladowca_id = w.wykladowca_id

UNION ALL

SELECT nazwa_kursu,
       prowadzacy,
       liczba_godzin,
       oplata,
       'FILIA' AS lokalizacja
FROM rep_kursy;


---------------------------------------------------------------------------------------------------------

-- Zadanie 9:
	-- Siedziba, baza 11a
SELECT mview_name,
       refresh_mode,
       refresh_method,
       last_refresh_date
FROM user_mviews
ORDER BY mview_name;
