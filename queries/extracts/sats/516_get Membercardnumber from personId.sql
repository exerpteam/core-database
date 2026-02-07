Select *
from
eclub2.entityidentifiers i
where
i.ref_center = :PersonsCenter and
ref_type = 1 and
i.ref_id = :PersonsId
