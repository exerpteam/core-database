select
    *
from
         eclub2.privilege_sets ps
    left join eclub2.privilege_usages pu
    on
         ps.id = pu.privilege_id
where
    pu.source_center in (:scope)
    and pu.use_time >= :from_date
    and pu.use_time <= :to_Date