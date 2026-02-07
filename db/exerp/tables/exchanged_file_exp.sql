CREATE TABLE 
    exchanged_file_exp 
    ( 
        id int4 NOT NULL, 
        exchanged_file_id int4, 
        service text(2147483647) NOT NULL, 
        configuration bytea, 
        status text(2147483647) NOT NULL, 
        attempt int4, 
        export_time int8, 
        PRIMARY KEY (id), 
        CONSTRAINT efe_ef_fk FOREIGN KEY (exchanged_file_id) REFERENCES "exerp"."exchanged_file" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
