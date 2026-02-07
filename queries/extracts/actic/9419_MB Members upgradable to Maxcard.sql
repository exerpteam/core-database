SELECT
	(p.center + 9000) AS kb,
	p.center centerid,
    cen.NAME CLUB,
    p.center || 'p' || p.id personid,
    p.ssn,
	p.birthdate,
    DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') PERSONTYPE, 
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') PERSONSTATUS,
--  DECODE (sub.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') subscription_STATE,
--  DECODE (sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  SUBSCRIPTION_SUB_STATE,
    p.FIRSTNAME,
    p.LASTNAME,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ZIPCODE,
    p.CITY,
    pea_email.txtvalue as Email,
    pea_mobile.txtvalue as Mobile,	
--  prod.PRICE currentProdPrice,
    current_sub.SUBSCRIPTION_PRICE currentMemberPrice,
    prod.NAME,
    latest_att.att_count AS TotalCheckInsInLast30Days,
    decode(current_sub.MaxStType, 0, 'CASH', 1, 'EFT', null) as MembershipType,
    decode(current_sub.MaxKort, 1, 'TRUE', 'FALSE') as AccessMaxkort,
    decode(CENTER_MAX_KORT.cnt, 0, 'FALSE', 'TRUE') as CenterHasMaxkort,
	TO_CHAR(TRUNC(exerpsysdate()), 'YYYY-MM-DD') todays_date
FROM
	persons p

left join PERSON_EXT_ATTRS pea_email on pea_email.PERSONCENTER = p.center and pea_email.PERSONID = p.id and pea_email.NAME = '_eClub_Email'
left join PERSON_EXT_ATTRS pea_mobile on pea_mobile.PERSONCENTER = p.center and pea_mobile.PERSONID = p.id and pea_mobile.NAME = '_eClub_PhoneSMS'
	
/* check if member has maxkort */
left join 
	(select 
        sub.owner_center,
        sub.owner_id,
		sub.SUBSCRIPTION_PRICE,
		st.center AS st_center,
		st.id AS st_id,
        max(nvl(sub.end_date, to_date('2100-01-01', 'YYYY-MM-DD'))) as MaxEndDate,
        max(case when st.ST_TYPE = 0 then 0 when sub.BINDING_END_DATE is null or exerpsysdate() > sub.BINDING_END_DATE then sub.SUBSCRIPTION_PRICE else sub.BINDING_PRICE end) as MaxEFTPrice,
        max(case when st.ST_TYPE = 1 then 0 else sub.SUBSCRIPTION_PRICE end) as MaxCashPrice,
        max(st.st_type) as MaxStType,
        max(case when pgl.PRODUCT_CENTER is not null then 1 else 0 end) as MaxKort
    from
        SUBSCRIPTIONS sub
    join
        SUBSCRIPTIONTYPES st on st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER and st.id = sub.SUBSCRIPTIONTYPE_ID
    left join 
        PRODUCT_AND_PRODUCT_GROUP_LINK pgl on pgl.PRODUCT_CENTER = st.center and pgl.PRODUCT_ID = st.id and pgl.PRODUCT_GROUP_ID = 2024
    where 
        sub.STATE in (2,4,8)
    group by sub.owner_center, sub.owner_id, sub.subscription_price, st.center, st.id

	) current_sub 
on 
	current_sub.owner_center = p.center 
	and current_sub.owner_id = p.id

/* check i center has maxkort */
JOIN 
    (SELECT 
		mxpdt.center, 
		COUNT(*) AS CNT 
	FROM 
		products mxpdt 
	WHERE 
		mxpdt.GLOBALID = 'EFT_12_M_AREA' 
		AND mxpdt.BLOCKED = 0 
	GROUP BY mxpdt.center
    ) CENTER_MAX_KORT 
ON 
	CENTER_MAX_KORT.center = p.center

/* checkins last 30 days */
LEFT JOIN
    (
        SELECT
            attends.person_center,
            attends.person_id,
            COUNT(*) AS att_count
        FROM
            attends
        WHERE
            attends.state = 'ACTIVE'
        AND attends.start_time > (datetolong(TO_CHAR(exerpsysdate(), 'YYYY-MM-DD HH24:MI')) - 30 * 86400 * 1000)
        GROUP BY
            attends.person_center,
            attends.person_id
    )
    latest_att
ON
    latest_att.person_center = p.center
	AND latest_att.person_id = p.id

/* Join products  */
JOIN PRODUCTS prod
ON
    current_sub.st_center = prod.CENTER
    AND current_sub.st_id = prod.ID

/* Join centers */
JOIN centers cen
ON
    cen.ID = p.CENTER	
	
WHERE
	p.sex != 'C'
	and p.status = 1
	and p.center in (:scope)
	and p.PERSONTYPE not in (2,4,8,9)
	AND current_sub.MaxStType = 1
	AND CENTER_MAX_KORT.cnt != 0
	AND current_sub.MaxKort != 1
	AND UPPER(prod.NAME) NOT LIKE ('%BAD%')
	AND UPPER(prod.NAME) NOT LIKE ('%LIFESTYLE%')
	AND UPPER(prod.NAME) NOT LIKE ('%JUNIOR%')
	AND UPPER(prod.NAME) NOT LIKE ('%BARN%')
	
ORDER BY p.center, p.id