SELECT
    lpad(IDENTITY,20,'0') || rpad(FIRSTNAME || ' ' || LASTNAME,20) || '000' || decode(sign(NVL( SUM(AMOUNT),0)),0,'0',-1,'0',+1,'-') || lpad(ABS(NVL( SUM(AMOUNT),0)*100),7,'0') || lpad(DEBIT_MAX,6,'0') data
FROM
    (
        SELECT DISTINCT
            ei.IDENTITY,
            p.CENTER,
            p.ID,
            p.FIRSTNAME,
            p.LASTNAME,
            art.CENTER art_center,
            art.ID     art_id,
            art.SUBID  art_subid,
            art.AMOUNT,
            ar.DEBIT_MAX
        FROM
            PERSONS p
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = p.CENTER
            AND ar.CUSTOMERID = p.ID
            AND ar.AR_TYPE = 1
        JOIN
            ENTITYIDENTIFIERS ei
        ON
            ei.REF_CENTER = p.CENTER
            AND ei.REF_ID = p.ID
            AND ei.REF_TYPE = 1
            AND ei.ENTITYSTATUS = 1
        LEFT JOIN
            AR_TRANS art
        ON
            art.CENTER = ar.CENTER
            AND art.ID = ar.ID
        WHERE
            ar.DEBIT_MAX > 0
			AND ei.IDMETHOD =  4
			AND p.status NOT IN (4,5,7,8)
            AND p.center IN (:scope) )
GROUP BY
    CENTER,
    id ,
    lpad(IDENTITY,20,'0'),
    rpad(FIRSTNAME || ' ' || LASTNAME,20),
    DEBIT_MAX