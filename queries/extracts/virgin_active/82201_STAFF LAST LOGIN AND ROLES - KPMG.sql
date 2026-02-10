-- The extract is extracted from Exerp on 2026-02-08
-- Estrae tutti i person type STAFF, anche se non hanno mai avuto un ruolo (GRT, Bagnini), con dettaglio dell'ultimo accesso, sub, stato e ruolo
SELECT
    p.FULLNAME as FullName,
	C.SHORTNAME as Emp_Club, --su cui ha ruolo
	emp.CENTER || 'emp' || emp.id "Employee_ID",
	(CASE emp.BLOCKED
	    WHEN 1 THEN 'RUOLO_BLOCCATO'
		WHEN 0 THEN 'RUOLO_ATTIVO'
		ELSE 'NESSUN RUOLO INSERITO'
	END) AS Emp_STATUS, --Verifica se ruolo staff è bloccato
    emp.last_login,     --Data ultimo login su quel ruolo/club
    --STRING_AGG(r.ROLENAME, ' ; ') as RolesList,   --Lista ruoli assegnati su club
    p.CENTER || 'p' || p.ID "Person_ID",
    (CASE p.STATUS
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END) AS Person_STATUS,
	 (CASE s.state
        WHEN 2 THEN 'Active'
        WHEN 4 THEN 'Active'
        WHEN 8 THEN 'Prevendita - Created'
        ELSE 'Inactive'
    END) AS Subscription_STATE,
    s.START_DATE AS Sub_StartDate,
	s.END_DATE AS Sub_EndDate
 FROM
     PERSONS p
 LEFT JOIN
     EMPLOYEES emp
     ON emp.PERSONCENTER = p.CENTER
     AND emp.PERSONID = p.ID
 LEFT JOIN --Left per includere ruoli che non hanno ruolo inserito
     EMPLOYEESROLES empr
     ON empr.CENTER = emp.CENTER
	 AND empr.id = emp.ID
 LEFT JOIN
     ROLES r
     ON r.ID = empr.ROLEID
     --AND r.IS_ACTION = 0  --includi ruoli con sole action (filtro in join)
 LEFT JOIN
     CENTERS c
     ON c.id = emp.CENTER
 LEFT JOIN
    SUBSCRIPTIONS S
	ON p.center = s.OWNER_CENTER
	AND p.id = s.OWNER_ID
	AND s.state IN (2,4,8) --Stato SUB = ACTIVE, FROZEN, CREATED
 WHERE
	 p.center in (:scope)
	 AND p.STATUS in (0,1,2,3,6,7,9) --Esclusi Anonymized, Duplicated, Transferred
     AND p.persontype in (2)
 GROUP BY C.SHORTNAME, emp.CENTER || 'emp' || emp.id, p.STATUS, emp.BLOCKED, p.CENTER || 'p' || p.ID, p.FULLNAME, emp.last_login, s.state, s.start_Date, s.end_date
ORDER BY p.CENTER || 'p' || p.ID