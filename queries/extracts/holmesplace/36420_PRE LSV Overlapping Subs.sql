SELECT
    s.owner_center || 'p' || s.owner_id AS PersonId,
    s.center || 'ss' || s.id            AS Sub1_Id,
    s.start_date                        AS Sub1_Start,
    s.end_date                          AS Sub1_End,
	sprod.name 							AS Sub1_Name,
    os.center || 'ss' || os.id          AS Sub2_Id,
    os.start_date                       AS Sub2_Start,
    os.end_date                         AS Sub2_End,
	osprod.name							AS Sub2_Name
FROM
    hp.subscriptions s
JOIN
    hp.subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
    AND st.st_type IN (0,1)
JOIN
      hp.products sprod
ON
      sprod.center = st.center
      AND sprod.id = st.id
JOIN
    hp.subscriptions os
ON
    os.owner_center = s.owner_center
    AND os.owner_id = s.owner_id
    AND os.center || 'ss' || os.id != s.center || 'ss' || s.id
JOIN
    hp.subscriptiontypes ost
ON
    ost.center = os.subscriptiontype_center
    AND ost.id = os.subscriptiontype_id
    AND ost.st_type IN (0,1)
JOIN
      hp.products osprod
ON
      osprod.center = ost.center
      AND osprod.id = ost.id
WHERE
    s.owner_center IN ($$Scope$$)
    AND s.state IN (2,4,7,8)
    AND os.state IN (2,4,7,8)
    AND s.creation_time <= os.creation_time
    AND s.start_date <= COALESCE(os.end_date, CURRENT_DATE)
    AND COALESCE(s.end_date, CURRENT_DATE) >= os.start_date
	-- Both subscription end date must be in the future
	AND COALESCE(s.end_date, CURRENT_DATE) >= CURRENT_DATE
	AND COALESCE(os.end_date, CURRENT_DATE) >= CURRENT_DATE