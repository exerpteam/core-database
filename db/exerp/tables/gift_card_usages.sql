CREATE TABLE 
    gift_card_usages 
    ( 
        id int4 NOT NULL, 
        TIME int8 DEFAULT 0 NOT NULL, 
        employee_center int4, 
        employee_id int4, 
        amount NUMERIC(0,0) NOT NULL, 
        REF    text(2147483647), 
        type   text(2147483647) NOT NULL, 
        transaction_center int4, 
        transaction_id int4, 
        transaction_subid int4, 
        gift_card_center int4 NOT NULL, 
        gift_card_id int4 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT usages_to_acc_trans_fk FOREIGN KEY (transaction_center, transaction_id, 
        transaction_subid) REFERENCES "exerp"."account_trans" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT gcu_to_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
    "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT gcu_to_gift_card_fk FOREIGN KEY (gift_card_center, gift_card_id) REFERENCES 
    "exerp"."gift_cards" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
