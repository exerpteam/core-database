SELECT
c.shortname as Club,
    p.center||'p'||p.id as MembershipNumber,
p.fullname as MemberName,
    ar.BALANCE as PaymentAccountBalance,
DECODE (p.STATUS, 0, 'Lead', 1, 'Active', 2, 'Inactive', 3, 'TemporaryInacttive', 4, 'Transferred', 5, 'Duplicate', 6, 'Prospect', 7, 'Deleted', 8, 'Anonymised', 9, 'Contact') as personstatus
FROM
    persons p
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.center
    AND ar.CUSTOMERID = p.id
JOIN
Centers c
ON
p.center = c.ID
WHERE
    p.CENTER IN (
403,
440,
436,
411,
441,
442,
419,
434,
407,
400,
406,
435,
401,
443
)
    AND ar.AR_TYPE = 4
    AND ar.BALANCE > 0