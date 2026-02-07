SELECT 
* from 
(select DISTINCT
            count(c.name) as missing_register_and_driver
        FROM
            clients c
        LEFT JOIN
            devices d
        ON
            c.id = d.client
            left JOIN
                    systemproperties sp
                ON
                    sp.client = c.id
                AND sp.globalid = 'CLIENT_CASHREGISTER'
        JOIN
            centers cen
        ON
            c.center = cen.id
        WHERE
            c.name LIKE '%PCI%'
            
            --and 
         /*   c.name in ('TXALPTDTPCI01',
'TXATPTDTPCI01',
'TXBBPTDTPCI11',
'TXCCPTDTPCI01',
'TXCRPTDTPCI01',
'TXHGPTDTPCI02',
'TXHGPTDTPCI11',
'TXPLPTDTPCI01')*/

        AND c.id not IN
            (
                SELECT
                    c.id
                FROM
                    clients c
                JOIN
                    systemproperties sp
                ON
                    sp.client = c.id
                AND sp.globalid = 'CLIENT_CASHREGISTER'
                WHERE
                    c.name LIKE '%PCI%')
        AND c.id not IN
            (
                SELECT
                    client
                FROM
                    devices d
                WHERE
                    name IN ('lifetimefitnessclubpos',
                             'ClubPOS')
                AND d.enabled = 'true' )
            --
        AND c.state = 'ACTIVE'
        --and c.center not in (238,100,275,151)
        )t1,
        
        
        /*Get count of computers that have Register configured, but not ClubPOS Driver*/
        (select DISTINCT
            count(c.name) as missing_ClubPOS_Driver_ONLY
        FROM
            clients c
        LEFT JOIN
            devices d
        ON
            c.id = d.client
            left JOIN
                    systemproperties sp
                ON
                    sp.client = c.id
                AND sp.globalid = 'CLIENT_CASHREGISTER'
        JOIN
            centers cen
        ON
            c.center = cen.id
        WHERE
            c.name LIKE '%PCI%'
            

        AND c.id IN
            (
                SELECT
                    c.id
                FROM
                    clients c
                JOIN
                    systemproperties sp
                ON
                    sp.client = c.id
                AND sp.globalid = 'CLIENT_CASHREGISTER'
                WHERE
                    c.name LIKE '%PCI%')
        AND c.id not IN
            (
                SELECT
                    client
                FROM
                    devices d
                WHERE
                    name IN ('lifetimefitnessclubpos',
                             'ClubPOS')
                AND d.enabled = 'true' )
            --
        AND c.state = 'ACTIVE'
        --and c.center not in (238,100,275,151)
        )t2,
        
        
     /*Get count of computers that have ClubPOS Driver configured, but not Register*/

        (select DISTINCT
            count(c.name) as missing_register_configuration_ONLY
        FROM
            clients c
        LEFT JOIN
            devices d
        ON
            c.id = d.client
            left JOIN
                    systemproperties sp
                ON
                    sp.client = c.id
                AND sp.globalid = 'CLIENT_CASHREGISTER'
        JOIN
            centers cen
        ON
            c.center = cen.id
        WHERE
            c.name LIKE '%PCI%'
  

        AND c.id not IN
            (
                SELECT
                    c.id
                FROM
                    clients c
                JOIN
                    systemproperties sp
                ON
                    sp.client = c.id
                AND sp.globalid = 'CLIENT_CASHREGISTER'
                WHERE
                    c.name LIKE '%PCI%')
        AND c.id  IN
            (
                SELECT
                    client
                FROM
                    devices d
                WHERE
                    name IN ('lifetimefitnessclubpos',
                             'ClubPOS')
                AND d.enabled = 'true' )
            --
        AND c.state = 'ACTIVE'
        --and c.center not in (238,100,275,151)
        )t3
        