CREATE TABLE 
    shopping_baskets 
    ( 
        id int4 NOT NULL, 
        status text(2147483647) NOT NULL, 
        origin text(2147483647) NOT NULL, 
        center int4, 
        client_center int4, 
        client_id int4, 
        employee_center int4, 
        employee_id int4, 
        created int8 NOT NULL, 
        modified int8 NOT NULL, 
        serialized_session bytea, 
        version int4 NOT NULL, 
        external_id VARCHAR(50), 
        configurable_payment_method int4, 
        cash_register_id int4, 
        PRIMARY KEY (id) 
    );
