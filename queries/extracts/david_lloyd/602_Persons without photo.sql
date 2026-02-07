-- This is the version from 2026-02-05
--  
SELECT DISTINCT
    p.center || 'p' || p.id as MemberID,
p.external_id,
    c.shortname AS "Club name",
sub.start_date,
    pic.mimevalue AS "Has photo",
    prod.name AS Subscription_Name
FROM
    persons p
JOIN
    centers c
ON
    c.id = p.center
JOIN
    subscriptions sub
ON
    sub.owner_center = p.center
AND sub.owner_id = p.id
JOIN
    subscriptiontypes subt
ON
    subt.center = sub.subscriptiontype_center
AND subt.id = sub.subscriptiontype_id
JOIN
    products prod
ON
    prod.center = subt.center
AND prod.id = subt.id
LEFT JOIN
    person_ext_attrs pic
ON
    pic.personcenter = p.center
AND pic.personid = p.id
AND pic.name = '_eClub_Picture'
WHERE
  
p.status IN (1,3)
AND p.sex != 'C'
AND p.blacklisted = 0
AND p.center IN (:scope)
AND sub.state IN (2,4)
AND (
        pic.mimevalue IS NULL
    OR  LENGTH(pic.mimevalue) < 1800)
and not exists
(SELECT 
    1
    
FROM
    persons p2
JOIN
    centers c2
ON
    c2.id = p2.center

join 
person_ext_attrs pic2
ON
    pic2.personcenter = p.center
AND pic2.personid = p.id
AND pic2.name = '_eClub_PictureFace'
where
(pic2.mimevalue IS not null and LENGTH(pic2.mimevalue) > 1800)               
and p.center = p2.center
and p.id = p2.id               )        
        
ORDER BY
p.external_id