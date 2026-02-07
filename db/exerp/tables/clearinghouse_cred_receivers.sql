CREATE TABLE 
    clearinghouse_cred_receivers 
    ( 
        clearinghouse int4 NOT NULL, 
        creditor_id VARCHAR(16) NOT NULL, 
        receiver_clearinghouse int4 NOT NULL, 
        receiver_creditor_id VARCHAR(16) NOT NULL, 
        CONSTRAINT ch_creditor FOREIGN KEY (clearinghouse, creditor_id) REFERENCES 
        "exerp"."clearinghouse_creditors" ("clearinghouse", "creditor_id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT receiver_chc FOREIGN KEY (receiver_clearinghouse, receiver_creditor_id) REFERENCES 
    "exerp"."clearinghouse_creditors" ("clearinghouse", "creditor_id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
