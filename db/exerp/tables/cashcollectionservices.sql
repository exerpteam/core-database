CREATE TABLE 
    cashcollectionservices 
    ( 
        id int4 NOT NULL, 
        top_node_id int4, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        name  text(2147483647), 
        STATE text(2147483647) NOT NULL, 
        blocked bool DEFAULT FALSE NOT NULL, 
        servicetype int4 NOT NULL, 
        datasupplier_id text(2147483647), 
        account_center int4, 
        account_id int4, 
        serial int4 NOT NULL, 
        ledger_number int4, 
        interests_account_center int4, 
        interests_account_id int4, 
        client_identification text(2147483647), 
        exclude_subscription_by_age bool DEFAULT FALSE, 
        invoice_fee_account_center int4, 
        invoice_fee_account_id int4, 
        reminder_fee_account_center int4, 
        reminder_fee_account_id int4, 
        PRIMARY KEY (id) 
    );
