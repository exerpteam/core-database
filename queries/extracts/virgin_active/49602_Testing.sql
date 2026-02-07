WITH
    params AS
    (
        SELECT /*+ materialize  */
            c.id AS CENTER_ID,
            datetolongtz(TO_CHAR(trunc(SYSDATE-8), 'YYYY-MM-DD HH24:MI'), c.time_zone) as FROM_DATE,
            datetolongtz(TO_CHAR(trunc(SYSDATE-2), 'YYYY-MM-DD HH24:MI'), c.time_zone) as TO_DATE
        FROM
            centers c
        WHERE
            c.id IN ($$scope$$)
    )
SELECT
    biview.*
FROM
    BI_FREEZES biview
JOIN
    PARAMS
    on biview.SUBSCRIPTION_CENTER_ID = params.CENTER_ID
    AND biview.ETS >= PARAMS.FROM_DATE
    AND biview.ETS < PARAMS.TO_DATE