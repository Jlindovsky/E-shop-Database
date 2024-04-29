DROP TABLE CART CASCADE CONSTRAINTS;

DROP TABLE ITEM CASCADE CONSTRAINTS;

DROP TABLE ACCOUNT CASCADE CONSTRAINTS;

DROP TABLE CLIENT CASCADE CONSTRAINTS;

DROP TABLE EMPLOYEE CASCADE CONSTRAINTS;

DROP TABLE ORDERTABLE CASCADE CONSTRAINTS;

DROP TABLE CATEGORY CASCADE CONSTRAINTS;

--Tabulka Ucet
--Generalizaci jsme vyřešili způsobem přídání role
--ACCOUNT čímž jsme dosáhli specializace/generalizace.
CREATE TABLE ACCOUNT (
  ACCOUNTID INT GENERATED BY DEFAULT ON NULL AS IDENTITY,
  USERNAME VARCHAR(255) NOT NULL,
  PASSWORD VARCHAR(255) NOT NULL,
  NAME VARCHAR(255) NOT NULL,
  EMAIL VARCHAR(255) NOT NULL CHECK (REGEXP_LIKE(EMAIL, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')),
  PHONE VARCHAR(20) NOT NULL
);

-- Tabulka Položka
CREATE TABLE ITEM (
  ITEMID INT GENERATED BY DEFAULT ON NULL AS IDENTITY,
  CATEGORYID INT,
  NAME VARCHAR(255) NOT NULL,
  DESCRIPTION VARCHAR(1000) NOT NULL,
  PRICE INT NOT NULL,
  IMAGE VARCHAR(255) NOT NULL CHECK (REGEXP_LIKE(IMAGE, '^[a-zA-Z0-9_-]+\.(jpg|jpeg|png|gif)$')),
  INSTOCK INT NOT NULL
);

-- Tabulka Košík
CREATE TABLE CART (
  ACCOUNTID INT,
  CARTID INT GENERATED BY DEFAULT ON NULL AS IDENTITY,
  ITEMID1 INT DEFAULT NULL,
  ITEMID2 INT DEFAULT NULL,
  ITEMID3 INT DEFAULT NULL,
  ITEMID4 INT DEFAULT NULL,
  ITEMID5 INT DEFAULT NULL,
  ITEMID6 INT DEFAULT NULL,
  ITEMID7 INT DEFAULT NULL,
  ITEMID8 INT DEFAULT NULL,
  ITEMID9 INT DEFAULT NULL,
  ITEMID10 INT DEFAULT NULL
);

-- Tabulka Kategorie
CREATE TABLE CATEGORY (
 -- ITEMID INT,
  CATEGORYID INT GENERATED BY DEFAULT ON NULL AS IDENTITY,
  NAME VARCHAR(255) NOT NULL,
  DESCRIPTION VARCHAR(1000) NOT NULL
);

-- Tabulka Uživatel
CREATE TABLE CLIENT (
  ACCOUNTID INT,
  STREET VARCHAR(255) NOT NULL,
  CITY VARCHAR(255) NOT NULL,
  PCS VARCHAR(10) NOT NULL CHECK (REGEXP_LIKE(PCS, '^\d{5}$')),
  FIRM VARCHAR(255) NOT NULL,
  ICO VARCHAR(255) NOT NULL CHECK (REGEXP_LIKE(ICO, '^\d{8}$'))
);

-- Tabulka Zaměstnanec
CREATE TABLE EMPLOYEE (
  ACCOUNTID INT,
  POSITION VARCHAR(255) NOT NULL
);

-- Tabulka Objednávka
CREATE TABLE ORDERTABLE (
  ACCOUNTID INT,
  CARTID INT,
  ORDERID INT GENERATED BY DEFAULT ON NULL AS IDENTITY,
  PRICE INT NOT NULL,
  PAYED INT CHECK (PAYED IN (0, 1)),
  DISPATCHED INT CHECK (DISPATCHED IN (0, 1)),
  DISPATCHEDBY INT
);

-- grant acces to xhlase01
GRANT CREATE SESSION TO XHLASE01;

GRANT SELECT, INSERT, UPDATE ON ORDERTABLE TO XHLASE01;

-- materialized view of price of order and name of account
CREATE MATERIALIZED VIEW ORDER_PRICE_MV AS
  SELECT
    OT.PRICE,
    A.NAME
  FROM
    ORDERTABLE OT
    JOIN ACCOUNT A
    ON OT.ACCOUNTID = A.ACCOUNTID;

-- average price or order from materialized view
SELECT
  AVG(PRICE)
FROM
  ORDER_PRICE_MV;

ALTER TABLE ACCOUNT ADD CONSTRAINT PK_ACCOUNT PRIMARY KEY (ACCOUNTID);

ALTER TABLE CLIENT ADD CONSTRAINT PK_CLIENT PRIMARY KEY (ACCOUNTID);

ALTER TABLE EMPLOYEE ADD CONSTRAINT PK_EMPLOYEE PRIMARY KEY (ACCOUNTID);

ALTER TABLE CART ADD CONSTRAINT PK_CART PRIMARY KEY (CARTID);

ALTER TABLE ITEM ADD CONSTRAINT PK_ITEM PRIMARY KEY (ITEMID);

ALTER TABLE CATEGORY ADD CONSTRAINT PK_CATEGORY PRIMARY KEY (CATEGORYID);

ALTER TABLE ORDERTABLE ADD CONSTRAINT PK_ORDER PRIMARY KEY (ORDERID);

ALTER TABLE ITEM ADD CONSTRAINT FK_CATEGORYID FOREIGN KEY (CATEGORYID) REFERENCES CATEGORY;

-- ALTER TABLE CATEGORY ADD CONSTRAINT FK_ITEMID_CATEGORY FOREIGN KEY (ITEMID) REFERENCES ITEM;

ALTER TABLE CART ADD CONSTRAINT FK_ITEMID_CART1 FOREIGN KEY (ITEMID1) REFERENCES ITEM;

ALTER TABLE CART ADD CONSTRAINT FK_ITEMID_CART2 FOREIGN KEY (ITEMID2) REFERENCES ITEM;

ALTER TABLE CART ADD CONSTRAINT FK_ITEMID_CART3 FOREIGN KEY (ITEMID3) REFERENCES ITEM;

ALTER TABLE CART ADD CONSTRAINT FK_ITEMID_CART4 FOREIGN KEY (ITEMID4) REFERENCES ITEM;

ALTER TABLE CART ADD CONSTRAINT FK_ITEMID_CART5 FOREIGN KEY (ITEMID5) REFERENCES ITEM;

ALTER TABLE CART ADD CONSTRAINT FK_ITEMID_CART6 FOREIGN KEY (ITEMID6) REFERENCES ITEM;

ALTER TABLE CART ADD CONSTRAINT FK_ITEMID_CART7 FOREIGN KEY (ITEMID7) REFERENCES ITEM;

ALTER TABLE CART ADD CONSTRAINT FK_ITEMID_CART8 FOREIGN KEY (ITEMID8) REFERENCES ITEM;

ALTER TABLE CART ADD CONSTRAINT FK_ITEMID_CART9 FOREIGN KEY (ITEMID9) REFERENCES ITEM;

ALTER TABLE CART ADD CONSTRAINT FK_ITEMID_CART10 FOREIGN KEY (ITEMID10) REFERENCES ITEM;

ALTER TABLE CART ADD CONSTRAINT FK_ACCOUNTID_CART FOREIGN KEY (ACCOUNTID) REFERENCES ACCOUNT ON DELETE CASCADE;

ALTER TABLE CLIENT ADD CONSTRAINT FK_ACCOUNTID_CLIENT FOREIGN KEY (ACCOUNTID) REFERENCES ACCOUNT ON DELETE CASCADE;

ALTER TABLE EMPLOYEE ADD CONSTRAINT FK_ACCOUNTID_EMPLOYEE FOREIGN KEY (ACCOUNTID) REFERENCES ACCOUNT ON DELETE CASCADE;

ALTER TABLE ORDERTABLE ADD CONSTRAINT FK_ACCOUNTID FOREIGN KEY (ACCOUNTID) REFERENCES CLIENT;

ALTER TABLE ORDERTABLE ADD CONSTRAINT FK_CARTID FOREIGN KEY (CARTID) REFERENCES CART;

ALTER TABLE ORDERTABLE ADD CONSTRAINT FK_DISPATCHEDBY FOREIGN KEY (DISPATCHEDBY) REFERENCES EMPLOYEE(ACCOUNTID);

--trigger pro slevu 5% při objednávce na 400
CREATE OR REPLACE TRIGGER PRICE_ADJUSTMENT_TRIGGER BEFORE
  INSERT ON ORDERTABLE FOR EACH ROW
BEGIN
  IF :NEW.PRICE > 400 THEN
    :NEW.PRICE := :NEW.PRICE * 0.95;
  END IF;
END;
/

-- trigger pro snížení počtu itemů ve stocku při vztvoření objednávky
CREATE OR REPLACE TRIGGER UPDATE_QUANTITY BEFORE
  INSERT ON ORDERTABLE FOR EACH ROW
DECLARE
  V_ITEM_ID ITEM.ITEMID%TYPE;
BEGIN
  FOR I IN 1..10 LOOP
    SELECT
      CASE I
        WHEN 1 THEN
          ITEMID1
        WHEN 2 THEN
          ITEMID2
        WHEN 3 THEN
          ITEMID3
        WHEN 4 THEN
          ITEMID4
        WHEN 5 THEN
          ITEMID5
        WHEN 6 THEN
          ITEMID6
        WHEN 7 THEN
          ITEMID7
        WHEN 8 THEN
          ITEMID8
        WHEN 9 THEN
          ITEMID9
        WHEN 10 THEN
          ITEMID10
      END INTO V_ITEM_ID
    FROM
      CART
    WHERE
      CART.CARTID = :NEW.CARTID;
    IF V_ITEM_ID IS NOT NULL THEN
      UPDATE ITEM
      SET
        INSTOCK = INSTOCK - 1
      WHERE
        ITEMID = V_ITEM_ID;
    END IF;
  END LOOP;
END;
/

-- Ukázková data
INSERT INTO ACCOUNT (
  USERNAME,
  PASSWORD,
  NAME,
  EMAIL,
  PHONE
) VALUES (
  'John',
  'password1',
  'John Doe',
  'john@example.com',
  '123456789'
);

INSERT INTO ACCOUNT (
  USERNAME,
  PASSWORD,
  NAME,
  EMAIL,
  PHONE
) VALUES (
  'Jane',
  'password2',
  'Jane Smith',
  'jane@example.com',
  '987654321'
);

INSERT INTO ACCOUNT (
  USERNAME,
  PASSWORD,
  NAME,
  EMAIL,
  PHONE
) VALUES (
  'admin',
  'admin123',
  'Administrator',
  'admin@example.com',
  '000000000'
);

INSERT INTO ACCOUNT (
  USERNAME,
  PASSWORD,
  NAME,
  EMAIL,
  PHONE
) VALUES (
  'guest',
  'guest123',
  'Guest User',
  'guest@example.com',
  '111111111'
);

INSERT INTO ACCOUNT (
  USERNAME,
  PASSWORD,
  NAME,
  EMAIL,
  PHONE
) VALUES (
  'Michael',
  'password3',
  'Michael Jordan',
  'michael@example.com',
  '555555555'
);

INSERT INTO ACCOUNT (
  USERNAME,
  PASSWORD,
  NAME,
  EMAIL,
  PHONE
) VALUES (
  'LeBron',
  'password4',
  'LeBron James',
  'lebron@example.com',
  '666666666'
);

INSERT INTO ACCOUNT (
  USERNAME,
  PASSWORD,
  NAME,
  EMAIL,
  PHONE
) VALUES (
  'Mark',
  'password7',
  'Mark Twain',
  'mark@example.com',
  '123456788'
);

INSERT INTO ACCOUNT (
  USERNAME,
  PASSWORD,
  NAME,
  EMAIL,
  PHONE
) VALUES (
  'Jan',
  'password8',
  'Jan Lindovsky',
  'jan@example.com',
  '987654311'
);

INSERT INTO ACCOUNT (
  USERNAME,
  PASSWORD,
  NAME,
  EMAIL,
  PHONE
) VALUES (
  'Terka',
  'password9',
  'Tereza Svachova',
  'terka@example.com',
  '000110000'
);

INSERT INTO ACCOUNT (
  USERNAME,
  PASSWORD,
  NAME,
  EMAIL,
  PHONE
) VALUES (
  'Domča',
  'password10',
  'Dominika Červená',
  'domca@example.com',
  '111112211'
);

INSERT INTO ACCOUNT (
  USERNAME,
  PASSWORD,
  NAME,
  EMAIL,
  PHONE
) VALUES (
  'Kuba',
  'password11',
  'Jakub Seďa',
  'kuba@example.com',
  '555555544'
);

INSERT INTO ACCOUNT (
  USERNAME,
  PASSWORD,
  NAME,
  EMAIL,
  PHONE
) VALUES (
  'Harry',
  'WatermelonSugar12',
  'Harry Styles',
  'slaayyy@example.com',
  '666666655'
);

INSERT INTO ACCOUNT (
  USERNAME,
  PASSWORD,
  NAME,
  EMAIL,
  PHONE
) VALUES (
  'Karl',
  'Spifire',
  'Ratatata',
  'sopitfire@example.com',
  '664666655'
);

INSERT INTO CATEGORY (
  NAME,
  DESCRIPTION
) VALUES (
  'Elektro',
  'Počítače, mobily, ...'
);

INSERT INTO CATEGORY (
  NAME,
  DESCRIPTION
) VALUES (
  'Auta',
  'široký výběr doplňků do aut'
);

INSERT INTO CATEGORY (
  NAME,
  DESCRIPTION
) VALUES (
  'Narozeniny',
  'Věci na oslavy narozenin'
);

INSERT INTO CATEGORY (
  NAME,
  DESCRIPTION
) VALUES (
  'Alkohol',
  'široký výběr alkoholu'
);

INSERT INTO ITEM (
  NAME,
  DESCRIPTION,
  PRICE,
  IMAGE,
  CATEGORYID,
  INSTOCK
) VALUES (
  'Dort',
  'Narozeninový dort',
  50,
  'image5.jpg',
  3,
  15
);

INSERT INTO ITEM (
  NAME,
  DESCRIPTION,
  PRICE,
  IMAGE,
  CATEGORYID,
  INSTOCK
) VALUES (
  'Rum',
  'Karibský rum',
  60,
  'image6.jpg',
  4,
  30
);

INSERT INTO ITEM (
  NAME,
  DESCRIPTION,
  PRICE,
  IMAGE,
  CATEGORYID,
  INSTOCK
) VALUES (
  'Iphone 8',
  'Úložiště 64 GB',
  10,
  'image1.jpg',
  1,
  5
);

INSERT INTO ITEM (
  NAME,
  DESCRIPTION,
  PRICE,
  IMAGE,
  CATEGORYID,
  INSTOCK
) VALUES (
  'Auto-lékárnička',
  'Praktická lékarnička do auta',
  20,
  'image2.jpg',
  2,
  2
);

INSERT INTO ITEM (
  NAME,
  DESCRIPTION,
  PRICE,
  IMAGE,
  CATEGORYID,
  INSTOCK
) VALUES (
  'Macbook Air',
  'rok výroby 2019',
  30,
  'image3.jpg',
  1,
  4
);

INSERT INTO ITEM (
  NAME,
  DESCRIPTION,
  PRICE,
  IMAGE,
  CATEGORYID,
  INSTOCK
) VALUES (
  'Osvěžovač vzduchu',
  'K pověšení na zpětné zrcátko',
  40,
  'image4.jpg',
  2,
  20
);

INSERT INTO CLIENT (
  ACCOUNTID,
  STREET,
  CITY,
  PCS,
  FIRM,
  ICO
) VALUES (
  3,
  'Street 3',
  'City 1',
  '13579',
  'Firm 3',
  '24681357'
);

INSERT INTO CLIENT (
  ACCOUNTID,
  STREET,
  CITY,
  PCS,
  FIRM,
  ICO
) VALUES (
  4,
  'Street 4',
  'City 4',
  '24680',
  'Firm 4',
  '35792468'
);

INSERT INTO CLIENT (
  ACCOUNTID,
  STREET,
  CITY,
  PCS,
  FIRM,
  ICO
) VALUES (
  5,
  'Street',
  'City',
  '98765',
  'Firm',
  '87654321'
);

INSERT INTO CLIENT (
  ACCOUNTID,
  STREET,
  CITY,
  PCS,
  FIRM,
  ICO
) VALUES (
  6,
  'Guest Street',
  'Guest City',
  '24680',
  'Guest Firm',
  '09876543'
);

INSERT INTO CLIENT (
  ACCOUNTID,
  STREET,
  CITY,
  PCS,
  FIRM,
  ICO
) VALUES (
  1,
  'Street 1',
  'City 1',
  '12345',
  'Firm 1',
  '12345678'
);

INSERT INTO CLIENT (
  ACCOUNTID,
  STREET,
  CITY,
  PCS,
  FIRM,
  ICO
) VALUES (
  2,
  'Street 2',
  'City 2',
  '54321',
  'Firm 2',
  '34567890'
);

INSERT INTO EMPLOYEE (
  ACCOUNTID,
  POSITION
) VALUES (
  9,
  'Assistant'
);

INSERT INTO EMPLOYEE (
  ACCOUNTID,
  POSITION
) VALUES (
  10,
  'Manager'
);

INSERT INTO EMPLOYEE (
  ACCOUNTID,
  POSITION
) VALUES (
  11,
  'Supervisor'
);

INSERT INTO EMPLOYEE (
  ACCOUNTID,
  POSITION
) VALUES (
  12,
  'Intern'
);

INSERT INTO EMPLOYEE (
  ACCOUNTID,
  POSITION
) VALUES (
  7,
  'Manager'
);

INSERT INTO EMPLOYEE (
  ACCOUNTID,
  POSITION
) VALUES (
  8,
  'Clerk'
);

INSERT INTO CART (
  ACCOUNTID,
  ITEMID1
) VALUES (
  1,
  1
);

INSERT INTO ORDERTABLE (
  PRICE,
  ACCOUNTID,
  PAYED,
  DISPATCHED,
  DISPATCHEDBY,
  CARTID
) VALUES (
  500,
  3,
  1,
  1,
  8,
  1
);

INSERT INTO ORDERTABLE (
  PRICE,
  ACCOUNTID,
  PAYED,
  DISPATCHED,
  DISPATCHEDBY,
  CARTID
) VALUES (
  70,
  3,
  1,
  1,
  7,
  1
);

-- INSERT INTO ORDERTABLE (
--   PRICE,
--   ACCOUNTID,
--   PAYED,
--   DISPATCHED,
--   DISPATCHEDBY
-- ) VALUES (
--   80,
--   4,
--   0,
--   0,
--   8
-- );

-- INSERT INTO ORDERTABLE (
--   PRICE,
--   ACCOUNTID,
--   PAYED,
--   DISPATCHED,
--   DISPATCHEDBY
-- ) VALUES (
--   60,
--   4,
--   0,
--   0,
--   7
-- );

-- INSERT INTO ORDERTABLE (
--   PRICE,
--   ACCOUNTID,
--   PAYED,
--   DISPATCHED
-- ) VALUES (
--   30,
--   1,
--   0,
--   0
-- );

-- INSERT INTO ORDERTABLE (
--   PRICE,
--   ACCOUNTID,
--   PAYED,
--   DISPATCHED
-- ) VALUES (
--   350,
--   2,
--   0,
--   0
-- );

--select of the most prici order
SELECT
  *
FROM
  (
    SELECT
      USERNAME,
      PRICE
    FROM
      ACCOUNT
      NATURAL JOIN ORDERTABLE
    ORDER BY
      PRICE DESC
  )
WHERE
  ROWNUM <= 1;

--user from city 1
SELECT
  EMAIL,
  NAME,
  PHONE,
  CITY
FROM
  ACCOUNT
  NATURAL JOIN CLIENT
WHERE
  CITY = 'City 1';

--EMPLOYEE that DISPATCHED an order
SELECT
  "NAME",
  POSITION,
  EMAIL,
  DISPATCHED
FROM
  EMPLOYEE
  JOIN ACCOUNT
  ON EMPLOYEE.ACCOUNTID = ACCOUNT.ACCOUNTID
  RIGHT JOIN ORDERTABLE
  ON ACCOUNT.ACCOUNTID = ORDERTABLE.DISPATCHEDBY
WHERE
  DISPATCHED = 1;

--Group by POSITION and count people in the position
SELECT
  POSITION,
  COUNT(NAME)AS NUMPOPLE
FROM
  ACCOUNT
  NATURAL JOIN EMPLOYEE
GROUP BY
  POSITION;

--Group by Category and cout items in category
SELECT
  CATEGORY."NAME",
  COUNT(ITEM."NAME")AS NUMITEM
FROM
  ITEM
  JOIN CATEGORY
  ON ITEM.CATEGORYID = CATEGORY.CATEGORYID
GROUP BY
  CATEGORY."NAME";

--Item that exists in Category with name Narozeniny
SELECT
  ITEM."NAME",
  ITEM.PRICE
FROM
  ITEM
WHERE
  EXISTS (
    SELECT
      CATEGORY."NAME"
    FROM
      CATEGORY
    WHERE
      ITEM.CATEGORYID = CATEGORY.CATEGORYID
      AND "NAME" = 'Narozeniny'
  );

--select a CLIENT with all orders above 300
SELECT
  DISTINCT "NAME"
FROM
  CLIENT
  NATURAL JOIN ACCOUNT
  NATURAL JOIN ORDERTABLE
WHERE
  "NAME" NOT IN (
    SELECT
      "NAME"
    FROM
      ORDERTABLE
      NATURAL JOIN ACCOUNT
      NATURAL JOIN CLIENT
    WHERE
      PRICE < 300
  );

---------------------------------4. fáze

-- add item to cart procedure
CREATE OR REPLACE PROCEDURE ADD_ITEM_N_TIMES (
  ITEM_ID NUMBER,
  PIECES NUMBER,
  CART_ID NUMBER
) IS
BEGIN
  FOR I IN 1..PIECES LOOP
    UPDATE CART
    SET
      ITEMID1 = CASE WHEN ITEMID1 IS NULL THEN ITEM_ID ELSE ITEMID1 END,
      ITEMID2 = CASE WHEN ITEMID1 IS NOT NULL
      AND ITEMID2 IS NULL THEN ITEM_ID ELSE ITEMID2 END,
      ITEMID3 = CASE WHEN ITEMID1 IS NOT NULL
      AND ITEMID2 IS NOT NULL
      AND ITEMID3 IS NULL THEN ITEM_ID ELSE ITEMID3 END,
      ITEMID4 = CASE WHEN ITEMID1 IS NOT NULL
      AND ITEMID2 IS NOT NULL
      AND ITEMID3 IS NOT NULL
      AND ITEMID4 IS NULL THEN ITEM_ID ELSE ITEMID4 END,
      ITEMID5 = CASE WHEN ITEMID1 IS NOT NULL
      AND ITEMID2 IS NOT NULL
      AND ITEMID3 IS NOT NULL
      AND ITEMID4 IS NOT NULL
      AND ITEMID5 IS NULL THEN ITEM_ID ELSE ITEMID5 END,
      ITEMID6 = CASE WHEN ITEMID1 IS NOT NULL
      AND ITEMID2 IS NOT NULL
      AND ITEMID3 IS NOT NULL
      AND ITEMID4 IS NOT NULL
      AND ITEMID5 IS NOT NULL
      AND ITEMID6 IS NULL THEN ITEM_ID ELSE ITEMID6 END,
      ITEMID7 = CASE WHEN ITEMID1 IS NOT NULL
      AND ITEMID2 IS NOT NULL
      AND ITEMID3 IS NOT NULL
      AND ITEMID4 IS NOT NULL
      AND ITEMID5 IS NOT NULL
      AND ITEMID6 IS NOT NULL
      AND ITEMID7 IS NULL THEN ITEM_ID ELSE ITEMID7 END,
      ITEMID8 = CASE WHEN ITEMID1 IS NOT NULL
      AND ITEMID2 IS NOT NULL
      AND ITEMID3 IS NOT NULL
      AND ITEMID4 IS NOT NULL
      AND ITEMID5 IS NOT NULL
      AND ITEMID6 IS NOT NULL
      AND ITEMID7 IS NOT NULL
      AND ITEMID8 IS NULL THEN ITEM_ID ELSE ITEMID8 END,
      ITEMID9 = CASE WHEN ITEMID1 IS NOT NULL
      AND ITEMID2 IS NOT NULL
      AND ITEMID3 IS NOT NULL
      AND ITEMID4 IS NOT NULL
      AND ITEMID5 IS NOT NULL
      AND ITEMID6 IS NOT NULL
      AND ITEMID7 IS NOT NULL
      AND ITEMID8 IS NOT NULL
      AND ITEMID9 IS NULL THEN ITEM_ID ELSE ITEMID9 END,
      ITEMID10 = CASE WHEN ITEMID1 IS NOT NULL
      AND ITEMID2 IS NOT NULL
      AND ITEMID3 IS NOT NULL
      AND ITEMID4 IS NOT NULL
      AND ITEMID5 IS NOT NULL
      AND ITEMID6 IS NOT NULL
      AND ITEMID7 IS NOT NULL
      AND ITEMID8 IS NOT NULL
      AND ITEMID9 IS NOT NULL
      AND ITEMID10 IS NULL THEN ITEM_ID ELSE ITEMID10 END
    WHERE
      CARTID = CART_ID;
  END LOOP;
END ADD_ITEM_N_TIMES;
/

-- delete items from cart
CREATE OR REPLACE PROCEDURE DELETE_ITEM_N_TIMES (
  ITEM_ID NUMBER,
  CART_ID NUMBER,
  PIECES NUMBER
) IS
BEGIN
  FOR I IN 1..PIECES LOOP
    UPDATE CART
    SET
      ITEMID1 = CASE WHEN ITEMID1 = ITEM_ID THEN NULL ELSE ITEMID1 END,
      ITEMID2 = CASE WHEN ITEMID2 = ITEM_ID THEN NULL ELSE ITEMID2 END,
      ITEMID3 = CASE WHEN ITEMID3 = ITEM_ID THEN NULL ELSE ITEMID3 END,
      ITEMID4 = CASE WHEN ITEMID4 = ITEM_ID THEN NULL ELSE ITEMID4 END,
      ITEMID5 = CASE WHEN ITEMID5 = ITEM_ID THEN NULL ELSE ITEMID5 END,
      ITEMID6 = CASE WHEN ITEMID6 = ITEM_ID THEN NULL ELSE ITEMID6 END,
      ITEMID7 = CASE WHEN ITEMID7 = ITEM_ID THEN NULL ELSE ITEMID7 END,
      ITEMID8 = CASE WHEN ITEMID8 = ITEM_ID THEN NULL ELSE ITEMID8 END,
      ITEMID9 = CASE WHEN ITEMID9 = ITEM_ID THEN NULL ELSE ITEMID9 END,
      ITEMID10 = CASE WHEN ITEMID10 = ITEM_ID THEN NULL ELSE ITEMID10 END
    WHERE
      CARTID = CART_ID;
  END LOOP;
END DELETE_ITEM_N_TIMES;
/

-- procedure trz to find cart belonging to user, if not exist it creates one
CREATE OR REPLACE PROCEDURE FIND_CART (
  USER_ID NUMBER
) IS
  CURSOR CART_CURSOR IS
  SELECT
    CART.CARTID
  FROM
    CART
    LEFT JOIN ORDERTABLE
    ON CART.CARTID = ORDERTABLE.CARTID
  WHERE
    CART.ACCOUNTID = USER_ID
    AND ORDERTABLE.CARTID IS NULL
    AND ROWNUM = 1; -- Return only one record
  V_CART_ID CART.CARTID%TYPE;
  V_CURSOR  SYS_REFCURSOR;
BEGIN
  OPEN CART_CURSOR;
  FETCH CART_CURSOR INTO V_CART_ID;
  IF CART_CURSOR%NOTFOUND THEN
    CLOSE CART_CURSOR;
    INSERT INTO CART (
      ACCOUNTID
    ) VALUES (
      USER_ID
    ) RETURNING CARTID INTO V_CART_ID;
  ELSE
    CLOSE CART_CURSOR;
  END IF;

  OPEN V_CURSOR FOR
    SELECT
      V_CART_ID
    FROM
      DUAL;
  DBMS_SQL.RETURN_RESULT(V_CURSOR);
END FIND_CART;
/

SELECT
  *
FROM
  CART;

SELECT
  *
FROM
  ORDERTABLE
WHERE
  ACCOUNTID = 1;

SELECT
  A.NAME,
  MAX(OT.PRICE) AS MAX_ORDER_PRICE
FROM
  ACCOUNT    A
  JOIN ORDERTABLE OT
  ON A.ACCOUNTID = OT.ACCOUNTID
GROUP BY
  A.NAME;

--account id index to faster find acount
CREATE INDEX IDX_ACCOUNT_ACCOUNTID ON ACCOUNT(ACCOUNTID);

--explain plan for finding max order in ordertable
EXPLAIN PLAN FOR
SELECT
  A.NAME,
  MAX(OT.PRICE) AS MAX_ORDER_PRICE
FROM
  ACCOUNT A
  JOIN ORDERTABLE OT
  ON A.ACCOUNTID = OT.ACCOUNTID
GROUP BY
  A.NAME;

SELECT
  *
FROM
  PLAN_TABLE;