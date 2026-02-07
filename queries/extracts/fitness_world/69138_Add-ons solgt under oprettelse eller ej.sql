-- This is the version from 2026-02-05
--  
Select distinct
CASE
	When sa.start_date = s.start_date
	Then 'Tilføjet ved oprettelse'
	Else 'Senere tilføjelse'
END AS "Oprettelses status",
longtodate(s.CREATION_TIME) AS "Medlemskab oprettelse",
s.start_date AS "Medlemskab start",
longtodate(sa.creation_time) AS "Add-on oprettelse",
sa.start_date AS "Add-on start",
s.owner_center ||'p'|| s.owner_id  AS Medlem,
pr.name AS Medlemskab,
add_pd.GLOBALID AS "Add-on globalID"
from subscription_addon sa
Join Subscriptions s
on sa.SUBSCRIPTION_CENTER = s.center and sa.SUBSCRIPTION_ID = s.id
JOIN MASTERPRODUCTREGISTER add_pd on add_pd.ID = sa.ADDON_PRODUCT_ID
join PRODUCTS PR
ON PR.CENTER = S.SUBSCRIPTIONTYPE_CENTER
AND PR.ID = S.SUBSCRIPTIONTYPE_ID
Where
add_pd.GLOBALID like 'ALL_IN%'
AND s.center in (:scope)
Order by
Medlem

