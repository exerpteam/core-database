SELECT
  art.center,
  longtodateC(art.trans_time, art.center) AS dt,
  art.amount,
  art.employeecenter,
  art.employeeid,
  act.info_type,
  act.text,
  act.info
FROM fernwood.account_trans act
JOIN fernwood.ar_trans art
  ON act.center = art.ref_center
 AND act.id     = art.ref_id
 AND act.subid  = art.ref_subid
 AND art.ref_type = 'ACCOUNT_TRANS'
JOIN fernwood.account_receivables ar
  ON ar.center = art.center
 AND ar.id     = art.id
WHERE act.info_type IN (8,23)
  AND ar.ar_type = 4
  AND ar.customercenter IN (:Scope)
  AND act.trans_time BETWEEN
      datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'), act.center)
      AND (datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), act.center) - 1)
ORDER BY dt DESC;
