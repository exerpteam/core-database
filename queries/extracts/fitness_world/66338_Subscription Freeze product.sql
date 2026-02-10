-- The extract is extracted from Exerp on 2026-02-08
--  
Select
pr1.NAME,
pr2.NAME,
pr2.PRICE
From products pr1

JOIN SUBSCRIPTIONTYPES st
ON
    st.center = pr1.center
    AND st.id = pr1.id

JOIN products pr2
ON
	st.FREEZESTARTUPPRODUCT_CENTER = pr2.CENTER
	AND st.FREEZESTARTUPPRODUCT_ID = pr2.ID


where 
pr1.PTYPE = 10
AND pr1.BLOCKED = 0
GROUP BY
pr1.NAME,
pr2.NAME,
pr2.PRICE

