CREATE TABLE 
    impliedemployeeroles 
    ( 
        roleid int4 NOT NULL, 
        implied int4 NOT NULL, 
        scope_override text(2147483647), 
        PRIMARY KEY (roleid, implied), 
        CONSTRAINT impemprole_to_improle_fk FOREIGN KEY (implied) REFERENCES "exerp"."roles" ("id") 
        ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT impemprole_to_role_fk FOREIGN KEY (roleid) REFERENCES "exerp"."roles" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
