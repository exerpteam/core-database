CREATE TABLE 
    deferrals 
    ( 
        id int4 NOT NULL, 
        center int4 NOT NULL, 
        entry_time int8 NOT NULL, 
        defer_acc_trans_center int4 NOT NULL, 
        defer_acc_trans_id int4 NOT NULL, 
        defer_acc_trans_subid int4 NOT NULL, 
        revenue_type text(2147483647) NOT NULL, 
        reversal_entry_time int8, 
        reversal_acc_trans_center int4, 
        reversal_acc_trans_id int4, 
        reversal_acc_trans_subid int4, 
        PRIMARY KEY (id), 
        CONSTRAINT deferred_to_acc_trans_fk FOREIGN KEY (defer_acc_trans_center, defer_acc_trans_id 
        , defer_acc_trans_subid) REFERENCES "exerp"."account_trans" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT reversed_to_acc_trans_fk FOREIGN KEY (reversal_acc_trans_center, 
    reversal_acc_trans_id, reversal_acc_trans_subid) REFERENCES "exerp"."account_trans" ("center", 
    "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
