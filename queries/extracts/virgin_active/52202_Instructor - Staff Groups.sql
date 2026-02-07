 SELECT
         P.PERSON_ID,
         P.SCOPE_ID,
         SG.NAME                                                                 STAFF_GROUP,
         p.PERSON_CENTER || 'p' || p.person_id   STAFF_MEMBER_ID,
         p.STAFF_GROUP_ID
 FROM
         PERSON_STAFF_GROUPS P
 JOIN
         STAFF_GROUPS SG
         ON SG.ID = P.STAFF_GROUP_ID
 WHERE
         SG.SCOPE_ID = '2'
 AND
         P.SCOPE_ID IN
         (
 '2',
 '6',
 '9',
 '12',
 '15',
 '16',
 '27',
 '29',
 '30',
 '33',
 '34',
 '35',
 '36',
 '38',
 '39',
 '40',
 '47',
 '48',
 '51',
 '56',
 '57',
 '59',
 '60',
 '61',
 '68',
 '69',
 '71',
 '75',
 '76',
 '405',
 '408',
 '410',
 '415',
 '421',
 '422',
 '425',
 '437',
 '438',
 '452',
 '700',
 '953',
 '954',
 '955')
