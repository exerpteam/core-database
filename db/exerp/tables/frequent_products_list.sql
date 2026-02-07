CREATE TABLE 
    frequent_products_list 
    ( 
        scope_type text(2147483647), 
        scope_id int4, 
        id int4 NOT NULL, 
        last_refresh int8, 
        type text(2147483647) NOT NULL, 
        version int8, 
        client_profile_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT frq_pr_lst_to_cli_prof_fk FOREIGN KEY (client_profile_id) REFERENCES 
        "exerp"."client_profiles" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
