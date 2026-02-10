-- The extract is extracted from Exerp on 2026-02-08
-- An extract for finding members that have an expired credit card agreement + have other payer.
 SELECT DISTINCT
             PAG.CENTER AS INNER_CENTER,
             PAG.ID     AS INNER_ID,
             PAG.SUBID  AS INNER_SUBID,
            (RL.RELATIVECENTER || 'p' || RL.RELATIVEID) AS PERSONKEY
         FROM
             ACCOUNT_RECEIVABLES AR
         INNER JOIN
             PAYMENT_ACCOUNTS PAA
         ON
             (
                 PAA.CENTER = AR.CENTER
                 AND PAA.ID = AR.ID)
         INNER JOIN
             PAYMENT_AGREEMENTS PAG
         ON
             (
                 PAA.ACTIVE_AGR_CENTER = PAG.CENTER
                 AND PAA.ACTIVE_AGR_ID = PAG.ID
                 AND PAA.ACTIVE_AGR_SUBID = PAG.SUBID)
         INNER JOIN
             PERSONS PE
         ON
             (
                 AR.CUSTOMERCENTER = PE.CENTER
                 AND AR.CUSTOMERID = PE.ID)
         INNER JOIN
             RELATIVES RL
         ON
             (
                 RL.CENTER = PE.CENTER
                 AND RL.ID = PE.ID
                 AND (
                         -- active
                     RL.STATUS = 1
                     OR RL.STATUS IS NULL)
                 AND (
                         -- other payer (eft payer)
                     RL.RTYPE = 12
                     OR RL.RTYPE IS NULL))
         INNER JOIN
             PERSONS PE1
         ON
             (
                 RL.RELATIVECENTER = PE1.CENTER
                 AND RL.RELATIVEID = PE1.ID
                 -- active or temp active
                 AND PE1.STATUS IN (1,
                                    3))
         INNER JOIN
             ACCOUNT_RECEIVABLES AR1
         ON
             (
                 AR1.CUSTOMERCENTER = PE1.CENTER
                 AND AR1.CUSTOMERID = PE1.ID)
         INNER JOIN
             PAYMENT_ACCOUNTS PAA1
         ON
             (
                 PAA1.CENTER = AR1.CENTER
                 AND PAA1.ID = AR1.ID)
         INNER JOIN
             PAYMENT_AGREEMENTS PAG1
         ON
             (
                 PAA1.ACTIVE_AGR_CENTER = PAG1.CENTER
                 AND PAA1.ACTIVE_AGR_ID = PAG1.ID
                 AND PAA1.ACTIVE_AGR_SUBID = PAG1.SUBID)
         WHERE
             (
                 -- pag marked as being notified
                 PAG.EXPIRATION_NOTIFIED = 1
                 -- but it has not expired yet
                 AND PAG.EXPIRATION_DATE > CURRENT_TIMESTAMP
                 -- and the agreement is active
                 AND PAG.STATE IN (4)
                 AND ((
                                 -- the relation is other payer (eft payer)
                         RL.RTYPE = 12
                         -- and the person being paid for is active or temp active
                         AND PE1.STATUS IN (1,
                                            3))
                                         -- active or temp active
                     OR PE.STATUS IN (1,
                                      3))
                                 -- person being paid for has an expired card
                 AND PAG1.EXPIRATION_DATE < CURRENT_TIMESTAMP )
