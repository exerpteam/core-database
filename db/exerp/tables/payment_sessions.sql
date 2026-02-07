CREATE TABLE 
    payment_sessions 
    ( 
        id int4 NOT NULL, 
        STATE text(2147483647) NOT NULL, 
        center int4, 
        created int8 NOT NULL, 
        modified int8 NOT NULL, 
        shopping_basket_id int4, 
        serialized_session bytea, 
        PRIMARY KEY (id) 
    );
