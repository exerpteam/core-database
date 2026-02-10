-- The extract is extracted from Exerp on 2026-02-08
-- PT Sales and their contract signed status (CF)
WITH params AS MATERIALIZED (
    SELECT
        id AS center_id,
        CAST(datetolongc(TO_CHAR(to_date(:From_Date,'YYYY-MM-DD'),'YYYY-MM-DD'), id) AS BIGINT) AS from_date,
        CAST(datetolongc(TO_CHAR(to_date(:To_Date,'YYYY-MM-DD'),'YYYY-MM-DD'), id) AS BIGINT) + 24*3600*1000 AS to_date
    FROM centers
    WHERE id IN (:Scope)
),

pt_base AS (
    SELECT
        s.center,
        --p.external_id AS "Person ID",
		s.owner_center || 'p' || s.owner_id as "Member ID",
        p.fullname    AS "Member Name",
        s.center || 'ss' || s.id AS "PT Subscription ID",
        pr.name       AS "PT Subscription Name",
        TO_CHAR(s.start_date, 'MM/DD/YYYY') AS "PT Start Date",
        TO_CHAR(longtodatec(s.creation_time, s.center), 'MM/DD/YYYY') AS "PT Created at",
        p2.fullname                             AS "Sold By",

        -- Contract fields (borrowed from Sales Audit)
        TO_CHAR(longtodateC(je.creation_time, p.center), 'MM/DD/YYYY') AS "Contract Creation Date",
        CASE WHEN jes.signature_center IS NULL THEN 'No' ELSE 'Yes' END AS "Contract Signed",
        TO_CHAR(longtodateC(si.creation_time, si.center), 'MM/DD/YYYY') AS "Signature Date"

    FROM subscriptions s
    JOIN params
      ON s.center = params.center_id
     AND s.creation_time >= params.from_date
     AND s.creation_time <  params.to_date

    JOIN subscriptiontypes st
      ON s.subscriptiontype_center = st.center
     AND s.subscriptiontype_id = st.id
     AND st.st_type = 2                           -- PT

    JOIN products pr
      ON pr.center = st.center
     AND pr.id = st.id

    JOIN persons p
      ON p.center = s.owner_center
     AND p.id = s.owner_id

	JOIN SUBSCRIPTION_SALES ss
	ON s.CENTER = ss.SUBSCRIPTION_CENTER
	AND s.ID = ss.SUBSCRIPTION_ID
	
	JOIN EMPLOYEES emp
	ON emp.CENTER = ss.EMPLOYEE_CENTER
	AND emp.ID = ss.EMPLOYEE_ID
	
	LEFT JOIN PERSONS p2
	ON p2.CENTER = emp.PERSONCENTER
	AND p2.ID = emp.PERSONID

    LEFT JOIN journalentries je
      ON je.person_center = p.center
     AND je.person_id = p.id
     AND je.ref_center = s.center
     AND je.ref_id = s.id
     AND je.jetype = 1                            -- Contracts

    LEFT JOIN journalentry_signatures jes
      ON je.id = jes.journalentry_id

    LEFT JOIN signatures si
      ON jes.signature_center = si.center
     AND jes.signature_id = si.id
)

SELECT *
FROM pt_base
ORDER BY "PT Created at" DESC, "Member ID";
