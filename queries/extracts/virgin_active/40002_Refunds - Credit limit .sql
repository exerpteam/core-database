WITH
    PARAMS AS
    (
        SELECT
            CAST(extract(epoch FROM timezone('Europe/London', CAST($$FromDate$$ AS timestamptz))) AS
            bigint)*1000 AS FromDate,
            CAST(extract(epoch FROM timezone('Europe/London', CAST($$ToDate$$ AS timestamptz))) AS
            bigint)*1000 AS ToDate
    )
    ,
    ptmem AS MATERIALIZED
    (
        SELECT
            s.owner_center,
            s.owner_id,
            addon_center.shortname AS PTDDCLUB
        FROM
            subscriptions s
        JOIN
            subscription_addon sa
        ON
            sa.subscription_center = s.center
        AND sa.subscription_id = s.id
        AND COALESCE(sa.end_date, CURRENT_TIMESTAMP) > CURRENT_TIMESTAMP -1
        AND sa.cancelled = 0
        JOIN
            MASTERPRODUCTREGISTER m
        ON
            sa.ADDON_PRODUCT_ID=m.ID
        JOIN
            PRODUCTS addon_pr
        ON
            addon_pr.GLOBALID = m.GLOBALID
        AND addon_pr.center = sa.CENTER_ID
        JOIN
            product_and_product_group_link papgl
        ON
            papgl.product_center = addon_pr.center
        AND papgl.product_id = addon_pr.id
        JOIN
            product_group pg
        ON
            pg.id = papgl.product_group_id
        JOIN
            centers addon_center
        ON
            addon_center.id = sa.center_id
        WHERE
            pg.name IN ('PT DD Standard',
                        'PT DD Master',
                        'PT DD ICON')
        GROUP BY
            s.owner_center,
            s.owner_id,
            addon_center.shortname
    )


SELECT
     c.shortname                                                                                                              AS CreditCenter,
     CASE cnl.canceltype  WHEN 0 THEN  'Wrong sale'  WHEN 1 THEN  'Faulty product'  WHEN 2 THEN  'Product returned'  WHEN 3 THEN 'Subscription changed'  ELSE 'Unknown' END AS Reason,
     COALESCE(cnl.cancel_reason, cn.text)                                                                                          AS CancelReason,
     CASE WHEN p.center IS NOT NULL THEN  p.center || 'p' || p.id ELSE  NULL END                                                                            AS MemberID,
     p.fullname                                                                                                               AS MemberName,
     perclub.shortname                                                                                                        AS MemberHomeClub,
     ptmem.PTDDCLUB                                                                                                           AS PTDDClub,
     cnl.center||'cred'||cnl.id||'cnl'||cnl.subid                                                                             AS CreditNoteLine,
     cnl.center||'cred'||cnl.id||'cnl'||cnl.subid                                                                             AS LineHeader,
     emp.center || 'emp' || emp.id                                                                                            AS EmployeeID,
     empper.fullname                                                                                                          AS EmployeeName,
     cnl.quantity                                                                                                             AS Quantity,
     prod.name                                                                                                                AS ProductName,
     cnl.total_amount                                                                                                         AS TotalAmount,
     longtodatec(cn.trans_time, cn.center)                                                                                    AS TransactionTime,
     cnl.text                                                                                                                 AS Text
 FROM
     credit_note_lines_mt cnl
 JOIN
     centers c
 ON
     c.id = cnl.center
 JOIN
     credit_notes cn
 ON
     cn.center = cnl.center
     AND cn.id = cnl.id
 JOIN
     employees emp
 ON
     emp.center = cn.employee_center
     AND emp.id = cn.employee_id
 JOIN
     persons empper
 ON
     empper.center = emp.personcenter
     AND empper.id = emp.personid
 JOIN
     products prod
 ON
     prod.center = cnl.productcenter
     AND prod.id = cnl.productid
 LEFT JOIN
     ar_trans art
 ON
     art.ref_center = cn.center
     AND art.ref_id = cn.id
     AND art.ref_type = 'CREDIT_NOTE'
 LEFT JOIN
     account_receivables ar
 ON
     ar.center = art.center
     AND ar.id = art.id
 LEFT JOIN
     persons p
 ON
     p.center = ar.customercenter
     AND p.id = ar.customerid
 LEFT JOIN
     centers perclub
 ON
     perclub.id = p.center
 LEFT JOIN
     ptmem
 ON
     ptmem.owner_center = p.center
     AND ptmem.owner_id = p.id

 CROSS JOIN params par

 WHERE
     CNL.CREDIT_TYPE = 1
     AND cnl.center IN ($$Scope$$)
	 AND cn.trans_time >= par.FromDate
     AND cn.trans_time <= par.ToDate
