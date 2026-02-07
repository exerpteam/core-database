 SELECT
     ca.center                                                                                                                                        AS companycenter,
     ca.id                                                                                                                                            AS companyid,
     ca.subid                                                                                                                                         AS agreementid,
     c.lastname                                                                                                                                       AS company ,
     CASE
         WHEN s.EXTENDED_TO_CENTER IS NULL
         THEN 'false'
         ELSE 'true'
     END                                                                                                                                              AS "extended",
     ca.name                                                                                                                                          AS agreement,
     p.center                                                                                                                                         AS memberCenter,
     p.id                                                                                                                                             AS memberId,
     p.firstname                                                                                                                                      AS firstname,
     p.lastname                                                                                                                                       AS lastname,
     p.ssn                                                                                                                                            AS SSN,
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' ELSE 'UNKNOWN' END AS personStatus,
     prod.name                                                                                                                                        AS SubscriptionType,
     s.start_date                                                                                                                                     AS startDate,
     s.end_date                                                                                                                                       AS EndDate,
     (
         SELECT
             MIN(si.START_DATE)
         FROM
             SUBSCRIPTIONS si
         WHERE
             si.OWNER_CENTER = p.CENTER
             AND si.OWNER_ID = p.ID
             AND si.SUB_STATE NOT IN (7,8)
     )                    AS MEMBER_SINCE,
     s.subscription_price AS Price
 FROM
     COMPANYAGREEMENTS ca
     /* company */
 JOIN PERSONS c
 ON
     ca.CENTER = c.CENTER
     AND ca.ID = c.ID
     /*company agreement relation*/
 JOIN RELATIVES rel
 ON
     rel.RELATIVECENTER = ca.CENTER
     AND rel.RELATIVEID = ca.ID
     AND rel.RELATIVESUBID = ca.SUBID
     AND rel.RTYPE = 3
     AND rel.status=1
 JOIN STATE_CHANGE_LOG scl
 ON
     scl.CENTER = rel.CENTER
     AND scl.ID = rel.ID
     AND scl.SUBID = rel.SUBID
     AND scl.STATEID = rel.STATUS
     /* persons under agreement*/
 JOIN PERSONS p
 ON
     rel.CENTER = p.CENTER
     AND rel.ID = p.ID
     AND rel.RTYPE = 3
     /* subscriptions active and frozen of person */
 LEFT JOIN subscriptions s
 ON
     s.OWNER_CENTER = rel.CENTER
     AND s.OWNER_ID = rel.ID
     AND s.STATE IN (2,4 )
     /* Link a subscription with its subscription type */
 LEFT JOIN subscriptiontypes st
 ON
     s.subscriptiontype_center = st.center
     AND s.subscriptiontype_id = st.id
     /* Link subscription type with it's global-name */
 LEFT JOIN products prod
 ON
     st.center = prod.center
     AND st.id = prod.id
 WHERE
         (c.center,c.id) in (:companies)
     AND p.persontype =  4 /*corporate*/
     /*corporate*/
     AND p.STATUS BETWEEN 0 AND 3
