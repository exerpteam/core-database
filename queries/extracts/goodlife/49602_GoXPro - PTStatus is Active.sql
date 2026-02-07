
SELECT

p.firstname
,p.lastname
,p.center||'p'||p.id AS person_id
,p.external_id
,email.txtvalue AS email


FROM

persons p

JOIN person_ext_attrs px
ON px.personcenter = p.center
AND px.personid = p.id
AND px.name = 'GoXProPTStatus'
AND px.txtvalue = 'ACTIVE'

LEFT JOIN PERSON_EXT_ATTRS email
ON email.personcenter = p.center
AND email.personid = p.id
AND email.name = '_eClub_Email'