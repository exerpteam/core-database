CREATE TABLE 
    data_cleaning_out 
    ( 
        id int4 NOT NULL, 
        data_cleaning_agency_id int4 NOT NULL, 
        exchanged_file_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT data_cleaning_out_to_agency_fk FOREIGN KEY (data_cleaning_agency_id) REFERENCES 
        "exerp"."datacleaning_agency" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT data_clean_out_to_exch_file_fk FOREIGN KEY (exchanged_file_id) REFERENCES 
    "exerp"."exchanged_file" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
