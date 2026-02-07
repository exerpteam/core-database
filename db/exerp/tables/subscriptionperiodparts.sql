CREATE TABLE 
    subscriptionperiodparts 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        spp_type int4 NOT NULL, 
        spp_state int4 NOT NULL, 
        period_number int4 NOT NULL, 
        from_date             DATE NOT NULL, 
        to_date               DATE NOT NULL, 
        old_billed_until_date DATE, 
        subscription_price    NUMERIC(0,0), 
        addons_price          NUMERIC(0,0), 
        entry_time int8 NOT NULL, 
        cancellation_time int8, 
        campaign_code_id int4, 
        had_hard_close_role bool, 
        sync_date DATE, 
        prorata_sessions int4, 
        prorata_sessions_total int4, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT subpp_to_subscription_fk FOREIGN KEY (center, id) REFERENCES 
        "exerp"."subscriptions" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
