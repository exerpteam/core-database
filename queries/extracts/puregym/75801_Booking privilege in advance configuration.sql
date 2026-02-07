 SELECT
         bp.id                                                                         AS "Booking privilege ID",
         ps.name                                                                       AS "Privilege set name",
         bpg.name                                                                      AS "Booking privilege group name (ref)",
         bpg.state                                                                     AS "Booking privilege group state",
         TO_CHAR (longtodateTZ (bp.valid_from, 'Europe/London'), 'MM/DD/YYYY HH24:MI') AS "Booking privilege valid from",
         bp.time_conf,
         unnest(xpath('/timeConfiguration/userInterface[@type = "WEB"]/span/text()',timeconfig))            AS WEB_in_advance_value,
         unnest(xpath('/timeConfiguration/userInterface[@type = "WEB"]/round/text()',timeconfig))           AS WEB_round,
         unnest(xpath('/timeConfiguration/userInterface[@type = "KIOSK"]/span/text()',timeconfig))          AS KIOSK_in_advance_value,
         unnest(xpath('/timeConfiguration/userInterface[@type = "KIOSK"]/round/text()',timeconfig))         AS KIOSK_round,
         unnest(xpath('/timeConfiguration/userInterface[@type = "MOBILE_API"]/span/text()',timeconfig))     AS MOBILE_API_in_advance_value,
         unnest(xpath('/timeConfiguration/userInterface[@type = "MOBILE_API"]/round/text()',timeconfig))    AS MOBILE_API_round,
         unnest(xpath('/timeConfiguration/userInterface[@type = "CLIENT"]/span/text()',timeconfig))         AS CLIENT_in_advance_value,
         unnest(xpath('/timeConfiguration/userInterface[@type = "CLIENT"]/round/text()',timeconfig))        AS CLIENT_round,
         unnest(xpath('/timeConfiguration/userInterface[@type = "API"]/span/text()',timeconfig))            AS API_in_advance_value,
         unnest(xpath('/timeConfiguration/userInterface[@type = "API"]/round/text()',timeconfig))           AS API_round
    FROM
         booking_privilege_groups bpg
    JOIN
         booking_privileges bp
      ON
         bp.group_id = bpg.id
    JOIN
         privilege_sets ps
      ON
         ps.id = bp.privilege_set,
    xmlparse(document convert_from(bp.time_conf, 'UTF-8')) AS timeconfig
   WHERE
         bp.time_conf IS NOT NULL
         AND length (timeconfig::text) > 63 --avoid not set advance configuration
         AND bp.valid_to IS NULL
         AND bp.id NOT IN (12220) -- Stuck