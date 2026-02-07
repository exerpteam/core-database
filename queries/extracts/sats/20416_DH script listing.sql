select

ext.id, ext.name, longtodate(max(extu.TIME)), count(*) used 
from SATS.EXTRACT ext 
join SATS.EXTRACT_USAGE extu on extu.EXTRACT_ID = ext.ID 
where ( 
case 
when length(ext.SQL_QUERY_BLOB) < 2001 
then UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(ext.SQL_QUERY_BLOB, 2000,1), 'UTF8') 
else UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(ext.SQL_QUERY_BLOB, 2000,1), 'UTF8') || 
UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(ext.SQL_QUERY_BLOB, 2000,2001), 'UTF8')

end) like '%ECLUB2%' 
and ext.BLOCKED = 0 
group by ext.id, ext.name