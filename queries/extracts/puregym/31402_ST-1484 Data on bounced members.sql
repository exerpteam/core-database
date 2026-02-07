SELECT
    PAYER_PID
  ,PR_REQUEST_DATE
  ,SUB_OWNER
  ,END_DATE
  ,REF
  ,ADMIN_FEE
  ,PAID_BEFORE_REPRESENTATION
  ,CALCULATED_REPRESENTATION
  ,ACTUAL_REPRESENTATION
  ,MAX(LOG_DATE) AGREEMENT_ENDED
FROM
    (
        SELECT
            ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID payer_pid
          ,pr.REQ_DATE                                pr_request_date
          ,s.OWNER_CENTER || 'p' || s.OWNER_ID        sub_owner
          ,s.END_DATE
          ,prs.REF
          ,prs.REJECTION_FEE admin_fee
          ,acl.LOG_DATE
            -- ,MAX(acl.LOG_DATE ) OVER (PARTITION BY pr.CENTER,pr.ID,pr.SUBID) agreement_ended
          , CASE
                WHEN prs.PAID_STATE IN ('LATE')
                THEN 'YES'
                ELSE 'NO'
            END                     paid_before_representation
          , (ci.RECEIVED_DATE + 10) calculated_representation
          ,prr.REQ_DATE             actual_representation
            --  ,prr.REQ_DATE - (ci.RECEIVED_DATE + 10) diff
        FROM
            PAYMENT_REQUEST_SPECIFICATIONS prs
        JOIN
            PAYMENT_REQUESTS pr
        ON
            pr.INV_COLL_CENTER = prs.CENTER
            AND pr.INV_COLL_ID = prs.ID
            AND pr.INV_COLL_SUBID = prs.SUBID
            AND pr.REQUEST_TYPE = 1
        JOIN
            PAYMENT_AGREEMENTS pa
        ON
            pa.CENTER = pr.CENTER
            AND pa.ID = pr.ID
            AND pa.SUBID = pr.AGR_SUBID
        LEFT JOIN
            AGREEMENT_CHANGE_LOG acl
        ON
            acl.AGREEMENT_CENTER = pa.CENTER
            AND acl.AGREEMENT_id = pa.ID
            AND acl.AGREEMENT_SUBID = pa.SUBID
            AND acl.STATE IN (5,6,7,8,10)
        JOIN
            CLEARING_IN ci
        ON
            ci.id = pr.XFR_DELIVERY
        LEFT JOIN
            PAYMENT_REQUESTS prr
        ON
            prr.INV_COLL_CENTER = prs.CENTER
            AND prr.INV_COLL_ID = prs.ID
            AND prr.INV_COLL_SUBID = prs.SUBID
            AND prr.REQUEST_TYPE = 6
        JOIN
            AR_TRANS art
        ON
            art.PAYREQ_SPEC_CENTER = prs.CENTER
            AND art.PAYREQ_SPEC_ID = prs.ID
            AND art.PAYREQ_SPEC_SUBID = prs.SUBID
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CENTER = art.CENTER
            AND ar.ID = art.ID
        JOIN
            INVOICELINES invl
        ON
            invl.CENTER = art.REF_CENTER
            AND invl.ID = art.REF_ID
            AND art.REF_TYPE = 'INVOICE'
        JOIN
            SPP_INVOICELINES_LINK link
        ON
            link.INVOICELINE_CENTER = invl.CENTER
            AND link.INVOICELINE_ID = invl.ID
            AND link.INVOICELINE_SUBID = invl.SUBID
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = link.PERIOD_CENTER
            AND s.ID = link.PERIOD_ID
        WHERE
            --    prs.REF = '186-169470'
            --    AND
            pr.XFR_INFO = 'Refer to payer'
            --AND ci.RECEIVED_DATE > to_date('2014-01-14', 'YYYY-MM-DD')
            AND ci.RECEIVED_DATE BETWEEN $$date_from$$ AND $$date_to$$ + 1
            AND ar.CUSTOMERCENTER IN ($$scope$$) )
GROUP BY
    PAYER_PID
  ,PR_REQUEST_DATE
  ,SUB_OWNER
  ,END_DATE
  ,REF
  ,ADMIN_FEE
  ,PAID_BEFORE_REPRESENTATION
  ,CALCULATED_REPRESENTATION
  ,ACTUAL_REPRESENTATION