
SELECT
    *
FROM
    (
        SELECT DISTINCT
            T1.*
          ,pa.CENTER
          , pa.ID
          ,pa.SUBID
          ,pa.STATE
          ,DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14
            , 'Agreement information incomplete',15,'Transfer',16,'Agreement Recreated',17, 'Signature missing', 'UNDEFINED') RESOLVED_STATE
          ,NVL2(pac.CENTER,1,0)                                                                                               ACTIVE_AGREEMENT
          ,ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID                                                                          pid
          ,ch.NAME                                                                                                            CLEARING_HOUSE
          ,chc.CREDITOR_NAME                                                                                                  CREDITOR
        FROM
            (
                SELECT
                    '801106000364080000009J' LINE
                  , '80110600036408'         REF
                  , '0009'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000714120000004J' LINE
                  , '80110300071412'         REF
                  , '0004'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000732180000003N' LINE
                  , '80110300073218'         REF
                  , '0003'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801101000324070000006J' LINE
                  , '80110100032407'         REF
                  , '0006'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801101000774340000006J' LINE
                  , '80110100077434'         REF
                  , '0006'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801101000780200000002N' LINE
                  , '80110100078020'         REF
                  , '0002'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801202000152010000059J' LINE
                  , '80120200015201'         REF
                  , '0059'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801101000720110000007J' LINE
                  , '80110100072011'         REF
                  , '0007'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801203000258060000069J' LINE
                  , '80120300025806'         REF
                  , '0069'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000186020000006J' LINE
                  , '80110300018602'         REF
                  , '0006'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000588010000007J' LINE
                  , '80110200058801'         REF
                  , '0007'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000374020000006J' LINE
                  , '80110400037402'         REF
                  , '0006'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000702020000000J' LINE
                  , '80110300070202'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801204000388110000054N' LINE
                  , '80120400038811'         REF
                  , '0054'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000764030000000J' LINE
                  , '80110200076403'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801105000532020000006J' LINE
                  , '80110500053202'         REF
                  , '0006'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801105000642080000000J' LINE
                  , '80110500064208'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000328050000005J' LINE
                  , '80110400032805'         REF
                  , '0005'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000574090000008J' LINE
                  , '80110300057409'         REF
                  , '0008'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801101000272030000006N' LINE
                  , '80110100027203'         REF
                  , '0006'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000774270000008N' LINE
                  , '80110200077427'         REF
                  , '0008'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000272030000000J' LINE
                  , '80110400027203'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801106000364080000009N' LINE
                  , '80110600036408'         REF
                  , '0009'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000622010000000N' LINE
                  , '80110400062201'         REF
                  , '0000'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000662060000007J' LINE
                  , '80110300066206'         REF
                  , '0007'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000766040000009J' LINE
                  , '80110400076604'         REF
                  , '0009'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000706020000003N' LINE
                  , '80110200070602'         REF
                  , '0003'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000078310000004J' LINE
                  , '80110300007831'         REF
                  , '0004'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000644100000007J' LINE
                  , '80110300064410'         REF
                  , '0007'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000396020000009J' LINE
                  , '80110400039602'         REF
                  , '0009'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801101000100030000009J' LINE
                  , '80110100010003'         REF
                  , '0009'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000628100000000J' LINE
                  , '80110300062810'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801105000388310000002N' LINE
                  , '80110500038831'         REF
                  , '0002'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000616050000005J' LINE
                  , '80110300061605'         REF
                  , '0005'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000392110000009J' LINE
                  , '80110400039211'         REF
                  , '0009'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000586020000007N' LINE
                  , '80110300058602'         REF
                  , '0007'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000702020000000J' LINE
                  , '80110300070202'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000732200000007N' LINE
                  , '80110400073220'         REF
                  , '0007'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801101000714120000008J' LINE
                  , '80110100071412'         REF
                  , '0008'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000714120000004J' LINE
                  , '80110300071412'         REF
                  , '0004'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000258060000006J' LINE
                  , '80110200025806'         REF
                  , '0006'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000374110000009J' LINE
                  , '80110300037411'         REF
                  , '0009'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801105000356060000001N' LINE
                  , '80110500035606'         REF
                  , '0001'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801105000642080000000J' LINE
                  , '80110500064208'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801202000662020000048N' LINE
                  , '80120200066202'         REF
                  , '0048'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801106000392110000004N' LINE
                  , '80110600039211'         REF
                  , '0004'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801106000642080000008N' LINE
                  , '80110600064208'         REF
                  , '0008'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000772320000002J' LINE
                  , '80110200077232'         REF
                  , '0002'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801101000774340000006J' LINE
                  , '80110100077434'         REF
                  , '0006'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000364100000002J' LINE
                  , '80110300036410'         REF
                  , '0002'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000474070000005J' LINE
                  , '80110300047407'         REF
                  , '0005'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000272030000018J' LINE
                  , '80110400027203'         REF
                  , '0018'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000698020000008J' LINE
                  , '80110400069802'         REF
                  , '0008'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801105000378060000005J' LINE
                  , '80110500037806'         REF
                  , '0005'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801204000378060000030J' LINE
                  , '80120400037806'         REF
                  , '0030'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801101000796050000009N' LINE
                  , '80110100079605'         REF
                  , '0009'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000102110000004N' LINE
                  , '80110300010211'         REF
                  , '0004'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000126010000004J' LINE
                  , '80110300012601'         REF
                  , '0004'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000518010000002J' LINE
                  , '80110300051801'         REF
                  , '0002'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000534020000007N' LINE
                  , '80110300053402'         REF
                  , '0007'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000668080000000J' LINE
                  , '80110300066808'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801105000152010000005J' LINE
                  , '80110500015201'         REF
                  , '0005'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000794790000007J' LINE
                  , '80110200079479'         REF
                  , '0007'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000102120000002J' LINE
                  , '80110300010212'         REF
                  , '0002'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000364100000002N' LINE
                  , '80110300036410'         REF
                  , '0002'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000574090000006J' LINE
                  , '80110400057409'         REF
                  , '0006'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801203000778730000025N' LINE
                  , '80120300077873'         REF
                  , '0025'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000574090000006J' LINE
                  , '80110400057409'         REF
                  , '0006'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801202000368080000072J' LINE
                  , '80120200036808'         REF
                  , '0072'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000800150000004N' LINE
                  , '80110300080015'         REF
                  , '0004'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801107000352020000005J' LINE
                  , '80110700035202'         REF
                  , '0005'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000796960000006N' LINE
                  , '80110200079696'         REF
                  , '0006'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000078470000008N' LINE
                  , '80110400007847'         REF
                  , '0008'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000794920000000J' LINE
                  , '80110200079492'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000800260000003J' LINE
                  , '80110200080026'         REF
                  , '0003'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801105000428020000007N' LINE
                  , '80110500042802'         REF
                  , '0007'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000088020000004N' LINE
                  , '80110300008802'         REF
                  , '0004'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801105000078020000000J' LINE
                  , '80110500007802'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801204000078020000027J' LINE
                  , '80120400007802'         REF
                  , '0027'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000790380000001N' LINE
                  , '80110200079038'         REF
                  , '0001'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000790850000002J' LINE
                  , '80110200079085'         REF
                  , '0002'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000790460000004N' LINE
                  , '80110200079046'         REF
                  , '0004'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000790550000005J' LINE
                  , '80110200079055'         REF
                  , '0005'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000800250000005J' LINE
                  , '80110200080025'         REF
                  , '0005'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000288010000000J' LINE
                  , '80110400028801'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000774340000000N' LINE
                  , '80110400077434'         REF
                  , '0000'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801107000328050000008N' LINE
                  , '80110700032805'         REF
                  , '0008'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000794870000000N' LINE
                  , '80110200079487'         REF
                  , '0000'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000352040000000J' LINE
                  , '80110300035204'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000356060000006J' LINE
                  , '80110300035606'         REF
                  , '0006'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801105000356060000001J' LINE
                  , '80110500035606'         REF
                  , '0001'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000356100000008N' LINE
                  , '80110300035610'         REF
                  , '0008'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801202000368080000072J' LINE
                  , '80120200036808'         REF
                  , '0072'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801101000266010000002N' LINE
                  , '80110100026601'         REF
                  , '0002'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000186040000002J' LINE
                  , '80110300018604'         REF
                  , '0002'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000678030000008N' LINE
                  , '80110400067803'         REF
                  , '0008'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000300040000001J' LINE
                  , '80110200030004'         REF
                  , '0001'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801107000792110000003J' LINE
                  , '80110700079211'         REF
                  , '0003'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000794790000007J' LINE
                  , '80110200079479'         REF
                  , '0007'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000288010000000J' LINE
                  , '80110400028801'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000794790000003J' LINE
                  , '80110400079479'         REF
                  , '0003'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000766080000004J' LINE
                  , '80110200076608'         REF
                  , '0004'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000794830000009J' LINE
                  , '80110200079483'         REF
                  , '0009'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000622010000000J' LINE
                  , '80110400062201'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000798110000007J' LINE
                  , '80110400079811'         REF
                  , '0007'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000622010000002N' LINE
                  , '80110300062201'         REF
                  , '0002'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000772460000000N' LINE
                  , '80110300077246'         REF
                  , '0000'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000790180000001N' LINE
                  , '80110300079018'         REF
                  , '0001'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000766080000000J' LINE
                  , '80110400076608'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000722070000009N' LINE
                  , '80110200072207'         REF
                  , '0009'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000644100000007J' LINE
                  , '80110300064410'         REF
                  , '0007'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000644100000005J' LINE
                  , '80110400064410'         REF
                  , '0005'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801105000428020000007J' LINE
                  , '80110500042802'         REF
                  , '0007'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801203000766040000041N' LINE
                  , '80120300076604'         REF
                  , '0041'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000780420000000N' LINE
                  , '80110400078042'         REF
                  , '0000'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801106000428020000005N' LINE
                  , '80110600042802'         REF
                  , '0005'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000790400000007J' LINE
                  , '80110200079040'         REF
                  , '0007'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000796510000001J' LINE
                  , '80110200079651'         REF
                  , '0001'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000374110000009J' LINE
                  , '80110300037411'         REF
                  , '0009'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000790420000001J' LINE
                  , '80110300079042'         REF
                  , '0001'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000374110000007N' LINE
                  , '80110400037411'         REF
                  , '0007'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000356080000000N' LINE
                  , '80110400035608'         REF
                  , '0000'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801101000302020000003J' LINE
                  , '80110100030202'         REF
                  , '0003'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801101000588090000002N' LINE
                  , '80110100058809'         REF
                  , '0002'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000136040000009J' LINE
                  , '80110200013604'         REF
                  , '0009'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000250030000000J' LINE
                  , '80110200025003'         REF
                  , '0000'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000384100000000N' LINE
                  , '80110300038410'         REF
                  , '0000'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000774330000004N' LINE
                  , '80110300077433'         REF
                  , '0004'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801101000272030000006J' LINE
                  , '80110100027203'         REF
                  , '0006'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000778750000004N' LINE
                  , '80110400077875'         REF
                  , '0004'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000792140000006J' LINE
                  , '80110300079214'         REF
                  , '0006'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801102000806250000002J' LINE
                  , '80110200080625'         REF
                  , '0002'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000778090000005J' LINE
                  , '80110300077809'         REF
                  , '0005'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000740030000006J' LINE
                  , '80110400074003'         REF
                  , '0006'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000078180000001N' LINE
                  , '80110300007818'         REF
                  , '0001'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801103000800150000004J' LINE
                  , '80110300080015'         REF
                  , '0004'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000368080000005J' LINE
                  , '80110400036808'         REF
                  , '0005'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801105000800150000009N' LINE
                  , '80110500080015'         REF
                  , '0009'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801202000797250000019N' LINE
                  , '80120200079725'         REF
                  , '0019'                   SUB_REF
                  , 'N'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801101000382100000008J' LINE
                  , '80110100038210'         REF
                  , '0008'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801101000800200000008J' LINE
                  , '80110100080020'         REF
                  , '0008'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000258060000002J' LINE
                  , '80110400025806'         REF
                  , '0002'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801202000795140000017J' LINE
                  , '80120200079514'         REF
                  , '0017'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual
                UNION ALL
                SELECT
                    '801104000328080000009J' LINE
                  , '80110400032808'         REF
                  , '0009'                   SUB_REF
                  , 'J'                      CODE
                FROM
                    dual ) t1
        LEFT JOIN
            PAYMENT_AGREEMENTS pa
        ON
            pa.REF = t1.REF
        LEFT JOIN
            PAYMENT_ACCOUNTS pac
        ON
            pac.ACTIVE_AGR_CENTER = pa.CENTER
            AND pac.ACTIVE_AGR_ID = pa.ID
            AND pac.ACTIVE_AGR_SUBID = pa.SUBID
        LEFT JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CENTER = pa.CENTER
            AND ar.id = pa.ID
        LEFT JOIN
            CLEARINGHOUSES ch
        ON
            ch.ID = pa.CLEARINGHOUSE
        LEFT JOIN
            CLEARINGHOUSE_CREDITORS chc
        ON
            chc.CLEARINGHOUSE = ch.ID
            AND chc.CREDITOR_ID = pa.CREDITOR_ID )