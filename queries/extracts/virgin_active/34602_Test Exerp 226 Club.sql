SELECT
        s.OWNER_CENTER || 'p' || s.OWNER_ID AS "PersonId",
        s.CENTER || 'ss'|| s.ID AS "SubscriptionId",
        s.START_DATE,
        s.BILLED_UNTIL_DATE,
        s.BINDING_END_DATE,
        s.END_DATE,
        st.ST_TYPE
        
FROM
        SUBSCRIPTIONS s
JOIN 
        SUBSCRIPTIONTYPES st
                ON s.SUBSCRIPTIONTYPE_CENTER = st.CENTER AND s.SUBSCRIPTIONTYPE_ID = st.ID
WHERE
        s.CENTER = 226
AND s.creation_time > $$From_date$$