-- The extract is extracted from Exerp on 2026-02-08
-- Report to show live sales
 SELECT
     cen.SHORTNAME,
     SS.SALES_DATE,
     p.CENTER || 'p' || p.ID personId,
     SS.SUBSCRIPTION_CENTER || 'ss' || SS.SUBSCRIPTION_ID subId,
     p.FULLNAME,
	 email.txtvalue  AS "Email",
     company.FULLNAME AS Company,
     pr.NAME "subscription",
     prg.NAME productGroup,
     SS.TYPE salesType,
     longtodateC(SU.CREATION_TIME, SU.CENTER) created
 FROM
     SUBSCRIPTION_SALES SS
 JOIN
     SUBSCRIPTIONS SU
 ON
     SUBSCRIPTION_CENTER = SU.CENTER
     AND SUBSCRIPTION_ID = SU.ID
 INNER JOIN
     SUBSCRIPTIONTYPES ST
 ON
     (
         SS.SUBSCRIPTION_TYPE_CENTER = ST.CENTER
         AND SS.SUBSCRIPTION_TYPE_ID = ST.ID)
 INNER JOIN
     PRODUCTS PR
 ON
     (
         SS.SUBSCRIPTION_TYPE_CENTER = PR.CENTER
         AND SS.SUBSCRIPTION_TYPE_ID = PR.ID)
 INNER JOIN
     PERSONS p
 ON
     p.center = SS.OWNER_CENTER
     AND p.ID = ss.OWNER_ID
 INNER JOIN
     CENTERS cen
 ON
     cen.ID = p.CENTER
 LEFT JOIN
     PRODUCT_GROUP prg
 ON
     prg.ID = pr.PRIMARY_PRODUCT_GROUP_ID
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     p.center=email.PERSONCENTER
     AND p.id=email.PERSONID
     AND email.name='_eClub_Email'
 LEFT JOIN
     RELATIVES r
 ON
     r.CENTER = p.CENTER
     AND r.ID = p.ID
     AND r.RTYPE = 3
     AND r.STATUS = 1
 LEFT JOIN
     PERSONS company
 ON
     company.ID = r.RELATIVEID
     AND company.CENTER = r.RELATIVECENTER
 WHERE
     (
         SS.SUBSCRIPTION_TYPE_CENTER IN ($$Scope$$)
         AND SS.SALES_DATE >= $$SalesFromDate$$
         AND SS.SALES_DATE <= $$SalesToDate$$ )
        --Exludung comps, operating x 2 & juniors
        AND PRG.ID NOT IN (5405,5611,5613,5406,5407,5615)
 order by cen.ID, SS.SALES_DATE
