-- This is the version from 2026-02-05
--  
----MAIN QUERY START----

/* lead, temp inactive & active member count */
WITH 
    member AS MATERIALIZED(   
        SELECT
                COUNT(*) AS total_members,
                p.center AS center_id
        FROM persons p
        WHERE p.status IN (0, 1, 3) 
        /* exclude companies and staff */
        and p.sex != 'C'
        and p.persontype not in (2) 
        GROUP BY p.center
    ),   

/* 30 days ago in epoch, used for participations and checkins */    
    date30 AS ( 
        select 
                (FLOOR(extract(epoch FROM now())*1000) - 2592000000) as date30
    ),

/* participation count */    
    participation as (
        select 
                count(*) as total_participations, 
                pa.booking_center
        from participations pa        
        cross join date30
        /* participation started after 30 days ago */
        where pa.start_time > date30 
        /* exclude cancelled */
        and pa.cancelation_time is null
        group by pa.booking_center
    ),
    
/* checkin count */    
    checkin as (
         select 
                count(*) as total_checkins, 
                ch.checkin_center 
        from checkins ch        
        cross join date30
        /* checkins after 30 days ago */
        where ch.checkin_time > date30
        /* exclude access Denied */ 
        and checkin_result != 3
        group by ch.checkin_center
    ), 

/* Exerp GO profile check */
    go_check as (
        select
                SUM(CASE WHEN sp.globalid = 'ExerpGoFeatures' THEN 1 ELSE 0 END) AS "go_check"                       
        from systemproperties sp 
        where sp.globalid = 'ExerpGoFeatures'
        --- 'ExerpGoProfileSettings'
    ),
    
/* Main query. licenses, area */    
    base AS  (   
        SELECT DISTINCT                     
                'Fitness World' as "Server",  
                c.id AS "Center",
                c.name AS "Name",
                c.startupdate AS "Center start-up date",            
                el.stop_date as "Exerp license stop date",
                c.address1 AS "Address 1",
                c.address2 AS "Address 2",
                c.address3 AS "Address 3",
                c.city AS "City",
                c.zipcode AS "Zipcode",
                c.country AS "Country",
                c.state AS "State",
                /* only lat/long for open centers */
                case when el.stop_date is not null then null else round(c.latitude, 6) end as "Latitude",  
                case when el.stop_date is not null then null else round(c.longitude, 6) end as "Longitude",            
                COALESCE(member.total_members, 0) AS "Active members",
                COALESCE(total_participations, 0) as total_participations_30days,
                COALESCE(total_checkins, 0) as total_checkins_30days,    

                
--                null as total_checkins_30days,  ---lifetime null          
                COALESCE(go_check, 0) AS "go_check",            
                l.feature,
                l.start_date AS "Feature start date",
                l.stop_date  AS "Feature stop date",
                a10.name AS "Scope 1",
                a9.name  AS "Scope 2",
                a8.name  AS "Scope 3",
                a7.name  AS "Scope 4",
                a6.name  AS "Scope 5",
                a5.name  AS "Scope 6",
                a4.name  AS "Scope 7",
                a3.name  AS "Scope 8",
                a2.name  AS "Scope 9",
                a.name   AS "Scope 10"

        FROM licenses l        
        JOIN centers c ON c.id = l.center_id
        /* join CTEs */        
        LEFT JOIN participation pa on c.id = pa.booking_center
        CROSS JOIN go_check g        
        LEFT JOIN checkin on checkin.checkin_center = c.id                
        LEFT JOIN member on member.center_id = c.id
        
        /* exerp/clubLead license only */
        JOIN licenses el ON c.id = el.center_id    
                AND el.id  IN (
                    SELECT MAX(id)
                    FROM licenses 
                    WHERE feature = 'clubLead'
                    GROUP BY center_id
                  )                 
        
        /* mimic scope tree. not dynamic */            
        JOIN area_centers ac ON c.id = ac.center
        JOIN areas a ON ac.area = a.id
        LEFT JOIN areas a2 ON a2.id = a.parent            
        LEFT JOIN areas a3 ON a3.id = a2.parent            
        LEFT JOIN areas a4 ON a4.id = a3.parent            
        LEFT JOIN areas a5 ON a5.id = a4.parent            
        LEFT JOIN areas a6 ON a6.id = a5.parent            
        LEFT JOIN areas a7 ON a7.id = a6.parent            
        LEFT JOIN areas a8 ON a8.id = a7.parent            
        LEFT JOIN areas a9 ON a9.id = a8.parent            
        LEFT JOIN areas a10 ON a10.id = a9.parent      
        
        WHERE
                a.root_area = 1 -- System scope
            AND (l.stop_date IS NULL
                OR l.stop_date >= DATE_TRUNC('month', CURRENT_DATE)::DATE ) 
                
            /* latest exerp license ID if centers have been stopped multiple times */               
            AND el.id  IN (
                    SELECT MAX(id)
                    FROM licenses WHERE feature = 'clubLead'
                    GROUP BY center_id
                  )            
        ORDER BY c.id asc
    )
