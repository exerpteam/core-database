CREATE TABLE 
    accounts 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        periodcenter int4, 
        periodid int4, 
        blocked bool DEFAULT FALSE NOT NULL, 
        atype int4 NOT NULL, 
        name        text(2147483647) NOT NULL, 
        external_id text(2147483647), 
        account_vat_type_group_id int4, 
        report_key int4, 
        globalid text(2147483647), 
        SYSTEM bool DEFAULT FALSE NOT NULL, 
        trans_rebook_rule_type text(2147483647), 
        trans_rebook_configuration bytea, 
        PRIMARY KEY (center, id) 
    );
