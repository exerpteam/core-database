-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-11554
 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             datetolongTZ(TO_CHAR(TRUNC(add_months(CURRENT_TIMESTAMP, -12*$$NumberOfYears$$)), 'YYYY-MM-dd HH24:MI'), 'Europe/Rome') AS FromDateLong
         
     )
 SELECT
     je.person_center || 'p' || je.person_id AS MemberId,
     je.document_name                        AS Document,
     longtodatec(je.creation_time, je.person_center) "Creation Date"
 FROM
     journalentries je
 CROSS JOIN
     params
 WHERE
     je.person_center IN (:Scope)
     AND je.creation_time <= params.FromDateLong
     AND je.jetype = 31
     AND je.s3key IS NOT NULL
