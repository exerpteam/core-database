CREATE TABLE 
    relatives 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        rtype int4 NOT NULL, 
        relativecenter int4 NOT NULL, 
        relativeid int4 NOT NULL, 
        relativesubid int4, 
        status int4 DEFAULT 0 NOT NULL, 
        expiredate                DATE, 
        family_allow_card_on_file VARCHAR(20), 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT relat_to_person_fk FOREIGN KEY (center, id) REFERENCES "exerp"."persons" 
        ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
