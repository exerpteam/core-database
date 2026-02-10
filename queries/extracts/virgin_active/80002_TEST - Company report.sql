-- The extract is extracted from Exerp on 2026-02-08
-- For Michelle and Rosie (from Exerp ticlet: EC-8781
WITH CONTACT_PERSON AS
(
    SELECT
        p.fullname,
        r.center,
        r.id,
        email.txtvalue AS email,
        work_phone.txtvalue as work_phone
    FROM
        PERSONS p
    JOIN
        RELATIVES r ON r.relativecenter = p.center AND r.relativeid = p.id AND r.rtype = 7 AND r.status = 1
    LEFT JOIN
        person_ext_attrs email ON email.personcenter = p.center AND email.personid = p.id AND email.name = '_eClub_Email'
    LEFT JOIN
        person_ext_attrs work_phone ON work_phone.personcenter = p.center AND work_phone.personid = p.id AND work_phone.name = '_eClub_PhoneWork'
),
AGREEMENT_PRIVILEGES AS
(
    SELECT
        cag.CENTER || 'p' || cag.ID || 'rpt' || cag.SUBID AS AgreementId,
        ps.NAME AS PrivilegeSetName,
        pg.SPONSORSHIP_AMOUNT AS DiscountPercentage
    FROM
        COMPANYAGREEMENTS cag
    LEFT JOIN
        PRIVILEGE_GRANTS pg ON pg.GRANTER_CENTER = cag.CENTER AND pg.GRANTER_ID = cag.ID AND pg.GRANTER_SUBID = cag.SUBID AND pg.GRANTER_SERVICE = 'CompanyAgreement'
    LEFT JOIN
        PRIVILEGE_SETS ps ON pg.PRIVILEGE_SET = ps.ID
    WHERE
        cag.STATE IN (1, 2) -- Active or Stop New
),
AGREEMENT_CLUBS AS
(
    SELECT
        AgreementId,
        STRING_AGG(ClubName, ', ' ORDER BY ClubName) AS ClubsAvailable
    FROM
    (
        SELECT DISTINCT
            r.RELATIVECENTER || 'p' || r.RELATIVEID || 'rpt' || r.RELATIVESUBID AS AgreementId,
            c.NAME AS ClubName
        FROM
            PERSONS p
        JOIN
            RELATIVES r ON p.CENTER = r.CENTER AND p.ID = r.ID AND r.RTYPE = 3 AND r.STATUS < 3
        JOIN
            CENTERS c ON p.CENTER = c.ID
        WHERE
            p.PERSONTYPE = 4 -- Assuming companies have PERSONTYPE = 4
    ) sub
    GROUP BY
        AgreementId
),
MEMBERSHIP_COUNTS AS
(
    SELECT
        r.RELATIVECENTER || 'p' || r.RELATIVEID || 'rpt' || r.RELATIVESUBID AS AgreementId,
        c.NAME AS ClubName,
        COUNT(*) FILTER (WHERE p.STATUS = 1) AS ActiveMembers,
        COUNT(*) FILTER (WHERE p.STATUS = 3) AS TempInactiveMembers
    FROM
        PERSONS p
    JOIN
        RELATIVES r ON p.CENTER = r.CENTER AND p.ID = r.ID AND r.RTYPE = 3 AND r.STATUS < 3
    JOIN
        CENTERS c ON p.CENTER = c.ID
    WHERE
        p.STATUS IN (1, 3)
    GROUP BY
        AgreementId,
        c.NAME
)
SELECT DISTINCT
    comp.fullname AS "Company Name",
    ca.NAME AS "Company Agreement Name",
    ac.ClubsAvailable AS "Available at",
    pr.NAME AS "Subscription Type",
    spp.SUBSCRIPTION_PRICE AS "Standard Price (JF Price)",
    COALESCE(ap.DiscountPercentage, 0) AS "Discount Applied (%)",
    spp.SUBSCRIPTION_PRICE - (spp.SUBSCRIPTION_PRICE * COALESCE(ap.DiscountPercentage, 0) / 100) AS "Subscription New Line Price",
    spp.SUBSCRIPTION_PRICE AS "Headline Subscription Price",
    spp.SUBSCRIPTION_PRICE - (spp.SUBSCRIPTION_PRICE * 8.7 / 100) AS "Global Product Line Price",
    mc.ActiveMembers AS "Active Members",
    mc.TempInactiveMembers AS "Temporary Inactive Members"
FROM
    COMPANYAGREEMENTS ca
JOIN
    PERSONS comp ON comp.center = ca.CENTER AND comp.id = ca.ID
LEFT JOIN
    AGREEMENT_PRIVILEGES ap ON ap.AgreementId = ca.CENTER || 'p' || ca.ID || 'rpt' || ca.SUBID
LEFT JOIN
    AGREEMENT_CLUBS ac ON ac.AgreementId = ca.CENTER || 'p' || ca.ID || 'rpt' || ca.SUBID
LEFT JOIN
    MEMBERSHIP_COUNTS mc ON mc.AgreementId = ca.CENTER || 'p' || ca.ID || 'rpt' || ca.SUBID
JOIN
    RELATIVES r ON r.RELATIVECENTER = ca.CENTER AND r.RELATIVEID = ca.ID AND r.RELATIVESUBID = ca.SUBID AND r.RTYPE = 3 AND r.STATUS < 3
JOIN
    PERSONS p ON p.CENTER = r.CENTER AND p.ID = r.ID
JOIN
    SUBSCRIPTIONS s ON s.OWNER_CENTER = p.CENTER AND s.OWNER_ID = p.ID AND s.STATE IN (2, 4, 7, 8)
JOIN
    SUBSCRIPTIONTYPES st ON s.SUBSCRIPTIONTYPE_CENTER = st.CENTER AND s.SUBSCRIPTIONTYPE_ID = st.ID
JOIN
    PRODUCTS pr ON st.CENTER = pr.CENTER AND st.ID = pr.ID
JOIN
    SUBSCRIPTIONPERIODPARTS spp ON spp.CENTER = s.CENTER AND spp.ID = s.ID AND spp.FROM_DATE <= CURRENT_DATE AND spp.TO_DATE >= CURRENT_DATE - 1 AND spp.SPP_STATE NOT IN (2)
WHERE
    comp.CENTER IN (:scope)
ORDER BY
    comp.fullname;
