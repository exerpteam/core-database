SELECT
    person_ext_attrs.txtvalue,
    COUNT(*) AS c
FROM
    person_ext_attrs
WHERE
    person_ext_attrs.name = '_eClub_Email'
	and person_ext_attrs.txtvalue is not null
GROUP BY
    person_ext_attrs.txtvalue
having count(*) > 1;