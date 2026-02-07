select distinct scl.* from SUBSCRIPTIONS s 
join SUBSCRIPTIONTYPES st on st.CENTER = s.SUBSCRIPTIONTYPE_CENTER and st.ID = s.SUBSCRIPTIONTYPE_ID 
join STATE_CHANGE_LOG scl on scl.CENTER = s.CENTER and scl.ID = s.ID and scl.ENTRY_TYPE = 2 and scl.STATEID = 3 
left join SUBSCRIPTIONPERIODPARTS spp on spp.CENTER = s.CENTER and spp.ID = s.ID 
left join SPP_INVOICELINES_LINK link on link.PERIOD_CENTER = spp.CENTER and link.PERIOD_ID = spp.ID and link.PERIOD_SUBID = spp.SUBID 
left join AR_TRANS art on art.REF_TYPE = 'INVOICE' and art.REF_CENTER = link.INVOICELINE_CENTER and art.REF_ID = link.INVOICELINE_ID 
left join PAYMENT_REQUEST_SPECIFICATIONS prs on prs.CENTER = art.PAYREQ_SPEC_CENTER and prs.ID = art.PAYREQ_SPEC_ID and prs.SUBID = art.PAYREQ_SPEC_SUBID
where st.ST_TYPE = 1 and s.STATE = 3 and s.SUB_STATE in (7,8) and scl.ENTRY_START_TIME between :from_date and :to_date