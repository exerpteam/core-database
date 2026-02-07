Select distinct
p.name,
p.GLOBALID,
st.RENEW_WINDOW,
SUM(
        CASE
            WHEN s.state = 2
            THEN 1
            ELSE 0
        END) AS "active subscriptions",
SUM(
        CASE
            WHEN s.state = 4
            THEN 1
            ELSE 0
        END) AS "Frozen subscriptions",
SUM(
        CASE
            WHEN s.state = 8
            THEN 1
            ELSE 0
        END) AS "created subscriptions"        
FROM
SUBSCRIPTIONTYPES st

join products p
ON

st.center = p.center
AND st.id = p.id

Join
SUBSCRIPTIONS s

ON
st.center = s.SUBSCRIPTIONTYPE_CENTER
AND st.id = s.SUBSCRIPTIONTYPE_id
and s.state in (2,4,8)

where
st.RENEW_WINDOW = 0

and ST_TYPE in (0,1)

group by
p.GLOBALID,
p.name,
st.RENEW_WINDOW,
s.state

