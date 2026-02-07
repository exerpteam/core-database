SELECT
    DECODE(PID, NULL, 'Total Amount', PID) AS PID,
    fullname,
    TRANS_TIME,
    SUM(amount),
    DUE_DATE,
    INFO,
    text,
    ENTRY_TIME
FROM
    (
        SELECT
            DECODE(ar.CUSTOMERCENTER, NULL, 'Total Amount', ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID) pid,
            p.FULLNAME,
            longToDateC(artp.TRANS_TIME, art.center) TRANS_TIME,
            arm.AMOUNT                         AMOUNT,
            artp.DUE_DATE,
            artp.INFO,
            artp.text,
            longToDateC(artp.ENTRY_TIME, art.center) ENTRY_TIME
        FROM
            AR_TRANS art
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CENTER = art.CENTER
            AND ar.ID = art.ID
        JOIN
            PERSONS p
        ON
            p.CENTER = ar.CUSTOMERCENTER
            AND p.ID = ar.CUSTOMERID
        JOIN
            account_trans act
        ON
            art.ref_center = act.center
            AND art.REF_ID = act.ID
            AND art.ref_subid = act.SUBID
            AND art.ref_type = 'ACCOUNT_TRANS'
        JOIN
            ART_MATCH arm
        ON
            arm.art_paying_center = art.CENTER
            AND arm.art_paying_id= art.ID
            AND arm.art_paying_subid = art.SUBID
        JOIN
            AR_TRANS artp
        ON
            artp.CENTER = arm.art_paid_center
            AND artp.ID = arm.art_paid_id
            AND artp.SUBID = arm.art_paid_subid
        WHERE
            ar.AR_TYPE IN (4, 5)
            AND ar.CENTER IN ($$Scope$$)
            AND act.info_type IN (3, 4)
            AND act.INFO = $$File_ID$$
	  )
GROUP BY
    GROUPING SETS ((PID, fullname, TRANS_TIME, DUE_DATE, INFO, text, ENTRY_TIME), ())