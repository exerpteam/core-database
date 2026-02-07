SELECT 	sb.id,
		sb.center,
		sb.employee_center || 'emp' || sb.employee_id AS EmployeeID,
		LongtodateC (sb.created, sb.center) AS CreatedDate,
		LongtodateC (sb.modified, sb.center) AS ModifiedDate,
		sb.version,
		sb.* 

FROM SHOPPING_BASKETS sb

WHERE
	sb.status = 'ACTIVE'
AND
	sb.origin = 'CLIENT'