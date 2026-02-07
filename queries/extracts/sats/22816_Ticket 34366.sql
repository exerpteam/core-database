
select count(JETYPE) cnt,year_month, center, signed from
(
SELECT
    je.JETYPE,
    to_char(longToDate(je.CREATION_TIME),'YYYY-MM') year_month,
    je.PERSON_CENTER center,
    CASE
                WHEN je.SIGNATURE_CENTER is null
                   THEN 'false'
                Else 'true'
    END AS signed
FROM
    SATS.JOURNALENTRIES je
LEFT JOIN SATS.SIGNATURES SIGN
ON
    sign.CENTER = je.SIGNATURE_CENTER
    AND sign.ID = je.SIGNATURE_ID
WHERE
    je.JETYPE = 1
    AND je.PERSON_CENTER IS NOT NULL
    and je.PERSON_CENTER in (:scope)
    and je.CREATION_TIME between :startDate and :endDate

) o
group by year_month, center, signed 
order by center, year_month