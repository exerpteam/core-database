SELECT

biview.PERSON_ID,					
biview.SUBSCRIPTION_ID,               
biview.SUBSCRIPTION_CENTER,           
biview.STATE,                        
biview.SUB_STATE,                     
biview.RENEWAL_TYPE,                  
biview.PRODUCT_ID,                    
biview.START_DATE,                    
biview.STOP_DATE,                     
biview.END_DATE,                      
biview.BILLED_UNTIL_DATE,             
biview.BINDING_END_DATE,              
biview.CREATION_DATE,                 
CAST(biview.SUBSCRIPTION_PRICE AS DECIMAL(15,2)) 									AS SUBSCRIPTION_PRICE,            
CAST(biview.BINDING_PRICE AS DECIMAL(15,2)) 									AS BINDING_PRICE,                 
biview.REQUIRES_MAIN,                 
biview.SUB_PRICE_UPDATE_EXCLUDED,     
biview.TYPE_PRICE_UPDATE_EXCLUDED,    
biview.FREEZE_PERIOD_PRODUCT_ID,      
biview.TRANSFERRED_TO,                
biview.EXTENDED_TO,                   
biview.PERIOD_UNIT,                   
biview.PERIOD_COUNT,                  
biview.CENTER_ID,
p.PRODUCT_GROUP_ID,
p.MASTER_PRODUCT_ID,
p.NAME as PRODUCT_NAME,
p.SALES_PRICE AS PRODUCT_SALES_PRICE,
p.MINIMUM_PRICE AS PRODUCT_MINIMUM_PRICE,
p.COST_PRICE AS PRODUCT_COST_PRICE	
FROM
    BI_SUBSCRIPTIONS biview
INNER JOIN BI_PRODUCTS p
	ON p.PRODUCT_ID = biview.PRODUCT_ID
WHERE
    (to_date('19700101', 'YYYYMMDD') 
+ ( 1 / 24 / 60 / 60 / 1000) 
* biview.ETS) BETWEEN $$FROMDATE$$ AND $$TODATE$$
	and biview.CENTER_ID in ($$scope$$)