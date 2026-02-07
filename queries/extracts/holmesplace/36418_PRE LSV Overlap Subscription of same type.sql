SELECT
    s.owner_center || 'p' || s.owner_id AS PersonId,
    s.center || 'ss' || s.id            AS OverlapSubId1,
    s.start_date                        AS Overlap1SubStartDate,
    s.end_date                          AS Overlap1SubEndDate,
    os.center || 'ss' || os.id          AS OverlapSubId2,
    os.start_date                       AS Overlap2SubStartDate,
    os.end_date                         AS Overlap2SubStopDate
FROM
    hp.subscriptions s
JOIN
    hp.subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
    AND st.st_type IN (0,1)
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
WHERE
    s.owner_center IN ($$Scope$$)
    AND s.state IN (2,4,7,8)
    AND os.state IN (2,4,7,8)
    AND st.st_type = ost.st_type
    AND s.creation_time <= os.creation_time
	AND s.id < os.id
    AND s.start_date <= COALESCE(os.end_date, CURRENT_DATE)
    AND COALESCE(s.end_date, CURRENT_DATE) >= os.start_date
	-- Both subscription end date must be in the future
	AND COALESCE(s.end_date, CURRENT_DATE) >= CURRENT_DATE
	AND COALESCE(os.end_date, CURRENT_DATE) >= CURRENT_DATE