-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    persons.center,
    persons.id,
    
    MIN(TO_CHAR(persons.birthdate, 'yyyy-MM-dd'))                    AS birthdate,
    MIN(DECODE(persons.sex, 'M', 'MALE', 'F', 'FEMALE'))             AS sex,
    MIN(persons.Address1)                                            AS AddressLine1,
    MIN(persons.address2)                                            AS AddressLine2,
    MIN(persons.Zipcode)                                             AS zip,
    MIN(persons.City)                                                AS city,
    MIN(DECODE(st.ST_TYPE, 1, 'EFT', 'CASH'))                        AS subscription_type,
    MIN(DECODE(companyAgrRel.rtype, 3, 'Company agreement', 'none')) AS company_agreement,
    MIN(DECODE (s.STATE, 4,'FROZEN','Not Frozen'))                   AS subscription_STATE,
    MIN(s.start_date)                                                AS subscription_start,
    longToDate(least(NVL(MIN(per_att.START_TIME),'999999999999999'), NVL(MIN(per_par.START_TIME),'999999999999999'))) first_attend_or_participation,
    floor((dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')) - least(NVL(MIN(per_att.START_TIME),'999999999999999'), NVL(MIN(per_par.START_TIME),'999999999999999')))/1000/60/60/24/7) weeks_from_start_to_now,
    CASE
        WHEN floor((dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')) - least(NVL(MIN(per_att.START_TIME),'999999999999999'), NVL(MIN(per_par.START_TIME),'999999999999999')))/1000/60/60/24/7) > 0
        THEN MIN(per_att.att_count)/floor((dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')) - least(NVL(MIN(per_att.START_TIME),'999999999999999'), NVL(MIN(per_par.START_TIME),'999999999999999')))/1000/60/60/24/7)
        ELSE -1
    END attends_per_week,
    MIN(per_att.att_count) attend_count,
    CASE
        WHEN floor((dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')) - least(NVL(MIN(per_att.START_TIME),'999999999999999'), NVL(MIN(per_par.START_TIME),'999999999999999')))/1000/60/60/24/7) > 0
        THEN MIN(per_par.par_count)/floor((dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')) - least(NVL(MIN(per_att.START_TIME),'999999999999999'), NVL(MIN(per_par.START_TIME),'999999999999999')))/1000/60/60/24/7)
        ELSE -1
    END participations_per_week,
    MIN(per_par.par_count) participation_count
    
FROM
    fw.persons
JOIN fw.subscriptions s
ON
    persons.center = s.owner_center
    AND persons.id = s.owner_id
    AND s.state IN (2,4)
left JOIN
    (
        SELECT
            attends.person_center,
            attends.person_id,
            COUNT(*)                AS att_count,
            MIN(attends.start_time) AS start_time
        FROM
            fw.attends
        WHERE
            attends.state = 'ACTIVE'
        GROUP BY
            attends.person_center,
            attends.person_id
    )
    per_att
ON
    per_att.person_center = persons.center
    AND per_att.person_id = persons.id
LEFT JOIN
    (
        SELECT
            COUNT(*) par_count,
            par.PARTICIPANT_CENTER,
            par.PARTICIPANT_ID,
            MIN(par.START_TIME) START_TIME
        FROM
            FW.PARTICIPATIONS par
        WHERE
            par.STATE = 'PARTICIPATION'
        GROUP BY
            par.PARTICIPANT_CENTER,
            par.PARTICIPANT_ID
    )
    per_par
ON
    per_par.PARTICIPANT_CENTER = persons.CENTER
    AND per_par.PARTICIPANT_ID = persons.ID
JOIN fw.subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
    AND s.subscriptiontype_id = st.id
LEFT JOIN fw.RELATIVES companyAgrRel
ON
    s.owner_center = companyAgrRel.CENTER
    AND s.owner_id = companyAgrRel.ID
    AND companyAgrRel.RTYPE = 3
    AND companyAgrRel.STATUS = 1
WHERE
    persons.sex != 'C'
    AND persons.center in (:scope)
    AND persons.status IN (1,3) -- active, temp inactive
GROUP BY
    persons.center,
    persons.id