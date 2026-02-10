-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    pro.globalid,
    pro.name as productname,
    pro.blocked as blocked_state,
    prog.name as primary_group
FROM
    fw.products pro
left join fw.product_group prog
    on
    pro.PRIMARY_PRODUCT_GROUP_ID = prog.id
group by
     pro.globalid,
     pro.name,
     pro.blocked,
     prog.name
order by
    prog.name,
    pro.globalid