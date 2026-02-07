SELECT
    ds.id             AS "ID",
    ds.definition_key AS "DEFINITION_KEY",
    ds.state          AS "STATE",
    ds.availability   AS "AVAILABILITY",
    ds.NAME           AS "NAME",
    ds.TYPE           AS "TYPE"
FROM
    documentation_settings ds
