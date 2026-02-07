SELECT
    KD.center,
    kf.KEY,
    TO_CHAR( KD.FOR_DATE,'yyyy-MM-dd') AS for_date,
    KD.VALUE                                AS value
FROM
    KPI_DATA KD
JOIN
    PUREGYM.KPI_FIELDS kf
ON
    kf.id = kd.FIELD
WHERE
    KD.FIELD IN(5801,5802,5803)
	and (kd.FOR_DATE between sysdate -$$offset$$ and trunc(sysdate)-1 or $$offset$$ = 0)