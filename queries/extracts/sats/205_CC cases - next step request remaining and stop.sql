select cc.personcenter || 'p' || cc.personid as person, cc.AMOUNT as CC_AMOUNT, cc.STARTDATE, cc.currentstep, 
cc.CURRENTSTEP_TYPE, cc.CURRENTSTEP_DATE, cc.NEXTSTEP_TYPE, cc.NEXTSTEP_DATE from ECLUB2.CASHCOLLECTIONCASES cc
where 
    cc.center between 300 and 399
    and cc.MISSINGPAYMENT = 1
    and cc.CLOSED = 0
    and cc.NEXTSTEP_TYPE = 3
    and 1 < (
        select count(*) from ECLUB2.CASHCOLLECTIONCASES cc2
        where cc2.PERSONCENTER = cc.PERSONCENTER
        and cc2.PERSONID = cc.PERSONID
        and cc2.CLOSED = 1
        and cc2.MISSINGPAYMENT = 1
    )
