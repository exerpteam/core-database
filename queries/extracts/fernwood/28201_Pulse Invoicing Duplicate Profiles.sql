-- The extract is extracted from Exerp on 2026-02-08
-- 
-- Duplicate members within the SAME club where
--   • base name (first two words) matches, AND
--   • DATE OF BIRTH matches
-- Only PERSON Active/Temp-Inactive and SUBS Active/Frozen.
-- One row per (person × subscription), with DOB + address.

WITH scope_centers AS (
  SELECT id AS center_id
  FROM centers
  WHERE id IN (:Scope)
),

-- Persons we care about (Active or Temporary Inactive)
persons_base AS (
  SELECT
      p.center,
      p.id,
      p.external_id,
      -- Build + normalise full name
      TRIM(COALESCE(p.firstname,'') || ' ' || COALESCE(p.lastname,'')) AS full_name,
      LOWER(REGEXP_REPLACE(TRIM(COALESCE(p.firstname,'') || ' ' || COALESCE(p.lastname,'')),
                           '\s+', ' ', 'g')) AS norm_name,
      -- Base name = first two words (handles suffixes like "Fiit30")
      TRIM(
        CONCAT(
          split_part(LOWER(REGEXP_REPLACE(TRIM(COALESCE(p.firstname,'') || ' ' || COALESCE(p.lastname,'')),
                                          '\s+', ' ', 'g')), ' ', 1),
          ' ',
          split_part(LOWER(REGEXP_REPLACE(TRIM(COALESCE(p.firstname,'') || ' ' || COALESCE(p.lastname,'')),
                                          '\s+', ' ', 'g')), ' ', 2)
        )
      ) AS base_name,
      p.birthdate,
      p.address1,
      p.city
  FROM persons p
  JOIN scope_centers sc ON sc.center_id = p.center
  WHERE p.status IN (1, 3)                -- Active or Temporary Inactive
),

-- Active/Frozen subscriptions
active_frozen_subs AS (
  SELECT
      s.center,
      s.id,
      s.owner_center,
      s.owner_id,
      s.subscriptiontype_center,
      s.subscriptiontype_id,
      s.state,
      s.start_date
  FROM subscriptions s
  WHERE COALESCE(s.state,0) IN (2,4)      -- ACTIVE(2) or FROZEN(4)
),

-- Persons (active/ti) who HAVE at least one active/frozen subscription, and have DOB
people_with_live_subs AS (
  SELECT pb.*
  FROM persons_base pb
  WHERE pb.birthdate IS NOT NULL
    AND EXISTS (
      SELECT 1
      FROM active_frozen_subs s
      WHERE s.owner_center = pb.center
        AND s.owner_id    = pb.id
    )
),

-- Base name + DOB groups with 2+ different Person IDs in the same club
dupe_name_dob AS (
  SELECT center, base_name, birthdate
  FROM people_with_live_subs
  GROUP BY center, base_name, birthdate
  HAVING COUNT(DISTINCT id) > 1
)

SELECT
    pws.center || 'p' || pws.id                   AS "Person ID",              -- col 1
    pws.external_id                               AS "External ID",            -- col 2
    pws.full_name                                 AS "Full Name",              -- col 3
    c.shortname                                   AS "Club",                   -- col 4
    TO_CHAR(pws.birthdate, 'DD/MM/YYYY')          AS "Birth Date",             -- col 5
    pws.address1                                  AS "Address",                -- col 6
    pws.city                                      AS "Suburb",                 -- col 7
    c.id || 'ss' || s.id                          AS "Subscription ID",        -- col 8
    prod.name                                     AS "Subscription Name",      -- col 9
    TO_CHAR(s.start_date, 'DD/MM/YYYY')           AS "Subscription Start Date",-- col 10
    CASE s.state WHEN 2 THEN 'ACTIVE' WHEN 4 THEN 'FROZEN' ELSE s.state::text END AS "Subscription State" -- col 11
FROM people_with_live_subs pws
JOIN dupe_name_dob d
  ON d.center = pws.center
 AND d.base_name = pws.base_name
 AND d.birthdate = pws.birthdate
JOIN active_frozen_subs s
  ON s.owner_center = pws.center
 AND s.owner_id    = pws.id
JOIN products prod
  ON prod.center = s.subscriptiontype_center
 AND prod.id     = s.subscriptiontype_id
JOIN centers c
  ON c.id = pws.center
ORDER BY c.shortname, pws.full_name, pws.id, s.id;
