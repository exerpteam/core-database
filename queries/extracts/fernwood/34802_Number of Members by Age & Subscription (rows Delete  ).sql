-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
  c.name AS club_name,
  derived.subscription_name AS membership_type,
  derived.age_group,
  COUNT(*) AS member_count
FROM (
  SELECT DISTINCT ON (p.center, p.id)
    p.id AS person_id,
    p.center,
    prod.name AS subscription_name,
    CASE
      WHEN FLOOR(MONTHS_BETWEEN(CURRENT_DATE, p.birthdate) / 12) BETWEEN 13 AND 18 THEN '13 to 18'
      WHEN FLOOR(MONTHS_BETWEEN(CURRENT_DATE, p.birthdate) / 12) BETWEEN 19 AND 24 THEN '19 to 24'
      WHEN FLOOR(MONTHS_BETWEEN(CURRENT_DATE, p.birthdate) / 12) BETWEEN 25 AND 34 THEN '25 - 34'
      WHEN FLOOR(MONTHS_BETWEEN(CURRENT_DATE, p.birthdate) / 12) BETWEEN 35 AND 44 THEN '35 - 44'
      WHEN FLOOR(MONTHS_BETWEEN(CURRENT_DATE, p.birthdate) / 12) BETWEEN 45 AND 54 THEN '45 - 54'
      WHEN FLOOR(MONTHS_BETWEEN(CURRENT_DATE, p.birthdate) / 12) BETWEEN 55 AND 64 THEN '55 - 64'
      WHEN FLOOR(MONTHS_BETWEEN(CURRENT_DATE, p.birthdate) / 12) BETWEEN 65 AND 74 THEN '65 - 74'
      WHEN FLOOR(MONTHS_BETWEEN(CURRENT_DATE, p.birthdate) / 12) BETWEEN 75 AND 100 THEN '75 to 100'
      ELSE NULL
    END AS age_group
  FROM
    persons p
    JOIN subscriptions s ON s.owner_id = p.id AND s.owner_center = p.center
    JOIN subscriptiontypes st ON st.center = s.subscriptiontype_center AND st.id = s.subscriptiontype_id
    JOIN products prod ON prod.center = st.center AND prod.id = st.id
  WHERE
    p.birthdate IS NOT NULL
    AND p.birthdate <> DATE '1940-02-29'
    AND FLOOR(MONTHS_BETWEEN(CURRENT_DATE, p.birthdate) / 12) > 12
    AND FLOOR(MONTHS_BETWEEN(CURRENT_DATE, p.birthdate) / 12) <= 100
    AND p.persontype <> 2
    AND s.state IN (2, 4)
  ORDER BY p.center, p.id, s.start_date DESC
) derived
JOIN centers c ON c.id = derived.center
WHERE derived.age_group IS NOT NULL
GROUP BY
  c.name,
  derived.subscription_name,
  derived.age_group
ORDER BY
  c.name,
  derived.subscription_name,
  CASE derived.age_group
    WHEN '13 to 18' THEN 1
    WHEN '19 to 24' THEN 2
    WHEN '25 - 34' THEN 3
    WHEN '35 - 44' THEN 4
    WHEN '45 - 54' THEN 5
    WHEN '55 - 64' THEN 6
    WHEN '65 - 74' THEN 7
    WHEN '75 to 100' THEN 8
    ELSE 9
  END;
