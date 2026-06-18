-- Zadanie 3: 
CREATE DATABASE LINK dblinkFilia 
CONNECT TO student
IDENTIFIED BY start123 
USING 
'(DESCRIPTION= 
  (ADDRESS=(PROTOCOL=TCP)(HOST=192.168.0.12)(PORT=1521))
  (CONNECT_DATA=(SERVICE_NAME=baza11b))  
)';

---------------------------------------------------------------------------------------------------------

-- ZADANIE 4:
SELECT * FROM kursanci@dblinkFilia;

---------------------------------------------------------------------------------------------------------

-- Zadanie 5:
CREATE OR REPLACE SYNONYM kursanciSiedziba FOR kursanci;
CREATE OR REPLACE SYNONYM wykladowcySiedziba FOR wykladowcy;
CREATE OR REPLACE SYNONYM rodzajeSiedziba FOR rodzaje;
CREATE OR REPLACE SYNONYM kursySiedziba FOR kursy;
CREATE OR REPLACE SYNONYM kursanciFilia FOR kursanci@dblinkFilia;
CREATE OR REPLACE SYNONYM wykladowcyFilia FOR wykladowcy@dblinkFilia;
CREATE OR REPLACE SYNONYM rodzajeFilia FOR rodzaje@dblinkFilia;
CREATE OR REPLACE SYNONYM kursyFilia FOR kursy@dblinkFilia;

---------------------------------------------------------------------------------------------------------

-- Zadanie 6:

CREATE OR REPLACE VIEW kursanciAll AS
SELECT imie, nazwisko 
FROM kursanciSiedziba 
UNION 
SELECT imie, nazwisko 
FROM kursanciFilia;

CREATE OR REPLACE VIEW wykladowcyAll AS
SELECT imie, nazwisko
FROM wykladowcySiedziba
UNION
SELECT imie, nazwisko
FROM wykladowcyFilia;

---------------------------------------------------------------------------------------------------------

-- Zadanie 7: 
CREATE OR REPLACE VIEW kursyAll AS
SELECT k.kurs_id,
       r.nazwa,
       w.imie || ' ' || w.nazwisko AS prowadzacy,
       COUNT(u.umowa_id) AS liczba_uczestnikow
FROM kursySiedziba k
JOIN rodzajeSiedziba r
  ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcySiedziba w
  ON k.wykladowca_id = w.wykladowca_id
LEFT JOIN umowy u
  ON k.kurs_id = u.kurs_id
GROUP BY k.kurs_id, r.nazwa, w.imie, w.nazwisko

UNION ALL

SELECT k.kurs_id,
       r.nazwa,
       w.imie || ' ' || w.nazwisko AS prowadzacy,
       COUNT(u.umowa_id) AS liczba_uczestnikow
FROM kursyFilia k
JOIN rodzajeFilia r
  ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcyFilia w
  ON k.wykladowca_id = w.wykladowca_id
LEFT JOIN umowy u
  ON k.kurs_id = u.kurs_id
GROUP BY k.kurs_id, r.nazwa, w.imie, w.nazwisko;

---------------------------------------------------------------------------------------------------------

-- zadanie 8:
SELECT SUM(przychod) AS laczny_przychod
FROM (
SELECT r.nazwa,
       COUNT(u.umowa_id) AS liczba_uczestnikow,
       r.cena,
       COUNT(u.umowa_id) * r.cena AS przychod
FROM kursySiedziba k
JOIN rodzajeSiedziba r
  ON k.rodzaj_id = r.rodzaj_id
LEFT JOIN umowy u
  ON k.kurs_id = u.kurs_id
GROUP BY k.kurs_id, r.nazwa, r.cena

UNION ALL

SELECT r.nazwa,
       COUNT(u.umowa_id) AS liczba_uczestnikow,
       r.cena,
       COUNT(u.umowa_id) * r.cena AS przychod
FROM kursyFilia k
JOIN rodzajeFilia r
  ON k.rodzaj_id = r.rodzaj_id
LEFT JOIN umowy u
  ON k.kurs_id = u.kurs_id
GROUP BY k.kurs_id, r.nazwa, r.cena
);

---------------------------------------------------------------------------------------------------------

-- Zadanie 9:
SELECT SUM(koszt) AS laczne_koszty
FROM (
SELECT r.nazwa,
       r.godz,
       w.stawka,
       r.godz * w.stawka AS koszt
FROM kursySiedziba k
JOIN rodzajeSiedziba r
  ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcySiedziba w
  ON k.wykladowca_id = w.wykladowca_id
  
UNION ALL

SELECT r.nazwa,
       r.godz,
       w.stawka,
       r.godz * w.stawka AS koszt
FROM kursyFilia k
JOIN rodzajeFilia r
  ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcyFilia w
  ON k.wykladowca_id = w.wykladowca_id
);

---------------------------------------------------------------------------------------------------------

-- Zadanie 10:
SELECT k.kurs_id,
       r.nazwa,
       COUNT(u.umowa_id) * r.cena AS przychod,
       r.godz * w.stawka AS koszt,
       COUNT(u.umowa_id) * r.cena - r.godz * w.stawka AS zysk
FROM kursySiedziba k
JOIN rodzajeSiedziba r
  ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcySiedziba w
  ON k.wykladowca_id = w.wykladowca_id
LEFT JOIN umowy u
  ON k.kurs_id = u.kurs_id
GROUP BY k.kurs_id, r.nazwa, r.cena, r.godz, w.stawka

UNION ALL

SELECT k.kurs_id,
       r.nazwa,
       COUNT(u.umowa_id) * r.cena AS przychod,
       r.godz * w.stawka AS koszt,
       COUNT(u.umowa_id) * r.cena - r.godz * w.stawka AS zysk
FROM kursyFilia k
JOIN rodzajeFilia r
  ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcyFilia w
  ON k.wykladowca_id = w.wykladowca_id
LEFT JOIN umowy u
  ON k.kurs_id = u.kurs_id
GROUP BY k.kurs_id, r.nazwa, r.cena, r.godz, w.stawka;

---------------------------------------------------------------------------------------------------------

-- Zadanie 11:
SELECT SUM(zysk) AS laczny_zysk
FROM (
SELECT k.kurs_id,
       r.nazwa,
       COUNT(u.umowa_id) * r.cena AS przychod,
       r.godz * w.stawka AS koszt,
       COUNT(u.umowa_id) * r.cena - r.godz * w.stawka AS zysk
FROM kursySiedziba k
JOIN rodzajeSiedziba r
  ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcySiedziba w
  ON k.wykladowca_id = w.wykladowca_id
LEFT JOIN umowy u
  ON k.kurs_id = u.kurs_id
GROUP BY k.kurs_id, r.nazwa, r.cena, r.godz, w.stawka

UNION ALL

SELECT k.kurs_id,
       r.nazwa,
       COUNT(u.umowa_id) * r.cena AS przychod,
       r.godz * w.stawka AS koszt,
       COUNT(u.umowa_id) * r.cena - r.godz * w.stawka AS zysk
FROM kursyFilia k
JOIN rodzajeFilia r
  ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcyFilia w
  ON k.wykladowca_id = w.wykladowca_id
LEFT JOIN umowy u
  ON k.kurs_id = u.kurs_id
GROUP BY k.kurs_id, r.nazwa, r.cena, r.godz, w.stawka
);
