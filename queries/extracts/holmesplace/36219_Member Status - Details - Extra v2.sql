WITH
    PARAMS AS
    (
        SELECT
            :scope                                                                 AS CENTER ,
            CAST (datetolong(TO_CHAR(DATE_TRUNC('day', d1.currentdate +2), 'YYYY-MM-DD HH24:MI')) AS BIGINT) AS STATUSFIELDTIME,
            CURRENTDATE,
            'DEBTOR' AS SELECTED_STATUS
         FROM
            (
                SELECT
                    CAST(to_date(:for_date,'YYYY-MM-DD') AS DATE) AS currentdate
            ) d1
    )
SELECT distinct
   p.center ||'p'|| p.id as "Member ID",
    p.fullname         AS "Full Name",
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
    pr.name,
    sp.type,
    sub.START_DATE,
    PARAMS.CURRENTDATE-31,
    sub.center,
    sub.id,
    sfp.id,
    sfp.END_DATE,
    sp.to_date,
    sub.end_date
    
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
  AND ((sfp.START_DATE <= :calculationsdate  AND sfp.END_DATE+1 >= PARAMS.CURRENTDATE) or ((sfp.start_date between :calculationsdate and PARAMS.CURRENTDATE) and sfp.END_DATE>= PARAMS.CURRENTDATE and sfp.type not in ('PRORATA')))
 
 
JOIN
    (
        SELECT
            pcl1.PERSON_CENTER,
            pcl1.PERSON_ID,
            COALESCE(MAX(CASE pcl1.CHANGE_ATTRIBUTE WHEN 'STATUS_DEBTOR' THEN COALESCE(pcl1.new_value, 'false') END), 'false') AS Debtor,
            COALESCE(MAX(CASE pcl1.CHANGE_ATTRIBUTE WHEN 'STATUS_LATE_START' THEN COALESCE(pcl1.new_value, 'false') END), 'false') AS LateStart,
            COALESCE(MAX(CASE pcl1.CHANGE_ATTRIBUTE WHEN 'STATUS_FROZEN' THEN COALESCE(pcl1.new_value, 'false') END), 'false') AS Frozen,
            COALESCE(MAX(CASE pcl1.CHANGE_ATTRIBUTE WHEN 'STATUS_EXTRA' THEN COALESCE(pcl1.new_value, 'false') END), 'false') AS Extra
        FROM
            PERSON_CHANGE_LOGS pcl1
        CROSS JOIN
            PARAMS
        LEFT JOIN
            PERSON_CHANGE_LOGS pcl2
        ON
            pcl2.PREVIOUS_ENTRY_ID = pcl1.id
        WHERE
           pcl1.CHANGE_ATTRIBUTE IN ('STATUS_FROZEN',
                                      'STATUS_LATE_START',
                                      'STATUS_EXTRA',
                                      'STATUS_DEBTOR')
          AND pcl1.ENTRY_TIME <= PARAMS.STATUSFIELDTIME
            AND (
                pcl2.id IS NULL
                OR pcl2.ENTRY_TIME > PARAMS.STATUSFIELDTIME)
            AND pcl1.PERSON_CENTER in (:scope)
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

and pr.name not in ('2x1 FREE Monthly incl. TOW_12','Free Full Monthly','22 DAY Ind Full Monthly 12 Freemium memberships','22 DAY Lifestyle Monthly incl. TOW_24 Free','22 DAY Classic Monthly incl. TOW_12 Free')
    AND (
        P.BIRTHDATE IS NULL
        OR extract(YEAR FROM age(PARAMS.currentdate, P.BIRTHDATE)) >= 16) -- exclude KIDS