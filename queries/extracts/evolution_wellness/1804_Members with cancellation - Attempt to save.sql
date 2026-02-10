-- The extract is extracted from Exerp on 2026-02-08
-- 
WITH
    params AS materialized
    (
        SELECT
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') AS currentDate,
            c.id                                       AS centerid
        FROM
            centers c
    )
    ,
    pmp_xml AS
    (
        SELECT
            sp.id,
            CAST(convert_from(sp.mimevalue, 'UTF-8') AS XML) AS pxml
        FROM
            evolutionwellness.systemproperties sp
        WHERE
            sp.globalid = 'DYNAMIC_EXTENDED_ATTRIBUTES'
    )
    ,
    second_Table AS
    (
        SELECT
            UNNEST(xpath('attributes/attribute',px.pxml))::text AS test
        FROM
            pmp_xml px
        JOIN
            evolutionwellness.systemproperties sp
        ON
            sp.id = px.id
    )
    ,
    reasons AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    split_part(test, '"', 2)                                      AS attribute_name,
                    trim(split_part(split_part(test, '<possibleValue id="', 2),'"',1))   AS ID,
                    trim(split_part(split_part(test, 'possibleValue id="1">', 2),'<',1)) AS reason
                FROM
                    second_Table
                UNION ALL
                SELECT
                    split_part(test, '"', 2) AS attribute_name,
                    trim(split_part(split_part(split_part(test, '<possibleValue id="1', 2),
                    '<possibleValue id="', 2),'"',1))                                    AS ID,
                    trim(split_part(split_part(test, 'possibleValue id="2">', 2),'<',1)) AS reason
                FROM
                    second_Table
                UNION ALL
                SELECT
                    split_part(test, '"', 2) AS attribute_name,
                    trim(split_part(split_part(split_part(test, '<possibleValue id="2', 2),
                    '<possibleValue id="', 2),'"',1))                                    AS ID,
                    trim(split_part(split_part(test, 'possibleValue id="3">', 2),'<',1)) AS reason
                FROM
                    second_Table
                UNION ALL
                SELECT
                    split_part(test, '"', 2) AS attribute_name,
                    trim(split_part(split_part(split_part(test, '<possibleValue id="3', 2),
                    '<possibleValue id="', 2),'"',1))                                    AS ID,
                    trim(split_part(split_part(test, 'possibleValue id="4">', 2),'<',1)) AS reason
                FROM
                    second_Table ) t
        WHERE
            t.attribute_name IN ('cancellationjourney1',
                                 'cancellationjourney2',
                                 'cancellationjourney3')
    )
SELECT
    p.fullname                                                         AS "Member name",
    mob.txtvalue                                                       AS "Mobile phone",
    email.txtvalue                                                     AS "Email",
    p.center ||'p'|| p.id                                              AS "Member ID",
    pr.name                                                            AS "Subscription name",
    longtodateC(sc.change_time, p.center)                              AS "Cancellation date",
    s.end_date                                                         AS "Stop date",
    sc.employee_center ||'emp'|| sc.employee_id                        AS "Stopped by employee ID",
    sta.fullname                                                      AS "Stopped by employee name",
    cancel1.reason                                                     AS "Attempt 1",
    TO_CHAR(longtodate(cancel1.last_edit_time), 'YYYY-MM-DD HH:MI:SS') AS "Last update Attempt 1",
    cancel1.center ||'emp'|| cancel1.id                                AS
    "Last updated by employee ID",
    cancel1.fullname                                             AS "Last updated by employee name",
    cancel2.reason                                                     AS "Attempt 2",
    TO_CHAR(longtodate(cancel2.last_edit_time), 'YYYY-MM-DD HH:MI:SS') AS "Last update Attempt 2",
    cancel2.center ||'emp'|| cancel2.id                                AS
    "Last updated by employee ID",
    cancel2.fullname                                             AS "Last updated by employee name",
    cancel3.reason                                                     AS "Attempt 3",
    TO_CHAR(longtodate(cancel3.last_edit_time), 'YYYY-MM-DD HH:MI:SS') AS "Last update Attempt3",
    cancel3.center ||'emp'|| cancel3.id                                AS
    "Last updated by employee ID",
    cancel3.fullname                                             AS "Last updated by employee name",
    cancel4.txtvalue                                                   AS "Comment",
    TO_CHAR(longtodate(cancel4.last_edit_time), 'YYYY-MM-DD HH:MI:SS') AS "Last update Comment",
    cancel4.center ||'emp'|| cancel3.id                                AS
    "Last updated by employee ID",
    cancel4.fullname                                             AS "Last updated by employee name"
FROM
    persons p
JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
JOIN
    params par
ON
    par.centerid = s.center
JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
JOIN
    products pr
ON
    pr.center = st.center
AND pr.id = st.id
JOIN
    subscription_change sc
ON
    sc.old_subscription_center = s.center
AND sc.old_subscription_id = s.id
JOIN
    employees emp
ON
    emp.center = sc.employee_center
AND emp.id = sc.employee_id
JOIN
    persons sta
ON
    sta.center = emp.personcenter
