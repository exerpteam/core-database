SELECT 
	subscription.CENTER || 'ss' || subscription.ID "SUBSCRIPTION_ID", 
	p.EXTERNAL_ID "SALES_PERSON_ID",
	sales.EMPLOYEE_CENTER, 
	sales.EMPLOYEE_ID

/*
	sales.OWNER_CENTER, 
	sales.OWNER_ID,
	sales.sales_date,
	subscription.BINDING_END_DATE, 
	subscription.SUBSCRIPTION_PRICE,
	subscription.BINDING_PRICE
*/
FROM 	SUBSCRIPTION_SALES sales, 
		SUBSCRIPTIONS subscription, 
		SUBSCRIPTIONTYPES types,
		EMPLOYEES e,
		PERSONS p
WHERE
	sales.SUBSCRIPTION_CENTER = subscription.CENTER AND
	sales.SUBSCRIPTION_ID = subscription.ID AND
	sales.SUBSCRIPTION_TYPE_CENTER = types.CENTER AND
	sales.SUBSCRIPTION_TYPE_ID = types.ID   AND
	sales.EMPLOYEE_CENTER = e.CENTER AND
	sales.EMPLOYEE_ID = e.ID AND
	e.PERSONCENTER=p.CENTER AND
	e.PERSONID=p.ID AND 
	sales.sales_date >= :sales_date
	/*sales.type = 1*/


