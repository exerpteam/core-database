SELECT
    p.CENTER,
    p.ID,
    p.firstname, 
    p.lastname,
    p.CENTER || 'p' || p.ID personid,
    p.PERSONTYPE,
	p.status,
    floor(months_between(exerpsysdate(), p.BIRTHDATE) / 12) age,
    p.sex gender,
    p.ZIPCODE,
    z.CITY,
    em.txtvalue AS Email,
    anl.txtvalue AS newsletter_yes_no,
    pr.name,
    sub.Subscription_Price,
    TO_CHAR(MAX(lastActivePeriodStart),'yyyy-mm-dd') last_active_period_start,
    TO_CHAR(MAX(sub.end_date),'yyyy-mm-dd') last_membership_end,
    MAX(sub.end_date) - MAX(lastActivePeriodStart) days,
	MAX(sub.end_date) + 1 drpoff_date
FROM
    persons p
LEFT JOIN ZipCodes z
ON
    p.Country = z.Country
    AND p.ZipCode = z.Zipcode
LEFT JOIN PERSON_EXT_ATTRS em
ON
    em.PERSONCENTER = p.center
    AND em.PERSONID = p.id
    AND em.NAME = '_eClub_Email'
    AND em.txtvalue IS NOT NULL
LEFT JOIN PERSON_EXT_ATTRS anl
ON
    anl.PERSONCENTER = p.center
    AND anl.PERSONID = p.id
    AND anl.NAME = 'eClubIsAcceptingEmailNewsLetters'
    AND anl.txtvalue = 'true'
LEFT JOIN eclub2.subscriptions sub
ON
    p.center = sub.owner_center
    AND p.id = sub.owner_id
LEFT JOIN SubscriptionTypes st
ON
    sub.SubscriptionType_Center = st.Center
    AND sub.SubscriptionType_ID = st.ID
LEFT JOIN Products pr
ON
    st.Center = pr.Center
    AND st.Id = pr.Id
LEFT JOIN
    (
        SELECT
            newMembership.OWNER_CENTER,
            newMembership.OWNER_ID,
            /* If more than one membership without a previous one,
            we must choose the start date of the latest one */
            MAX(newMembership.START_DATE) lastActivePeriodStart
        FROM
            eclub2.subscriptions newMembership
        WHERE
            /* Membership must be more than one day or have no end date */
            (
                newMembership.END_DATE - newMembership.START_DATE > 1
                OR newMembership.END_DATE IS NULL
            )
            AND NOT EXISTS
            (
                /* There is no membership starting before this one in window */
                /* Join backwards to find memberships with end date
                before start of this one but within window period of 25 days */
                SELECT
                    *
                FROM
                    eclub2.subscriptions oldMembership
                WHERE
                    newMembership.OWNER_CENTER = oldMembership.OWNER_CENTER
                    AND newMembership.OWNER_ID = oldMembership.OWNER_ID
                    /* Exclude one day memberships */
                    AND oldMembership.END_DATE - oldMembership.START_DATE > 1
                    AND
                    (
                        (
                            /* outer must start after end date */
                            newMembership.START_DATE > oldMembership.START_DATE
                            /* but not later than */
                            AND newMembership.START_DATE - oldMembership.END_DATE < 26
                        )
                        OR
                        (
                            /* If overlap new one starts before old ones end */
                            newMembership.START_DATE < oldMembership.END_DATE
                            /* If overlap new one starts after old ones start */
                            AND newMembership.START_DATE > oldMembership.START_DATE
                        )
                    )
            )
        GROUP BY
            newMembership.OWNER_CENTER,
            newMembership.OWNER_ID
    )
    lastPeriod
ON
    p.center = lastPeriod.owner_center
    AND p.id = lastPeriod.owner_id
WHERE
    p.center <= :FraCenter
	AND p.center >= :TilCenter
    AND p.STATUS IN (2)
    AND p.persontype <> 2
    AND sub.end_date - sub.start_date > 0
    AND lastPeriod.owner_center IS NOT NULL
    ANd sub.END_DATE =
    (
        SELECT
            max(subInner.END_DATE)
        FROM
            SUBSCRIPTIONS subInner
        WHERE
            subInner.OWNER_CENTER = p.center
            AND subInner.OWNER_ID = p.id
    )
GROUP BY
    p.CENTER,
   p.ID,
p.firstname,
 p.lastname,
    p.CENTER || 'p' || p.ID,
    p.PERSONTYPE,
	p.status,
    floor(months_between(exerpsysdate(), p.BIRTHDATE) / 12),
    p.sex,
    p.Zipcode,
    z.City,
    em.txtvalue,
    anl.txtvalue,
    pr.name,
    sub.Subscription_Price