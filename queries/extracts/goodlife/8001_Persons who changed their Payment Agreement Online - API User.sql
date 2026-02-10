-- The extract is extracted from Exerp on 2026-02-08
-- Created For: PDS to find members who updated their banking info online resulting in payment agreements not linked to subscriptions.  Only API User 990p228.  Created by: ? Date Added: ?updated by Sandra G Apr 2023
SELECT DISTINCT
	CASE WHEN p.Id IS NULL
		THEN ''
		ELSE 
			p.center || 'p' || p.id
		END AS "Person ID",
	(CASE
		WHEN p.status = 0
		THEN 'Lead'	
		WHEN p.status = 1
		THEN 'Active'	
		WHEN p.status = 2
		THEN 'Inactive'	
		WHEN p.status = 3
		THEN 'Temporarily Inactive'	
		WHEN p.status = 4
		THEN 'Transferred'	
		WHEN p.status = 5
		THEN 'Duplicate'	
		WHEN p.status = 6
		THEN 'Prospect'	
		WHEN p.status = 7
		THEN 'Deleted'	
		WHEN p.status = 8
		THEN 'Anonymized'	
		WHEN p.status = 9
		THEN 'Contact'	
	END) AS "Person Status",
	/*(CASE
		WHEN p.member_status = 0
		THEN 'N/A (Old Person ID)'
		WHEN p.member_status = 1
		THEN 'Non-Member'
		WHEN p.member_status = 2
		THEN 'Member'
		WHEN p.member_status = 4
		THEN 'Extra'
		WHEN p.member_status = 5
		THEN 'Ex-Member'
		WHEN p.member_status = 6
		THEN 'Legacy Member'
	END) AS "Member Status",*/
	(CASE
	       WHEN p.persontype = 0 
	       THEN 'Private'
               WHEN p.persontype = 1 
               THEN 'Student'
               WHEN p.persontype = 2 
               THEN 'Staff'              
               WHEN p.persontype= 3 
               THEN 'Friend'              
               WHEN p.persontype = 4 
               THEN 'Corporate'
               WHEN p.persontype = 5 
               THEN 'One Man Corporate'
               WHEN p.persontype=6 
               THEN 'Family'               
               WHEN p.persontype=7 
               THEN 'Senior'
                WHEN p.persontype = 8 
                THEN 'Guest'
                WHEN p.persontype = 9 
                THEN 'Child'
                WHEN p.persontype = 10 
                THEN 'External Staff'
                END) AS "Person Type",
	pa.ref as "Payment Agreement Number",
	CASE pa.STATE
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'
        WHEN 15
        THEN 'Transfer'
        WHEN 16
        THEN 'Agreement Recreated'
        WHEN 17
        THEN 'Signature missing'
        ELSE 'UNDEFINED'
    END AS "Payment Agreement Status",
	longtodateC(pa.creation_time, pa.center) as "Date Payment Agreement Created Online",
	'('||SUBSTRING(px.txtvalue,3,3)||') '||SUBSTRING(px.txtvalue,6,3)||'-'||SUBSTRING(px.txtvalue,9,4) AS "Home Phone",
	'('||SUBSTRING(px1.txtvalue,3,3)||') '||SUBSTRING(px1.txtvalue,6,3)||'-'||SUBSTRING(px1.txtvalue,9,4) AS "Mobile Phone"
	
FROM agreement_change_log acl
	
	LEFT JOIN PAYMENT_AGREEMENTS pa
		ON pa.center = acl.agreement_center
	    AND pa.id = acl.agreement_id
	    AND pa.subid = acl.agreement_subid
	    
	LEFT JOIN goodlife.subscriptions s
	ON s.payment_agreement_center = pa.center
	   and s.payment_agreement_id = pa.id
	   and s.payment_agreement_subid = pa.subid
        
        LEFT JOIN goodlife.payment_accounts pac
        ON pac.active_agr_center = pa.center
        and pac.active_agr_id = pa.id
        and pac.active_agr_subid = pa.subid 
		
	LEFT JOIN ACCOUNT_RECEIVABLES ar 
		ON ar.CENTER = pa.CENTER 
		AND ar.id = pa.id
	LEFT JOIN PERSONS p 
		ON p.ID = ar.CUSTOMERID 
		AND p.CENTER = ar.CUSTOMERCENTER
	LEFT JOIN person_ext_attrs px
		ON p.center = px.personcenter
		AND p.id = px.personid
		AND px.name = '_eClub_PhoneHome'
	LEFT JOIN person_ext_attrs px1
		ON p.center = px1.personcenter
		AND p.id = px1.personid
		AND px1.name = '_eClub_PhoneSMS'

WHERE

		s.center IS NULL
		AND pac.center IS NULL
		AND acl.state = 1
		AND (acl.employee_center, acl.employee_id) IN ((990,228))
		
		
		/*
		API User (990emp228)

                )
		
		*/
		AND LONGTODATEC(acl.entry_time,acl.agreement_center)  between :fromdate and :todate