/* returned columns */
SELECT
    "Server",             
    "Center",               
    "Name",                 
    "Center start-up date",
    "Exerp license stop date", 
    "Address 1",            
    "Address 2",            
    "Address 3",            
    "City",                 
    "Zipcode",              
    "Country",              
    "State",  
    "Latitude", 
    "Longitude",        
    "Active members", 
    "total_participations_30days",
    "total_checkins_30days",    
    "go_check",
    "Scope 1",             
    "Scope 2",             
    "Scope 3",             
    "Scope 4",             
    "Scope 5",             
    "Scope 6",             
    "Scope 7",             
    "Scope 8",             
    "Scope 9",             
    "Scope 10",
    CASE 
        WHEN "Center start-up date" > CURRENT_TIMESTAMP THEN 'yes'
        ELSE 'no'
    END AS "Presale",    
    CASE 
        WHEN SUM(CASE WHEN feature = 'clubLead' THEN 1 ELSE 0 END) >= 1 AND 
             SUM(CASE WHEN feature = 'generalLedger' THEN 1 ELSE 0 END) >= 1 THEN 'yes' 
        ELSE 'no' 
    END AS "Live",
    
    /* license counter per center. not dynamic */ 
    SUM(CASE WHEN feature = 'clubLead' THEN 1 ELSE 0 END) AS "clubLead",
    SUM(CASE WHEN feature = 'staffBooking' THEN 1 ELSE 0 END) AS "staffBooking",
    SUM(CASE WHEN feature = 'resourceBooking' THEN 1 ELSE 0 END) AS "resourceBooking",
    SUM(CASE WHEN feature = 'electronicSignature' THEN 1 ELSE 0 END) AS "electronicSignature",
    SUM(CASE WHEN feature = 'dataCleaning' THEN 1 ELSE 0 END) AS "dataCleaning",
    SUM(CASE WHEN feature = 'inventoryManagement' THEN 1 ELSE 0 END) AS "inventoryManagement",
    SUM(CASE WHEN feature = 'gateControl' THEN 1 ELSE 0 END) AS "gateControl",
    SUM(CASE WHEN feature = 'kpiTracker' THEN 1 ELSE 0 END) AS "kpiTracker",
    SUM(CASE WHEN feature = 'chargedSMS' THEN 1 ELSE 0 END) AS "chargedSMS",
    SUM(CASE WHEN feature = 'classBooking' THEN 1 ELSE 0 END) AS "classBooking",
    SUM(CASE WHEN feature = 'bundleProducts' THEN 1 ELSE 0 END) AS "bundleProducts",
    SUM(CASE WHEN feature = 'startupCampaign' THEN 1 ELSE 0 END) AS "startupCampaign",
    SUM(CASE WHEN feature = 'vendingMachines' THEN 1 ELSE 0 END) AS "vendingMachines",
    SUM(CASE WHEN feature = 'debtCollection' THEN 1 ELSE 0 END) AS "debtCollection",
    SUM(CASE WHEN feature = 'expenseVoucher' THEN 1 ELSE 0 END) AS "expenseVoucher",
    SUM(CASE WHEN feature = 'creditCardTerminal' THEN 1 ELSE 0 END) AS "creditCardTerminal",
    SUM(CASE WHEN feature = 'corporateRebates' THEN 1 ELSE 0 END) AS "corporateRebates",
    SUM(CASE WHEN feature = 'corporateSponsorship' THEN 1 ELSE 0 END) AS "corporateSponsorship",
    SUM(CASE WHEN feature = 'giftCards' THEN 1 ELSE 0 END) AS "giftCards",
    SUM(CASE WHEN feature = 'noShowSanctions' THEN 1 ELSE 0 END) AS "noShowSanctions",
    SUM(CASE WHEN feature = 'automatedMessages' THEN 1 ELSE 0 END) AS "automatedMessages",
    SUM(CASE WHEN feature = 'questionnaires' THEN 1 ELSE 0 END) AS "questionnaires",
    SUM(CASE WHEN feature = 'selfServiceTerminal' THEN 1 ELSE 0 END) AS "selfServiceTerminal",
    SUM(CASE WHEN feature = 'openAPI' THEN 1 ELSE 0 END) AS "openAPI",
    SUM(CASE WHEN feature = 'webSales' THEN 1 ELSE 0 END) AS "webSales",
    SUM(CASE WHEN feature = 'webServices' THEN 1 ELSE 0 END) AS "webServices",
    SUM(CASE WHEN feature = 'customHardware' THEN 1 ELSE 0 END) AS "customHardware",
    SUM(CASE WHEN feature = 'generalLedger' THEN 1 ELSE 0 END) AS "generalLedger",
    SUM(CASE WHEN feature = 'payAsYouGo' THEN 1 ELSE 0 END) AS "payAsYouGo",
    SUM(CASE WHEN feature = 'automatedExports' THEN 1 ELSE 0 END) AS "automatedExports",
    SUM(CASE WHEN feature = 'subscriptionPriceControl' THEN 1 ELSE 0 END) AS "subscriptionPriceControl",
    SUM(CASE WHEN feature = 'addOn' THEN 1 ELSE 0 END) AS "addOn", 
    SUM(CASE WHEN feature = 'childCare' THEN 1 ELSE 0 END) AS "childCare",
    SUM(CASE WHEN feature = 'courses' THEN 1 ELSE 0 END) AS "courses",
    SUM(CASE WHEN feature = 'push' THEN 1 ELSE 0 END) AS "push",
    SUM(CASE WHEN feature = 'creditCardAgreement' THEN 1 ELSE 0 END) AS "creditCardAgreement",
    SUM(CASE WHEN feature = 'clipcards' THEN 1 ELSE 0 END) AS "clipcards",
    SUM(CASE WHEN feature = 'targetGroups' THEN 1 ELSE 0 END) AS "targetGroups",
    SUM(CASE WHEN feature = 'taskManagement' THEN 1 ELSE 0 END) AS "taskManagement",
    SUM(CASE WHEN feature = 'offsiteAccess' THEN 1 ELSE 0 END) AS "offsiteAccess",
    SUM(CASE WHEN feature = 'hosting' THEN 1 ELSE 0 END) AS "hosting",
    SUM(CASE WHEN feature = 'social' THEN 1 ELSE 0 END) AS "social",
    SUM(CASE WHEN feature = 'CRM' THEN 1 ELSE 0 END) AS "CRM",
    SUM(CASE WHEN feature = 'secondaryMembership' THEN 1 ELSE 0 END) AS "secondaryMembership",
    SUM(CASE WHEN feature = 'campaignCodes' THEN 1 ELSE 0 END) AS "campaignCodes",
    SUM(CASE WHEN feature = 'installmentPlans' THEN 1 ELSE 0 END) AS "installmentPlans",
    SUM(CASE WHEN feature = 'mobileAPI' THEN 1 ELSE 0 END) AS "mobileAPI",
    SUM(CASE WHEN feature = 'bookASeat' THEN 1 ELSE 0 END) AS "bookASeat",
    SUM(CASE WHEN feature = 'BIQlikOEM' THEN 1 ELSE 0 END) AS "BIQlikOEM",
    SUM(CASE WHEN feature = 'BIQlikFULL' THEN 1 ELSE 0 END) AS "BIQlikFULL",
    SUM(CASE WHEN feature = 'BIExport' THEN 1 ELSE 0 END) AS "BIExport",
    SUM(CASE WHEN feature = 'memberApp' THEN 1 ELSE 0 END) AS "memberApp",
    SUM(CASE WHEN feature = 'staffMobileApp' THEN 1 ELSE 0 END) AS "staffMobileApp",
    SUM(CASE WHEN feature = 'staffTabletApp' THEN 1 ELSE 0 END) AS "staffTabletApp",
    SUM(CASE WHEN feature = 'recurringClipcardSubscriptions' THEN 1 ELSE 0 END) AS "recurringClipcardSubscriptions",
    SUM(CASE WHEN feature = 'coursesAndLevels' THEN 1 ELSE 0 END) AS "coursesAndLevels",
    SUM(CASE WHEN feature = 'dataWarehouse' THEN 1 ELSE 0 END) AS "dataWarehouse",
    SUM(CASE WHEN feature = 'promiseToPay' THEN 1 ELSE 0 END) AS "promiseToPay",
    SUM(CASE WHEN feature = 'camps' THEN 1 ELSE 0 END) AS "camps",
    SUM(CASE WHEN feature = 'documentationManagement' THEN 1 ELSE 0 END) AS "documentationManagement",
    SUM(CASE WHEN feature = 'processAutomation' THEN 1 ELSE 0 END) AS "processAutomation",
    SUM(CASE WHEN feature = 'cardOnFile' THEN 1 ELSE 0 END) AS "cardOnFile",
    SUM(CASE WHEN feature = 'memberWeb' THEN 1 ELSE 0 END) AS "memberWeb",
    SUM(CASE WHEN feature = 'familyProfile' THEN 1 ELSE 0 END) AS "familyProfile",
    SUM(CASE WHEN feature = 'retentionCampaigns' THEN 1 ELSE 0 END) AS "retentionCampaigns",
    SUM(CASE WHEN feature = 'ClearTaxIntegration' THEN 1 ELSE 0 END) AS "ClearTaxIntegration",
    SUM(CASE WHEN feature = 'CustomAttribute' THEN 1 ELSE 0 END) AS "CustomAttribute",
    SUM(CASE WHEN feature = 'OAuthPushTargets' THEN 1 ELSE 0 END) AS "OAuthPushTargets"

    
    /* , SUM(CASE WHEN feature = 'NewLicense' THEN 1 ELSE 0 END) AS "NewLicense" */  


FROM 
    base
GROUP BY 
    "Server",         
    "Center",               
    "Name",                 
    "Center start-up date", 
    "Exerp license stop date",
    "Address 1",            
    "Address 2",            
    "Address 3",            
    "City",                 
    "Zipcode",              
    "Country",              
    "State",  
    "Latitude", 
    "Longitude",                
    "Active members", 
    "total_participations_30days", 
    "total_checkins_30days", 
    "go_check",
    "Scope 1",             
    "Scope 2",             
    "Scope 3",             
    "Scope 4",             
    "Scope 5",             
    "Scope 6",             
    "Scope 7",             
    "Scope 8",             
    "Scope 9",             
    "Scope 10"
    
ORDER BY "Center" asc