WITH
    params AS materialized
    (
        SELECT
            (:date_from)::DATE AS date_from,
            (:date_to)::DATE   AS date_to,
            c.id
        FROM
            centers c
        WHERE
            c.id IN (:scope)
    ),
    pmp_xml AS
    (
        SELECT
            sp.id,
            CAST(convert_from(sp.mimevalue, 'UTF-8') AS XML) AS pxml
        FROM
            evolutionwellness.systemproperties sp
        WHERE
            sp.globalid = 'DYNAMIC_EXTENDED_ATTRIBUTES'
    )
    ,
    second_Table AS
    (
        SELECT
            UNNEST(xpath('attributes/attribute',px.pxml))::text AS xml_content,
			px.pxml
	     FROM
            pmp_xml px
        JOIN
            evolutionwellness.systemproperties sp
        ON
            sp.id = px.id
    )
    ,
    third_Table AS
    (
        SELECT
            split_part(xml_content,'"',2) AS Attribute, 
			unnest(string_to_array(xml_content, 'possibleValue id=')) AS Value,
			split_part(unnest(string_to_array(xml_content, 'possibleValue id=')),'"',2) AS Source,
			split_part(unnest(string_to_array(xml_content, 'possibleValue id=')),'>',2) AS tmp_SourceName
        FROM
            second_Table
     ),
	SourceValues AS
	(
		select 
			Attribute,
			Source,
			SUBSTRING(tmp_SourceName, 1, POSITION('<' IN tmp_SourceName)-1) AS Source_Name
		from 
			third_table
		where attribute = 'Source' and Source != 'Source'
	)


