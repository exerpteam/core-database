SELECT
        c.COUNTRY AS "Country",
        p.CENTER || 'p' || p.ID AS "PersonId",
        DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS "PersonType",
        s.CENTER || 'ss' || s.ID AS "SubscriptionId",
        s.START_DATE AS "SubscriptionStartDate",
        s.BILLED_UNTIL_DATE AS "SubscriptionBilledUntilDate",
        s.END_DATE AS "SubscriptionEndDate",
        DECODE (s.RENEWAL_POLICY_OVERRIDE, NULL, NULL, 4, 'Postpaid Policy','UNKNOWN') AS "SubscriptionRenewalPolicy",
        DECODE (st.ST_TYPE, 0, 'Cash', 1, 'EFT', 3, 'Prospect') as "SubscriptionType",
		(CASE
			WHEN pag.STATE IS NULL THEN 'OtherPayer'
			ELSE
        DECODE (pag.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',
                        9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',
                        14,'Agreement information incomplete',15,'Transfer',16,'Agreement Recreated',17, 'Signature missing', 'UNDEFINED') 
		END) AS "PaymentAgreementState",
		(CASE
			WHEN pcc.RENEWAL_POLICY IS NULL THEN 'OtherPayer'
			ELSE
        DECODE (pcc.RENEWAL_POLICY, 5, 'Prepaid Policy','UNKNOWN') 
		END) AS "PaymentAgreementRenewalPolicy",
        (CASE
                WHEN r.CENTER IS NULL THEN NULL
                ELSE r.CENTER || 'p' || r.ID 
        END) AS "OtherPayer",
ch.name
FROM SATS.PERSONS p
JOIN SATS.SUBSCRIPTIONS s 
        ON p.CENTER = s.OWNER_CENTER AND p.ID = s.OWNER_ID
JOIN SATS.SUBSCRIPTIONTYPES st
        ON st.CENTER = s.SUBSCRIPTIONTYPE_CENTER AND st.ID = s.SUBSCRIPTIONTYPE_ID
JOIN SATS.PRODUCTS pr
        ON pr.CENTER = st.CENTER AND pr.ID = st.ID      
JOIN SATS.CENTERS c
        ON p.CENTER = c.ID
LEFT JOIN SATS.ACCOUNT_RECEIVABLES ar
        ON ar.CUSTOMERCENTER = p.CENTER AND ar.CUSTOMERID = p.ID AND ar.AR_TYPE = 4
LEFT JOIN SATS.PAYMENT_ACCOUNTS pac
        ON pac.CENTER = ar.CENTER AND pac.ID = ar.ID
LEFT JOIN SATS.PAYMENT_AGREEMENTS pag
        ON pag.CENTER = pac.ACTIVE_AGR_CENTER AND pag.ID = pac.ACTIVE_AGR_ID AND pag.SUBID = pac.ACTIVE_AGR_SUBID
LEFT JOIN SATS.PAYMENT_CYCLE_CONFIG pcc
        ON pag.PAYMENT_CYCLE_CONFIG_ID = pcc.ID
LEFT JOIN SATS.RELATIVES r
        ON r.RELATIVECENTER = p.CENTER AND r.RELATIVEID = p.ID AND r.RTYPE = 12 AND r.STATUS = 1
LEFT JOIN CLEARINGHOUSES ch ON pag.clearinghouse = ch.id 
WHERE
        p.STATUS IN (1,3)
        AND s.STATE IN (2,4,8)
        AND (s.end_date IS NULL OR s.billed_until_date IS NULL OR s.end_date != s.billed_until_date)        
        AND (s.CENTER || 'ss' || s.ID) IN ('511ss98012','511ss99407','511ss102631','511ss102521','511ss102741','511ss108183','511ss106197','511ss108868','511ss121419','511ss121980','511ss137716','511ss122587','511ss128256','511ss129306','511ss129505','511ss433794','511ss140095','511ss145112','511ss181730','511ss145363','511ss382936','511ss352538','511ss442941','511ss205334','511ss12930','511ss54420','511ss85365','511ss364929','511ss3385','511ss3710','511ss3937','511ss45480','511ss5106','511ss206531','511ss5596','511ss5499','511ss5458','511ss54407','511ss356129','511ss61215','511ss6534','511ss6821','511ss65802','511ss7313','511ss7216','511ss7629','511ss135353','511ss85071','511ss452204')
ORDER BY c.COUNTRY