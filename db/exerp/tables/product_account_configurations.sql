CREATE TABLE 
    product_account_configurations 
    ( 
        id int4 NOT NULL, 
        name                 text(2147483647) NOT NULL, 
        product_account_type text(2147483647) NOT NULL, 
        blocked bool DEFAULT FALSE NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        sales_account_globalid     text(2147483647), 
        expenses_account_globalid  text(2147483647), 
        refund_account_globalid    text(2147483647), 
        write_off_account_globalid text(2147483647), 
        defer_rev_account_globalid text(2147483647), 
        inventory_account_globalid text(2147483647), 
        defer_lia_account_globalid VARCHAR(30), 
        PRIMARY KEY (id) 
    );
