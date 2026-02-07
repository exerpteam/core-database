WITH
    recursive v1 AS
    (
        SELECT
            /*+ materialized */
            checkins.id ,
            centers.name center_name ,
            checkins.person_center ,
            checkins.person_id ,
            state_change_log.stateid ,
            checkins.checkin_center ,
            checkins.checkin_time ,
            checkins.checkin_result ,
            CASE
                WHEN checkins.checkin_time <= LAG(checkins.checkin_time, 1 ) OVER (PARTITION BY checkins.person_center, checkins.person_id, checkins.checkin_center ORDER BY checkins.checkin_time) + :hours_unique_checkins *3600*1000 --previous checkin
                THEN LAG(checkins.id, 1) OVER (PARTITION BY checkins.person_center, checkins.person_id, checkins.checkin_center ORDER BY checkins.checkin_time) --previous checkin id
                ELSE NULL
            END AS parent_id ,
            CASE
                WHEN checkins.checkin_time <= LAG(checkins.checkin_time, 1 ) OVER (PARTITION BY checkins.person_center, checkins.person_id, checkins.checkin_center ORDER BY checkins.checkin_time) + :hours_unique_checkins *3600*1000 --previous checkin
                THEN LAG(checkins.checkin_time, 1 ) OVER (PARTITION BY checkins.person_center, checkins.person_id, checkins.checkin_center ORDER BY checkins.checkin_time)
                ELSE NULL
            END AS parent_checkin
        FROM
            centers
        JOIN
            checkins
        ON
            checkins.checkin_center = centers.id
            AND checkins.checkin_result IN (0,1)
            AND checkins.checkin_time >= $$startdate$$
            AND checkins.checkin_time < $$startdate$$ + 604800 * 1000
            AND checkins.checkin_center IN ($$scope$$)
        JOIN
            state_change_log
        ON
            checkins.person_center = state_change_log.center
            AND checkins.person_id = state_change_log.id
            AND state_change_log.entry_type = 5
            AND checkins.checkin_time BETWEEN state_change_log.entry_start_time AND COALESCE(state_change_log.entry_end_time, checkins.checkin_time)
    )
    ,
    v2 AS
    (
        SELECT
            v1.*,
            v1.id           AS root_id,
            v1.checkin_time AS root_checkin,
            1               AS pos_level
        FROM
            v1
        WHERE
            v1.parent_id IS NULL
        UNION
        SELECT
            v0.*,
            v1.id           AS root_id,
            v1.checkin_time AS root_checkin,
            2               AS pos_level
        FROM
            v1 AS v0
        JOIN
            v1
        ON
            v1.id = v0.parent_id
    )
    ,
    v3 AS
    (
        SELECT
            /*+ materialized */
            v2.* ,
            CASE
                WHEN v2.pos_level = 1
                THEN 'OK'
                ELSE (
                        CASE
                            WHEN v2.parent_id = v2.root_id
                                OR v2.checkin_time BETWEEN v2.root_checkin AND v2.root_checkin + :hours_unique_checkins *3600*1000
                            THEN 'DELETE'
                            ELSE (
                                    CASE
                                        WHEN v2.parent_checkin BETWEEN v2.root_checkin AND v2.root_checkin + :hours_unique_checkins *3600*1000
                                        THEN 'KEEP'
                                        ELSE 'DELETE'
                                    END)
                        END)
            END decision_flag
        FROM
            v2
    )
SELECT
    checkin_center ,
    center_name ,
    TO_CHAR(longtodateC(v3.checkin_time,v3.checkin_center) , 'YYYY-MM-DD') checkin_date ,
    SUM(
        CASE
            WHEN stateid = 2
            THEN 1
            ELSE 0
        END ) UNIQUE_SUCCES_CHECKINS_MEM ,
    SUM(
        CASE
            WHEN stateid = 1
            THEN 1
            ELSE 0
        END ) UNIQUE_SUCCES_CHECKINS_NONMEM ,
    SUM(
        CASE
            WHEN stateid = 4
            THEN 1
            ELSE 0
        END ) UNIQUE_SUCCES_CHECKINS_EXTRA ,
    SUM(
        CASE
            WHEN stateid IN (1,2,4)
            THEN 0
            ELSE 1
        END ) UNIQUE_SUCCES_CHECKINS_OTHERS
FROM
    v3
WHERE
    decision_flag IN ( 'OK',
                      'KEEP')
GROUP BY
    v3.checkin_center,
    v3.center_name,
    TO_CHAR(longtodateC(v3.checkin_time,v3.checkin_center) , 'YYYY-MM-DD')
ORDER BY
    v3.checkin_center,
    v3.center_name,
    TO_CHAR(longtodateC(v3.checkin_time,v3.checkin_center) , 'YYYY-MM-DD')