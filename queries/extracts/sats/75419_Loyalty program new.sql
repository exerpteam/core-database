-- The extract is extracted from Exerp on 2026-02-08
-- Used to extract all members in a scope on a specific level. 
 Select
 p.center || 'p' || p.id as memberid,
 p.external_id as "External Id",
 p.fullname as "Member name",
 ext.txtvalue as loyaltylevel,
 longtodate(ENTRY_TIME) as entry_time
 FROM
             persons p
         JOIN
             PERSON_EXT_ATTRS ext
         ON
             ext.PERSONCENTER = p.CENTER
             AND ext.PERSONID = p.ID
             AND ext.NAME = 'UNBROKENMEMBERSHIPGROUPALL'
 LEFT JOIN
                     PERSON_CHANGE_LOGS pcl
                 ON
                     p.center = pcl.person_center
                     AND p.id = pcl.person_id
                     AND ext.name = pcl.CHANGE_ATTRIBUTE
                     AND pcl.NEW_VALUE = ext.txtvalue
                          WHERE
             p.center in (:center)
 and
 ext.txtvalue in (:Loyalty_level)
 and p.status not in (4,5,7,8)
