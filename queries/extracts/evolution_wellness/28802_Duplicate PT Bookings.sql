-- The extract is extracted from Exerp on 2026-02-08
--  
WITH base AS ( 
  SELECT
    CAST(ccu.time                  AS BIGINT) AS ccu_time_ms,
    CAST(ccu.cancellation_timestamp AS BIGINT) AS ccu_cancel_ms,
    ccu.card_center                          AS ccu_center,
    ccu.card_id,
    ccu.card_subid,
    CAST(pu.target_start_time      AS BIGINT) AS pu_time_ms,
    pu.target_center                          AS pu_center,
    pu.person_center,
    pu.person_id
  FROM card_clip_usages AS ccu
  JOIN privilege_usages  AS pu
    ON pu.source_center = ccu.card_center
   AND pu.source_id     = ccu.card_id
   AND pu.source_subid  = ccu.card_subid
   AND pu.id            = ccu.ref
),
binned AS (
  SELECT
    *,
    ((ccu_time_ms + 15000) / 30000) AS ccu_bin30,
    ((pu_time_ms  + 15000) / 30000) AS pu_bin30
  FROM base
),
scored AS (
  SELECT
    *,
    COUNT(*) OVER (
      PARTITION BY
        ccu_center, card_id, card_subid,  
        ccu_bin30, pu_bin30               
    ) AS pair_cnt
  FROM binned
)
SELECT
	
	person_center ||'p'|| person_id AS "Person ID",
  TO_CHAR(to_timestamp(ccu_time_ms   / 1000.0), 'YYYY-MM-DD HH24:MI:SS') AS booking_creation_time,
  TO_CHAR(to_timestamp(ccu_cancel_ms / 1000.0), 'YYYY-MM-DD HH24:MI:SS') AS booking_cancel_time,
  TO_CHAR(to_timestamp(pu_time_ms    / 1000.0), 'YYYY-MM-DD HH24:MI:SS') AS booking_start_time

FROM scored
WHERE pair_cnt >= 2
AND person_center IN ( :scope )