SELECT DISTINCT
    c1.country            AS "Country Name",
    cex1.txt_value        AS "Brand",
    c1.name               AS "Club Name",
    p1.center||'p'||p1.id AS "Member Number",
    p1.external_id        AS "Member external ID",
    p1.firstname          AS "First Name",
    p1.lastname           AS "Last Name",
    CASE
        WHEN ccc1.center IS NOT NULL
        THEN 'Arrears'
        WHEN s1.state = 4
        THEN 'Frozen'
        WHEN p1.BLACKLISTED = 2
        THEN 'Suspended'
        ELSE 'OK'
    END AS "Member Status",
    CASE
        WHEN ccc1.center IS NULL
        THEN 'OK'
        ELSE 'Arrears'
    END      AS "Payment Status",
    COALESCE(sv1.Source_Name, pea_source1.txtvalue) AS "Referral Marketing Source",
    pea_campaign1.txtvalue 	AS "Referral Markering Campaign",
    pr1.name AS "Plan Name",
    NULL     AS "Plan Class",
    CASE
        WHEN (st1.periodunit=2
            AND st1.st_type=0)
        THEN st1.periodcount
        WHEN (st1.periodunit=2
            AND st1.st_type!=0)
        THEN st1.bindingperiodcount
        ELSE NULL
    END AS "MCP Duration",
    CASE
        WHEN st1.st_type=0
        THEN 'Cash'
        WHEN ch1.ctype IN (141,
                           144,
                           160,
                           169,
                           173,
                           175,
                           183,
                           184,
                           186,
                           188,
                           190,
                           193,
                           194,
                           196,
                           197,
                           198,
                           203)
        THEN 'Credit Card'
        WHEN ch1.ctype IN (1,
                           2,
                           4,
                           64,
                           130,
                           137,
                           140,
                           143,
                           145,
                           146,
                           148,
                           150,
                           152,
                           153,
                           155,
                           156,
                           157,
                           158,
                           159,
                           165,
                           167,
                           168,
                           172,
                           176,
                           177,
                           178,
                           179,
                           180,
                           181,
                           182,
                           185,
                           187,
                           189,
                           191,
                           192,
                           199,
                           200,
                           201,
                           202,
                           204,
                           205,
                           206)
        THEN 'Direct Debit'
        WHEN ch1.ctype IN (8,
                           16,
                           32,
                           128,
                           129,
                           131,
                           132,
                           133,
                           134,
                           135,
                           136,
                           139,
                           142,
                           147,
                           149,
                           151,
                           154,
                           161,
                           166,
                           170,
                           171,
                           174,
                           195)
        THEN 'Invoice'
        ELSE 'UNKNOWN'
    END AS "Primary Payment Method",
    CASE
        WHEN st1.st_type!=0
        AND (s1.start_date<=s1.end_date
            OR  s1.end_Date IS NULL )
        THEN s1.SUBSCRIPTION_PRICE
        WHEN st1.st_type=0
        AND s1.start_date<=s1.end_date
        THEN ROUND (s1.SUBSCRIPTION_PRICE / greatest(MONTHS_BETWEEN(s1.end_date, s1.start_date),1))
    END                 AS "Revised Yield",
    pea_creat1.txtvalue AS "Join Date",
    s1.start_date       AS "Start Date",
    CASE
        WHEN UPPER(p_emp1.fullname) LIKE '% API %'
        THEN '1'
        ELSE '0'
    END                                          AS "JOL Joiner",
    COUNT(*) over(partition BY p1.center, p1.id) AS "No Of Referrals",
    cex2.txt_value                               AS "Referee Brand",
    c2.name                                      AS "Referee Club Name",
    p2.center||'p'||p2.id                        AS "Referee Member Number",
    p2.external_id                               AS "Referee Member external ID",
    p2.firstname                                 AS "Referee First Name",
    p2.lastname                                  AS "Referee Last Name",
    CASE
        WHEN ccc2.center IS NOT NULL
        THEN 'Arrears'
        WHEN s2.state = 4
        THEN 'Frozen'
        WHEN p2.BLACKLISTED = 2
        THEN 'Suspended'
        ELSE 'OK'
    END AS "Referee Member Status",
    CASE
        WHEN ccc2.center IS NULL
        THEN 'OK'
        ELSE 'Arrears'
    END      AS "Referee Payment Status",
    pr2.name AS "Referee Plan Name",
    NULL     AS "Referee Plan Class",
    CASE
        WHEN (st2.periodunit=2
            AND st2.st_type=0)
        THEN st2.periodcount
        WHEN (st2.periodunit=2
            AND st2.st_type!=0)
        THEN st2.bindingperiodcount
        ELSE NULL
    END AS "Referee MCPMonths",
    CASE
        WHEN st2.st_type=0
        THEN 'Cash'
        WHEN ch2.ctype IN (141,
                           144,
                           160,
                           169,
                           173,
                           175,
                           183,
                           184,
                           186,
                           188,
                           190,
                           193,
                           194,
                           196,
                           197,
                           198,
                           203)
        THEN 'Credit Card'
        WHEN ch2.ctype IN (1,
                           2,
                           4,
                           64,
                           130,
                           137,
                           140,
                           143,
                           145,
                           146,
                           148,
                           150,
                           152,
                           153,
                           155,
                           156,
                           157,
                           158,
                           159,
                           165,
                           167,
                           168,
                           172,
                           176,
                           177,
                           178,
                           179,
                           180,
                           181,
                           182,
                           185,
                           187,
                           189,
                           191,
                           192,
                           199,
                           200,
                           201,
                           202,
                           204,
                           205,
                           206)
        THEN 'Direct Debit'
        WHEN ch2.ctype IN (8,
                           16,
                           32,
                           128,
                           129,
                           131,
                           132,
                           133,
                           134,
                           135,
                           136,
                           139,
                           142,
                           147,
                           149,
                           151,
                           154,
                           161,
                           166,
                           170,
                           171,
                           174,
                           195)
        THEN 'Invoice'
        ELSE 'UNKNOWN'
    END AS "Referee Primary Payment Method",
    CASE
        WHEN st2.st_type!=0
        AND (s2.start_date<=s2.end_date
            OR  s2.end_Date IS NULL )
        THEN s2.SUBSCRIPTION_PRICE
        WHEN st2.st_type=0
        AND s2.start_date<=s2.end_date
        THEN ROUND (s2.SUBSCRIPTION_PRICE / greatest(MONTHS_BETWEEN(s2.end_date, s2.start_date),1))
    END                 AS "Referee Yield",
    pea_creat2.txtvalue AS "Referee Join Date",
    s2.start_date       AS "Referee Start Date",
    CASE
        WHEN gym.gym
        THEN gym.gym
        ELSE false
    END AS "Modular Plan",
    CASE
        WHEN UPPER(mpr.cached_productname) LIKE '%UNLIMITED GROUP FITNESS%'
        THEN '1'
        ELSE '0'
    END AS "UNL",
    CASE
        WHEN UPPER(mpr.cached_productname) LIKE '%UNLIMITED CYCLING%'
        THEN '1'
        ELSE '0'
    END AS "CYC",
    CASE
        WHEN UPPER(mpr.cached_productname) LIKE '%UNLIMITED HIIT%'
        THEN '1'
        ELSE '0'
    END AS "HIT",
    CASE
        WHEN UPPER(mpr.cached_productname) LIKE '%UNLIMITED MIND%'
        THEN '1'
        ELSE '0'
    END  AS "MBD",
    NULL AS "OTH",
    CASE
        WHEN gym.gym
        THEN gym.gym
        ELSE false
    END AS "GYM",
    CASE
        WHEN UPPER(p_emp2.fullname) LIKE '% API %'
        THEN '1'
        ELSE '0'
    END  AS "JOL Joiner",
