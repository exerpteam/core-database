-- The extract is extracted from Exerp on 2026-02-08
-- Shows reports run by employee and time.
SELECT
    report_key report, longtodate (report_usage.time) time, employee_center||'p'||employee_id employee
FROM
    fw.report_usage

order by employee