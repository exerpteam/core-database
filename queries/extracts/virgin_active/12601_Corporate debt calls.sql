SELECT DISTINCT 
        table2.FullName as "Company",
        table2.PersonId as "Membership Number",
        table2.CCC_StartDate as "Date Company Entered Debt",
        trunc(sysdate)-table2.CCC_StartDate as "Number of Days in Debt",
        table2.MessageSubject as "Last Corporate Debt Message",
        table2.MessageSent as "Date of Last Message",
        table2.Debt as "Value of debt (£)",
        longtodate(FIRST_VALUE(art.TRANS_TIME) OVER (PARTITION BY table2.P_CENTER,table2.P_ID ORDER BY art.TRANS_TIME DESC)) as "Date of last payment",
        table2.numberofMembers as "Total number of active members",
        table2.JournalEntryName as "Last Manual Note",
        table2.EmployeeName AS "Note Added By",
        table2.JournalEntyCreated as "Date Note Added",
        accountManager.FULLNAME AS "Account Manager"
FROM
(
        SELECT table1.*,
               emp.FULLNAME AS EmployeeName,
               longtodate(ccje.CREATIONTIME) AS JournalEntyCreated,
               RANK() over (partition by table1.PersonId ORDER BY ccje.CREATIONTIME DESC) AS RK2,
               je.NAME as JournalEntryName
        FROM 
        (
                SELECT 
                        numberMembers.FULLNAME AS FullName,
                        numberMembers.CENTER || 'p' || numberMembers.ID AS PersonId,
                        ccc.STARTDATE AS CCC_StartDate,
                        numberMembers.CENTER AS P_Center,
                        numberMembers.ID AS P_Id,
                        numberMembers.numberofMembers,
                        ccc.CENTER AS CCC_Center,
                        ccc.ID AS CCC_Id,
                        ccc.AMOUNT AS Debt,
                        longtodate(m.SENTTIME) AS MessageSent, 
                        RANK() over (partition by numberMembers.CENTER, numberMembers.ID ORDER BY m.SENTTIME DESC) AS RK, 
                        m.SUBJECT AS MessageSubject
                FROM 
                        (SELECT pin.CENTER, pin.ID, pin.FULLNAME, count(*) as numberofMembers
                                FROM PERSONS pin
                                JOIN CASHCOLLECTIONCASES ccc ON ccc.PERSONCENTER=pin.CENTER AND ccc.PERSONID=pin.ID AND ccc.CLOSED=0 AND ccc.MISSINGPAYMENT=1
                                JOIN RELATIVES memRel ON memRel.RELATIVECENTER = pin.CENTER AND memRel.RELATIVEID = pin.ID AND memRel.RTYPE = 3 AND memRel.STATUS = 1
                                JOIN PERSONS activeMem ON activeMem.CENTER=memRel.CENTER and activeMem.ID = memRel.ID and activeMem.STATUS IN (1,3)
                                WHERE pin.SEX='C'
                                GROUP BY pin.CENTER, pin.ID, pin.FULLNAME
                         ) numberMembers
                JOIN CASHCOLLECTIONCASES ccc ON ccc.PERSONCENTER=numberMembers.CENTER AND ccc.PERSONID=numberMembers.ID AND ccc.CLOSED=0 AND ccc.MISSINGPAYMENT=1
                LEFT JOIN MESSAGES m ON (ccc.CENTER || 'ccol' || ccc.ID) = m.REFERENCE and m.DELIVERYCODE=2             
        ) table1
        LEFT JOIN CASHCOLLECTIONJOURNALENTRIES ccje ON ccje.CENTER = table1.CCC_Center AND ccje.ID = table1.CCC_Id
        LEFT JOIN JOURNALENTRIES je ON je.ID = ccje.JOURNALENTRY_ID
        LEFT JOIN PERSONS emp ON je.CREATORCENTER = emp.CENTER AND je.CREATORID = emp.ID
        WHERE RK = 1
) table2
LEFT JOIN RELATIVES rel ON rel.CENTER = table2.P_CENTER AND rel.ID = table2.P_ID AND rel.RTYPE = 10 AND rel.STATUS=1
LEFT JOIN PERSONS accountManager ON accountManager.CENTER=rel.RELATIVECENTER and accountManager.ID = rel.RELATIVEID

LEFT JOIN ACCOUNT_RECEIVABLES ar ON ar.CUSTOMERCENTER = table2.P_CENTER AND ar.CUSTOMERID = table2.P_ID and ar.AR_TYPE = 4
LEFT JOIN AR_TRANS art ON art.CENTER = ar.CENTER AND art.ID = ar.ID AND art.amount > 0 AND art.REF_TYPE='ACCOUNT_TRANS' AND art.TEXT not like 'Transfer to cash collection account%'

WHERE RK2 = 1



