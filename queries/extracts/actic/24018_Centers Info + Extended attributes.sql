/**
* Creator: Mikael Ahlberg
* Purpose: List centers with extended information
*
*/
Select distinct
c.ID,
c.STARTUPDATE,
c.Name,
c.PHONE_NUMBER,
c.ADDRESS1,
c.COUNTRY,
c.ZIPCODE,
c.EXTERNAL_ID,
TO_CHAR(c.LATITUDE, '999999999.000000') AS LATITUDE,
TO_CHAR(c.LONGITUDE, '999999999.000000') AS LONGITUDE,
il.txt_value AS Infrastrukturleverantör,
ipvpn.txt_value AS IP_VPN_Gateway,
ut.txt_value AS Uppkopplingstyp,
h.txt_value AS Hastighet,
w.txt_value AS WLAN,
tele.txt_value AS Telefonilösning,
k1.txt_value AS Kassadator1,
k2.txt_value AS Kassadator2,
k3.txt_value AS Kassadator3,
ki1.txt_value AS Kiosk1,
ki2.txt_value AS Kiosk2,
ki3.txt_value AS Kiosk3,
gl.txt_value AS Grindlösning,
convert_from(ce.MIME_VALUE, 'UTF8') as Övrigt


FROM Centers c

LEFT JOIN  CENTER_EXT_ATTRS ce 
ON c.ID = ce.CENTER_ID
AND ce.NAME = 'Kommentar'

LEFT JOIN center_EXT_ATTRS il
ON
il.center_id = c.id
AND il.name = 'Infrastrukturleverantor'

LEFT JOIN center_EXT_ATTRS tele
ON
tele.center_id = c.id
AND tele.name = 'telefoni'


LEFT JOIN center_EXT_ATTRS ut
ON
ut.center_id = c.id
AND ut.name = 'Uppkopplingstyp'


LEFT JOIN center_EXT_ATTRS h
ON
h.center_id = c.id
AND h.name = 'Hastighet'


LEFT JOIN center_EXT_ATTRS w
ON
w.center_id = c.id
AND w.name = 'WLAN'


LEFT JOIN center_EXT_ATTRS k1
ON
k1.center_id = c.id
AND k1.name = 'Kassadator1'



LEFT JOIN center_EXT_ATTRS k2
ON
k2.center_id = c.id
AND k2.name = 'Kassadator2'

LEFT JOIN center_EXT_ATTRS k3
ON
k3.center_id = c.id
AND k3.name = 'Kassadator3'

LEFT JOIN center_EXT_ATTRS ki1
ON
ki1.center_id = c.id
AND ki1.name = 'Kiosk1'

LEFT JOIN center_EXT_ATTRS ki2
ON
k2.center_id = c.id
AND ki2.name = 'Kiosk2'

LEFT JOIN center_EXT_ATTRS ki3
ON
ki3.center_id = c.id
AND ki3.name = 'Kiosk3'

LEFT JOIN center_EXT_ATTRS gl
ON
gl.center_id = c.id
AND gl.name = 'Grindlosning'





LEFT JOIN center_EXT_ATTRS IPVPN
ON
ipvpn.center_id = c.id
AND ipvpn.name = 'IPVPNG'




WHERE c.ID IN (:ChosenScope)


























