SELECT
    ID AS "ID",
    CASE
        WHEN TOP_NODE_ID IS NULL
        THEN ID
        ELSE TOP_NODE_ID
    END                  AS "SEMESTER_ID",
    NAME             AS "NAME",
    START_DATE       AS "START_DATE",
    END_DATE         AS "END_DATE",
    AVAILABLE_ON_WEB AS "AVAILABLE_ON_WEB",
    SCOPE_TYPE       AS "SCOPE_TYPE",
    SCOPE_ID         AS "SCOPE_ID"
FROM
    SEMESTERS BPT