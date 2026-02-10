-- The extract is extracted from Exerp on 2026-02-08
--  
 Select distinct
 p.center || 'p' || p.id as memberid,
 p.external_id as "External Id",
 p.fullname as "Member name",
 ext.txtvalue as loyaltylevel
 FROM
             persons p
         JOIN
                             persons pt
                         ON
                             pt.TRANSFERS_CURRENT_PRS_CENTER = p.CENTER
                         AND pt.TRANSFERS_CURRENT_PRS_ID = p.ID
         JOIN
             person_ext_attrs ext
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
                     and pcl.CHANGE_SOURCE not in ('MEMBER_TRANSFER')
 left join
                         PERSON_CHANGE_LOGS pcl2
                         ON
                             pt.center = pcl2.person_center
                         AND pt.id = pcl2.person_id
                         AND ext.name = pcl2.CHANGE_ATTRIBUTE
                         AND pcl2.NEW_VALUE = ext.txtvalue
                         and pcl2.CHANGE_SOURCE not in ('MEMBER_TRANSFER')
                          WHERE
             p.center in (:center)
 and
 ext.txtvalue in ('Platinum')
 and p.status not in (4,5,7,8)
 and ((longtodate(pcl.entry_time) < :todate and longtodate(pcl.entry_time) > :fromdate) or (longtodate(pcl2.entry_time) < :todate and longtodate(pcl2.entry_time) > :fromdate ))
 and not exists (
 select
 p2.center ||'p'|| p2.id,
 prod.name,
 longtodate(i.entry_time)
 from  persons p2
 left join invoices i
 on
 p2.center = i.payer_center
 and
 p2.id = i.payer_id
 left join INVOICE_LINES_MT il
 on
 i.center = il.center
 and
 i.id = il.id
 left join products prod
 on
 il.PRODUCTCENTER = prod.center
 and
 il.PRODUCTID = prod.id
 WHERE
 p2.center = p.center and
 p2.id = p.id
 and prod.globalid = 'LOYALTY_PLATINUM_PTCOUPON2' )
