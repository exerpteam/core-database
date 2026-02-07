WITH
    ended_pif_subscriptions AS
    (
        SELECT
            cp.external_id,
            cp.center AS person_center,
            cp.id     AS person_id,
            cp.fullname AS member_name,
            pr.name,
            st.st_type,
            s.end_date,
            s.state,
            cp.status
            
        FROM
            subscriptions s
        JOIN
            subscriptiontypes st
        ON
            s.subscriptiontype_center = st.center
        AND s.subscriptiontype_id = st.id
        JOIN
            products pr
        ON
            st.center = pr.center
        AND st.id = pr.id
        JOIN
            persons p
        ON
            s.owner_center = p.center
        AND s.owner_id = p.id
        JOIN
            persons cp
        ON
            p.current_person_center = cp.center
        AND p.current_person_id = cp.id
        WHERE
        --   s.center = 102 and s.id = 5 
        st.st_type = 0 -- PIF
        AND s.end_date BETWEEN :from_date AND :to_date
        AND s.state in (3, 7) -- ended or window
        AND s.sub_state = 1
    )
SELECT
    s.center, 
    s_ended.external_id AS member_external_id,
    s_ended.person_center||'p'||s_ended.person_id AS member_id,
    s_ended.member_name,
    CASE s_ended.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS current_user_status,
    TO_CHAR(s_ended.end_date,'MM/DD/YYYY') AS old_membership_end_date,
    s_ended.name AS old_membership,
    pr.name AS new_membership,
    TO_CHAR(s.start_date,'MM/DD/YYYY') AS new_membership_start_date,
    TO_CHAR(s.end_date,'MM/DD/YYYY') AS new_membership_end_date,
    CASE 
      WHEN st.st_type = 0 THEN 'PIF' 
      WHEN st.st_type = 1 THEN 'EFT' 
    END AS contract_type,
    sp.fullname AS "Sales Created By",
    s.subscription_price  AS "Subscription Price"
FROM
    ended_pif_subscriptions s_ended
JOIN
    subscriptions s
ON
    s_ended.person_center = s.owner_center
AND s_ended.person_id = s.owner_id
AND s.state IN (2,4,8)
JOIN
    subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
AND s.subscriptiontype_id = st.id
AND st.st_type = 0 -- PIF
JOIN
    products pr
ON
    st.center = pr.center
AND st.id = pr.id
LEFT JOIN
    persons sp
ON
   sp.center = s.creator_center
   AND sp.id = s.creator_id