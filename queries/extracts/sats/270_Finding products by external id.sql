select name, external_id from eclub2.products where external_id = :extern
group by  name, external_id
