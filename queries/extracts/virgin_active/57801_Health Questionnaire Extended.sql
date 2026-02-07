 WITH
     quest AS
     (
         SELECT
             cp.center,
             cp.id,
             qa.subid,
             cp.CENTER || 'p' || cp.ID                                                    AS PersonId,
                     floor(months_between(CURRENT_DATE, p.BIRTHDATE) / 12) AS age,
             qc.NAME                                                                      AS Questionnaire,
             qa.RESULT_CODE                                                               AS Answers,
             CASE
             WHEN p.STATUS = 0
             THEN 'Lead'
             WHEN p.STATUS = 1
             THEN 'ACTIVE'
             WHEN p.STATUS = 3
             THEN 'Temporary Inactive'
             WHEN p.STATUS = 9
             THEN 'Contact'
             END AS Personstatus,
             qa.completed,
             CASE
                 WHEN a.id IS NOT NULL
                 THEN a.name
                 WHEN c.id IS NOT NULL
                 THEN c.shortname
                 ELSE NULL
             END AS Scope
         FROM
             QUESTIONNAIRES q
         JOIN
             QUESTIONNAIRE_CAMPAIGNS qc
         ON
             qc.QUESTIONNAIRE = q.ID
         JOIN
             QUESTIONNAIRE_ANSWER qa
         ON
             qa.QUESTIONNAIRE_CAMPAIGN_ID = qc.ID
         JOIN
             PERSONS p
         ON
             qa.CENTER = p.CENTER
             AND qa.ID = p.ID
         JOIN
                    persons cp
         ON
                         cp.center = p.current_person_center
                         AND cp.id = p.current_person_id
         LEFT JOIN
             areas a
         ON
             a.id = qc.scope_id
             AND qc.scope_type = 'A'
         LEFT JOIN
             centers c
         ON
             c.id = qc.scope_id
             AND qc.scope_type = 'C'
         WHERE
             q.ID IN ( 1601, 1)
             AND cp.center IN ($$Scope$$)
             AND cp.BLACKLISTED IN ($$is_suspended$$)
             AND cp.STATUS IN ($$personStatus$$)
     )
 SELECT
     t.PersonId AS "PersonId",
         t.age,
     t.Questionnaire,
     t.Answers,
     t.Personstatus AS "Person Status",
     t.scope        AS "Scope",
     t.text         AS "Suspended Reason",
     t.hascompleted AS "Has Already Completed"
 FROM
     (
         SELECT DISTINCT
             q.*,
             COALESCE(NULLIF(CAST(q1.center AS VARCHAR), 'Yes'), 'No')                                                            AS hascompleted,
             convert_from(je.big_text, 'UTF-8')  AS text,
             rank() over (partition BY je.person_center, je.person_id ORDER BY je.creation_time DESC) AS rnk
         FROM
             quest q
         LEFT JOIN
             quest q1
         ON
             q.PersonId = q1.PersonId
             AND q1.completed = 1
         LEFT JOIN
             journalentries je
         ON
             je.person_center = q.center
             AND je.person_id = q.id
             AND je.name = 'Suspended'
             AND je.jetype = 3
    )t
 WHERE
     t.rnk = 1