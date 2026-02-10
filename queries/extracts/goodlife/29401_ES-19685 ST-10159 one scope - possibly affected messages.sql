-- The extract is extracted from Exerp on 2026-02-08
-- Pulls a list of members with email address from one of the blocked domains, who had a contract email sent since November 19 2019
SELECT
    p.center ||'p'|| p.id                           AS member,
    email.txtvalue                                  AS email_domain,
    longtodateTZ(m.senttime, 'America/Toronto')     AS messagecreationtime,
    longtodateTZ(m.receivedtime, 'America/Toronto') AS messagedelivertime,
    m.center,
    m.id,
    m.subid,
    m.deliverycode,
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
    OR  email.txtvalue LIKE '%@windowslive.%'
    OR  email.txtvalue LIKE '%@yahoo.%')
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
AND m.deliverycode = 2
AND m.center = :center
AND (
        m.senttime >= datetolongc('2019-11-19 00:01' , m.CENTER) )