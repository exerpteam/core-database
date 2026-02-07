SELECT
s.owner_center ||'p'|| s.owner_id AS member_id,
s.center ||'ss'|| s.id AS subscription_key
FROM
    subscriptions s
JOIN
    centers c
ON
    c.id = s.center
JOIN
    subscriptiontypes st
    ON
    st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
JOIN
products pr
ON
pr.center = st.center
AND pr.id = st.id
AND pr.ptype = 10
AND pr.blocked = false
WHERE
s.creator_center = 4
AND s.creator_id = 66201
AND c.country ='GB'
AND pr.name IN ('Active Aces Max 6 12 Month by DD 120 mins' ,
                               'Active Aces Max 6 12 Month by DD 60 mins' ,
                               'Active Aces Max 6 12 Month by DD 90 mins' ,
                               'Active Aces Max 6 3 Month Racq by DD 120 mins' ,
                               'Active Aces Max 6 3 Month Racq by DD 60 mins' ,
                               'Active Aces Max 6 3 Month Racq by DD 90 mins' ,
                               'Active Performance Aces Max 6 12m by DD 120 mins' ,
                               'Active Performance Aces Max 6 12m by DD 90 mins' ,
                               'Active Performance Aces Max 6 3 Month by DD 120min' ,
                               'Group Max 6 12 Month Swim by DD' ,
                               'Group Max 6 3 Month Swim by DD' ,
                               'Mini Active Aces Max 6 12 Month by DD 60 mins' ,
                               'Mini Active Aces Max 6 12 Month by DD 90 mins' ,
                               'Mini Active Aces Max 6 3 Month Racq by DD 60 mins' ,
                               'NM Active Aces Max 6 12 Month by DD 60 mins' ,
                               'NM Active Aces Max 6 3 Month by DD 60 mins' ,
                               'NM Group Max 6 12 Month Swim by DD' ,
                               'NM Group Max 6 3 Month Swim by DD' ,
                               'NM Mini Active Aces Max 6 12 Month by DD 60 mins' ,
                               'NM Mini Active Aces Max 6 3 Month by DD 60 mins' ,
                               'NM Parent & Baby Max 8 12 Month Swim by DD' ,
                               'NM Parent & Baby Max 8 3 Month Swim by DD' ,
                               'NM Private 121 12 Month Swim by DD' ,
                               'NM Private 121 3 Month Swim by DD' ,
                               'NM Private 221 12 Month Swim by DD' ,
                               'NM Private 221 3 Month Swim by DD' ,
                               'NM Small Group Max 4 12 Month Swim by DD' ,
                               'NM Small Group Max 4 3 Month Swim by DD' ,
                               'NM Squad Max 12 x 1 12 Month Swim by DD' ,
                               'NM Squad Max 12 x 1 12 Month Swim by DD' ,
                               'NM Squad Max 12 x 1 3 Month Swim by DD' ,
                               'NM Squad Max 12 x 1 3 Month Swim by DD' ,
                               'NM Squads Max 8 12 Month by DD 90 mins' ,
                               'NM Squads Max 8 3 Month by DD 90 mins' ,
                               'NM Tiny Active Aces Max 6 12 Month by DD 45 mins' ,
                               'NM Tiny Active Aces Max 6 3 Month by DD 45 mins' ,
                               'Parent & Baby Max 8 12 Month Swim by DD' ,
                               'Parent & Baby Max 8 3 Month Swim by DD' ,
                               'Private 121 12 Month Swim by DD' ,
                               'Private 121 3 Month Swim by DD' ,
                               'Private 221 12 Month Swim by DD' ,
                               'Private 221 3 Month Swim by DD' ,
                               'Small Group Max 4 12 Month Swim by DD' ,
                               'Small Group Max 4 3 Month Swim by DD' ,
                               'Squad Max 12 x 1 12 Month Swim by DD' ,
                               'Squad Max 12 x 1 12 Month Swim by DD' ,
                               'Squad Max 12 x 1 3 Month Swim by DD' ,
                               'Squad Max 12 x 1 3 Month Swim by DD' ,
                               'Squads Max 8 12 Month by DD 90 mins' ,
                               'Squads Max 8 3 Month Racq by DD 90 mins' ,
                               'Tiny Active Aces Max 6 12 Month by DD 45 mins' ,
                               'Tiny Active Aces Max 6 12 Month by DD 60 mins' ,
                               'Tiny Active Aces Max 6 3 Month Racq by DD 45 mins')