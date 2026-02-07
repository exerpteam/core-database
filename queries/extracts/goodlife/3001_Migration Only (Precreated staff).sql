SELECT
    p.center || 'p' || p.id as "PersonId",
    p.fullname "Person FullName",
    pea.txtvalue "Care Id",
    cb.fullname "Created By",
    ei.identity AS "Barcode Id",
  p.center
FROM persons p
JOIN relatives r ON p.center=r.center AND p.id=r.id AND r.rtype=8
JOIN persons cb ON cb.center = r.relativecenter AND cb.id = r.relativeid
LEFT JOIN person_ext_attrs pea on pea.personcenter = p.center and pea.personid = p.id and pea.name = 'CAREID'
LEFT JOIN entityidentifiers ei ON ei.ref_center = p.center AND ei.ref_id = p.id AND ei.idmethod=1
WHERE p.sex != 'C'
      AND p.PERSONTYPE = 2
      AND p.status in (0,1,2,3,6,9)
	  AND pea.txtvalue IS NOT NULL
      --AND lower(cb.fullname) not like 'exerp%'
      AND p.center in (:scope)
