CREATE TABLE 
    families 
    ( 
        center int4 NOT NULL, 
        family_name VARCHAR(50), 
        status      VARCHAR(20) DEFAULT 'ACTIVE'::character VARYING NOT NULL, 
        id serial DEFAULT nextval('families_id_seq'::regclass) NOT NULL, 
        PRIMARY KEY (id) 
    );
