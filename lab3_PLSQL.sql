SET SERVEROUTPUT ON;

-- Zadanie 1:
	-- Siedziba, baza 11a
DECLARE
  v_kursanci NUMBER;
  v_kursy NUMBER;
  v_wykladowcy NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_kursanci FROM kursanci;
  SELECT COUNT(*) INTO v_kursy FROM kursy;
  SELECT COUNT(*) INTO v_wykladowcy FROM wykladowcy;

  DBMS_OUTPUT.PUT_LINE('Liczba kursantow: ' || v_kursanci);
  DBMS_OUTPUT.PUT_LINE('Liczba kursow: ' || v_kursy);
  DBMS_OUTPUT.PUT_LINE('Liczba wykladowcow: ' || v_wykladowcy);
END;
/


---------------------------------------------------------------------------------------------------------

-- Zadanie 2:
	-- Siedziba, baza 11a
DECLARE
  v_suma NUMBER;
BEGIN
  SELECT SUM(r.cena)
  INTO v_suma
  FROM umowy u
  JOIN kursy k
    ON u.kurs_id = k.kurs_id
  JOIN rodzaje r
    ON k.rodzaj_id = r.rodzaj_id
  WHERE u.miasto = 'BYDGOSZCZ';

  DBMS_OUTPUT.PUT_LINE('Laczna wartosc umow dla BYDGOSZCZY: ' || v_suma || ' zl');
END;
/


---------------------------------------------------------------------------------------------------------

-- Zadanie 3:
	-- Siedziba, baza 11a
DECLARE
  v_miasto VARCHAR2(30);
  v_liczba NUMBER;
BEGIN
  v_miasto := 'BYDGOSZCZ';

  SELECT COUNT(*)
  INTO v_liczba
  FROM umowy
  WHERE miasto = v_miasto;

  IF v_liczba = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Brak umow dla miasta');
  ELSIF v_liczba < 50 THEN
    DBMS_OUTPUT.PUT_LINE('Mala liczba umow');
  ELSIF v_liczba <= 100 THEN
    DBMS_OUTPUT.PUT_LINE('Srednia liczba umow');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Duza liczba umow');
  END IF;
END;
/


---------------------------------------------------------------------------------------------------------

-- Zadanie 4:
	-- Siedziba, baza 11a
BEGIN
  FOR r IN (
    SELECT k.kurs_id,
           ro.nazwa,
           ro.godz,
           ro.cena,
           w.imie || ' ' || w.nazwisko AS prowadzacy
    FROM kursy k
    JOIN rodzaje ro
      ON k.rodzaj_id = ro.rodzaj_id
    JOIN wykladowcy w
      ON k.wykladowca_id = w.wykladowca_id
  ) LOOP
    DBMS_OUTPUT.PUT_LINE(
      'Kurs ' || r.kurs_id || ': ' || r.nazwa || ', ' ||
      r.godz || 'h, ' || r.cena || ' zl, prowadzacy: ' || r.prowadzacy
    );
  END LOOP;
END;
/


---------------------------------------------------------------------------------------------------------

-- Zadanie 5:
	-- Siedziba, baza 11a
CREATE OR REPLACE PROCEDURE raport_umow_miasto(p_miasto IN VARCHAR2)
AS
  v_liczba NUMBER;
  v_suma NUMBER;
  v_srednia NUMBER;
BEGIN
  SELECT COUNT(*), SUM(r.cena), AVG(r.cena)
  INTO v_liczba, v_suma, v_srednia
  FROM umowy u
  JOIN kursy k
    ON u.kurs_id = k.kurs_id
  JOIN rodzaje r
    ON k.rodzaj_id = r.rodzaj_id
  WHERE u.miasto = p_miasto;

  DBMS_OUTPUT.PUT_LINE('Raport dla miasta: ' || p_miasto);
  DBMS_OUTPUT.PUT_LINE('Liczba umow: ' || v_liczba);
  DBMS_OUTPUT.PUT_LINE('Laczna wartosc umow: ' || v_suma || ' zl');
  DBMS_OUTPUT.PUT_LINE('Srednia wartosc umowy: ' || ROUND(v_srednia, 2) || ' zl');
END;
/

BEGIN
  raport_umow_miasto('BYDGOSZCZ');
