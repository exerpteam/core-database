select ar.CUSTOMERCENTER,ar.CUSTOMERID,sum(art.AMOUNT) balance from ACCOUNT_RECEIVABLES ar 
join AR_TRANS art on art.CENTER = ar.CENTER and art.ID = ar.ID and ar.AR_TYPE = 5
where ar.CUSTOMERCENTER in ($$scope$$)
group by ar.CUSTOMERCENTER,ar.CUSTOMERID
having sum(art.AMOUNT) > 0