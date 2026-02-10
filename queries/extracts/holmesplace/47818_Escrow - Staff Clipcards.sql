-- The extract is extracted from Exerp on 2026-02-08
-- Staff only. Excludes most clips which are not PT
-- Parameters: Center(SCOPE)

SELECT

	center.NAME AS "XClub",
    p.center || 'p' || p.id AS "XPERSONID",
	clips.CENTER || 'cc' || clips.id || 'id' || clips.subid AS "XCCID",
    pd.GLOBALID "XGlobalName",
	center.ID AS "XcenterId",
	pd.primary_product_group_id AS "ProductGroupId",
	pg.name AS "XprodGroup",
	pd.NAME AS "XnameConvirt",
	p.external_id AS "ExternalUserId",
CASE p.STATUS
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARY INACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    								END AS "Xperspnstatus",
	CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN  'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS "XpersonType",

	NULL AS "ExternalProductId",
	NULL AS "ProductName",
	NULL AS "BasePrice",
	il.TOTAL_AMOUNT  AS "SellingPrice",
	'19,00' AS "VatRate",
	clips.CLIPS_INITIAL AS "InitialQuantity",
    clips.CLIPS_LEFT AS "RemainingQuantity",
	CASE clips.CLIPS_INITIAL
	WHEN 1 THEN '0'
	ELSE '1'
	END AS "IsBundle",
	NULL AS "IsBundle",
	TO_CHAR(longtodate(clips.VALID_FROM), 'DD-MM-YYYY') AS "SellDate",
    TO_CHAR(longtodate(clips.VALID_UNTIL), 'DD-MM-YYYY') AS "ExpiryDate",
	NULL AS "DefaultEmployeeLogin",
	NULL AS "SellerEmployeeLogin",
	NULL AS "UserNumber",
	NULL AS "PaymentType",
	NULL AS "BarCode"
    
   
    
    
    
FROM
    clipcards clips
JOIN CENTERS center
ON
    clips.center = center.id
JOIN CLIPCARDTYPES ct
ON
    ct.center = clips.center
    AND ct.id = clips.id
JOIN INVOICELINES il
ON
    il.center = clips.INVOICELINE_CENTER
    AND il.id = clips.INVOICELINE_ID
    AND il.SUBID = clips.INVOICELINE_SUBID

JOIN products pd
ON
    pd.center = ct.center
    AND pd.id = ct.id

LEFT JOIN product_group pg
ON pd.primary_product_group_id = pg.id






JOIN persons p
ON
    p.center = clips.OWNER_CENTER
    AND p.id = clips.OWNER_ID
WHERE
    p.CENTER IN ($$scope$$)
	AND p.persontype IN (2)   ---staff
	AND clips.CLIPS_LEFT > 0
    AND clips.FINISHED = 0
    AND clips.CANCELLED = 0
    AND clips.BLOCKED = 0
	AND pd.NAME NOT IN ('Towel x 2', 'Deposit Parking','Parking_1 Ticket', 'Parking_1 Ticket for 4h', 'Day Pass Parking', 'Parking_ Aggregator', 'Gesundheits-Coaching 1st Clip 1x55min', 'Guestcard _1 Day regular', 'Guestcard_1 Entry correctur', 'Gesundheits-Coaching 2x30min', 'Guestpass Health Week', 'Personal Training Beratung', 'Bodyscan_1 Visit', 'Fitness Check')

AND
(
p.STATUS IN (0,1,3,6,9)
OR (
p.status IN (2)
AND pg.name NOT IN ('GYM Income', 'Coaching', 'Nutrition Income', 'Studio Income', 'Studio: Courses')))

AND (
(
clips.VALID_FROM >= $$SellDateFrom$$
AND pd.NAME NOT IN ('Personal Training Beratung'))
OR
(
clips.VALID_FROM >= $$PTClipsSellDateFrom$$
AND pg.name IN ('PT Clipcards'))
OR
(
clips.VALID_FROM >= $$TrialSellDateFrom$$
AND pd.NAME IN ('Personal Training Beratung'))
OR
(
clips.VALID_FROM >=$$GuestPassSellDateFrom$$
AND pg.NAME IN ('Aktivity'))
AND p.status NOT IN (2)
OR
(clips.VALID_FROM >=$$LeadGuestPassSellDateFrom$$
AND pg.NAME IN ('Aktivity')
AND p.status IN (0,6))

)

