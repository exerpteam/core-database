-- The extract is extracted from Exerp on 2026-02-08
-- Report showing price increases for each club by 'apply date' (date the increase is applicable for). 
 SELECT
     sub.center,
     sub.id,
     centre.ID club_Id,
     centre.NAME club_name,
     p.CENTER || 'p' || p.id member_id,
     mex.TXTVALUE member_salutation,
     prod.name "subscription",
     p.FIRSTNAME member_firstname,
     p.LASTNAME member_lastname,
     sub.SUBSCRIPTION_PRICE "CURRENT PRICE",
     pc.PRICE "NEW PRICE",
     pc.PRICE - sub.SUBSCRIPTION_PRICE "VARIANCE",
     TO_CHAR(pc.FROM_DATE, 'DD.MM.YYYY') APPLY_DATE,
     CASE
         WHEN payer.CENTER IS NOT NULL
         THEN payer.CENTER || 'p' || payer.ID
         ELSE NULL
     END payer_id,
     pex.TXTVALUE payer_salutation,
     payer.FIRSTNAME payer_firstname,
     payer.LASTNAME payer_lastname,
     pc.ID change_id,
     CASE
         WHEN pc.CANCELLED = 1
         THEN 'CANCELLED'
         WHEN pc.APPLIED = 1
         THEN 'APPLIED'
         WHEN pc.PENDING = 1
         THEN 'PENDING'
         WHEN pc.APPROVED = 1
         THEN 'APPROVED'
         WHEN pc.APPROVED = 0
             AND pc.PENDING = 0
             AND pc.APPLIED = 0
             AND pc.CANCELLED = 0
         THEN 'DRAFT'
         ELSE 'ERROR'
     END change_State,
     etc.NAME AS "Event Name",
 CASE  DELIVERYMETHOD  WHEN 0 THEN  'STAFF'  WHEN 1 THEN  'EMAIL'  WHEN 2 THEN  'SMS'  WHEN 3 THEN  'PERSINTF' WHEN 4 THEN  'BLOCKPERSINTF' WHEN 5 THEN  'LETTER' ELSE null END AS "Delivery Channel",
     CASE
         WHEN pc.NOTIFIED = 1
         THEN 'Yes'
         ELSE 'No'
     END change_sent,
     CASE
         WHEN pc.APPROVED_EMPLOYEE_CENTER IS NOT NULL
             AND pc.APPROVED = 1
         THEN pc.APPROVED_EMPLOYEE_CENTER || 'emp' || pc.APPROVED_EMPLOYEE_ID
         ELSE NULL
     END change_approved_by
 FROM
     SUBSCRIPTIONS sub
 JOIN
     SUBSCRIPTION_PRICE pc
 ON
     pc.SUBSCRIPTION_CENTER = sub.CENTER
     AND pc.SUBSCRIPTION_ID = sub.ID
 JOIN
     SUBSCRIPTIONTYPES stype
 ON
     sub.SUBSCRIPTIONTYPE_CENTER = stype.CENTER
     AND sub.SUBSCRIPTIONTYPE_ID = stype.ID
 JOIN
     PRODUCTS prod
 ON
     stype.CENTER = prod.CENTER
     AND stype.ID = prod.ID
 JOIN
     CENTERS centre
 ON
     sub.CENTER = centre.ID
 JOIN
     PRODUCTS joinProd
 ON
     stype.PRODUCTNEW_CENTER = joinProd.CENTER
     AND stype.PRODUCTNEW_ID = joinProd.ID
 JOIN
     PERSONS p
 ON
     p.CENTER = sub.OWNER_CENTER
     AND p.ID = sub.OWNER_ID
 LEFT JOIN
     RELATIVES op_rel
 ON
     op_rel.RELATIVECENTER = sub.OWNER_CENTER
     AND op_rel.RELATIVEID = sub.OWNER_ID
     AND op_rel.RTYPE = 12
     AND op_rel.STATUS < 3
 LEFT JOIN
     persons payer
 ON
     payer.CENTER = op_rel.CENTER
     AND payer.ID = op_rel.ID
 LEFT JOIN
     PERSON_EXT_ATTRS mex
 ON
     mex.PERSONCENTER = p.CENTER
     AND mex.PERSONID = p.ID
     AND mex.NAME = '_eClub_Salutation'
 LEFT JOIN
     PERSON_EXT_ATTRS pex
 ON
     pex.PERSONCENTER = payer.CENTER
     AND pex.PERSONID = payer.ID
     AND pex.NAME = '_eClub_Salutation'
 LEFT JOIN
     PERSONS gm
 ON
     centre.MANAGER_CENTER = gm.CENTER
     AND centre.MANAGER_ID = gm.ID
 LEFT JOIN
     EVENT_TYPE_CONFIG etc
 ON
     etc.ID = pc.EVENT_CONFIG_ID
 LEFT JOIN
     MESSAGES m on m.REFERENCE = 'sp'||pc.ID
  left join TEMPLATES t on t.id = m.TEMPLATEID
 WHERE
     pc.FROM_DATE = $$ApplyDate$$
     AND sub.CENTER IN ($$Scope$$)
     AND pc.TYPE IN ('SCHEDULED')
     AND (
         -- All
         (
             $$State$$ = '0')
         OR
         -- Draft
         (
             $$State$$ = '1'
             AND pc.APPROVED = 0
             AND pc.PENDING = 0
             AND pc.APPLIED = 0
             AND pc.CANCELLED = 0)
         OR
         -- Approved
         (
             $$State$$ = '2'
             AND pc.APPROVED = 1
             AND pc.PENDING = 0
             AND pc.APPLIED = 0
             AND pc.CANCELLED = 0)
         OR
         -- Pending
         (
             $$State$$ = '3'
             AND pc.PENDING = 1
             AND pc.APPLIED = 0
             AND pc.CANCELLED = 0)
         OR
         -- Applied
         (
             $$State$$ = '4'
             AND pc.APPLIED = 1
             AND pc.CANCELLED = 0)
         OR
         -- Cancelled
         (
             $$State$$ = '9'
             AND pc.CANCELLED = 1) )
