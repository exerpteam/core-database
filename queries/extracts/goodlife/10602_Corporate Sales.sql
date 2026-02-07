SELECT 
  p.center||'p'||p.ID AS "Person_ID",
  pea.txtvalue As "Date_Person_Added",
  p.fullname AS "Person_Full_Name", 
  s.start_date AS "Subscription_Start_Date",
  r.relativecenter||'p'||r.relativeid||'rpt'||r.relativesubid AS "Company_Agreement_ID"

FROM 
  PERSONS p 
LEFT JOIN
  RELATIVES r
ON 
  p.center = r.center
  AND p.ID = r.ID
  AND rtype = 3
  AND r.status = 1
JOIN    
  SUBSCRIPTIONS s
ON
  p.CENTER = s.OWNER_CENTER 
  AND p.ID = s.OWNER_ID
join
	SUBSCRIPTIONTYPES st
on
	s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = st.ID

JOIN
  PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
ON

	ppgl.product_center = st.productnew_center
    AND ppgl.product_id = st.productnew_id

JOIn
  PERSON_EXT_ATTRS pea
ON
  p.CENTER = pea.PERSONCENTER
  AND p.ID = pea.PERSONID
  AND pea.NAME = 'CREATION_DATE'
WHERE  

  to_date(pea.txtvalue,'YYYY-MM-DD') >= (:DateFrom)
  AND to_date(pea.txtvalue,'YYYY-MM-DD') <= (:DateTo)
  AND ppgl.product_group_id in (:Product_Group_ID)
  --AND p.persontype = 4

