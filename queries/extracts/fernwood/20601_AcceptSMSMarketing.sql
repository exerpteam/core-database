SELECT 
        p.center ||'p'||p.id as "Person ID"
        ,p.external_id AS "External ID"
        ,'AcceptSMSMarketing' AS "Need Apply Step"
FROM
        persons p
LEFT JOIN
        person_ext_attrs AcceptSMSMarketing
               on AcceptSMSMarketing.personcenter = p.center
               and AcceptSMSMarketing.personid = p.id
               and AcceptSMSMarketing.name = 'AcceptSMSMarketing'
WHERE
        p.status not in (4,5,7,8)
        AND 
        p.center in (:scope)
        AND
        AcceptSMSMarketing.txtvalue IS NULL