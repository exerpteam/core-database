CREATE TABLE 
    clients 
    ( 
        id int4 NOT NULL, 
        clientid    text(2147483647) NOT NULL, 
        type        text(2147483647) NOT NULL, 
        STATE       text(2147483647) NOT NULL, 
        name        text(2147483647), 
        description text(2147483647), 
        center int4, 
        expiration_date DATE, 
        last_contact int8, 
        alert_sent_for_last_contact_at int8, 
        is_registered bool DEFAULT FALSE NOT NULL, 
        available_as_template bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (id) 
    );