--  NULL AS "Referee Contact Method",
    COALESCE(sv2.Source_Name, pea_source2.txtvalue) AS  "Referee Marketing Source"
/* #187280    CAS
        WHEN pea_source2.txtvalue IN ('CPO',
                                      'CPAIA')
        THEN 'Corporate'
        WHEN pea_source2.txtvalue IN ('EMWWYB')
        THEN 'Ex-Member'
        WHEN pea_source2.txtvalue IN ('GV')
        THEN 'Guest Visit'
        WHEN pea_source2.txtvalue IN ('IAM',
                                      'IFT',
                                      'Internet',
                                      'Internet - Web Apps',
                                      'IOR',
                                      'ISM',
                                      'IWA',
                                      'IWWYB')
        THEN 'Internet'
        WHEN pea_source2.txtvalue IN ('ORSM',
                                      'ORCLB',
                                      'ORFV')
        THEN 'Outreach'
        WHEN pea_source2.txtvalue IN ('PIWINMTVC',
                                      'PIWIES',
                                      'PIWISMS',
                                      'PIWIDM',
                                      'PIWIE',
                                      'PIWIW',
                                      'PIWIFFC',
                                      'PIWISOP')
        THEN 'Phone-In/Walk-In'
        WHEN pea_source2.txtvalue IN ('RFLG',
                                      'RFSC',
                                      'RFBF',
                                      'RFP',
                                      'RFBP')
        THEN 'Referral'
        ELSE 'Other'
    END AS "Referee Marketing Source"                            */
FROM
    persons p2
JOIN
    params
ON
    p2.center=params.id
JOIN
    relatives r
ON
    r.center=p2.center
AND r.id=p2.id
JOIN
    persons p1
ON
    r.relativecenter=p1.center
AND r.relativeid=p1.id
JOIN
    centers c1
ON
    p1.center = c1.id
    LEFT JOIN
            PERSON_EXT_ATTRS pea_source1
        ON
            pea_source1.PERSONCENTER = p1.center
        AND pea_source1.PERSONID = p1.id
        AND pea_source1.NAME = 'Source'
    LEFT JOIN
	    SourceValues sv1
	ON
	    sv1.Source = pea_source1.txtvalue
    LEFT JOIN
            PERSON_EXT_ATTRS pea_campaign1
        ON
            pea_campaign1.PERSONCENTER = p1.center
        AND pea_campaign1.PERSONID = p1.id
        AND pea_campaign1.NAME = 'Campaign'
JOIN
    centers c2
ON
    p2.center=c2.id
    ----------------------person 2 details
    ---------------------------------------------------------
JOIN
    evolutionwellness.person_ext_attrs pea_creat2
ON
    p2.center=pea_creat2.personcenter
AND p2.id=pea_creat2.personid
LEFT JOIN
    subscriptions s2
ON
    s2.owner_center=p2.center
AND s2.owner_id=p2.id
AND s2.state IN (2,
                 4)
LEFT JOIN
    products pr2
ON
    s2.subscriptiontype_center=pr2.center
AND s2.subscriptiontype_id=pr2.id
LEFT JOIN
    account_receivables ar2
ON
    ar2.customercenter=p2.center
AND ar2.customerid=p2.id
AND ar2.ar_type=4
AND ar2.state=0
LEFT JOIN
    payment_agreements pag2
ON
    ar2.center=pag2.center
