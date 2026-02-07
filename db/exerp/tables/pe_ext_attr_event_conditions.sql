CREATE TABLE 
    pe_ext_attr_event_conditions 
    ( 
        id int4 NOT NULL, 
        attribute_name  text(2147483647) NOT NULL, 
        attribute_value text(2147483647), 
        regex_value     VARCHAR(200), 
        PRIMARY KEY (id) 
    );
