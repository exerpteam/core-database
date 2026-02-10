-- The extract is extracted from Exerp on 2026-02-08
-- Use for last day of month
WITH
    PARAMS AS
    (
        SELECT
            :scope                                                                 AS CENTER ,
            CAST (datetolong(TO_CHAR(DATE_TRUNC('day', d1.currentdate +2), 'YYYY-MM-DD HH24:MI')) AS BIGINT) AS STATUSFIELDTIME,
			CAST (datetolong(TO_CHAR(DATE_TRUNC('day', d1.currentdate +1), 'YYYY-MM-DD HH24:MI')) -1 AS BIGINT) AS STATUSFIELDTIMEEXTRA,
            CURRENTDATE,
            'DEBTOR' AS SELECTED_STATUS
         FROM
            (
                SELECT
                    CAST(to_date(:for_date,'YYYY-MM-DD') AS DATE) AS currentdate
            ) d1
    )
SELECT distinct
cen.country AS "Country",
   p.center ||'p'|| p.id as "Member ID",
    p.fullname         AS "Full Name",
CASE p.persontype
        WHEN 0 THEN 'PRIVATE'
        WHEN 1 THEN 'STUDENT'
        WHEN 2 THEN 'STAFF'
        WHEN 3 THEN 'FRIEND'
        WHEN 4 THEN 'CORPORATE'
        WHEN 5 THEN 'ONEMANCORPORATE'
        WHEN 6 THEN 'FAMILY'
        WHEN 7 THEN 'SENIOR'
        WHEN 8 THEN 'GUEST'
        WHEN 9 THEN 'CHILD'
        WHEN 10 THEN 'EXTERNAL_STAFF'
        ELSE 'UNKNOWN'
    END AS PERSONTYPE,
    case when normal_price.PRICE is null
    then sp.price
    else normal_price.PRICE
    end AS "Membership price",
    CASE
        WHEN sfp.id IS NOT NULL
        THEN sfp.START_DATE
        ELSE sp.from_date
    END AS "Free start date",
    CASE
        WHEN sfp.id IS NOT NULL
        THEN sfp.END_DATE
        when (sp.to_date is not null and sfp.id is null)
        then sp.to_date
        else sub.end_date
       END AS "Free end date",
    CASE
        WHEN sfp.id IS NOT NULL
        THEN 'Free period assigned'
        WHEN sp.to_date IS NULL
        THEN 'Free - Error'
        WHEN sp.type IN ('PRORATA',
                         'INITIAL')
        THEN 'Campaign (pro-rata)'
        WHEN sp.type IN ('CAMPAIGN')
        THEN 'Campaign'
        WHEN sp.type IN ('MANUAL')
        THEN 'Manual'
        WHEN sp.type IN ('CONVERSION')
        THEN 'Conversion'
        ELSE 'Other (' ||sp.type|| ')'
    END AS "Extra Category",
    CASE
        WHEN sfp.id IS NOT NULL
        THEN sfp.text
        ELSE sp.coment
    END AS "Comment",
    pr.name AS "MembershipName",
    sp.type AS "FreePeriodType",
    sub.START_DATE AS "SubStartDate",
    sub.center AS "CenterId",
    sub.id AS "SubsId",
    sfp.id AS "FreePeriodId",
    sfp.END_DATE AS "FreePeriodEnd",
    sp.to_date AS "PriceToDate",
    sub.end_date AS "SubEndDate"
    
FROM
    PERSONS P
CROSS JOIN
    PARAMS
JOIN
    SUBSCRIPTIONS sub
ON
    sub.OWNER_CENTER = p.center
    AND sub.owner_id = p.id
    AND sub.START_DATE <= PARAMS.CURRENTDATE
    AND (
        sub.END_DATE IS NULL
        OR sub.END_DATE >= PARAMS.CURRENTDATE)
JOIN
    HP.SUBSCRIPTIONTYPES st
ON
    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND st.id = sub.SUBSCRIPTIONTYPE_ID
    AND st.IS_ADDON_SUBSCRIPTION = 0
    and st.st_type in (0,1)
JOIN
    Products pr
ON
    st.Center = pr.Center
AND st.Id = pr.Id
and (pr.name not like 'PT by DD%%' or pr.name not in ('2x1 FREE Monthly incl. TOW_12'))

JOIN
        CENTERS cen 
ON 
		cen.ID = sub.OWNER_CENTER
    
JOIN
    SUBSCRIPTIONPERIODPARTS spp
ON
    spp.CENTER = sub.center
    AND spp.id = sub.id
    AND spp.FROM_DATE <= PARAMS.CURRENTDATE
 AND spp.to_date >= PARAMS.CURRENTDATE
    AND spp.SUBSCRIPTION_PRICE = 0
    AND (
        spp.SPP_STATE = 1
        OR spp.CANCELLATION_TIME >= PARAMS.STATUSFIELDTIME)
JOIN
    HP.SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = sub.center
    AND sp.SUBSCRIPTION_ID = sub.id
    AND sp.FROM_DATE <= :calculationsdate
AND (
        sp.TO_DATE IS NULL
        OR sp.TO_DATE >= PARAMS.CURRENTDATE)
    AND sp.CANCELLED = 0
-- and/* ((sp.type not IN ('PRORATA')) or*/
 --(sp.type in ('PRORATA') and sub.START_DATE <= ) 
left JOIN
    HP.SUBSCRIPTION_PRICE normal_price
ON
    normal_price.SUBSCRIPTION_CENTER = sub.center
    AND normal_price.SUBSCRIPTION_ID = sub.id
    AND normal_price.TO_DATE IS NULL
    AND normal_price.CANCELLED = 0
    and normal_price.PRICE != 0
