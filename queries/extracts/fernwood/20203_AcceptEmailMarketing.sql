SELECT 
        p.center ||'p'||p.id as "Person ID"
        ,p.external_id AS "External ID"
        ,'AcceptEmailMarketing' AS "Need Apply Step"
FROM
        persons p
LEFT JOIN
        person_ext_attrs AcceptEmailMarketing
               on AcceptEmailMarketing.personcenter = p.center
               and AcceptEmailMarketing.personid = p.id
               and AcceptEmailMarketing.name = 'AcceptEmailMarketing'
WHERE
        p.status not in (4,5,7,8)
        AND 
        p.center in (:Scope)
        AND
        AcceptEmailMarketing.txtvalue IS NULL