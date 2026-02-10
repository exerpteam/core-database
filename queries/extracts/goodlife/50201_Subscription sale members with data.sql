-- The extract is extracted from Exerp on 2026-02-08
-- 
--ES-43553 no message attachments

SELECT
m.center||'p'||m.id as member,
p.firstname,
p.lastname,
email.txtvalue as email,
CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
  longtodateTZ(m.senttime, 'America/Toronto')    sent_time,
 m.subject
FROM
    messages m
         left   JOIN
            message_attachments ma
        ON
            ma.message_center = m.center
        AND ma.message_id = m.id
        AND ma.message_subid = m.subid
        join persons p on m.center = p.center and m.id = p.id
        JOIN
    person_ext_attrs email
ON
    p.center = email.personcenter
AND p.id = email.personid
AND email.name = '_eClub_Email'
WHERE
m.subject in ( 'Your GoodLife Fitness Subscription Confirmation')
and ma.s3key is null
and m.senttime >= datetolongTZ('2024-11-28 00:01','America/Toronto')
and m.senttime < datetolongTZ('2024-12-12 11:45:50','America/Toronto')

;