-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    t1.*
FROM
    ( WITH
            params AS MATERIALIZED
            (   SELECT
                    DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) AS cutdate,
                    c.ID                                                          AS CenterID,
                    c.name                                                        AS centerName,
                    DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD'))-interval
                    '1 month'                             AS latest_joindate,
                    c.email                               AS centeremail,
                    c.manager_center ||'p'|| c.manager_id AS managerId,
                    staff.fullname                        AS managerName,
                    staff.external_id                     AS managerExternalId
                FROM
                    CENTERS c
                JOIN
                    persons staff
                ON
                    staff.center = c.manager_center
                AND staff.id = c.manager_id
            )
        SELECT
            p.external_id         AS "Member ID",
            p.center ||'p'|| p.id AS "Personkey",
            op.txtvalue           AS "Contact GUID",
            p.firstname           AS "Firstname",
            p.lastname            AS "Lastname",
            prod.name             AS "Package Description",
            s.binding_end_date    AS "Expiry Date", 
            par.centername        AS "Center Name",
            par.centeremail       AS "Center Email",
            par.managerExternalId AS "General Manager ID",
            par.managerName       AS "General Manager name",
            pea.txtvalue          AS "Email",
            prs.open_amount       AS "Open Amount",
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
                ELSE 'UNDEFINED'
            END                       AS "Payment agreement state",
            com.center ||'p'|| com.id AS "Company ID",
            com.fullname              AS "Company name"
        FROM
            payment_request_specifications prs
        JOIN
            params par
        ON
            par.CenterID = prs.center
        JOIN
            account_receivables ar
        ON
            ar.center = prs.center
        AND ar.id = prs.id
        JOIN
            persons p
        ON
            p.center = ar.customercenter
        AND p.id = ar.customerid
        JOIN
            payment_requests pr
        ON
            prs.center = pr.inv_coll_center
        AND prs.id = pr.inv_coll_id
        AND prs.subid = pr.inv_coll_subid
        AND pr.request_type = 1
        AND pr.state NOT IN (1,2,3,4,8,12,18)
        JOIN
            payment_agreements pag
        ON
            pag.center = pr.center
        AND pag.id = pr.id
        AND pag.subid = pr.agr_subid
        JOIN
            subscriptions s
        ON
            s.owner_center = p.center
        AND s.owner_id = p.id
        AND s.state IN (2,4)
        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        JOIN
            products prod
        ON
            prod.center = st.center
        AND prod.id = st.id
        JOIN
            product_and_product_group_link prgl
        ON
            prgl.product_center = prod.center
        AND prgl.product_id = prod.id
        LEFT JOIN
            person_ext_attrs pea
        ON
            pea.personcenter = p.center
        AND pea.personid = p.id
        AND pea.name = '_eClub_Email'
        LEFT JOIN
            person_ext_attrs op
        ON
            op.personcenter = p.center
        AND op.personid = p.id
        AND op.name = '_eClub_OldSystemPersonId'
        LEFT JOIN
            (   SELECT
                    rel.relativecenter,
                    rel.relativeid,
                    comp.center,
                    comp.id,
                    comp.fullname
                FROM
                    relatives rel
                JOIN
                    persons comp
                ON
                    comp.center = rel.center
                AND comp.id = rel.id
                WHERE
                    rel.rtype = 2
                AND rel.status = 1
                AND comp.sex = 'C') com
        ON
            com.relativecenter = p.center
        AND com.relativeid = p.id
        WHERE
            pr.req_date >= par.cutdate
        AND ar.balance < 0
        AND ar.ar_type = 4
        AND p.sex != 'C'
        AND p.persontype != 2
        AND prs.open_amount >= 10
        AND pr.clearinghouse_id IN (2)
        AND pr.rejected_reason_code != '2'
        AND prgl.product_group_id = 203
        AND p.center IN (:scope)
        AND p.last_active_start_date < par.latest_joindate
        AND NOT EXISTS
            (   SELECT
                    1
                FROM
                    payment_requests rep_req
                WHERE
                    rep_req.inv_coll_center = prs.center
                AND rep_req.inv_coll_id = prs.id
                AND rep_req.inv_coll_subid = prs.subid
                AND rep_req.request_type = 6
                AND rep_req.state NOT IN (8)
                HAVING
                    COUNT(*) >= 1 )
        AND NOT EXISTS
            (   SELECT
                    1
                FROM
                    tasks ta
                WHERE
                    ta.type_id = 200
                AND ta.step_id = 203
                AND ta.person_center = p.center
                AND ta.person_id = p.id)
        AND NOT EXISTS
            (   SELECT
                    sub.*
                FROM
                    subscriptions sub
                JOIN
                    subscriptiontypes subst
                ON
                    subst.center = sub.subscriptiontype_center
                AND subst.id = sub.subscriptiontype_id
                JOIN
                    products subpr
                ON
                    subpr.center = subst.center
                AND subpr.id = subst.id
                JOIN
                    product_and_product_group_link subprgl
                ON
                    subprgl.product_center = subpr.center
                AND subprgl.product_id = subpr.id
                WHERE
                    sub.center = s.center
                AND sub.id = s.id
                AND subprgl.product_group_id = 401) ) t1