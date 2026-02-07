SELECT
        t1.PersonId,
        t1.SubscriptionId,
		(CASE
			WHEN t1.Center = 238 THEN NULL
			ELSE
        		replace(left(t1.new_comment,strpos(t1.new_comment,chr(13))-1),'MembershipId: ','')
		END) AS MMS_SubscriptionId
FROM
(
        SELECT
                s.OWNER_CENTER || 'p' || s.OWNER_ID AS PersonId,
                s.CENTER || 'ss' || s.ID AS SubscriptionId,
				s.CENTER AS Center,
                RIGHT(s.sub_comment,length(s.sub_comment)-strpos(s.sub_comment,'MembershipId:')+1) AS new_comment
        FROM
            lifetime.subscriptions  s
        WHERE
            s.sub_comment IS NOT NULL
        AND s.center IN (:center)
) t1