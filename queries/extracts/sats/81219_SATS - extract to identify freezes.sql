SELECT
    s.owner_center || 'p' || s.owner_id                                                AS MemberId,
    s.center || 'ss' || s.id                                                      AS SubscriptionId,
    s.start_date                                                          AS SUBSCRIPTION_STARTDATE,
    s.end_date                                                              AS SUBSCRIPTION_ENDDATE,
    DECODE(S.STATE,2,'ACTIVE',3,'ENDED',4,'FROZEN',7,'WINDOW',8,'CREATED','Undefined') AS
                      SUBSCRIPTION_STATE,
 longtodatec(sfp.ENTRY_TIME,cen.id) FREEZE_CREATION_DATE,
    sfp.start_date AS FREEZE_START_DATE,
    sfp.end_date   AS FREEZE_END_DATE,
    sfp.text "Freeze text",
    pc.name AS Payment_cycle_name,
  prd.price Freeze_Price , EXTRACT (xmltype (  st.freezelimit, 871), '/FREEZELIMIT/FREEZEAPPLYPERIOD/FREEZEDURATION').getstringVal() Freeze_Duration
FROM
    subscriptions s
JOIN
    SUBSCRIPTION_FREEZE_PERIOD sfp
ON
    s.CENTER = sfp.SUBSCRIPTION_CENTER
AND s.ID = sfp.SUBSCRIPTION_ID
JOIN
    persons per
ON
    per.id = s.owner_id
AND per.center = s.owner_center
JOIN
    CENTERS cen
ON
    cen.id = s.center
JOIN
    account_receivables ar
ON
    ar.customercenter = s.owner_center
AND ar.customerid = s.owner_id
AND ar.ar_type = 4 --payment
JOIN
    payment_agreements pag
ON
    ar.id=pag.id
AND ar.center=pag.center
JOIN
    payment_cycle_config pc
ON
    pc.id = pag.payment_cycle_config_id
join subscriptiontypes st
on st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id --and st.st_type=1
 join products prd
on st.FREEZEPERIODPRODUCT_CENTER = prd.center and st.FREEZEPERIODPRODUCT_id = prd.id
WHERE
    sfp.ENTRY_TIME <= 1646089220000 --March 1/2022  , 12
--AND sfp.ENTRY_TIME >= 1645570799000 --  February 22/2022 , 12
AND sfp.STATE IN ('ACTIVE')
AND sfp.TYPE = 'CONTRACTUAL'
--AND cen.country='DK' --Denmark
and cen.id in (:scope)
AND s.state IN (2,4,8) --Active,Frozen,Created
and sfp.end_date >= to_date('23-02-2022','dd-mm-yyyy')
and pag.active=1
