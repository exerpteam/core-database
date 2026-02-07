SELECT
    cn.center,
    cn.id,
    (TO_DATE('1970-01-01','yyyy-mm-dd') + cn.trans_time/(24*3600*1000) + 1/24) AS TransaktionsDato,
    CNL.PERSON_CENTER ||'p'|| CNL.person_id                                    AS PersonId,
    cn.employee_center                                                         AS ansat_center,
    cn.employee_id                                                             AS ansat_id,
    cn.text,
    cnl.total_amount
FROM
    CREDIT_NOTES CN
JOIN
    CREDIT_NOTE_LINES_MT CNL
ON
    CN.CENTER = CNL.CENTER
AND CN.ID = CNL.ID
LEFT JOIN
    INVOICES I
ON
    I.CENTER = CNL.INVOICELINE_CENTER
AND I.ID = CNL.INVOICELINE_ID
WHERE
    CNL.CENTER IN(:CNCenter)
AND CN.TRANS_TIME BETWEEN :CNFrom AND :CNTo