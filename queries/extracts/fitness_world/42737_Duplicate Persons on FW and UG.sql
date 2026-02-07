-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-3293
SELECT
    '***'||SUBSTR(UG.ssn,4,4)||'***' AS SSN,
    UG.UrbanGym_MemberID,
    UG.UrbanGym_Person_External_ID,
    FW.FW_MemberID,
    FW.FW_Person_External_ID
    --SELECT count(*)
FROM
    (
        SELECT DISTINCT
            p.fullname,
            p.ssn                                                                                                                                                                            AS SSN,
            p.external_id                                                                                                                                                                    AS UrbanGym_Person_External_ID,
            p.center||'p'||p.id                                                                                                                                                              AS UrbanGym_MemberID,
            DECODE (p.status, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5, 'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS UrbanGym_MEMBER_STATUS
        FROM
            persons p
        WHERE
            p.center BETWEEN 400 AND 421
            AND p.center = p.TRANSFERS_CURRENT_PRS_CENTER
            AND p.id = p.TRANSFERS_CURRENT_PRS_ID ) UG,
    (
        SELECT DISTINCT
            p.fullname,
            p.ssn,
            p.external_id                                                                                                                                                                    AS FW_Person_External_ID,
            p.center||'p'||p.id                                                                                                                                                              AS FW_MemberID,
            DECODE (p.status, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5, 'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS FW_MEMBER_STATUS
        FROM
            persons p
        WHERE
            (
                p.center < 400
                OR p.center>420)
            AND p.center = p.TRANSFERS_CURRENT_PRS_CENTER
            AND p.id = p.TRANSFERS_CURRENT_PRS_ID ) FW
WHERE
    FW.SSN = UG.SSN