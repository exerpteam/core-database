 WITH
     params AS Materialized
     (
         SELECT
              datetolongTZ(TO_CHAR(CAST($$StartDate$$ AS DATE), 'YYYY-MM-DD HH24:MI'), 'Europe/London')                  AS StartDateLong,
             (datetolongTZ(TO_CHAR(CAST($$EndDate$$   AS DATE), 'YYYY-MM-DD HH24:MI'), 'Europe/London')+ 86400 * 1000)-1 AS EndDateLong
     )
     ,
     v_transfer AS
     (
         SELECT
             scl.center,
             scl.id,
             scl.employee_center || 'emp' || scl.employee_id AS Employee,
             scl.ENTRY_START_TIME
         FROM
             STATE_CHANGE_LOG SCL
         CROSS JOIN
             params
         WHERE
             scl.employee_center = 100
             /* Changes made by employee at center 100 and not 100emp1 */
             AND scl.employee_id != 1
             AND scl.ENTRY_START_TIME >= params.StartDateLong
             AND scl.ENTRY_START_TIME <= params.EndDateLong
             AND scl.center IN ($$Scope$$)
             AND SCL.ENTRY_TYPE = 1
             AND SCL.STATEID = 4
     )
 /* Member needs to have person state change log transfer and previous state must be active. Exclude rejoiner and inactive members*/
 SELECT DISTINCT
     transfer.Center,
     transfer.Center || 'p' || transfer.Id              AS PersonId,
     SUBSTR(pea.txtvalue,1, position('p' IN pea.txtvalue)-1) AS NewCenter,
     pea.txtvalue                                       AS NewPersonId,
     transfer.Employee,
     'Transfer member' AS feature,
     transfer.EntryTime
 FROM
     (
         SELECT
             t.center AS Center,
             t.id     AS Id,
             t.Employee,
             longtodatec(t.ENTRY_START_TIME, scl.center) AS EntryTime,
             scl.stateid,
             rank() over (partition BY scl.center, scl.id ORDER BY scl.entry_start_time DESC) AS rnk
         FROM
             v_transfer t
         JOIN
             STATE_CHANGE_LOG SCL
         ON
             scl.center = t.center
             AND scl.id = t.id
             AND SCL.ENTRY_TYPE = 1
             AND scl.entry_start_time < t.entry_start_time )transfer
 LEFT JOIN
     PERSON_EXT_ATTRS pea
 ON
     pea.PERSONCENTER= transfer.Center
     AND pea.PERSONID= transfer.Id
     AND pea.NAME = '_eClub_TransferredToId'
 WHERE
     transfer.stateid = 1
     AND transfer.rnk = 1
