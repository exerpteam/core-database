-- The extract is extracted from Exerp on 2026-02-08
-- Extract to find clients with a pci-pal device and an incorrect callbackURL 
Was called ES-7722 (from the ticket)
SELECT 
 CLIENT_NAME,
     CLIENT_ID,
     '('||CENTER_ID||') -'||CENTER_NAME AS CENTER,
     CASE
         WHEN CALLBACK_URL <> 'https://virginactive.exerp.com/dist/externalPaymentTransaction'
         THEN CALLBACK_URL
         WHEN CALLBACK_URL = 'https://virginactive.exerp.com/dist/externalPaymentTransaction'
         THEN 'Callback URL is correct'
     END AS CALLBACK_URL_CHECK,
     CASE
         WHEN URL <> 'https://ip3cloud.com/clients/virginactive/launch.php'
         THEN URL
         WHEN URL = 'https://ip3cloud.com/clients/virginactive/launch.php'
         THEN 'URL is correct'
     END AS URL_CHECK,
     CASE
         WHEN API_KEY <> '2184cf05598cd9b9cc603346cf3e4d30'
         THEN API_KEY
         WHEN API_KEY = '2184cf05598cd9b9cc603346cf3e4d30'
         THEN 'API Key is correct'
     END AS API_KEY_CHECK   
     
FROM (

SELECT
    CAST(unnest((xpath('//callbackUrl/text()', xmlparse(document convert_from(d.configuration, 'UTF-8'))
    ))) AS VARCHAR)                                                                            AS CALLBACK_URL,
    CAST(unnest((xpath('//url/text()', xmlparse(document convert_from(d.configuration, 'UTF-8'))))) AS VARCHAR)  AS
    URL,
    CAST(unnest((xpath('//apiKey/text()', xmlparse(document convert_from(d.configuration, 'UTF-8'))))) AS VARCHAR) 
    AS API_KEY,
    d.*,
    cl.NAME AS CLIENT_NAME,
    cl.CLIENTID AS CLIENT_ID,
    c.NAME AS CENTER_NAME,
    c.ID AS CENTER_ID
FROM
    devices d
JOIN
    CLIENTS cl
ON
    cl.ID = d.CLIENT
JOIN
    CENTERS c
ON
    c.id = cl.CENTER ) t1
--    
WHERE driver = 'com.exerp.clublead.devices.drivers.pcipal.PciPalDriver'
-- Not required for postgres
--AND CALLBACK_URL <> 'https://virginactive.exerp.com/dist/externalPaymentTransaction'
----AND URL <> 'https://ip3cloud.com/clients/virginactive/launch.php'
--AND API_KEY <> '2184cf05598cd9b9cc603346cf3e4d30'