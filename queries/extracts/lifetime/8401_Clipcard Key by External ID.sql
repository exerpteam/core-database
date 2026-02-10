-- The extract is extracted from Exerp on 2026-02-08
-- ES-27735
SELECT
    pd.name                                    AS "clipcard_name",
    cc.center ||'cc'|| cc.id ||'cc'|| cc.subid AS "clipcard_key",
    cc.owner_center ||'p'|| cc.owner_id        AS "owner_personID",
    c.name                                     AS "cc_center_name",
    ep.fullname                                AS "assigned_staff",
    cc.clips_left,
    cc.finished,
    cc.cancelled,
    cc.blocked,
    TO_CHAR(longtodatec(cc.valid_from,c.ID), 'YYYY-MM-DD HH24:MI')  AS "valid_from",
    TO_CHAR(longtodatec(cc.valid_until,c.ID), 'YYYY-MM-DD HH24:MI') AS "valid_until",
	TO_CHAR(longtodatec(cc.last_modified,c.ID), 'YYYY-MM-DD HH24:MI')  AS "last_modified",
    p.external_id
FROM
    clipcards cc
JOIN
    clipcardtypes cct
 ON
    cct.center = cc.center
AND cct.id = cc.id
JOIN
    products pd
 ON
    pd.center = cct.center
AND pd.id = cct.id
AND pd.ptype = 4 --clipcard
JOIN
    centers c
 ON
    cc.center = c.id
JOIN
    persons p
 ON
    p.center = cc.owner_center
AND p.id = cc.owner_id
LEFT JOIN
    persons ep
 ON
    ep.center = cc.assigned_staff_center
AND ep.id = cc.assigned_staff_id

WHERE
    p.external_id IN (:extid)
   
ORDER BY
cc.last_modified desc
--cc.valid_from desc, pd.name asc, c.name asc;