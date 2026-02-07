SELECT
	CASE OrderBy
		-- This is the record line, consisting of record count and remainder of visit info
		WHEN 3 THEN '"' || TO_CHAR(RecordNo) || '",' || FileLine
		-- This is the footer line, consisting of count of visit records and sum of entity numbers
		WHEN 4 THEN '"' || TO_CHAR(ROWNUM - 2) || '","0"'
		ELSE FileLine
	END FileLine
FROM
(
	SELECT
		-- Header record #1: VA entity number , file number (incremented by day), date / time , constants: %%BATCHNUMBER%% is replaced by Go Anywhere
		1 OrderBy, '"1067434512","%%BATCHNUMBER%%","' || TO_CHAR(sysdate, 'YYYYMMddHH24MISS') || '","Point Events Request"' FileLine, 
		0 RecordNo
	FROM
		DUAL
	UNION ALL
	SELECT
		-- Header record #2: Column Names
		2 OrderBy, '"RecordNo","RecordType","PartnerMembershipNo","SiteEntityNo","MemberEntityNo","Date","DetailedCategoryID"' FileLine, 
		0 RecordNo
	FROM
		DUAL
	UNION ALL
	SELECT
		3 OrderBy, '"Create","' || TO_CHAR(person.ExternalId) || '","' || sp.TXTVALUE || '","' || person.VitalityEntityNo || '","' || TO_CHAR(longToDateC(cin.CHECKIN_TIME,person.CENTER),'YYYYMMdd') || '","HPLA"' FileLine,
		RANK() OVER (ORDER BY cin.CHECKIN_TIME) RecordNo
	FROM
	(
		-- Get list of active corporate vitality members 
		SELECT
			p.CENTER,
			p.ID,
			p.External_ID ExternalId,
			LookupEntityId.TXTVALUE VitalityEntityNo
		FROM
			PERSONS p
		JOIN
			CENTERS c
		ON
			c.ID = p.CENTER and c.country = 'GB'
		JOIN
			RELATIVES comp_rel
		ON
			comp_rel.center = p.center
			AND comp_rel.id = p.id
			AND comp_rel.RTYPE = 3
			AND comp_rel.STATUS < 3
		JOIN
			COMPANYAGREEMENTS cag
		ON
			cag.center= comp_rel.RELATIVECENTER
			AND cag.id=comp_rel.RELATIVEID
			AND cag.subid = comp_rel.RELATIVESUBID
		JOIN
			persons comp
		ON
			comp.center = cag.center
			AND comp.id=cag.id
		LEFT JOIN
			PERSON_EXT_ATTRS LookupEntityId
		ON
			p.center = LookupEntityId.PERSONCENTER
			AND p.id = LookupEntityId.PERSONID
			AND LookupEntityId.name = '_eClub_PBLookupPartnerPersonId'
		WHERE
			comp.center = 4
			AND comp.ID = 674
			AND p.STATUS IN (1,3)
			AND TRIM(LookupEntityId.TXTVALUE) IS NOT NULL -- Oracle dumbness: it interprets an empty varchar string as NULL
		UNION
		-- Get list of non-corporate vitality members using extended attribute VITENT
		SELECT
			p.CENTER,
			p.ID,
			p.External_ID ExternalId,
			LookupEntityId.TXTVALUE VitalityEntityNo
		FROM
			PERSONS p
		JOIN
			PERSON_EXT_ATTRS LookupEntityId
		ON
			p.CENTER = LookupEntityId.PERSONCENTER
			AND p.ID = LookupEntityId.PERSONID
			AND LookupEntityId.NAME = 'VITENT'
		WHERE
			p.STATUS IN (1,3)
			AND LookupEntityId.TXTVALUE IS NOT NULL
			AND TRIM(LookupEntityId.TXTVALUE) IS NOT NULL -- Oracle dumbness: it interprets an empty varchar string as NULL
	) person

	JOIN CHECKINS cin
	ON
		cin.PERSON_CENTER = person.CENTER
		AND cin.PERSON_ID = person.ID
	LEFT JOIN 
		SYSTEMPROPERTIES sp
	ON
		sp.SCOPE_ID = cin.CHECKIN_CENTER
		AND sp.SCOPE_TYPE = 'C'
		AND sp.GLOBALID = 'PruhealthBranchEntityNo'
	WHERE 
		longToDateC(cin.CHECKIN_TIME,person.CENTER) BETWEEN $$FromDate$$ AND $$ToDate$$
	UNION ALL
	-- This is a placeholder for the footer which will contain calculated fields: count of visit records
	SELECT
		4 OrderBy, 
		'' FileLine,
		0 RecordNo
	FROM
		DUAL
)
ORDER BY
	OrderBy, RecordNo
