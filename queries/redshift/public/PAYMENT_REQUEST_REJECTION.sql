SELECT 
    id AS "CLEARINGHOUSE_ID",
    name AS "CLEARINGHOUSE_NAME",
    split_part(cleaned_line, '|', 1) AS "REJECTED_REASON_CODE",
    LEFT(split_part(cleaned_line, '|', 2), 200) AS "REJECTED_REASON_DESCRIPTION"
FROM (
    SELECT DISTINCT 
        id,
        name,
        regexp_replace(code_line, '&#x0d;', '', 'g') AS cleaned_line
    FROM (
        SELECT
            id,
            name,
            regexp_split_to_table(
                (
                    xpath(
                        '//value[@id="CodeMappingTable"]/mime/text()',
                        xmlparse(document convert_from(properties_config, 'UTF8'))
                    )
                )[1]::text,
                E'\n'
            ) AS code_line
        FROM clearinghouses
        WHERE properties_config IS NOT NULL
    ) AS extracted
    WHERE code_line <> ''
) AS cleaned
WHERE cleaned_line <> ''
ORDER BY 1

