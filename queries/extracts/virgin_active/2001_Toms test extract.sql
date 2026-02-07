SELECT *
FROM ENTITYIDENTIFIERS
where rownum < 100
and idmethod=4
--and length(Identity) > 16