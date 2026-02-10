-- The extract is extracted from Exerp on 2026-02-08
--  
select longtodateC(last_contact,center) as lastcontact,* from clients
where center = 238
and name in ('IADMPTDT08','IADMPTDT06','IADMPTDTPCI02','IADMPTDT02','IADMPTDT05','IADMEDDT02')