WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize  */
                datetolongC(TO_CHAR(TRUNC(TO_DATE(getCenterTime(c.ID),'YYYY-MM-DD HH24:MI') - 13),'YYYY-MM-DD HH24:MI'),c.ID) AS STARTTIME,
                datetolongC(TO_CHAR(TRUNC(TO_DATE(getCenterTime(c.ID),'YYYY-MM-DD HH24:MI')),'YYYY-MM-DD HH24:MI'),c.ID)-1 AS ENDTIME,  
                c.ID as CenterID
        FROM
                HP.CENTERS c
        WHERE
                c.COUNTRY = 'CH'
    )
SELECT /*+ NO_BIND_AWARE */ DISTINCT
           p.center,
           p.id,
           gc.payer_center||'p'||gc.payer_id as PERSONKEY,
           gc.amount as amount,
           gc.id as giftcards,
           to_char(gc.EXPIRATIONDATE, 'dd-MM-yyyy') as expdate,
           pd.NAME as clipcardname,
           ide.IDENTITY as bar,
           p.FIRSTNAME as firstname,
           p.FULLNAME as fullname,
           p.LASTNAME as lastname
        FROM
            GIFT_CARDS gc
        JOIN PARAMS ON gc.CENTER = PARAMS.CenterID
        JOIN
        products pd
        on
        pd.center = gc.product_center
        and pd.id = gc.product_id  
        JOIN
        PERSONS p
        ON  
        gc.payer_id = p.ID and
        gc.payer_center = p.CENTER
        JOIN
        ENTITYIDENTIFIERS ide
        on
        ide.ref_id = gc.id
        and
        ide.ref_center = gc.payer_center
        and
        pd.NAME ='Gift Card Compensation 75'
        AND  ide.IDMETHOD = 1
                AND
        gc.PURCHASE_TIME > PARAMS.STARTTIME
    AND gc.PURCHASE_TIME < PARAMS.ENDTIME
