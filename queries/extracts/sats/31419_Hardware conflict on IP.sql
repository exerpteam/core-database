SELECT
extractvalue(xmltype(d.CONFIGURATION,nls_charset_id('AL32UTF8')),'properties/ip') ip_number,
extractvalue(xmltype(d.CONFIGURATION,nls_charset_id('AL32UTF8')),'properties/port') port,
--extractvalue(xmltype(d.CONFIGURATION,nls_charset_id('AL32UTF8')),'properties/configuration') configuration,
c.*,
d.ID,
d.CLIENT,
d.NAME,
d.DRIVER,
d.ENABLED,
d.CONFIGURATION
FROM
SATS.DEVICES d
JOIN SATS.CLIENTS c
ON
c.ID = d.CLIENT
WHERE
STATE != 'DELETED'
and d.CONFIGURATION is not null
