 SELECT
     per.center||'p'||per.id "Member ID",
     sub.center||'ss'||sub.id  "Subscription",
     prd.name,
     sub.start_date "Subscription start date",
     activation_result_type.txtvalue "Activation result type",
     lookup_result_type.txtvalue "Lookup result tpe"
 FROM
     persons per
 LEFT JOIN
     person_ext_attrs activation_result_type
 ON
     per.id = activation_result_type.personid
 AND per.center = activation_result_type.personcenter
 AND activation_result_type.name='_eClub_PBActivationResultType'
 LEFT JOIN
     person_ext_attrs lookup_result_type
 ON
     per.id = lookup_result_type.personid
 AND per.center = lookup_result_type.personcenter
 AND lookup_result_type.name='_eClub_PBLookupResultType'
     /*JOIN
     "EXERP_TDA"."newTable" nper
     ON
     nper."Member"= per.center||'p'||per.id*/
 JOIN
     subscriptions sub
 ON
     sub.owner_center=per.center
 AND sub.owner_id=per.id
 JOIN
     products prd
 ON
     sub.SUBSCRIPTIONTYPE_CENTER = prd.center
 AND sub.SUBSCRIPTIONTYPE_ID = prd.id
 WHERE
     prd.globalid IN ('UK211',
                      'UK0046',
                      'UK0040',
                      'UK319',
                      'UK127', 'OP005')
 --AND per.id=89803
 --AND per.center=421
 AND sub.start_date BETWEEN to_date('18-01-2021','dd-mm-yyyy') AND to_date('11-02-2021','dd-mm-yyyy'
     )