left JOIN
    SUBSCRIPTION_REDUCED_PERIOD sfp
ON
    sub.CENTER = sfp.SUBSCRIPTION_CENTER
    AND sub.id = sfp.SUBSCRIPTION_ID
    AND sfp.STATE != 'CANCELLED'
  AND ((sfp.START_DATE <= :calculationsdate  AND sfp.END_DATE >= PARAMS.CURRENTDATE) or ((sfp.start_date between :calculationsdate and PARAMS.CURRENTDATE) and sfp.END_DATE>= PARAMS.CURRENTDATE and sfp.type not in ('PRORATA')))
 
 
JOIN
    (
        SELECT
            pcl1.PERSON_CENTER,
            pcl1.PERSON_ID,
            COALESCE(MAX(CASE pcl1.CHANGE_ATTRIBUTE WHEN 'STATUS_DEBTOR' THEN COALESCE(pcl1.new_value, 'false') END), 'false') AS Debtor,
            COALESCE(MAX(CASE pcl1.CHANGE_ATTRIBUTE WHEN 'STATUS_LATE_START' THEN COALESCE(pcl1.new_value, 'false') END), 'false') AS LateStart,
            COALESCE(MAX(CASE pcl1.CHANGE_ATTRIBUTE WHEN 'STATUS_FROZEN' THEN COALESCE(pcl1.new_value, 'false') END), 'false') AS Frozen,
            COALESCE(MAX(CASE pcl1.CHANGE_ATTRIBUTE WHEN 'STATUSEXTRA2' THEN COALESCE(pcl1.new_value, 'false') END), 'false') AS Extra
        FROM
            PERSON_CHANGE_LOGS pcl1
        CROSS JOIN
            PARAMS
        LEFT JOIN
            PERSON_CHANGE_LOGS pcl2
        ON
            pcl2.PREVIOUS_ENTRY_ID = pcl1.id
        WHERE
            (pcl1.CHANGE_ATTRIBUTE IN ('STATUS_DEBTOR',
                                      'STATUS_FROZEN',
                                      'STATUS_LATE_START')
            AND pcl1.ENTRY_TIME <= PARAMS.STATUSFIELDTIME
            AND (
                pcl2.id IS NULL
                OR pcl2.ENTRY_TIME > PARAMS.STATUSFIELDTIME)
            AND pcl1.PERSON_CENTER in (:scope)) or
  (pcl1.CHANGE_ATTRIBUTE IN ('STATUSEXTRA2')
            AND pcl1.ENTRY_TIME <= PARAMS.STATUSFIELDTIMEEXTRA
            AND (
                pcl2.id IS NULL
                OR pcl2.ENTRY_TIME > PARAMS.STATUSFIELDTIMEEXTRA)
            AND pcl1.PERSON_CENTER in (:scope))
        GROUP BY
            pcl1.PERSON_CENTER,
            pcl1.PERSON_ID ) STATUSES
ON
    STATUSES.PERSON_CENTER = P.CENTER
    AND STATUSES.PERSON_ID = P.ID
    AND STATUSES.Extra = 'true'
    AND STATUSES.debtor = 'false'
    AND STATUSES.LateStart = 'false'
    AND STATUSES.Frozen = 'false' --- only frozen, non debtors
WHERE
p.center in (:scope) and

  (sfp.TYPE NOT IN ('FREEZE','SUB_PERIOD') or (sfp.type is NULL and sp.price = 0 and (sp.to_date is NULL or sp.to_date >= PARAMS.CURRENTDATE )))

and pr.name not in ('2x1 FREE Monthly incl. TOW_12','Staff Free Full Monthly','Free Full Monthly','Regional Free Full Monthly Austria','22 DAY Ind Full Monthly 12 Freemium memberships','22 DAY Lifestyle Monthly incl. TOW_24 Free','22 DAY Classic Monthly incl. TOW_12 Free','22 DAY Ind Full Monthly 12 Freemium','Free Full Monthly ','Corporate Monthly incl. TOW_12 EPO FREE','Free Full Monthly incl. TOW','14 DAY Classic Monthly incl. TOW_12 Free','Health City Gold  Free','Tenant','Parking monthly Free no membership','National Germany Barter Free Full Annual incl. TOW_12 M','Special 5 Weeks Faceforce Free','Regional Berlin Barter Fulltime Free Annual_6 M','Classic 12 Month 14 Days Free','Groupon Lifestyle 24 Month Annual Free','Groupon Classic 12 Month Annual Free','Groupon Flexi 6 Month Annual Free','14 day Classic Premium 12 Free, 14 day Lifestyle Premium 24 Free', 'Classic 12 Month National Free', 'Groupon Flexi 3 Month Annual Free', '14 day Boutique 1M','14 day Classic Premium 12 Free', '14 day Lifestyle Premium 24 Free', '14 day Boutique 12M','@HOME Digital 14 DAY Monthly', '14 DAY Challenge', 'Regional Berlin Free Full incl. TOW_12 M', 'Free FIT in Monthly','Classic Corporate EPO/HIGH5 Annual 1', 'Groupon 24 Month Annual VIPP Free','Regional North Free Full incl. TOW_12 M','Free Full Monthly VIPP', 'Free Flexi Full Monthly incl. TOW','Classic National Free 12', 'Classic Corporate EPO/HIGH5 Annual 12','21-Day Trial', 'Aggregator Free','Regional West Free incl. TOW_12 M','Groupon 12 Month Annual VIPP Free','PT Subscription Free','2x1 FREE Lifestyle Premium_24','2x1 FREE Lifestyle VIPP_24')
    AND (
        P.BIRTHDATE IS NULL
        OR extract(YEAR FROM age(PARAMS.currentdate, P.BIRTHDATE)) >= 1) -- exclude KIDS