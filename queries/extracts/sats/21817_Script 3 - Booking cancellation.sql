 SELECT
     COUNT(p.CENTER) cnt,
     ROUND((p.CANCELATION_TIME - p.START_TIME)/1000/60/60) hours_before
 FROM
     PARTICIPATIONS p
 WHERE
     p.CANCELATION_TIME IS NOT NULL
     AND p.CANCELATION_REASON NOT IN ('CENTER')
     and p.CENTER in (:scope)
         and p.START_TIME between :period_start and :period_end
 GROUP BY
     ROUND((p.CANCELATION_TIME - p.START_TIME)/1000/60/60)
