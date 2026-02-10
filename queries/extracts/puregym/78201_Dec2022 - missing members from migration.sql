-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    pcl.person_center||'p'||pcl.person_id    former_person_id,
    pcl2.new_value                        AS first_name,
    pcl3.new_value                        AS last_name,
    pcl.new_value                         AS email,
    pcl4.new_value                        AS phone,
    CASE s.STATE
        WHEN 2
        THEN 'ACTIVE'
        WHEN 3
        THEN 'ENDED'
        WHEN 4
        THEN 'FROZEN'
        WHEN 7
        THEN 'WINDOW'
        WHEN 8
        THEN 'CREATED'
        ELSE NULL
    END AS SUBSCRIPTION_STATE,
    s.start_date,
    s.end_date,
 	prod.name,
    prod.globalid,
    ar.balance,
    CASE pag.STATE
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'
        WHEN 15
        THEN 'Transfer'
        WHEN 16
        THEN 'Agreement Recreated'
        WHEN 17
        THEN 'Signature missing'
        ELSE NULL
    END                              AS Agreement_STATE,
    longtodateC(pcl.entry_time, 100) AS join_date
FROM
    person_change_logs pcl
JOIN
    person_change_logs pcl2
ON
    pcl.person_id=pcl2.person_id
AND pcl2.person_center=pcl.person_center
JOIN
    person_change_logs pcl3
ON
    pcl.person_id=pcl3.person_id
AND pcl.person_center=pcl3.person_center
LEFT JOIN
    person_change_logs pcl4
ON
    pcl.person_id=pcl4.person_id
AND pcl.person_center=pcl4.person_center
AND pcl4.change_attribute = 'MOB_PHONE'
LEFT JOIN
    subscriptions s
ON
    pcl.person_center=s.owner_center
AND pcl.person_id=s.owner_id
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    pcl.person_center = ar.CUSTOMERCENTER
AND pcl.person_id = ar.CUSTOMERID
LEFT JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.center = ar.center
AND pac.id = ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS pag
ON
    pag.center = pac.ACTIVE_AGR_center
AND pag.id = pac.ACTIVE_AGR_id
AND pag.SUBID = pac.ACTIVE_AGR_SUBID
LEFT JOIN
    SUBSCRIPTIONTYPES st
ON
    s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
AND s.SUBSCRIPTIONTYPE_ID = st.ID
LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = st.CENTER
AND prod.id = st.ID
WHERE
    pcl.entry_time BETWEEN 1669769237000::bigint AND 1670374037000::bigint
AND pcl.change_attribute = 'E_MAIL'
AND pcl2.change_attribute = 'FIRST_NAME'
AND pcl3.change_attribute = 'LAST_NAME'
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            persons p
        WHERE
            pcl.person_id=p.id
        AND pcl.person_center=p.center)