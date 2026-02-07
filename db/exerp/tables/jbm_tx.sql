CREATE TABLE 
    jbm_tx 
    ( 
        node_id int4, 
        transaction_id int8 NOT NULL, 
        branch_qual bytea, 
        format_id int4, 
        global_txid bytea, 
        PRIMARY KEY (transaction_id) 
    );
