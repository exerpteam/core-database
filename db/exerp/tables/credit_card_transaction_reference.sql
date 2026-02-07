CREATE TABLE 
    credit_card_transaction_reference 
    ( 
        id int4 NOT NULL, 
        invoice_payment_session_id int4 NOT NULL, 
        transaction_reference json NOT NULL, 
        PRIMARY KEY (id) 
    );
