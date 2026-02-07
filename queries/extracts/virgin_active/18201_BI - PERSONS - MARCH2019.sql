WITH
    params AS
    (
        SELECT
            /*+ materialize  */
            c.ID                                                               AS ID,
            datetolongC(TO_CHAR(TRUNC(SYSDATE)-5, 'YYYY-MM-DD HH24:MI'), c.id) AS FROMDATE,
            datetolongC(TO_CHAR(TRUNC(SYSDATE+1), 'YYYY-MM-DD HH24:MI'), c.id) AS TODATE
        FROM
            centers c

    )
SELECT
    p.PERSON_ID ,
    p.HOME_CENTER_ID ,
    p.HOME_CENTER_PERSON_ID ,
    pd.FULLNAME as FULL_NAME,
    p.COUNTRY_ID ,
    p.POSTAL_CODE ,
    p.CITY ,
    p.DATE_OF_BIRTH ,
    p.GENDER ,
    p.PERSON_TYPE ,
    p.PERSON_STATUS ,
    p.CREATION_DATE ,
    p.PAYER_PERSON_ID ,
    p.COMPANY_ID ,
    p.ETS
FROM
    BI_PERSONS p
left JOIN
persons pd on pd.EXTERNAL_ID = p.PERSON_ID

JOIN
    PARAMS
ON
    p.HOME_CENTER_ID= params.id
WHERE
    p.ETS >= 1551398400000

and P.HOME_CENTER_ID IN ($$scope$$)