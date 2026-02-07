SELECT DISTINCT
    cco.GENERATED_DATE,
    cco.SENT_DATE,
    cco.ID                                FILE_ID,
    i2.personcenter || 'p' || i2.personid pid
FROM
    (
        SELECT
            i1.center,
            i1.id,
            i1.personcenter,
            i1.personid,
            MIN(ccr.REQ_DELIVERY) delivery
        FROM
            (
                SELECT DISTINCT
                    FIRST_VALUE(cc.CENTER) OVER (PARTITION BY cc.PERSONCENTER,cc.PERSONID ORDER BY cc.STARTDATE ASC) center,
                    FIRST_VALUE(cc.ID) OVER (PARTITION BY cc.PERSONCENTER,cc.PERSONID ORDER BY cc.STARTDATE ASC)     id,
                    cc.PERSONCENTER,
                    cc.PERSONID
                FROM
                    CASHCOLLECTIONCASES cc
                WHERE
                    cc.CASHCOLLECTIONSERVICE IS NOT NULL
                    AND cc.MISSINGPAYMENT = 1 )i1
        JOIN
            CASHCOLLECTION_REQUESTS ccr
        ON
            ccr.CENTER = i1.center
            AND ccr.id = i1.id
            AND ccr.REQ_DELIVERY IS NOT NULL
        GROUP BY
            i1.center,
            i1.id,
            i1.personcenter,
            i1.personid )i2
JOIN
    CASHCOLLECTION_OUT cco
ON
    cco.ID = i2.delivery
WHERE
    cco.id IN ($$out_file_id$$)
	and i2.personcenter in ($$scope$$)
ORDER BY
    cco.SENT_DATE DESC