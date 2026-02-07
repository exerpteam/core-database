SELECT
    PAYER_PID
  ,PR_REQUEST_DATE
  ,SUB_OWNER
  ,END_DATE
  ,REF
  ,ADMIN_FEE
  ,admin_fee_paid
  ,PAID_BEFORE_REPRESENTATION_DUE
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
          ,case when sum(artm.AMOUNT)>= 5 then 1 else 0 end as admin_fee_paid
          ,acl.LOG_DATE
            -- ,MAX(acl.LOG_DATE ) OVER (PARTITION BY pr.CENTER,pr.ID,pr.SUBID) agreement_ended

          , (ci.RECEIVED_DATE + 10) calculated_representation
          ,prr.REQ_DATE             actual_representation
          ,case when prs.PAID_STATE_LAST_ENTRY_TIME is not null and longToDateC(prs.PAID_STATE_LAST_ENTRY_TIME,prs.CENTER) < prr.DUE_DATE and prs.OPEN_AMOUNT = 0 and prs.PAID_STATE = 'CLOSED' then 1
          else 0 end as PAID_BEFORE_REPRESENTATION_DUE
         
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
           /*Stop Subscription And Credit Invoices*/ 
        
        left join AR_TRANS art2 on art2.PAYREQ_SPEC_CENTER = prs.CENTER and     art2.PAYREQ_SPEC_ID = prs.ID and art2.PAYREQ_SPEC_SUBID = prs.SUBID  and art2.TEXT = 'Admin Fee' and art2.AMOUNT = -5    
        left join JOURNALENTRIES je on je.PERSON_CENTER = ar.CUSTOMERCENTER and je.PERSON_ID = ar.CUSTOMERID and je.NAME = 'Apply: Stop subscription and credit invoices' and je.CREATION_TIME > pr.ENTRY_TIME   
        left join ART_MATCH artm on artm.ART_PAID_CENTER = art2.CENTER and artm.ART_PAID_ID = art2.ID and artm.ART_PAID_SUBID = art2.SUBID and (je.CREATION_TIME is null or artm.ENTRY_TIME < je.CREATION_TIME)
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
            pr.XFR_INFO = 'Refer to payer'
            AND ci.RECEIVED_DATE BETWEEN $$date_from$$ AND $$date_to$$ + 1
            AND ar.CUSTOMERCENTER IN ($$scope$$)
                                                   
group by 
            ar.CUSTOMERCENTER ,ar.CUSTOMERID 
          ,pr.REQ_DATE         
          ,s.OWNER_CENTER,s.OWNER_ID        
          ,s.END_DATE
          ,prs.REF
          ,prs.REJECTION_FEE 
          ,acl.LOG_DATE
          , CASE
                WHEN prs.PAID_STATE IN ('LATE')
                THEN 'YES'
                ELSE 'NO'
            END
          , (ci.RECEIVED_DATE + 10) 
          ,prr.REQ_DATE        
          ,case when prs.PAID_STATE_LAST_ENTRY_TIME is not null and longToDateC(prs.PAID_STATE_LAST_ENTRY_TIME,prs.CENTER) < prr.DUE_DATE and prs.OPEN_AMOUNT = 0 and prs.PAID_STATE = 'CLOSED' then 1
          else 0 end 
                                                   
                                                   )
GROUP BY
    PAYER_PID
  ,PR_REQUEST_DATE
  ,SUB_OWNER
  ,END_DATE
  ,REF
  ,ADMIN_FEE
  ,PAID_BEFORE_REPRESENTATION_DUE
  ,CALCULATED_REPRESENTATION
  ,ACTUAL_REPRESENTATION
  ,admin_fee_paid