SELECT 
        p.center ||'p'||p.id as "Person ID"
        ,p.external_id AS "External ID"
        ,'AcceptPhoneMarketing' AS "Need Apply Step"
FROM
        persons p
LEFT JOIN
        person_ext_attrs AcceptPhoneMarketing
               on AcceptPhoneMarketing.personcenter = p.center
               and AcceptPhoneMarketing.personid = p.id
               and AcceptPhoneMarketing.name = 'AcceptPhoneMarketing'
WHERE
        p.status not in (4,5,7,8)
        AND 
        p.center in (:scope)
        AND
        AcceptPhoneMarketing.txtvalue IS NULL