END;
/


---------------------------------------------------------------------------------------------------------

-- Zadanie 6:
	-- Siedziba, baza 11a
CREATE OR REPLACE FUNCTION wartosc_kursu(p_kurs_id IN NUMBER)
RETURN NUMBER
AS
  v_cena NUMBER;
BEGIN
  SELECT r.cena
  INTO v_cena
  FROM kursy k
  JOIN rodzaje r
    ON k.rodzaj_id = r.rodzaj_id
  WHERE k.kurs_id = p_kurs_id;

  RETURN v_cena;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END;
/

DECLARE
  v_cena NUMBER;
BEGIN
  v_cena := wartosc_kursu(1);
  DBMS_OUTPUT.PUT_LINE('Cena kursu: ' || v_cena);
END;
/


---------------------------------------------------------------------------------------------------------

-- Zadanie 7:
	-- Siedziba, baza 11a
CREATE OR REPLACE PROCEDURE pokaz_kursanta(p_kursant_id IN NUMBER)
AS
  v_imie kursanci.imie%TYPE;
  v_nazwisko kursanci.nazwisko%TYPE;
BEGIN
  SELECT imie, nazwisko
  INTO v_imie, v_nazwisko
  FROM kursanci
  WHERE kursant_id = p_kursant_id;

  DBMS_OUTPUT.PUT_LINE(v_imie || ' ' || v_nazwisko);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono kursanta o ID: ' || p_kursant_id);
END;
/

BEGIN
  pokaz_kursanta(1);
END;
/


---------------------------------------------------------------------------------------------------------

-- Zadanie 8:
	-- Siedziba, baza 11a
DECLARE
  CURSOR c_umowy IS
    SELECT u.umowa_id,
           k.imie || ' ' || k.nazwisko AS kursant,
           r.nazwa AS kurs,
           r.cena
    FROM umowy u
    JOIN kursanci k
      ON u.kursant_id = k.kursant_id
    JOIN kursy ks
      ON u.kurs_id = ks.kurs_id
    JOIN rodzaje r
      ON ks.rodzaj_id = r.rodzaj_id
    WHERE u.miasto = 'BYDGOSZCZ';

  v_wiersz c_umowy%ROWTYPE;
BEGIN
  OPEN c_umowy;

  LOOP
    FETCH c_umowy INTO v_wiersz;
    EXIT WHEN c_umowy%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE(
      'Umowa ' || v_wiersz.umowa_id || ' | ' || v_wiersz.kursant ||
      ' | ' || v_wiersz.kurs || ' | ' || v_wiersz.cena || ' zl'
    );
  END LOOP;

  CLOSE c_umowy;
END;
/


---------------------------------------------------------------------------------------------------------

-- Zadanie 9:
	-- Siedziba, baza 11a
CREATE OR REPLACE PROCEDURE raport_umow_szczecin
AS
BEGIN
  FOR r IN (
    SELECT u.umowa_id,
           k.imie || ' ' || k.nazwisko AS kursant,
           ro.nazwa AS kurs,
           ro.cena,
           u.miasto
    FROM umowy u
    JOIN kursanciFilia k
      ON u.kursant_id = k.kursant_id
    JOIN kursyFilia ks
      ON u.kurs_id = ks.kurs_id
    JOIN rodzajeFilia ro
      ON ks.rodzaj_id = ro.rodzaj_id
    WHERE u.miasto = 'SZCZECIN'
  ) LOOP
    DBMS_OUTPUT.PUT_LINE(
      'Umowa ' || r.umowa_id || ' | ' || r.kursant ||
      ' | ' || r.kurs || ' | ' || r.cena || ' zl | ' || r.miasto
    );
  END LOOP;
END;
/

BEGIN
  raport_umow_szczecin;
END;
/


---------------------------------------------------------------------------------------------------------

-- Zadanie 10:
	-- Siedziba, baza 11a
CREATE OR REPLACE PROCEDURE raport_uczelni
AS
  v_b_liczba NUMBER;
  v_b_suma NUMBER;
  v_b_najdrozszy VARCHAR2(30);
  v_b_najpopularniejszy VARCHAR2(30);

  v_s_liczba NUMBER;
  v_s_suma NUMBER;
  v_s_najdrozszy VARCHAR2(30);
  v_s_najpopularniejszy VARCHAR2(30);
