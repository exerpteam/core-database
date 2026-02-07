SELECT DISTINCT
    p.center||'p'||p.id as memberid,    
    to_char((longtodateTZ(m.senttime, 'America/Toronto')), 'YYYY-MM-DD HH24:MI:SS') as creationtime,
    to_char((longtodateTZ(m.receivedtime, 'America/Toronto')), 'YYYY-MM-DD HH24:MI:SS') as messagedelivertime,
    m.center,
    m.id,
    m.subid,
    m.deliverycode,
    m.templatetype,
    m.message_type_id,
    m.subject
FROM
    persons p
LEFT JOIN
    person_ext_attrs email
ON
    p.center = email.personcenter
AND p.id = email.personid
AND email.name = '_eClub_Email'
JOIN
    messages m
ON
    m.center = p.center
AND m.id = p.id
   WHERE
    (
        email.txtvalue LIKE '%@hotmail.%'
    OR  email.txtvalue LIKE '%@outlook.%'
    OR  email.txtvalue LIKE '%@live.%'
    OR  email.txtvalue LIKE '%@msn.%'
    OR  email.txtvalue LIKE '%@windowslive.%' )
AND m.deliverycode = 2
AND m.senttime >= 1575392400000  --Tuesday, December 3, 2019 12.00.00 Eastern Time
AND m.senttime < 1576769400000 --Thursday, December 19, 2019 10.30.00 Eastern Time
AND (
        m.subject IN ('Your Freeze Confirmation From GoodLife Fitness',
                      'Your Subscription Freeze is Ending',
                      'GoodLife Fitness Parking Pass - Terms and Conditions',
                      'CERT Paid in Full Eligible Renewal Reminder',
                      'Membership Renewal Notice',
                      'Important Notice Of Payment Resubmission',
                      'Important Notice Of Credit Card Payment Resubmission',
                      'GoodLife Fitness Order Confirmation')
    OR  m.subject LIKE '%Thank You For Choosing GoodLife Fitness!')
AND (
        m.templatetype||'t'||m.message_type_id) IN ('40t48',
                                                    '88t38',
                                                    '103t49',
                                                    '155t78',
                                                    '166t91',
                                                    '167t92',
                                                    '171t97') 