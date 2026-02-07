select 
        r.id as role_id,
        r.rolename,
        ir.rolename as implied_rolename,
        r.is_action as role_is_action,
        ir.is_action as implied_role_is_action,
        *

from impliedemployeeroles ier
join roles r on ier.roleid = r.id
join roles ir on ir.id = ier.implied
order by r.rolename asc, ir.rolename asc