BEGIN
  SELECT COUNT(*), SUM(r.cena)
  INTO v_b_liczba, v_b_suma
  FROM umowy u
  JOIN kursy k
    ON u.kurs_id = k.kurs_id
  JOIN rodzaje r
    ON k.rodzaj_id = r.rodzaj_id
  WHERE u.miasto = 'BYDGOSZCZ';

  SELECT nazwa
  INTO v_b_najdrozszy
  FROM (
    SELECT r.nazwa
    FROM umowy u
    JOIN kursy k
      ON u.kurs_id = k.kurs_id
    JOIN rodzaje r
      ON k.rodzaj_id = r.rodzaj_id
    WHERE u.miasto = 'BYDGOSZCZ'
    ORDER BY r.cena DESC
  )
  WHERE ROWNUM = 1;

  SELECT nazwa
  INTO v_b_najpopularniejszy
  FROM (
    SELECT r.nazwa
    FROM umowy u
    JOIN kursy k
      ON u.kurs_id = k.kurs_id
    JOIN rodzaje r
      ON k.rodzaj_id = r.rodzaj_id
    WHERE u.miasto = 'BYDGOSZCZ'
    GROUP BY r.nazwa
    ORDER BY COUNT(*) DESC
  )
  WHERE ROWNUM = 1;

  SELECT COUNT(*), SUM(r.cena)
  INTO v_s_liczba, v_s_suma
  FROM umowy u
  JOIN kursyFilia k
    ON u.kurs_id = k.kurs_id
  JOIN rodzajeFilia r
    ON k.rodzaj_id = r.rodzaj_id
  WHERE u.miasto = 'SZCZECIN';

  SELECT nazwa
  INTO v_s_najdrozszy
  FROM (
    SELECT r.nazwa
    FROM umowy u
    JOIN kursyFilia k
      ON u.kurs_id = k.kurs_id
    JOIN rodzajeFilia r
      ON k.rodzaj_id = r.rodzaj_id
    WHERE u.miasto = 'SZCZECIN'
    ORDER BY r.cena DESC
  )
  WHERE ROWNUM = 1;

  SELECT nazwa
  INTO v_s_najpopularniejszy
  FROM (
    SELECT r.nazwa
    FROM umowy u
    JOIN kursyFilia k
      ON u.kurs_id = k.kurs_id
    JOIN rodzajeFilia r
      ON k.rodzaj_id = r.rodzaj_id
    WHERE u.miasto = 'SZCZECIN'
    GROUP BY r.nazwa
    ORDER BY COUNT(*) DESC
  )
  WHERE ROWNUM = 1;

  DBMS_OUTPUT.PUT_LINE('RAPORT UCZELNI');
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Miasto: BYDGOSZCZ');
  DBMS_OUTPUT.PUT_LINE('Liczba umow: ' || v_b_liczba);
  DBMS_OUTPUT.PUT_LINE('Laczna wartosc umow: ' || v_b_suma || ' zl');
  DBMS_OUTPUT.PUT_LINE('Najdrozszy kurs: ' || v_b_najdrozszy);
  DBMS_OUTPUT.PUT_LINE('Najpopularniejszy kurs: ' || v_b_najpopularniejszy);
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Miasto: SZCZECIN');
  DBMS_OUTPUT.PUT_LINE('Liczba umow: ' || v_s_liczba);
  DBMS_OUTPUT.PUT_LINE('Laczna wartosc umow: ' || v_s_suma || ' zl');
  DBMS_OUTPUT.PUT_LINE('Najdrozszy kurs: ' || v_s_najdrozszy);
  DBMS_OUTPUT.PUT_LINE('Najpopularniejszy kurs: ' || v_s_najpopularniejszy);
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('PODSUMOWANIE');
  DBMS_OUTPUT.PUT_LINE('Liczba wszystkich umow: ' || (v_b_liczba + v_s_liczba));
  DBMS_OUTPUT.PUT_LINE('Laczna wartosc wszystkich umow: ' || (v_b_suma + v_s_suma) || ' zl');
END;
/

BEGIN
  raport_uczelni;
END;
/
