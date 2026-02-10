-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT 
        c.id AS "Center"
        ,c.name AS "Name"
        ,c.startupdate AS "Center start up date"  
        ,CASE  
                WHEN l.feature = 'addOn' THEN 'Add-on' 
                WHEN l.feature = 'automatedExports' THEN 'Auto exports'
                WHEN l.feature = 'automatedMessages' THEN 'Automated messages' 
                WHEN l.feature = 'BIExport' THEN 'BI Export'            
                WHEN l.feature = 'BIQlikFULL' THEN 'BI with Qlik FULL'
                WHEN l.feature = 'BIQlikOEM' THEN 'BI with Qlik OEM' 
                WHEN l.feature = 'bookASeat' THEN 'Book a seat' 
                WHEN l.feature = 'bundleProducts' THEN 'Bundle products'                
                WHEN l.feature = 'campaignCodes' THEN 'Campaign codes' 
                WHEN l.feature = 'camps' THEN 'Camps'      
                WHEN l.feature = 'cardOnFile' THEN 'Card on file'  
                WHEN l.feature = 'chargedSMS' THEN 'Charged SMS' 
                WHEN l.feature = 'childCare' THEN 'Child care'          
                WHEN l.feature = 'classBooking' THEN 'Class booking'
                WHEN l.feature = 'clipcards' THEN 'Clipcards'
                WHEN l.feature = 'clubLead' THEN 'Exerp'
                WHEN l.feature = 'corporateRebates' THEN 'Corp. rebates'                 
                WHEN l.feature = 'corporateSponsorship' THEN 'Corp. sponsorship'                                                                
                WHEN l.feature = 'courses' THEN 'Courses'
                WHEN l.feature = 'coursesAndLevels' THEN 'Courses and Levels'
                WHEN l.feature = 'creditCardTerminal' THEN 'Credit card terminal'
                WHEN l.feature = 'creditCardAgreement' THEN 'Credit card agreement'
                WHEN l.feature = 'CRM' THEN 'CRM'                 
                WHEN l.feature = 'customHardware' THEN 'Custom hardware'
                WHEN l.feature = 'dataCleaning' THEN 'Data cleaning'
                WHEN l.feature = 'debtCollection' THEN 'Debt collection'
                WHEN l.feature = 'dataWarehouse' THEN 'Data Warehouse'
                WHEN l.feature = 'documentationManagement' THEN 'Documentation Management'
                WHEN l.feature = 'electronicSignature' THEN 'E-signature'
                WHEN l.feature = 'expenseVoucher' THEN 'Expense voucher'
                WHEN l.feature = 'familyProfile' THEN 'Family Profile'
                WHEN l.feature = 'gateControl' THEN 'Gate control'
                WHEN l.feature = 'generalLedger' THEN 'General ledger' 
                WHEN l.feature = 'giftCards' THEN 'Gift cards'
                WHEN l.feature = 'hosting' THEN 'Hosting'
                WHEN l.feature = 'installmentPlans' THEN 'Installment plans' 
                WHEN l.feature = 'inventoryManagement' THEN 'Inventory management'
                WHEN l.feature = 'kpiTracker' THEN 'KPI Tracker'
                WHEN l.feature = 'memberApp' THEN 'Member App'
                WHEN l.feature = 'memberWeb' THEN 'Member Web'
                WHEN l.feature = 'mobileAPI' THEN 'Mobile API'
                WHEN l.feature = 'noShowSanctions' THEN 'No-show sanctions'
                WHEN l.feature = 'offsiteAccess' THEN 'Offsite access'
                WHEN l.feature = 'openAPI' THEN 'Open API'
                WHEN l.feature = 'offsiteAccess' THEN 'Offsite access'
                WHEN l.feature = 'payAsYouGo' THEN 'Pay as you go'
                WHEN l.feature = 'processAutomation' THEN 'Process Automation'
                WHEN l.feature = 'promiseToPay' THEN 'Promise to Pay'
                WHEN l.feature = 'push' THEN 'Push messages'                
                WHEN l.feature = 'questionnaires' THEN 'Questionnaires' 
                WHEN l.feature = 'recurringClipcardSubscriptions' THEN 'Recurring clipcards'
                WHEN l.feature = 'resourceBooking' THEN 'Resource booking'
                WHEN l.feature = 'retentionCampaigns' THEN 'Retention Campaigns'
                WHEN l.feature = 'secondaryMembership' THEN 'Secondary membership'
                WHEN l.feature = 'selfServiceTerminal' THEN 'Kiosk'
                WHEN l.feature = 'social' THEN 'Book a Friend'
                WHEN l.feature = 'staffBooking' THEN 'Staff booking'
                WHEN l.feature = 'staffMobileApp' THEN 'Staff Mobile App'
                WHEN l.feature = 'staffTabletApp' THEN 'Staff Tablet App'
                WHEN l.feature = 'subscriptionPriceControl' THEN 'Subscription price control'
                WHEN l.feature = 'startupCampaign' THEN 'Startup Campaign'
                WHEN l.feature = 'taskManagement' THEN 'Task management' 
                WHEN l.feature = 'targetGroups' THEN 'Target groups' 
                WHEN l.feature = 'taskManagement' THEN 'Task management'
                WHEN l.feature = 'webSales' THEN 'Online sales'
                WHEN l.feature = 'webServices' THEN 'Online services'
                WHEN l.feature = 'vendingMachines' THEN 'Vending machines'  
                ELSE l.feature
        END AS "Feature" 
        ,l.start_date AS "Feature start date" 
        ,l.stop_date AS "Feature stop date"                             
FROM
        licenses l
JOIN
        centers c ON c.id = l.center_id 
JOIN
        leejam.licenses hosting
        on hosting.center_id = c.id
        AND hosting.feature = 'hosting'
        AND (hosting.stop_date IS NULL OR hosting.stop_date > current_date)
WHERE
        (l.stop_date IS NULL OR l.stop_date > current_date)             