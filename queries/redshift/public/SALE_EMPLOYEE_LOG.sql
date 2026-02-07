SELECT
    ise.id AS                                    "ID",
    ise.invoice_center|| 'inv' || ise.invoice_id "SALE_ID",
    CASE
        WHEN (sales_person.CENTER != sales_person.TRANSFERS_CURRENT_PRS_CENTER
                OR sales_person.id != sales_person.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = sales_person.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = sales_person.TRANSFERS_CURRENT_PRS_ID)
        ELSE sales_person.EXTERNAL_ID
    END "SALE_PERSON_ID",
    CASE
        WHEN (change_person.CENTER != change_person.TRANSFERS_CURRENT_PRS_CENTER
                OR change_person.id != change_person.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = change_person.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = change_person.TRANSFERS_CURRENT_PRS_ID)
        ELSE change_person.EXTERNAL_ID
    END               "CHANGE_PERSON_ID",
    ise.start_time     AS "FROM_DATETIME",
    ise.invoice_center AS "CENTER_ID",
    ise.start_time     AS "ETS"
FROM
    invoice_sales_employee ise
LEFT JOIN
    EMPLOYEES sales_staff
ON
    sales_staff.center = ise.sales_employee_center
    AND sales_staff.id = ise.sales_employee_id
LEFT JOIN
    PERSONS sales_person
ON
    sales_person.center = sales_staff.personcenter
    AND sales_person.ID = sales_staff.personid
LEFT JOIN
    EMPLOYEES change_staff
ON
    change_staff.center = ise.change_employee_center
    AND change_staff.id = ise.change_employee_id
LEFT JOIN
    PERSONS change_person
ON
    change_person.center = change_staff.personcenter
    AND change_person.ID = change_staff.personid
