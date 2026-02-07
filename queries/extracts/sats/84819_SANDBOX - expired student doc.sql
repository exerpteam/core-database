Select p.center, p.id, TO_DATE(a.txtvalue, 'YYYY-MM-DD') AS "Documentation expiry date" from persons p
join PERSON_EXT_ATTRS A on P.CENTER = A.PERSONCENTER and P.ID = A.PERSONID and A.NAME = '_eClub_StudyDocValidUntil'
where
A.TXTVALUE <= '2022-11-07' and
   P.STATUS IN (1,3)  and P.PERSONTYPE = 1