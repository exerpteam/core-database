-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-6907
 SELECT
   il.PERSON_CENTER||'p'||il.PERSON_ID   AS "Member ID",
   pr.NAME  AS "Free Clipcard sold",
   LongtodateC(i.ENTRY_TIME,i.center) AS "Date for the sale",
   csales_person.center||'p'||csales_person.id "Staff ID"
 FROM
   INVOICE_LINES_MT il
 JOIN
   INVOICES i
 ON
   i.CENTER = il.CENTER
   AND i.ID = il.ID
 JOIN
   PRODUCTS pr
 ON
   il.PRODUCTCENTER = pr.CENTER
   AND il.PRODUCTID = pr.ID
   AND pr.GLOBALID in ('PT30LEVEL1_1_CLIP_HK', 'PT30_LEVEL2_1_CLIP', 'PT30LEVEL3_1_CLIP_HK', 'PT30LEVEL4_1_CLIP_HK',
    'PT60LEVEL1_1_CLIP_HK', 'PT60_LEVEL_2_1_CLIP_HK', 'PT60_LEVEL2_10_CLIPS_FREE', 'PT60_LEVEL_3_1_CLIP_HK', 'PT60_LEVEL3_10_CLIPS_FREE',
    'PT60_LEVEL_4_1_CLIP_HK','PT60_LEVEL4_10_CLIPS_FREE','PT60_LEVEL_5_1_CLIP_HK','PT60DUO_LEVEL_1_1CLIP_FREE','PT60_DUO_LEVEL2_1_CLIP_FREE',
    'PT60DUO_LEVEL3_1_CLIP_FREE', 'PT60DUO_LEVEL4_1_CLIP_FREE')
 JOIN
    EMPLOYEES staff
 ON
    staff.center = i.EMPLOYEE_CENTER
    AND staff.id = i.EMPLOYEE_ID
 LEFT JOIN
    PERSONS sales_person
 ON
     sales_person.center = staff.personcenter
     AND sales_person.ID = staff.personid
 LEFT JOIN
     PERSONS csales_person
 ON
     csales_person.center = sales_person.TRANSFERS_CURRENT_PRS_CENTER
     AND csales_person.ID = sales_person.TRANSFERS_CURRENT_PRS_ID
 WHERE
   i.center in (:Scope)
   AND i.TRANS_TIME BETWEEN :From_Date AND :To_Date+24*2600*1000
