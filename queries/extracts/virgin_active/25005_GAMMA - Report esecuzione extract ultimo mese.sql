-- The extract is extracted from Exerp on 2026-02-08
--  
select
  to_char(to_date('01-JAN-1970','DD-MM-YYYY HH24:MI SS') + 
    (efe.EXPORT_TIME / (1000*60 * 60 * 24) ) ,'DD/MM/YYYY HH24:MI') as oraCreazione,

  to_char(to_date('01-JAN-1970','DD-MM-YYYY HH24:MI SS') + 
    (op.STOP_TIME / (1000*60 * 60 * 24) ) ,'DD/MM/YYYY HH24:MI') as oraEsportazione,


 e.FILENAME, 
 e.STATUS as statoCreazione,
 efe.STATUS as statoEsportazione,
 
 efe.SERVICE as canaleInvio, 
op.OPERATION_ID as operazione,
 op.RESULT as risultatoOperazione
FROM 
EXCHANGED_FILE e
INNER JOIN
EXCHANGED_FILE_EXP efe
ON e.ID = efe.EXCHANGED_FILE_ID

INNER JOIN
EXCHANGED_FILE_OP op
ON e.ID = op.EXCHANGED_FILE_ID

WHERE  longtodate(e.ENTRY_TIME) > ADD_MONTHS(TRUNC(SYSDATE),-1)
AND e.SCOPE_ID IN(24,100)
order by e.FILENAME, op.ID