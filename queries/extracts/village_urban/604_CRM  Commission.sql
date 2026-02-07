/*
* revenue meaning paid at startup
* Add last person handling the tour
* Need to add logic for commisionable sale as well
*/

SELECT
    ss.SALES_DATE,
    s.START_DATE,
    prod.name                                       subscription_name,
    p.CENTER || 'p' || p.ID                         customer_pid,
    p.FULLNAME                                      customer,
    ass.CENTER || 'p' || ass.ID                     assignee_pid,
    ass.FULLNAME                                    assignee_name,
    empP.CENTER || 'p' || empP.ID                   sales_pid,
    empP.FULLNAME                                   sales_name,
    scl.EMPLOYEE_CENTER || 'emp' || scl.EMPLOYEE_ID emp_person_created_by,
    t.STATUS                                        TASK_STATUS ,
    longToDate(t.CREATION_TIME)             TASK_CREATED,
    longToDate(t.LAST_UPDATE_TIME)          TASK_LAST_UPDATED
FROM
    SUBSCRIPTION_SALES ss
JOIN
    SUBSCRIPTIONS s
ON
    s.CENTER = ss.SUBSCRIPTION_CENTER
    AND s.ID = ss.SUBSCRIPTION_ID
LEFT JOIN
    STATE_CHANGE_LOG scl
ON
    scl.ENTRY_TYPE = 1
    AND scl.STATEID = 0
    AND scl.CENTER = s.OWNER_CENTER
    AND scl.ID = s.OWNER_ID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
JOIN
    TASKS t
ON
    t.PERSON_CENTER = p.CENTER
    AND t.PERSON_ID = p.ID
LEFT JOIN
    PERSONS ass
ON
    ass.CENTER = t.ASIGNEE_CENTER
    AND ass.ID = t.ASIGNEE_ID
LEFT JOIN
    EMPLOYEES emp
ON
    emp.CENTER = ss.EMPLOYEE_CENTER
    AND emp.ID = ss.EMPLOYEE_ID
LEFT JOIN
    PERSONS empP
ON
    empP.CENTER = emp.PERSONCENTER
    AND empP.ID = emp.PERSONID
WHERE
    ss.CANCELLATION_DATE IS NULL
    AND TRUNC(ss.SALES_DATE) >= $$from_date$$
    AND TRUNC(ss.SALES_DATE) < ($$to_date$$ + 1)
    AND ss.SUBSCRIPTION_CENTER IN ($$scope$$)