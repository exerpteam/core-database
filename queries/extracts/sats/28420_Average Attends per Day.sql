SELECT
    decode(c.id,null,' Total',c.id) as "Center Id",
    c.name as "Center Name",
    TO_CHAR(SUM(counts.num) / COUNT(counts.check_date),'99990.99') AS "AVG attends per day"
FROM
    (
        SELECT
            att.CENTER,
            TO_CHAR(longtodate(att.START_TIME),'yyyy-MM-dd') AS check_date,
            COUNT(*)                                         AS num
        FROM
            SATS.ATTENDS att
        WHERE
            att.CENTER IN($$scope$$)
            AND att.START_TIME BETWEEN $$from_date$$ AND $$end_date$$
        GROUP BY
            att.CENTER,
            TO_CHAR(longtodate(att.START_TIME),'yyyy-MM-dd')) counts
JOIN
    SATS.CENTERS c
ON
    c.id = counts.center
GROUP BY
    grouping sets ( (c.id, c.name), () )