SELECT DISTINCT
    i1.ssid,
    i1.ssid_list,
	i1.sid_owner,
	i1.sid_owner_list,
	i1.payer_id,
	i1.payer_id_list

FROM
    (
        SELECT
            s.CENTER || 'ss' || s.id                                            ssid,
            s.OWNER_CENTER || 'p' || s.OWNER_ID sid_owner,
			ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID payer_id,

            '(' || s.CENTER || ',' || s.id || '),'                                            ssid_list,
            '(' || s.OWNER_CENTER || ',' || s.OWNER_ID || '),' sid_owner_list ,
			'(' || ar.CUSTOMERCENTER || ',' || ar.CUSTOMERID || '),' payer_id_list,


            floor(months_between(NVL(cc.STARTDATE,SYSDATE),p.BIRTHDATE)/12)     SUB_OWNER_AGE,
            floor(months_between(NVL(cc.STARTDATE,SYSDATE),payer.BIRTHDATE)/12) PAYER_AGE

        FROM
            JOURNALENTRIES je
        JOIN
            PERSONS p
        ON
            p.CENTER = je.PERSON_CENTER
            AND p.ID = je.PERSON_ID
        JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = je.PERSON_CENTER
            AND s.OWNER_ID = je.PERSON_ID            
        LEFT JOIN
            RELATIVES rel
        ON
            rel.RELATIVECENTER = p.CENTER
            AND rel.RELATIVEID = p.ID
            AND rel.RTYPE = 12
            AND rel.STATUS = 1
        LEFT JOIN
            PERSONS payer
        ON
            payer.CENTER = rel.CENTER
            AND payer.ID = rel.ID
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ((
                    rel.CENTER IS NOT NULL
                    AND rel.CENTER = ar.CUSTOMERCENTER
                    AND rel.ID = ar.CUSTOMERID )
                OR (
                    rel.CENTER IS NULL
                    AND S.OWNER_CENTER = ar.CUSTOMERCENTER
                    AND s.OWNER_ID = ar.CUSTOMERID))
            AND ar.AR_TYPE = 4
        LEFT JOIN
            CASHCOLLECTIONCASES cc
        ON
            cc.PERSONCENTER = ar.CUSTOMERCENTER
            AND cc.PERSONID = ar.CUSTOMERID
            AND cc.MISSINGPAYMENT = 1

        JOIN
            SUBSCRIPTION_CHANGE sc
        ON
            sc.OLD_SUBSCRIPTION_CENTER = s.CENTER
            AND sc.OLD_SUBSCRIPTION_ID = s.ID
            AND sc.EMPLOYEE_CENTER = 4
            AND sc.EMPLOYEE_ID = 834
            AND TO_CHAR(exerpro.longToDate(je.CREATION_TIME),'YYYY-MM-DD') IN ('2015-03-03','2015-03-04',
                                                                               '2015-03-05')
            AND TO_CHAR(sc.EFFECT_DATE,'YYYY-MM-DD') IN ('2015-03-04','2015-03-04',
                                                         '2015-03-05')
        WHERE
            TO_CHAR(exerpro.longToDate(je.CREATION_TIME),'YYYY-MM-DD') IN ('2015-03-04','2015-03-04','2015-03-05')
/*
		    and s.STATE = 7
    		and s.SUB_STATE = 1
    		and	p.STATUS = 2
*/
            AND je.CREATORCENTER = 4
            AND je.CREATORID = 834
            AND je.NAME = 'Stop'
			/* Remove the ones _not _in state window ended */
			and (s.center,s.id) not in ((401,340),(401,4731),(415,4326),(415,4327))
			/* Remove any that don't have a blocked/inactive as state before */
			and (s.center,s.id) not in ((401,4107),(401,4298),(406,5164),(408,76),(417,1163),(418,1077),(418,1131),
			(425,1308),(425,3678),(429,123),(436,6150),(440,7032),(444,1263),(444,3263),(446,2787),(446,2951),(446,3469))


) i1


WHERE
    (
        SUB_OWNER_AGE >= 18
        AND (
            PAYER_AGE IS NULL
            OR PAYER_AGE >= 18))