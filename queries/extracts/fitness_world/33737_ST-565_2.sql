-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    *
FROM
    (
        SELECT
            p.CENTER,
            p.FIRSTNAME,
            p.LASTNAME,
            p.SEX,
            p.ZIPCODE,
            ROUND(months_between(exerpsysdate(),p.BIRTHDATE) / 12) AGE,
            p.BIRTHDATE,
            prod.NAME,
			s.state,
            s.BINDING_PRICE,
            e.TxtValue as mail
        FROM
            PERSONS p
        JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.center
            AND s.OWNER_ID = p.id
            AND s.STATE = 2
            JOIN 
    Person_Ext_Attrs e
    ON 
    p.center = e.PersonCenter 
    AND p.id = e.PersonId 
    AND e.Name = '_eClub_Email' 
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.ID = s.SUBSCRIPTIONTYPE_ID 
            ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM <= $$number_of_rows$$