-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             $$FreeFromDate$$ AS StartDate,
             $$FreeToDate$$ AS EndDate,
                         0          AS numberOfDays
     )
 SELECT
     DISTINCT s.OWNER_CENTER || 'p' || s.OWNER_ID AS Member,
     p.FIRSTNAME || ' ' || p.LASTNAME                  AS Name,
     c.NAME                                            AS Club,
     srd.START_DATE                                    AS StartDate,
     srd.END_DATE                                      AS EndDate,
     srd.STATE,
     -- s.SUBSCRIPTIONTYPE_ID,
     s.BINDING_PRICE                                 AS Price,
     srd.TEXT                                        AS Free_Comment,
     srd.TYPE                                        AS Assignment_type,
     srd.EMPLOYEE_CENTER || 'emp' || srd.EMPLOYEE_ID AS Created_by
 FROM
     SUBSCRIPTION_REDUCED_PERIOD srd
 JOIN
     subscriptions s
 ON
     s.ID = srd.SUBSCRIPTION_ID
 AND s.CENTER = srd.SUBSCRIPTION_CENTER
 JOIN
     Centers c
 ON
     s.OWNER_CENTER = c.ID
 JOIN
     PERSONS p
 ON
     s.OWNER_CENTER = p.CENTER
 AND s.OWNER_ID = p.ID
 CROSS JOIN params
 WHERE srd.STATE = 'ACTIVE'
 AND (srd.START_DATE >= StartDate  AND srd.END_DATE <= EndDate)
 AND s.center IN ($$Scope$$)
