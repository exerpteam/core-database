CREATE TABLE 
    data_cleaning_monitor_period 
    ( 
        id int4 NOT NULL, 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        one_shot bool NOT NULL, 
        agency int4, 
        agency_id text(2147483647), 
        monitoring_start_time int8 NOT NULL, 
        monitoring_stop_time int8, 
        start_data_clean_out_line_id int4, 
        start_data_clean_in_line_id int4, 
        stop_data_clean_out_line_id int4, 
        stop_data_clean_in_line_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT period_to_start_in_line_fk FOREIGN KEY (start_data_clean_in_line_id) REFERENCES 
        "exerp"."data_cleaning_in_line" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT period_to_stop_in_line_fk FOREIGN KEY (stop_data_clean_in_line_id) REFERENCES 
    "exerp"."data_cleaning_in_line" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT period_to_start_out_line_fk FOREIGN KEY (start_data_clean_out_line_id) REFERENCES 
    "exerp"."data_cleaning_out_line" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT period_to_stop_out_line_fk FOREIGN KEY (stop_data_clean_out_line_id) REFERENCES 
    "exerp"."data_cleaning_out_line" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT data_clean_period_to_person_fk FOREIGN KEY (person_center, person_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