AND ar2.id=pag2.id
AND pag2.active=true
LEFT JOIN
    clearinghouses ch2
ON
    ch2.id=pag2.clearinghouse
LEFT JOIN
    evolutionwellness.center_ext_attrs cex2
ON
    c2.id= cex2.center_id
AND cex2.name='GoXProBrand'
LEFT JOIN
    evolutionwellness.subscriptiontypes st2
ON
    s2.subscriptiontype_center=st2.center
AND s2.subscriptiontype_id=st2.id
LEFT JOIN
    evolutionwellness.subscription_addon sa
ON
    s2.center= sa.subscription_center
AND s2.id=sa.subscription_id
AND sa.cancelled = false
AND (
        sa.end_date IS NULL
    OR  sa.end_date > CURRENT_DATE )
LEFT JOIN
    masterproductregister mpr
ON
    sa.addon_product_id = mpr.id
LEFT JOIN
    employees emp2
ON
    s2.creator_center=emp2.center
AND s2.creator_id=emp2.id
LEFT JOIN
    persons p_emp2
ON
    p_emp2.center=emp2.personcenter
AND p_emp2.id=emp2.personid
LEFT JOIN
    evolutionwellness.person_ext_attrs pea_source2
ON
    p2.center= pea_source2.personcenter
AND p2.id=pea_source2.personid
AND pea_source2.name='Source'
    LEFT JOIN
	    SourceValues sv2
	ON
	    sv2.Source = pea_source2.txtvalue
LEFT JOIN
    lateral
    (
        SELECT
            true::BOOLEAN AS gym
        FROM
            product_group pg2
        JOIN
            product_and_product_group_link ppg2
        ON
            ppg2.product_group_id=pg2.id
        WHERE
            (
                pg2.id = 688
            OR  pg2.top_node_id=688)
        AND pr2.center=ppg2.product_center
        AND pr2.id=ppg2.product_id) AS gym
ON
    true
LEFT JOIN
    evolutionwellness.cashcollectioncases ccc2
ON
    ccc2.personcenter=p2.center
AND ccc2.id=p2.id
AND ccc2.closed =false
AND ccc2.missingpayment=true
    ---------------person 1 details--------------------------------------------
LEFT JOIN
    subscriptions s1
ON
    s1.owner_center=p1.center
AND s1.owner_id=p1.id
AND s1.state IN (2,
                 4)
LEFT JOIN
    products pr1
ON
    s1.subscriptiontype_center=pr1.center
AND s1.subscriptiontype_id=pr1.id
LEFT JOIN
    account_receivables ar1
ON
    ar1.customercenter=p1.center
AND ar1.customerid=p1.id
AND ar1.ar_type=4
AND ar1.state=0
LEFT JOIN
    payment_agreements pag1
ON
    ar1.center=pag1.center
AND ar1.id=pag1.id
AND pag1.active=true
LEFT JOIN
    clearinghouses ch1
ON
    ch1.id=pag1.clearinghouse
LEFT JOIN
    evolutionwellness.person_ext_attrs pea_creat1
ON
    p1.center=pea_creat1.personcenter
AND p1.id=pea_creat1.personid
AND pea_creat1.name='CREATION_DATE'
LEFT JOIN
    evolutionwellness.center_ext_attrs cex1
ON
    c1.id= cex1.center_id
AND cex1.name='GoXProBrand'
LEFT JOIN
    evolutionwellness.subscriptiontypes st1
ON
    s1.subscriptiontype_center=st1.center
AND s1.subscriptiontype_id=st1.id
LEFT JOIN
    employees emp1
ON
    s1.creator_center=emp1.center
AND s1.creator_id=emp1.id
LEFT JOIN
    persons p_emp1
ON
    p_emp1.center=emp1.personcenter
AND p_emp1.id=emp1.personid
LEFT JOIN
    evolutionwellness.cashcollectioncases ccc1
ON
    ccc1.personcenter= p1.center
AND ccc1.id=p1.id
AND ccc1.closed =false
AND ccc1.missingpayment=true
WHERE
    r.rtype=13
AND r.status=1
AND pea_creat2.txtvalue::DATE >= params.date_from
AND pea_creat2.txtvalue::DATE <= params.date_to
AND pea_creat2.name='CREATION_DATE'