AND sta.id = emp.personid
LEFT JOIN
    (
        SELECT
            pea1.personcenter,
            pea1.personid,
            pea1.name,
            pea1.last_edit_time,
            rea1.reason,
            emp1.center,
            emp1.id,
            sta1.fullname
        FROM
            person_ext_attrs pea1
        JOIN
            reasons rea1
        ON
            rea1.attribute_name = pea1.name
        AND rea1.id = pea1.txtvalue
        AND pea1.name = 'cancellationjourney1'
        JOIN
            (
                SELECT
                    pcl.person_center,
                    pcl.person_id,
                    pcl.employee_center,
                    pcl.employee_id,
                    rank() over (partition BY pcl.person_center, pcl.person_id ORDER BY
                    pcl.entry_time DESC) ranking
                FROM
                    person_change_logs pcl
                WHERE
                    pcl.change_attribute = 'cancellationjourney1') emp_change1
        ON
            emp_change1.person_center = pea1.personcenter
        AND emp_change1.person_id = pea1.personid
        JOIN
            employees emp1
        ON
            emp1.center = emp_change1.employee_center
        AND emp1.id = emp_change1.employee_id
        JOIN
            persons sta1
        ON
            sta1.center = emp1.personcenter
        AND sta1.id = emp1.personid) cancel1
ON
    cancel1.personcenter = p.center
AND cancel1.personid = p.id
LEFT JOIN
    (
        SELECT
            pea2.personcenter,
            pea2.personid,
            pea2.name,
            pea2.last_edit_time,
            rea2.reason,
            emp2.center,
            emp2.id,
            sta2.fullname
        FROM
            person_ext_attrs pea2
        JOIN
            reasons rea2
        ON
            rea2.attribute_name = pea2.name
        AND rea2.id = pea2.txtvalue
        AND pea2.name = 'cancellationjourney2'
        JOIN
            (
                SELECT
                    pcl.person_center,
                    pcl.person_id,
                    pcl.employee_center,
                    pcl.employee_id,
                    rank() over (partition BY pcl.person_center, pcl.person_id ORDER BY
                    pcl.entry_time DESC) ranking
                FROM
                    person_change_logs pcl
                WHERE
                    pcl.change_attribute = 'cancellationjourney2') emp_change2
        ON
            emp_change2.person_center = pea2.personcenter
        AND emp_change2.person_id = pea2.personid
        JOIN
            employees emp2
        ON
            emp2.center = emp_change2.employee_center
        AND emp2.id = emp_change2.employee_id
        JOIN
            persons sta2
        ON
            sta2.center = emp2.personcenter
        AND sta2.id = emp2.personid) cancel2
ON
    cancel2.personcenter = p.center
AND cancel2.personid = p.id
LEFT JOIN
    (
        SELECT
            pea3.personcenter,
            pea3.personid,
            pea3.name,
            pea3.last_edit_time,
            rea3.reason,
            emp3.center,
            emp3.id,
            sta3.fullname
        FROM
            person_ext_attrs pea3
        JOIN
            reasons rea3
        ON
            rea3.attribute_name = pea3.name
        AND rea3.id = pea3.txtvalue
        AND pea3.name = 'cancellationjourney3'
        JOIN
            (
                SELECT
                    pcl.person_center,
                    pcl.person_id,
                    pcl.employee_center,
                    pcl.employee_id,
                    rank() over (partition BY pcl.person_center, pcl.person_id ORDER BY
                    pcl.entry_time DESC) ranking
                FROM
                    person_change_logs pcl
                WHERE
                    pcl.change_attribute = 'cancellationjourney3') emp_change3
        ON
            emp_change3.person_center = pea3.personcenter
        AND emp_change3.person_id = pea3.personid
        JOIN
            employees emp3
        ON
            emp3.center = emp_change3.employee_center
        AND emp3.id = emp_change3.employee_id
        JOIN
            persons sta3
        ON
            sta3.center = emp3.personcenter
        AND sta3.id = emp3.personid) cancel3
ON
    cancel3.personcenter = p.center
AND cancel3.personid = p.id
LEFT JOIN
(
    SELECT
            pea4.personcenter,
            pea4.personid,
            pea4.name,
            pea4.txtvalue,
            pea4.last_edit_time,
            emp4.center,
            emp4.id,
            sta4.fullname
        FROM
            person_ext_attrs pea4
        JOIN
        (SELECT
        pcl.person_center,
        pcl.person_id,
        pcl.employee_center,
        pcl.employee_id,
        rank() over (partition BY pcl.person_center, pcl.person_id ORDER BY pcl.entry_time DESC) ranking
        FROM
        person_change_logs pcl
        WHERE
        pcl.change_attribute = 'cancellationjourney4') emp_change4
        ON
        emp_change4.person_center = pea4.personcenter
        AND emp_change4.person_id = pea4.personid
        JOIN
        employees emp4
        ON
        emp4.center = emp_change4.employee_center
        AND emp4.id = emp_change4.employee_id
        JOIN
        persons sta4
        ON
        sta4.center = emp4.personcenter
        AND sta4.id = emp4.personid
        WHERE
        pea4.name = 'cancellationjourney4'
    )cancel4
ON
    cancel4.personcenter = p.center
AND cancel4.personid = p.id
LEFT JOIN
person_ext_attrs email
ON
email.personcenter = p.center
AND email.personid = p.id
AND email.name = '_eClub_Email'
LEFT JOIN
person_ext_attrs mob
ON
mob.personcenter = p.center
AND mob.personid = p.id
AND mob.name = '_eClub_PhoneSMS'
WHERE
    s.end_date = :stopDate
AND sc.type = 'END_DATE'
AND st.st_type = 1
AND s.end_date IS NOT NULL
AND s.end_date >= par.currentDate
AND s.sub_state != 8
AND sc.cancel_time IS NULL
AND p.center IN (:scope)
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            subscriptions sub
        WHERE
            sub.owner_center = p.center
        AND sub.owner_id = p.id
        AND (
                sub.end_date IS NULL
            OR  sub.start_date > par.currentDate) )
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            person_ext_attrs pea
        WHERE
            pea.personcenter = p.center
        AND pea.personid = p.id
        AND pea.name IN ('cancellationjourney1',
                         'cancellationjourney2',
                         'cancellationjourney3')
        AND pea.txtvalue IN ('2',
                             '4') )