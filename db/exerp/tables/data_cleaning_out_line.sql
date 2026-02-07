CREATE TABLE 
    data_cleaning_out_line 
    ( 
        id int4 NOT NULL, 
        data_cleaning_out_id int4 NOT NULL, 
        line_type  text(2147483647) NOT NULL, 
        line_state text(2147483647) NOT NULL, 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT line_to_data_cleaning_out_fk FOREIGN KEY (data_cleaning_out_id) REFERENCES 
        "exerp"."data_cleaning_out" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT data_clean_out_line_to_pers_fk FOREIGN KEY (person_center, person_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
