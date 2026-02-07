/*
* Fetch membershipchanges made by customersupport during a given period.
* Creator: Henrik Håkanson, 2020-02-19
*/
SELECT 
	newSub.OWNER_CENTER || 'p' || newSub.OWNER_ID AS MEMBER,
	TO_CHAR(longtodate(change.CHANGE_TIME), 'YYYY-MM-DD') AS ChangeTime,
	pers.FULLNAME AS EMPLOYEE,
	change.TYPE AS TYPE,
	oldCenter.NAME AS OLD_CENTER,
	newCenter.NAME AS NEW_CENTER,
	oldProd.NAME AS OLDPRODUCT,
	newProd.NAME AS NEW_PRODUCT
FROM SUBSCRIPTION_CHANGE change
	JOIN SUBSCRIPTIONS oldSub
		ON change.OLD_SUBSCRIPTION_CENTER = oldSub.CENTER
		AND change.OLD_SUBSCRIPTION_ID = oldSub.ID
	JOIN SUBSCRIPTIONS newSub
		ON change.NEW_SUBSCRIPTION_CENTER = newSub.CENTER
		AND change.NEW_SUBSCRIPTION_ID = newSub.ID
	INNER JOIN SUBSCRIPTIONTYPES st
	ON
		newSub.SUBSCRIPTIONTYPE_CENTER = st.CENTER
		AND newSub.SUBSCRIPTIONTYPE_ID = st.ID
	LEFT JOIN PRODUCTS newProd
	ON
    	st.CENTER = newProd.CENTER
    	AND st.ID = newProd.ID
	
	INNER JOIN SUBSCRIPTIONTYPES st2
	ON
		oldSub.SUBSCRIPTIONTYPE_CENTER = st2.CENTER
		AND oldSub.SUBSCRIPTIONTYPE_ID = st2.ID
	LEFT JOIN PRODUCTS oldProd
	ON
    	st2.CENTER = oldProd.CENTER
    	AND st2.ID = oldProd.ID
	

	JOIN EMPLOYEES emp
		ON emp.CENTER = change.EMPLOYEE_CENTER
		AND emp.ID = change.EMPLOYEE_ID
	JOIN EMPLOYEESROLES role
		ON emp.CENTER = role.CENTER
		AND emp.ID = role.ID
		AND role.ROLEID = 7346 --Incluce only memberservice
	JOIN PERSONS pers
		ON emp.PERSONCENTER = pers.CENTER
		AND emp.PERSONID = pers.ID
	JOIN CENTERS newCenter 
		ON newCenter.ID = newSub.CENTER
	JOIN CENTERS oldCenter 
		ON oldCenter.ID = oldSub.CENTER
WHERE
	change.CHANGE_TIME > $$fromDate$$
	AND change.CHANGE_TIME <= ($$toDate$$ + 1000 * 60 * 60 * 24)
	AND oldProd.NAME != newProd.NAME
	AND newProd.NAME NOT LIKE '%Benify%'
	AND (
			UPPER(newProd.NAME) like '%MAX%'
			OR (
				UPPER(newProd.NAME) like '%REGIONALT%' 
				AND (UPPER(oldProd.NAME) NOT LIKE '%REGIONALT%'
					AND UPPER(oldProd.NAME) NOT LIKE '%MAX%')
				)
		)
 