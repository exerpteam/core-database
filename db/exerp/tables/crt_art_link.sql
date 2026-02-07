CREATE TABLE 
    crt_art_link 
    ( 
        crt_center int4 NOT NULL, 
        crt_id int4 NOT NULL, 
        crt_subid int4 NOT NULL, 
        art_center int4 NOT NULL, 
        art_id int4 NOT NULL, 
        art_subid int4 NOT NULL, 
        PRIMARY KEY (crt_center, crt_id, crt_subid, art_center, art_id, art_subid), 
        CONSTRAINT crtartlink_art_fk FOREIGN KEY (art_center, art_id, art_subid) REFERENCES 
        "exerp"."ar_trans" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT crtartlink_crt_fk FOREIGN KEY (crt_center, crt_id, crt_subid) REFERENCES 
    "exerp"."cashregistertransactions" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
