-- The extract is extracted from Exerp on 2026-02-08
--  


SELECT
    kfield.EXTERNAL_ID,
    kdata.CENTER,
    TO_CHAR(kdata.FOR_DATE, 'YYYY-MM-DD') kdate,
    kdata.VALUE
FROM
    HP.KPI_DATA kdata
JOIN
    HP.KPI_FIELDS kfield
ON
    kdata.FIELD = kfield.ID
WHERE
    date_trunc('day',kdata.FOR_DATE) = date_trunc('day',CURRENT_DATE) - interval '1 day'
    AND kfield.EXTERNAL_ID IN ( 'DD_ENDING_IN_MONTH',
                               'DD_SALES_12_MONTH',
                               'DD_SALES_24_MONTH',
                               'DD_SALES_OTHER',
                               'PT_PARTICIPATIONS',
                               'PT_CLIPS_SOLD_AMOUNT',
                               'PT_CLIPS_SOLD_CLIPS')
ORDER BY
    kfield.EXTERNAL_ID,
    kdata.CENTER

