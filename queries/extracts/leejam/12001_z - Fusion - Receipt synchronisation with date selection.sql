-- The extract is extracted from Exerp on 2026-02-08
-- EC-7672 - New fusion report
SELECT
        t."BusinessUnitName"
        ,t."ReceiptMethodName"
        ,t."ReceiptNumber"
        ,t.crt_type
        ,t.ReceiptDate
        ,t.GlDate                                                           
        ,t."Amount"
        ,t."CustomerName"                        
        ,t."CustomerAccountNumber"
        ,t."CurrencyCode"
        ,t."Club Number"
        ,t."Exerp Invoice ID"
        ,t."Payment Source"
        --,t.a
FROM
(
SELECT DISTINCT --Note for Paytabs: PTB used for UAE clubs and PTS used for KSA clubs
                t1."BusinessUnitName"
                ,CASE
                        WHEN t1.gl_account = '11120104' THEN 'BSF BILAL NASIR.CARD.RECEIPT'
                        WHEN t1.gl_account = '11120099' THEN 'BSF ESAM EJLAN.CARD.RECEIPT'
                        WHEN t1.gl_account = '11120102' THEN 'BSF HAITHAM GHURBA.CARD.RECEIP'
                        WHEN t1.gl_account = '11120106' THEN 'BSF MEHMOOD.CASH.RECEIPT'
                        WHEN t1.gl_account = '11120103' THEN 'BSF RIYAD SENO.CARD.RECEIPT'
                        WHEN t1.gl_account = '11120108' THEN 'BSF YAHYA.CARD.RECEIPT'
                        WHEN t1.gl_account = '11120101' THEN 'BSF YOUSEF TURKISTANI.CARD.REC'
                        WHEN t1.gl_account = '11120113' THEN 'BT.BSF-BASSAM RAMZAN'
                        WHEN t1.gl_account = '11120111' THEN 'BT.BSF-HADI TURKMANI'
                        WHEN t1.gl_account = '11120110' THEN 'BT.BSF-HANI SHUMS'
                        WHEN t1.gl_account = '11120100' THEN 'CARD.BSF - AHMED ALAWI'
                        WHEN t1.gl_account = '11120300' THEN 'CARD.BSF.Abdullah Bakshab'
                        WHEN t1.gl_account = '11120295' THEN 'CASH.BSF.SABIC RETIREE'
                        WHEN t1.gl_account = '11120001' THEN 'KSA_BANK_TRANSFER-NCB104'
                        WHEN t1.gl_account = '11120123' THEN 'KSA_BANK_TRANSFER-NCB2107'
                        WHEN t1.gl_account = '11120152' THEN 'KSA_BANK_TRANSFER-SABB'
                        WHEN t1.gl_account = '11120301' THEN 'ONLINE.Madina Sharq FTL'
                        WHEN (
                                (
                                t1.gl_account IS NULL 
                                OR 
                                t1.gl_account NOT IN ('11120104','11120099','11120102','11120106','11120103','11120108','11120101','11120113','11120111','11120110','11120100','11120300','11120295','11120001','11120123','11120152','11120301')
                                ) 
                                AND 
                                (
                                t1.crt_type IS NULL 
                                OR 
                                t1.crt_type = 0
                                ) 
                                AND 
                                (
                                t1.crt_center IS NULL 
                                OR 
                                t1.crt_center = 0
                                ) 
                                AND 
                                t1.coment IS NULL) THEN 
                                        CASE 
                                                --UAE clubs
                                                WHEN (t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') AND t1.inv_center = 111001 THEN 'ONLINE.MAMZAR FT'
                                                WHEN (t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') AND t1.inv_center = 111004 THEN 'ONLINE.MAMZAR LD'
                                                WHEN (t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') AND t1.inv_center = 112001 THEN 'ONLINE.NAEEMMALL PRO'
                                                WHEN (t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') AND t1.inv_center = 112002 THEN 'ONLINE.NAEEMMALL LD'
                                                WHEN (t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') AND t1.inv_center = 113001 THEN 'ONLINE.RASHIDIYA PRO'
                                                WHEN (t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') AND t1.inv_center = 113002 THEN 'ONLINE.AJMAN FT LD'
                                                WHEN (t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') AND t1.inv_center = 114001 THEN 'ONLINE.HAZZANA GT'
                                                WHEN (t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') AND t1.inv_center = 114002 THEN 'ONLINE.HAZZANA LD'
                                                WHEN (t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') AND t1.inv_center = 101 THEN 'ONLINE.BSF'
                                                --KSA clubs
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101 THEN 'ONLINE.BSF'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101101 THEN 'ONLINE.BAKHASHAB FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101102 THEN 'ONLINE.SAFA FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101103 THEN 'ONLINE.NADA FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101105 THEN 'ONLINE.Masarrah PLUS'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101106 THEN 'ONLINE.Gharnata FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101107 THEN 'ONLINE.GHARNATA JR'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101108 THEN 'ONLINE.AZIZIA JEDDAH PRO 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101109 THEN 'ONLINE.ANDALUS FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101110 THEN 'ONLINE.SABEEN FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101111 THEN 'ONLINE.NAEEM FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101112 THEN 'ONLINE.OBHUR FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101114 THEN 'ONLINE.SALAMA PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101116 THEN 'ONLINE.ARBEEN FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101118 THEN 'ONLINE.BASATEEN FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101119 THEN 'ONLINE.NAJRAN PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101121 THEN 'ONLINE.SKAKA PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101122 THEN 'ONLINE.PALESTINE PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101123 THEN 'ONLINE.Samer PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101125 THEN 'ONLINE.TAIBA PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101127 THEN 'ONLINE.Jizan PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101128 THEN 'ONLINE.BAHA PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101130 THEN 'ONLINE.KILO14 PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101133 THEN 'ONLINE.KING ROAD LD FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101134 THEN 'ONLINE.FAWZ FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101135 THEN 'ONLINE.FAWZ FT LD'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101136 THEN 'ONLINE.SAMER LADIES'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101137 THEN 'ONLINE.HAMDANIAH LADIES'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101138 THEN 'ONLINE.PALESTINE LADIES'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101139 THEN 'ONLINE.ARBEIN LADIES'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101140 THEN 'ONLINE.SALAMA LD FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101141 THEN 'ONLINE.MACARONA LD FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101142 THEN 'ONLINE.KING ROAD FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101144 THEN 'ONLINE. Jed Az Xpress'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101145 THEN 'ONLINE Garnata Ladies Xpress'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101146 THEN 'ONLINE.Najran  XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101201 THEN 'ONLINE.TAIF PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101202 THEN 'ONLINE.SHEHAR FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101203 THEN 'ONLINE.GHAZALI PRO 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101301 THEN 'ONLINE.TABOUK PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101302 THEN 'ONLINE.MUROOJ FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101303 THEN 'ONLINE.MUROOJ LADIES FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101401 THEN 'ONLINE.KHAMEES MUSHAIT PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101402 THEN 'ONLINE.Mazaab FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101501 THEN 'ONLINE.MADINA RING ROAD'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101502 THEN 'ONLINE.MADINA AZIZIA PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101503 THEN 'ONLINE.Madina Az LD PRO 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101504 THEN 'ONLINE.Khalida LD FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101505 THEN 'ONLINE.SHARQ FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101506 THEN 'ONLINE.SHARQ JR'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101507 THEN 'ONLINE.SHARQ PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101508 THEN 'ONLINE .Sharq Xpress'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101509 THEN 'ONLINE Aziziah Med M Xpress'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101510 THEN 'ONLINE.Madina Sharq FTL'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101601 THEN 'ONLINE.MECCA RING ROAD'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101602 THEN 'ONLINE.MECCA SHARAE'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101603 THEN 'ONLINE.MECCA OMRA'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101605 THEN 'ONLINE.Fayha.FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101606 THEN 'ONLINE.WALI ALAHAD PRO 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101607 THEN 'ONLINE.AWALY FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101609 THEN 'ONLINE.AWALY PLUS'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101611 THEN 'ONLINE.FAYHA LADIES'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101612 THEN 'ONLINE.Aawali LD FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101613 THEN 'ONLINE Wali Alahad Xpress'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101701 THEN 'ONLINE.WATER FRONT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101702 THEN 'ONLINE.WATER FRONT LADIES'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101801 THEN 'ONLINE.ABHA FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102101 THEN 'ONLINE.Shafie FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102102 THEN 'SABB.ONLINE.GHADEER FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102103 THEN 'ONLINE.Ishbilia FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102104 THEN 'ONLINE.Rawabi FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102105 THEN 'ONLINE.Swedi FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102106 THEN 'ONLINE.Rabwa FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102107 THEN 'ONLINE.Mansorah PRO 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102108 THEN 'ONLINE.Shefa.PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102109 THEN 'ONLINE.Shobra PRO 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102110 THEN 'ONLINE.Taawon FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102111 THEN 'ONLINE.Nakheel FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102113 THEN 'ONLINE.Buraidah Muntazah PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102114 THEN 'ONLINE.King Abdulaziz FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102115 THEN 'ONLINE.SABB KHARJ PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102116 THEN 'ONLINE.Qadasiya PRO 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102117 THEN 'ONLINE.Sahafa PRO 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102119 THEN 'ONLINE.Ghadeer PLUS'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102120 THEN 'ONLINE.Wadi PRO 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102121 THEN 'ONLINE.Badea FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102125 THEN 'ONLINE.Badea 2 PRO 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102126 THEN 'ONLINE.RYD Azizia PRO 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102127 THEN 'ONLINE.Hitten.FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102128 THEN 'ONLINE.King Faisal FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102129 THEN 'ONLINE.Yasmeen FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102131 THEN 'ONLINE.Waha FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102132 THEN 'ONLINE.Olaya View FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102133 THEN 'ONLINE.Nada FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102134 THEN 'ONLINE.Khaleej PRO 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102136 THEN 'ONLINE.Western RR FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102138 THEN 'ONLINE.Jawdah School JR'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102139 THEN 'ONLINE.Laban PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102140 THEN 'ONLINE.Moansiah FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102141 THEN 'ONLINE.Naseem PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102144 THEN 'ONLINE.SABB NADWA PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102145 THEN 'ONLINE.RYD KHOZAMA FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102147 THEN 'ONLINE.Shabab FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102150 THEN 'ONLINE.SABB AZIZIA LADIES PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102153 THEN 'ONLINE.Unaizah.FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102154 THEN 'ONLINE.BSF NAFEL LADIES FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102155 THEN 'ONLINE.SABB KHALEEJ PROLADIES'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102156 THEN 'ONLINE.SABB ORAJIA LADIES'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102158 THEN 'ONLINE.Aqeeq LD FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102159 THEN 'ONLINE.SABB MALGALADIES FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102161 THEN 'ONLINE.HAMRA FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102163 THEN 'ONLINE.FALAH LD'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102165 THEN 'ONLINE.NUZHA FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102167 THEN 'ONLINE.RAHMANIA FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102172 THEN 'ONLINE.KHALEEJ LD FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102173 THEN 'ONLINE.MOANSIAH LADIES'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102175 THEN 'ONLINE.BADEA LADIES FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102176 THEN 'ONLINE.PNU LADIES'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102177 THEN 'ONLINE.Yasmeen Ladies'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102178 THEN 'ONLINE.RIYADH KHOZAMA LADIES'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102179 THEN 'ONLINE.YARMOUK LD FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102182 THEN 'ONLINE. AHSA XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102183 THEN 'ONLINE Buraida Muntaza LD Xpr'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102184 THEN 'ONLINE.Tuwaiq  LD XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102185 THEN 'ONLINE.Tuwaiq Xp'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102186 THEN 'ONLINE.Marwah LD XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102187 THEN 'ONLINE.NASEM GHR XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102188 THEN 'ONLINE.AZIZIZ XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102189 THEN 'ONLINE.NASEM SHA XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102190 THEN 'ONLINE.NASEM LD XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102191 THEN 'ONLINE.MURJ XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102193 THEN 'ONLINE.KHARJ XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102194 THEN 'ONLINE.KHARJ XP LD'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102195 THEN 'ONLINE.RIMAL XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102196 THEN 'ONLINE.QURTBAH XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102198 THEN 'ONLINE.Al Shifa Bader  XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102201 THEN 'ONLINE.HAIL PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102204 THEN 'ONLINE.Khamashia XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102205 THEN 'ONLINE.NUQRH XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102206 THEN 'ONLINE.NUQRH LD XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102303 THEN 'ONLINE.EASTERN RR Pro 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102401 THEN 'ONLINE.DAWADMI PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102402 THEN 'ONLINE Dawadmi Ladies FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102403 THEN 'ONLINE Dawadmi Male Xpress'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102501 THEN 'ONLINE.Arar.PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102601 THEN 'ONLINE.Al Quds RiyadhXP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102602 THEN 'ONLINE.Uqadh Riyadh XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102608 THEN 'ONLINE.Aqeeq PLUS'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103101 THEN 'ONLINE.FAISALIAH FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103102 THEN 'ONLINE.SAIHAT PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103103 THEN 'ONLINE.GOLDEN BELT FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103104 THEN 'ONLINE.NOOR PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103105 THEN 'ONLINE.OLAYA KHOBAR FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103107 THEN 'Online.OLAYA-PLUS'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103108 THEN 'ONLINE.KHOZAMA KHBR FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103112 THEN 'ONLINE.KHBR KHOZ LADIES'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103113 THEN 'ONLINE.OLAYA LD PLUS'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103201 THEN 'ONLINE.HAFAR AL BATIN'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103301 THEN 'ONLINE.CORNICHE FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103304 THEN 'ONLINE.Montazah.FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103306 THEN 'ONLINE.Golden Belt LD FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103307 THEN 'ONLINE.ZOHOUR LADIES FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103308 THEN 'ONLINE.SABB JAMAEIN  LD FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103310 THEN 'ONLINE.Ashulah XP'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103401 THEN 'ONLINE.Ahsa.PRO'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103405 THEN 'ONLINE.AHSA LADIES'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103501 THEN 'ONLINE.JALMUDAH FT 16+'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103502 THEN 'ONLINE.JALMUDAH JR'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103503 THEN 'ONLINE.FIRDAWS FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103504 THEN 'ONLINE.JALMUDAH LADIES'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 210001 THEN 'ONLINE.SABB.Corp Sales -Cash'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102606 THEN 'Online. Irqah Male FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103407 THEN 'Online. Ahsa Mubarraz FTL'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103406 THEN 'Online.JAZERA. Ahsa Mubarraz Male'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103309 THEN 'ONLINE.Sadaf Khobar Xpress '
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102625 THEN 'ONLINE.Ishbilia Xpress'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101614 THEN 'ONLINE.Al Salehiyah FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101615 THEN 'ONLINE.Al Salehiyah ladies FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103408 THEN 'BSF Online Sales.Ahsa L FT'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102638 THEN 'ONLINE.Kharj Xpress male'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102640 THEN 'ONLINE.Qyrawan Xpress male'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 102642 THEN 'ONLINE.RABWA Xpress male'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 103507 THEN 'ONLINE.Jr ac / Jalmudah'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101150 THEN 'ONLINE.Al Asalah Xpress'
                                                WHEN (t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') AND t1.inv_center = 101132 THEN 'ONLINE.Naseem FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101101 THEN 'ONLINE TAMARA Bakhashab FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101102 THEN 'ONLINE TAMARA Safa FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101103 THEN 'ONLINE TAMARA Nahda FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101105 THEN 'ONLINE TAMARA Masarrah PLUS'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101106 THEN 'ONLINE TAMARA Gharnata FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101109 THEN 'ONLINE TAMARA Andalus FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101110 THEN 'ONLINE TAMARA Sabeen FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101111 THEN 'ONLINE TAMARA Naeem FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101112 THEN 'ONLINE TAMARA Obhur FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101114 THEN 'ONLINE TAMARA Salama PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101116 THEN 'ONLINE TAMARA Arbein FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101118 THEN 'ONLINE TAMARA Basateen FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101119 THEN 'ONLINE TAMARA Najran PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101121 THEN 'ONLINE TAMARA Skaka PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101122 THEN 'ONLINE TAMARA Palestine PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101123 THEN 'ONLINE TAMARA Samer PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101125 THEN 'ONLINE TAMARA Taiba PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101127 THEN 'ONLINE TAMARA Jizan PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101128 THEN 'ONLINE TAMARA Baha PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101130 THEN 'ONLINE TAMARA Kilo14 PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101133 THEN 'ONLINE TAMARA King Rd LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101134 THEN 'ONLINE TAMARA Pr Fawaz FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101135 THEN 'ONLINE TAMARA Pr Fawz LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101136 THEN 'ONLINE TAMARA Samer LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101137 THEN 'ONLINE TAMARA Hmdniah LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101138 THEN 'ONLINE TAMARA Palstne LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101139 THEN 'ONLINE TAMARA Arbein LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101140 THEN 'ONLINE TAMARA Salama LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101141 THEN 'ONLINE TAMARA Macrona LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101142 THEN 'ONLINE TAMARA King Road FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101144 THEN 'ONLINE TAMARA Jed Az Xpress'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101145 THEN 'ONLINE TAMARA Gnt LD Xpress'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101146 THEN 'ONLINE TAMARA Najran  XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101201 THEN 'ONLINE TAMARA Taif PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101202 THEN 'ONLINE TAMARA Shehar FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101302 THEN 'ONLINE TAMARA Murooj FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101303 THEN 'ONLINE TAMARA Murooj LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101401 THEN 'ONLINE TAMARA Khamis PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101402 THEN 'ONLINE TAMARA Maazab FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101501 THEN 'ONLINE TAMARA Madina RR FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101502 THEN 'ONLINE TAMARA Madina Az PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101504 THEN 'ONLINE TAMARA Khalida LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101505 THEN 'ONLINE TAMARA Sharq FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101508 THEN 'ONLINE TAMARA Sharq Xpress'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101509 THEN 'ONLINE TAMARA Mdn Az Xpress'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101510 THEN 'ONLINE TAMARA Madina Sharq FTL'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101601 THEN 'ONLINE TAMARA Mecca RR FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101602 THEN 'ONLINE TAMARA Sharaei PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101603 THEN 'ONLINE TAMARA Omra PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101605 THEN 'ONLINE TAMARA Fayha FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101607 THEN 'ONLINE TAMARA Awaly FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101611 THEN 'ONLINE TAMARA Fayha LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101612 THEN 'ONLINE TAMARA Awaly LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101613 THEN 'ONLINE TAMARA W Ahad Xpress'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101701 THEN 'ONLINE TAMARA Waterfront FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101702 THEN 'ONLINE TAMARA W front LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101801 THEN 'ONLINE TAMARA Abha FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102101 THEN 'ONLINE TAMARA Shafie FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102102 THEN 'ONLINE TAMARA Ghadeer FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102103 THEN 'ONLINE TAMARA Ishbilia FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102104 THEN 'ONLINE TAMARA Rawabi FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102105 THEN 'ONLINE TAMARA Swedi FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102106 THEN 'ONLINE TAMARA Rabwa FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102107 THEN 'ONLINE TAMARA Mansorah PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102108 THEN 'ONLINE TAMARA Shefa PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102109 THEN 'ONLINE TAMARA Shobra PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102110 THEN 'ONLINE TAMARA Taawon FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102111 THEN 'ONLINE TAMARA Nakheel FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102113 THEN 'ONLINE TAMARA Buraidh M PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102115 THEN 'ONLINE TAMARA Kharj PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102116 THEN 'ONLINE TAMARA Qadasiya PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102117 THEN 'ONLINE TAMARA Sahafa PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102119 THEN 'ONLINE TAMARA Ghadeer PLUS'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102120 THEN 'ONLINE TAMARA Wadi PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102121 THEN 'ONLINE TAMARA Badea FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102125 THEN 'ONLINE TAMARA Badea 2 PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102126 THEN 'ONLINE TAMARA Riyadh Az PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102127 THEN 'ONLINE TAMARA Hitten FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102128 THEN 'ONLINE TAMARA K Faisal FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102129 THEN 'ONLINE TAMARA Yasmeen FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102131 THEN 'ONLINE TAMARA Waha FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102132 THEN 'ONLINE TAMARA Olaya View FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102133 THEN 'ONLINE TAMARA Nada FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102134 THEN 'ONLINE TAMARA Khaleej PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102136 THEN 'ONLINE TAMARA Western RR FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102139 THEN 'ONLINE TAMARA Laban PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102140 THEN 'ONLINE TAMARA Moansiah FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102141 THEN 'ONLINE TAMARA Naseem PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102144 THEN 'ONLINE TAMARA Nadwa PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102145 THEN 'ONLINE TAMARA Riyadh Kzm FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102150 THEN 'ONLINE TAMARA RydAz LD PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102153 THEN 'ONLINE TAMARA Unaizah FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102154 THEN 'ONLINE TAMARA Nafel LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102155 THEN 'ONLINE TAMARA Khalij LD PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102156 THEN 'ONLINE TAMARA Oraija LD PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102159 THEN 'ONLINE TAMARA Malga LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102161 THEN 'ONLINE TAMARA Hamra LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102163 THEN 'ONLINE TAMARA Falah LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102165 THEN 'ONLINE TAMARA Nuzha LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102167 THEN 'ONLINE TAMARA Rahmnia LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102172 THEN 'ONLINE TAMARA Khaleej LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102173 THEN 'ONLINE TAMARA Monsiah LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102175 THEN 'ONLINE TAMARA Badea LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102177 THEN 'ONLINE TAMARA Yasmeen LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102178 THEN 'ONLINE TAMARA Ryd Kzm LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102179 THEN 'ONLINE TAMARA Yarmouk LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102182 THEN 'ONLINE TAMARA AHSA XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102183 THEN 'ONLINE TAMARA Brd LD Xpress'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102184 THEN 'ONLINE TAMARA Tuwaiq  LD XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102185 THEN 'ONLINE TAMARA Tuwaiq Xp'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102186 THEN 'ONLINE TAMARA Marwah LD XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102187 THEN 'ONLINE TAMARA NASEM GHR XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102188 THEN 'ONLINE TAMARA AZIZIZ XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102189 THEN 'ONLINE TAMARA NASEM SHA XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102190 THEN 'ONLINE TAMARA NASEM LD XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102191 THEN 'ONLINE TAMARA MURJ XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102193 THEN 'ONLINE TAMARA KHARJ XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102194 THEN 'ONLINE TAMARA KHARJ XP LD'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102195 THEN 'ONLINE TAMARA RIMAL XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102196 THEN 'ONLINE TAMARA QURTBAH XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102198 THEN 'ONLINE TAMARA Al Shifa Bader'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102204 THEN 'ONLINE TAMARA Khamashia XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102205 THEN 'ONLINE TAMARA NUQRH XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102206 THEN 'ONLINE TAMARA NUQRH LD XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102303 THEN 'ONLINE TAMARA Eastrn RR Pro'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102402 THEN 'ONLINE TAMARA Dawadmi L FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102403 THEN 'ONLINE TAMARA Dawdmi Xpress'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102501 THEN 'ONLINE TAMARA Arar PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102601 THEN 'ONLINE TAMARA Al Quds RiyadhXP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102602 THEN 'ONLINE TAMARA Uqadh Riyadh XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102608 THEN 'ONLINE TAMARA Aqiq +'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103101 THEN 'ONLINE TAMARA Faisaliah FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103102 THEN 'ONLINE TAMARA Sihat PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103103 THEN 'ONLINE TAMARA GoldenBelt FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103104 THEN 'ONLINE TAMARA Noor PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103105 THEN 'ONLINE TAMARA Olaya FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103107 THEN 'ONLINE TAMARA OLAYA PLUS'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103108 THEN 'ONLINE TAMARA Khobar Kzm FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103112 THEN 'ONLINE TAMARA Khb Kzm LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103201 THEN 'ONLINE TAMARA Hafar PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103301 THEN 'ONLINE TAMARA Corniche FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103304 THEN 'ONLINE TAMARA Montazah FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103306 THEN 'ONLINE TAMARA Gld Blt LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103307 THEN 'ONLINE TAMARA Zohoor LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103308 THEN 'ONLINE TAMARA Jamaeen LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103310 THEN 'ONLINE TAMARA Ashulah XP'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103401 THEN 'ONLINE TAMARA Ahsa PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103405 THEN 'ONLINE TAMARA Ahsa LD Pro'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103501 THEN 'ONLINE TAMARA Jalmudah FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103503 THEN 'ONLINE TAMARA Firdaws FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103504 THEN 'ONLINE TAMARA Jalmudh LD FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 111001 THEN 'ONLINE TAMARA Mamzar FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 111004 THEN 'ONLINE TAMARA Mamzar L FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 112001 THEN 'ONLINE TAMARA Naeem M PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 112002 THEN 'ONLINE TAMARA Naeem L PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 113001 THEN 'ONLINE TAMARA Rash 2. PRO'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 114001 THEN 'ONLINE TAMARA Hazzana FT '
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 114002 THEN 'ONLINE TAMARA Hazzana L FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102606 THEN 'ONLINE TAMARA Iqrah FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103407 THEN 'ONLINE TAMARA Ahsa Mubarraz FTL'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103406 THEN 'ONLINE TAMARA Ahsa Mubarraz FT Male'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 113002 THEN 'ONLINE TAMARA AJMAN FT LD'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103408 THEN 'ONLINE TAMARA Ahsa L FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103309 THEN 'ONLINE TAMARA.Sadaf Khobar Xpress '
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102625 THEN 'ONLINE TAMARA.Ishbilia Xpress'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101614 THEN 'ONLINE TAMARA.Al Salehiyah FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101615 THEN 'ONLINE TAMARA.Al Salehiyah ladies FT'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102638 THEN 'ONLINE TAMARA.Kharj Xpress male'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102640 THEN 'ONLINE TAMARA.Qyrawan Xpress male'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 102642 THEN 'ONLINE TAMARA.RABWA Xpress male'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 103507 THEN 'ONLINE TAMARA.Jr ac / Jalmudah'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101150 THEN 'ONLINE TAMARA.Al Asalah Xpress'
                                                WHEN ((length(t1.art_info) = 11 AND t1.art_info LIKE '14%') OR (t1.art_info ~ '^TM[0-9]+') OR (t1.art_info LIKE 'TM-%')) AND t1.inv_center = 101132 THEN 'ONLINE TAMARA.Naseem FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101101 THEN 'ONLINE TABBY Bakhashab FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101102 THEN 'ONLINE TABBY Safa FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101103 THEN 'ONLINE TABBY Nahda FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101105 THEN 'ONLINE TABBY Masarrah PLUS'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101106 THEN 'ONLINE TABBY Gharnata FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101109 THEN 'ONLINE TABBY Andalus FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101110 THEN 'ONLINE TABBY Sabeen FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101111 THEN 'ONLINE TABBY Naeem FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101112 THEN 'ONLINE TABBY Obhur FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101114 THEN 'ONLINE TABBY Salama PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101116 THEN 'ONLINE TABBY Arbein FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101118 THEN 'ONLINE TABBY Basateen FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101119 THEN 'ONLINE TABBY Najran PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101121 THEN 'ONLINE TABBY Skaka PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101122 THEN 'ONLINE TABBY Palestine PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101123 THEN 'ONLINE TABBY Samer PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101125 THEN 'ONLINE TABBY Taiba PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101127 THEN 'ONLINE TABBY Jizan PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101128 THEN 'ONLINE TABBY Baha PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101130 THEN 'ONLINE TABBY Kilo14 PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101133 THEN 'ONLINE TABBY King Rd LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101134 THEN 'ONLINE TABBY Pr Fawaz FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101135 THEN 'ONLINE TABBY Pr Fawz LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101136 THEN 'ONLINE TABBY Samer LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101137 THEN 'ONLINE TABBY Hmdniah LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101138 THEN 'ONLINE TABBY Palstne LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101139 THEN 'ONLINE TABBY Arbein LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101140 THEN 'ONLINE TABBY Salama LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101141 THEN 'ONLINE TABBY Macrona LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101142 THEN 'ONLINE TABBY King Road FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101144 THEN 'ONLINE TABBY Jed Az Xpress'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101145 THEN 'ONLINE TABBY Gnt LD Xpress'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101146 THEN 'ONLINE TABBY Najran  XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101201 THEN 'ONLINE TABBY Taif PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101202 THEN 'ONLINE TABBY Shehar FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101302 THEN 'ONLINE TABBY Murooj FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101303 THEN 'ONLINE TABBY Murooj LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101401 THEN 'ONLINE TABBY Khamis PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101402 THEN 'ONLINE TABBY Maazab FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101501 THEN 'ONLINE TABBY Madina RR FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101502 THEN 'ONLINE TABBY Madina Az PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101504 THEN 'ONLINE TABBY Khalida LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101505 THEN 'ONLINE TABBY Sharq FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101508 THEN 'ONLINE TABBY Sharq Xpress'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101509 THEN 'ONLINE TABBY Mdn Az Xpress'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101510 THEN 'ONLINE TABBY Madina Sharq FTL'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101601 THEN 'ONLINE TABBY Mecca RR FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101602 THEN 'ONLINE TABBY Sharaei PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101603 THEN 'ONLINE TABBY Omra PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101605 THEN 'ONLINE TABBY Fayha FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101607 THEN 'ONLINE TABBY Awaly FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101611 THEN 'ONLINE TABBY Fayha LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101612 THEN 'ONLINE TABBY Awaly LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101613 THEN 'ONLINE TABBY W Ahad Xpress'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101701 THEN 'ONLINE TABBY Waterfront FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101702 THEN 'ONLINE TABBY W front LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101801 THEN 'ONLINE TABBY Abha FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102101 THEN 'ONLINE TABBY Shafie FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102102 THEN 'ONLINE TABBY Ghadeer FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102103 THEN 'ONLINE TABBY Ishbilia FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102104 THEN 'ONLINE TABBY Rawabi FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102105 THEN 'ONLINE TABBY Swedi FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102106 THEN 'ONLINE TABBY Rabwa FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102107 THEN 'ONLINE TABBY Mansorah PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102108 THEN 'ONLINE TABBY Shefa PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102109 THEN 'ONLINE TABBY Shobra PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102110 THEN 'ONLINE TABBY Taawon FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102111 THEN 'ONLINE TABBY Nakheel FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102113 THEN 'ONLINE TABBY Buraidh M PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102115 THEN 'ONLINE TABBY Kharj PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102116 THEN 'ONLINE TABBY Qadasiya PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102117 THEN 'ONLINE TABBY Sahafa PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102119 THEN 'ONLINE TABBY Ghadeer PLUS'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102120 THEN 'ONLINE TABBY Wadi PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102121 THEN 'ONLINE TABBY Badea FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102125 THEN 'ONLINE TABBY Badea 2 PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102126 THEN 'ONLINE TABBY Riyadh Az PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102127 THEN 'ONLINE TABBY Hitten FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102128 THEN 'ONLINE TABBY K Faisal FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102129 THEN 'ONLINE TABBY Yasmeen FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102131 THEN 'ONLINE TABBY Waha FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102132 THEN 'ONLINE TABBY Olaya View FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102133 THEN 'ONLINE TABBY Nada FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102134 THEN 'ONLINE TABBY Khaleej PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102136 THEN 'ONLINE TABBY Western RR FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102139 THEN 'ONLINE TABBY Laban PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102140 THEN 'ONLINE TABBY Moansiah FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102141 THEN 'ONLINE TABBY Naseem PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102144 THEN 'ONLINE TABBY Nadwa PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102145 THEN 'ONLINE TABBY Riyadh Kzm FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102150 THEN 'ONLINE TABBY RydAz LD PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102153 THEN 'ONLINE TABBY Unaizah FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102154 THEN 'ONLINE TABBY Nafel LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102155 THEN 'ONLINE TABBY Khalij LD PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102156 THEN 'ONLINE TABBY Oraija LD PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102159 THEN 'ONLINE TABBY Malga LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102161 THEN 'ONLINE TABBY Hamra LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102163 THEN 'ONLINE TABBY Falah LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102165 THEN 'ONLINE TABBY Nuzha LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102167 THEN 'ONLINE TABBY Rahmnia LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102172 THEN 'ONLINE TABBY Khaleej LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102173 THEN 'ONLINE TABBY Monsiah LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102175 THEN 'ONLINE TABBY Badea LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102177 THEN 'ONLINE TABBY Yasmeen LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102178 THEN 'ONLINE TABBY Ryd Kzm LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102179 THEN 'ONLINE TABBY Yarmouk LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102182 THEN 'ONLINE TABBY AHSA XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102183 THEN 'ONLINE TABBY Brd LD Xpress'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102184 THEN 'ONLINE TABBY Tuwaiq  LD XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102185 THEN 'ONLINE TABBY Tuwaiq Xp'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102186 THEN 'ONLINE TABBY Marwah LD XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102187 THEN 'ONLINE TABBY NASEM GHR XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102188 THEN 'ONLINE TABBY AZIZIZ XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102189 THEN 'ONLINE TABBY NASEM SHA XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102190 THEN 'ONLINE TABBY NASEM LD XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102191 THEN 'ONLINE TABBY MURJ XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102193 THEN 'ONLINE TABBY KHARJ XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102194 THEN 'ONLINE TABBY KHARJ XP LD'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102195 THEN 'ONLINE TABBY RIMAL XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102196 THEN 'ONLINE TABBY QURTBAH XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102198 THEN 'ONLINE TABBY Al Shifa Bader'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102204 THEN 'ONLINE TABBY Khamashia XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102205 THEN 'ONLINE TABBY NUQRH XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102206 THEN 'ONLINE TABBY NUQRH LD XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102303 THEN 'ONLINE TABBY Eastrn RR Pro'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102402 THEN 'ONLINE TABBY Dawadmi L FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102403 THEN 'ONLINE TABBY Dawdmi Xpress'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102501 THEN 'ONLINE TABBY Arar PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102601 THEN 'ONLINE TABBY Al Quds RiyadhXP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102602 THEN 'ONLINE TABBY Uqadh Riyadh XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102608 THEN 'ONLINE TABBY Aqiq +'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103101 THEN 'ONLINE TABBY Faisaliah FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103102 THEN 'ONLINE TABBY Sihat PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103103 THEN 'ONLINE TABBY GoldenBelt FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103104 THEN 'ONLINE TABBY Noor PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103105 THEN 'ONLINE TABBY Olaya FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103107 THEN 'ONLINE TABBY OLAYA PLUS'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103108 THEN 'ONLINE TABBY Khobar Kzm FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103112 THEN 'ONLINE TABBY Khb Kzm LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103201 THEN 'ONLINE TABBY Hafar PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103301 THEN 'ONLINE TABBY Corniche FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103304 THEN 'ONLINE TABBY Montazah FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103306 THEN 'ONLINE TABBY Gld Blt LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103307 THEN 'ONLINE TABBY Zohoor LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103308 THEN 'ONLINE TABBY Jamaeen LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103310 THEN 'ONLINE TABBY Ashulah XP'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103401 THEN 'ONLINE TABBY Ahsa PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103408 THEN 'ONLINE TABBY Al Ahsa Ladies FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103501 THEN 'ONLINE TABBY Jalmudah FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103503 THEN 'ONLINE TABBY Firdaws FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103504 THEN 'ONLINE TABBY Jalmudh LD FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 111001 THEN 'ONLINE TABBY Mamzar FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 111004 THEN 'ONLINE TABBY Mamzar L FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 112001 THEN 'ONLINE TABBY Naeem M PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 112002 THEN 'ONLINE TABBY Naeem L PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 113001 THEN 'ONLINE TABBY Rash 2. PRO'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 114001 THEN 'ONLINE TABBY Hazzana FT '
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 114002 THEN 'ONLINE TABBY Hazzana L FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102606 THEN 'ONLINE TABBY Iqrah FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103407 THEN 'ONLINE TABBY Ahsa Mubarraz FTL'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103406 THEN 'ONLINE TABBY Ahsa Mubarraz FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 113002 THEN 'ONLINE TABBY AJMAN FT LD'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103408 THEN 'ONLINE TABBY Al Ahsa Ladies FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103309 THEN 'ONLINE TABBY .Sadaf Khobar Xpress'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102625 THEN 'ONLINE TABBY.Ishbilia Xpress '
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101614 THEN 'ONLINE TABBY .Al Salehiyah FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101615 THEN 'ONLINE TABBY .Al Salehiyah ladies FT'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102638 THEN 'ONLINE TABBY.Kharj Xpress male'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102640 THEN 'ONLINE TABBY.Qyrawan Xpress male'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 102642 THEN 'ONLINE TABBY.RABWA Xpress male'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 103507 THEN 'ONLINE TABBY.Jr ac / Jalmudah'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101150 THEN 'ONLINE TABBY.Al Asalah Xpress'
                                                WHEN  t1.art_info LIKE 'TBY%' AND t1.inv_center = 101132 THEN 'ONLINE TABBY.Naseem FT'
                                                ELSE
                                                        CASE
                                                                WHEN t1.inv_center = 111001 THEN 'ONLINE SPOTII MAMZAR FT'
                                                                WHEN t1.inv_center = 111004 THEN 'ONLINE SPOTII MAMZAR LD'
                                                                WHEN t1.inv_center = 112001 THEN 'ONLINE SPOTII NAEEMMALL PRO'
                                                                WHEN t1.inv_center = 112002 THEN 'ONLINE SPOTII NAEEMMALL LD'
                                                                WHEN t1.inv_center = 113001 THEN 'ONLINE SPOTII RASHIDIYA PRO'
                                                                WHEN t1.inv_center = 114001 THEN 'ONLINE SPOTII HAZZANA GT'
                                                                WHEN t1.inv_center = 114002 THEN 'ONLINE SPOTII HAZZANA LD'
                                                                WHEN t1.inv_center = 100 THEN 'ONLINE.SPOTII BSF'
                                                                WHEN t1.inv_center = 101 THEN 'ONLINE SPOTII.BSF'
                                                                WHEN t1.inv_center = 101101 THEN 'ONLINE SPOTII Bakhashab FT'
                                                                WHEN t1.inv_center = 101102 THEN 'ONLINE SPOTII Safa FT'
                                                                WHEN t1.inv_center = 101103 THEN 'ONLINE SPOTII Nahda FT'
                                                                WHEN t1.inv_center = 101105 THEN 'ONLINE SPOTII Masarrah PLUS'
                                                                WHEN t1.inv_center = 101106 THEN 'ONLINE SPOTII Gharnata FT'
                                                                WHEN t1.inv_center = 101109 THEN 'ONLINE SPOTII Andalus FT'
                                                                WHEN t1.inv_center = 101110 THEN 'ONLINE SPOTII Sabeen FT'
                                                                WHEN t1.inv_center = 101111 THEN 'ONLINE SPOTII Naeem FT'
                                                                WHEN t1.inv_center = 101112 THEN 'ONLINE SPOTII Obhur FT'
                                                                WHEN t1.inv_center = 101114 THEN 'ONLINE SPOTII Salama PRO'
                                                                WHEN t1.inv_center = 101116 THEN 'ONLINE SPOTII Arbein FT'
                                                                WHEN t1.inv_center = 101118 THEN 'ONLINE SPOTII Basateen FT'
                                                                WHEN t1.inv_center = 101119 THEN 'ONLINE SPOTII Najran PRO'
                                                                WHEN t1.inv_center = 101121 THEN 'ONLINE SPOTII Skaka PRO'
                                                                WHEN t1.inv_center = 101122 THEN 'ONLINE SPOTII Palestine PRO'
                                                                WHEN t1.inv_center = 101123 THEN 'ONLINE SPOTII Samer PRO'
                                                                WHEN t1.inv_center = 101125 THEN 'ONLINE SPOTII Taiba PRO'
                                                                WHEN t1.inv_center = 101127 THEN 'ONLINE SPOTII Jizan PRO'
                                                                WHEN t1.inv_center = 101128 THEN 'ONLINE SPOTII Baha PRO'
                                                                WHEN t1.inv_center = 101130 THEN 'ONLINE SPOTII Kilo14 PRO'
                                                                WHEN t1.inv_center = 101133 THEN 'ONLINE SPOTII King Rd LD FT'
                                                                WHEN t1.inv_center = 101134 THEN 'ONLINE SPOTII Pr Fawaz FT'
                                                                WHEN t1.inv_center = 101135 THEN 'ONLINE SPOTII Pr Fawz LD FT'
                                                                WHEN t1.inv_center = 101136 THEN 'ONLINE SPOTII Samer LD FT'
                                                                WHEN t1.inv_center = 101137 THEN 'ONLINE SPOTII Hmdniah LD FT'
                                                                WHEN t1.inv_center = 101138 THEN 'ONLINE SPOTII Palstne LD FT'
                                                                WHEN t1.inv_center = 101139 THEN 'ONLINE SPOTII Arbein LD FT'
                                                                WHEN t1.inv_center = 101140 THEN 'ONLINE SPOTII Salama LD FT'
                                                                WHEN t1.inv_center = 101141 THEN 'ONLINE SPOTII Macrona LD FT'
                                                                WHEN t1.inv_center = 101142 THEN 'ONLINE SPOTII King Road FT'
                                                                WHEN t1.inv_center = 101144 THEN 'ONLINE SPOTII Jed Az Xpress'
                                                                WHEN t1.inv_center = 101145 THEN 'ONLINE SPOTII Gnt LD Xpress'
                                                                WHEN t1.inv_center = 101146 THEN 'ONLINE SPOTII Najran  XP'
                                                                WHEN t1.inv_center = 101201 THEN 'ONLINE SPOTII Taif PRO'
                                                                WHEN t1.inv_center = 101202 THEN 'ONLINE SPOTII Shehar FT'
                                                                WHEN t1.inv_center = 101203 THEN 'ONLINE SPOTII Ghazali Pro'
                                                                WHEN t1.inv_center = 101301 THEN 'ONLINE SPOTII Tabuk PRO'
                                                                WHEN t1.inv_center = 101302 THEN 'ONLINE SPOTII Murooj FT'
                                                                WHEN t1.inv_center = 101303 THEN 'ONLINE SPOTII Murooj LD FT'
                                                                WHEN t1.inv_center = 101401 THEN 'ONLINE SPOTII Khamis PRO'
                                                                WHEN t1.inv_center = 101402 THEN 'ONLINE SPOTII Maazab FT'
                                                                WHEN t1.inv_center = 101501 THEN 'ONLINE SPOTII Madina RR FT'
                                                                WHEN t1.inv_center = 101502 THEN 'ONLINE SPOTII Madina Az PRO'
                                                                WHEN t1.inv_center = 101504 THEN 'ONLINE SPOTII Khalida LD FT'
                                                                WHEN t1.inv_center = 101505 THEN 'ONLINE SPOTII Sharq FT'
                                                                WHEN t1.inv_center = 101506 THEN 'ONLINE SPOTII Sharq JR'
                                                                WHEN t1.inv_center = 101508 THEN 'ONLINE SPOTII Sharq Xpress'
                                                                WHEN t1.inv_center = 101509 THEN 'ONLINE SPOTII Mdn Az Xpress'
                                                                WHEN t1.inv_center = 101510 THEN 'ONLINE SPOTII Madina Sharq FTL'
                                                                WHEN t1.inv_center = 101601 THEN 'ONLINE SPOTII Mecca RR FT'
                                                                WHEN t1.inv_center = 101602 THEN 'ONLINE SPOTII Sharaei PRO'
                                                                WHEN t1.inv_center = 101603 THEN 'ONLINE SPOTII Omra PRO'
                                                                WHEN t1.inv_center = 101605 THEN 'ONLINE SPOTII Fayha FT'
                                                                WHEN t1.inv_center = 101607 THEN 'ONLINE SPOTII Awaly FT'
                                                                WHEN t1.inv_center = 101611 THEN 'ONLINE SPOTII Fayha LD FT'
                                                                WHEN t1.inv_center = 101612 THEN 'ONLINE SPOTII Awaly LD FT'
                                                                WHEN t1.inv_center = 101613 THEN 'ONLINE SPOTII W Ahad Xpress'
                                                                WHEN t1.inv_center = 101701 THEN 'ONLINE SPOTII Waterfront FT'
                                                                WHEN t1.inv_center = 101702 THEN 'ONLINE SPOTII W front LD FT'
                                                                WHEN t1.inv_center = 101801 THEN 'ONLINE SPOTII Abha FT'
                                                                WHEN t1.inv_center = 102101 THEN 'ONLINE SPOTII Shafie FT'
                                                                WHEN t1.inv_center = 102102 THEN 'ONLINE SPOTII Ghadeer FT'
                                                                WHEN t1.inv_center = 102103 THEN 'ONLINE SPOTII Ishbilia FT'
                                                                WHEN t1.inv_center = 102104 THEN 'ONLINE SPOTII Rawabi FT'
                                                                WHEN t1.inv_center = 102105 THEN 'ONLINE SPOTII Swedi FT'
                                                                WHEN t1.inv_center = 102106 THEN 'ONLINE SPOTII Rabwa FT'
                                                                WHEN t1.inv_center = 102107 THEN 'ONLINE SPOTII Mansorah PRO'
                                                                WHEN t1.inv_center = 102108 THEN 'ONLINE SPOTII Shefa PRO'
                                                                WHEN t1.inv_center = 102109 THEN 'ONLINE SPOTII Shobra PRO'
                                                                WHEN t1.inv_center = 102110 THEN 'ONLINE SPOTII Taawon FT'
                                                                WHEN t1.inv_center = 102111 THEN 'ONLINE SPOTII Nakheel FT'
                                                                WHEN t1.inv_center = 102113 THEN 'ONLINE SPOTII Buraidh M PRO'
                                                                WHEN t1.inv_center = 102115 THEN 'ONLINE SPOTII Kharj PRO'
                                                                WHEN t1.inv_center = 102116 THEN 'ONLINE SPOTII Qadasiya PRO'
                                                                WHEN t1.inv_center = 102117 THEN 'ONLINE SPOTII Sahafa PRO'
                                                                WHEN t1.inv_center = 102119 THEN 'ONLINE SPOTII Ghadeer PLUS'
                                                                WHEN t1.inv_center = 102120 THEN 'ONLINE SPOTII Wadi PRO'
                                                                WHEN t1.inv_center = 102121 THEN 'ONLINE SPOTII Badea FT'
                                                                WHEN t1.inv_center = 102125 THEN 'ONLINE SPOTII Badea 2 PRO'
                                                                WHEN t1.inv_center = 102126 THEN 'ONLINE SPOTII Riyadh Az PRO'
                                                                WHEN t1.inv_center = 102127 THEN 'ONLINE SPOTII Hitten FT'
                                                                WHEN t1.inv_center = 102128 THEN 'ONLINE SPOTII K Faisal FT'
                                                                WHEN t1.inv_center = 102129 THEN 'ONLINE SPOTII Yasmeen FT'
                                                                WHEN t1.inv_center = 102131 THEN 'ONLINE SPOTII Waha FT'
                                                                WHEN t1.inv_center = 102132 THEN 'ONLINE SPOTII Olaya View FT'
                                                                WHEN t1.inv_center = 102133 THEN 'ONLINE SPOTII Nada FT'
                                                                WHEN t1.inv_center = 102134 THEN 'ONLINE SPOTII Khaleej PRO'
                                                                WHEN t1.inv_center = 102136 THEN 'ONLINE SPOTII Western RR FT'
                                                                WHEN t1.inv_center = 102139 THEN 'ONLINE SPOTII Laban PRO'
                                                                WHEN t1.inv_center = 102140 THEN 'ONLINE SPOTII Moansiah FT'
                                                                WHEN t1.inv_center = 102141 THEN 'ONLINE SPOTII Naseem PRO'
                                                                WHEN t1.inv_center = 102144 THEN 'ONLINE SPOTII Nadwa PRO'
                                                                WHEN t1.inv_center = 102145 THEN 'ONLINE SPOTII Riyadh Kzm FT'
                                                                WHEN t1.inv_center = 102147 THEN 'ONLINE SPOTII Shabab FT'
                                                                WHEN t1.inv_center = 102150 THEN 'ONLINE SPOTII RydAz LD PRO'
                                                                WHEN t1.inv_center = 102153 THEN 'ONLINE SPOTII Unaizah FT'
                                                                WHEN t1.inv_center = 102154 THEN 'ONLINE SPOTII Nafel LD FT'
                                                                WHEN t1.inv_center = 102155 THEN 'ONLINE SPOTII Khalij LD PRO'
                                                                WHEN t1.inv_center = 102156 THEN 'ONLINE SPOTII Oraija LD PRO'
                                                                WHEN t1.inv_center = 102158 THEN 'ONLINE SPOTII Aqeeq LD Plus'
                                                                WHEN t1.inv_center = 102159 THEN 'ONLINE SPOTII Malga LD FT'
                                                                WHEN t1.inv_center = 102161 THEN 'ONLINE SPOTII Hamra LD FT'
                                                                WHEN t1.inv_center = 102163 THEN 'ONLINE SPOTII Falah LD FT'
                                                                WHEN t1.inv_center = 102165 THEN 'ONLINE SPOTII Nuzha LD FT'
                                                                WHEN t1.inv_center = 102167 THEN 'ONLINE SPOTII Rahmnia LD FT'
                                                                WHEN t1.inv_center = 102172 THEN 'ONLINE SPOTII Khaleej LD FT'
                                                                WHEN t1.inv_center = 102173 THEN 'ONLINE SPOTII Monsiah LD FT'
                                                                WHEN t1.inv_center = 102175 THEN 'ONLINE SPOTII Badea LD FT'
                                                                WHEN t1.inv_center = 102177 THEN 'ONLINE SPOTII Yasmeen LD FT'
                                                                WHEN t1.inv_center = 102178 THEN 'ONLINE SPOTII Ryd Kzm LD FT'
                                                                WHEN t1.inv_center = 102179 THEN 'ONLINE SPOTII Yarmouk LD FT'
                                                                WHEN t1.inv_center = 102182 THEN 'ONLINE SPOTII AHSA XP'
                                                                WHEN t1.inv_center = 102183 THEN 'ONLINE SPOTII Brd LD Xpress'
                                                                WHEN t1.inv_center = 102184 THEN 'ONLINE SPOTII Tuwaiq  LD XP'
                                                                WHEN t1.inv_center = 102185 THEN 'ONLINE SPOTII Tuwaiq Xp'
                                                                WHEN t1.inv_center = 102186 THEN 'ONLINE SPOTII Marwah LD XP'
                                                                WHEN t1.inv_center = 102187 THEN 'ONLINE SPOTII NASEM GHR XP'
                                                                WHEN t1.inv_center = 102188 THEN 'ONLINE SPOTII AZIZIZ XP'
                                                                WHEN t1.inv_center = 102189 THEN 'ONLINE SPOTII NASEM SHA XP'
                                                                WHEN t1.inv_center = 102190 THEN 'ONLINE SPOTII NASEM LD XP'
                                                                WHEN t1.inv_center = 102191 THEN 'ONLINE SPOTII MURJ XP'
                                                                WHEN t1.inv_center = 102193 THEN 'ONLINE SPOTII KHARJ XP'
                                                                WHEN t1.inv_center = 102194 THEN 'ONLINE SPOTII KHARJ XP LD'
                                                                WHEN t1.inv_center = 102195 THEN 'ONLINE SPOTII RIMAL XP'
                                                                WHEN t1.inv_center = 102196 THEN 'ONLINE SPOTII QURTBAH XP'
                                                                WHEN t1.inv_center = 102198 THEN 'ONLINE SPOTII Al Shifa Bader'
                                                                WHEN t1.inv_center = 102201 THEN 'ONLINE SPOTII Hail PRO'
                                                                WHEN t1.inv_center = 102204 THEN 'ONLINE SPOTII Khamashia XP'
                                                                WHEN t1.inv_center = 102205 THEN 'ONLINE SPOTII NUQRH XP'
                                                                WHEN t1.inv_center = 102206 THEN 'ONLINE SPOTII NUQRH LD XP'
                                                                WHEN t1.inv_center = 102303 THEN 'ONLINE SPOTII Eastrn RR Pro'
                                                                WHEN t1.inv_center = 102401 THEN 'ONLINE SPOTII Dawadmi FT'
                                                                WHEN t1.inv_center = 102402 THEN 'ONLINE SPOTII Dawadmi LD FT'
                                                                WHEN t1.inv_center = 102403 THEN 'ONLINE SPOTII Dawdmi Xpress'
                                                                WHEN t1.inv_center = 102501 THEN 'ONLINE SPOTII Arar PRO'
                                                                WHEN t1.inv_center = 102601 THEN 'ONLINE SPOTII Al Quds RiyadhXP'
                                                                WHEN t1.inv_center = 102602 THEN 'ONLINE SPOTII Al Quds RiyadhXP'
                                                                WHEN t1.inv_center = 102608 THEN 'ONLINE SPOTII Aqeeq PLUS'
                                                                WHEN t1.inv_center = 103101 THEN 'ONLINE SPOTII Faisaliah FT'
                                                                WHEN t1.inv_center = 103102 THEN 'ONLINE SPOTII Sihat PRO'
                                                                WHEN t1.inv_center = 103103 THEN 'ONLINE SPOTII GoldenBelt FT'
                                                                WHEN t1.inv_center = 103104 THEN 'ONLINE SPOTII Noor PRO'
                                                                WHEN t1.inv_center = 103105 THEN 'ONLINE SPOTII Olaya FT'
                                                                WHEN t1.inv_center = 103107 THEN 'ONLINE SPOTII OLAYA PLUS'
                                                                WHEN t1.inv_center = 103108 THEN 'ONLINE SPOTII Khobar Kzm FT'
                                                                WHEN t1.inv_center = 103112 THEN 'ONLINE SPOTII Khb Kzm LD FT'
                                                                WHEN t1.inv_center = 103113 THEN 'ONLINE SPOTII Olaya LD PLUS'
                                                                WHEN t1.inv_center = 103201 THEN 'ONLINE SPOTII Hafar PRO'
                                                                WHEN t1.inv_center = 103301 THEN 'ONLINE SPOTII Corniche FT'
                                                                WHEN t1.inv_center = 103304 THEN 'ONLINE SPOTII Montazah FT'
                                                                WHEN t1.inv_center = 103306 THEN 'ONLINE SPOTII Gld Blt LD FT'
                                                                WHEN t1.inv_center = 103307 THEN 'ONLINE SPOTII Zohoor LD FT'
                                                                WHEN t1.inv_center = 103308 THEN 'ONLINE SPOTII Jamaeen LD FT'
                                                                WHEN t1.inv_center = 103310 THEN 'ONLINE SPOTII Ashulah XP'
                                                                WHEN t1.inv_center = 103401 THEN 'ONLINE SPOTII Ahsa PRO'
                                                                WHEN t1.inv_center = 103405 THEN 'ONLINE SPOTII Ahsa LD Pro'
                                                                WHEN t1.inv_center = 103501 THEN 'ONLINE SPOTII Jalmudah FT'
                                                                WHEN t1.inv_center = 103502 THEN 'ONLINE SPOTII Jalmudah JR'
                                                                WHEN t1.inv_center = 103503 THEN 'ONLINE SPOTII Firdaws FT'
                                                                WHEN t1.inv_center = 103504 THEN 'ONLINE SPOTII Jalmudh LD FT'
                                                                WHEN t1.inv_center = 210001 THEN 'ONLINE SPOTII CORP SALES'
                                                                WHEN t1.inv_center = 102606 THEN 'ONLINE SPOTII Iqrah FT'
                                                                WHEN t1.inv_center = 103407 THEN 'ONLINE SPOTII Mubarraz FTL'
                                                                WHEN t1.inv_center = 103406 THEN 'ONLINE SPOTII Mubarraz FT'
                                                                WHEN t1.inv_center = 113002 THEN 'ONLINE SPOTII AJMAN FT LD'
                                                                WHEN t1.inv_center = 103408 THEN 'SABB Spotii Sales-Ahsa L FT'
                                                                WHEN t1.inv_center = 103309 THEN 'ONLINE SPOTII .Sadaf Khobar Xpress '
                                                                WHEN t1.inv_center = 102625 THEN 'ONLINE SPOTII Ishbilia Xpress'
                                                                WHEN t1.inv_center = 101614 THEN 'ONLINE SPOTII Al Salehiyah FT'
                                                                WHEN t1.inv_center = 101615 THEN 'ONLINE SPOTII Al Salehiyah ladies FT'
                                                                WHEN t1.inv_center = 102638 THEN 'ONLINE SPOTII Kharj Xpress male'
                                                                WHEN t1.inv_center = 102640 THEN 'ONLINE SPOTII Qyrawan Xpress male'
                                                                WHEN t1.inv_center = 102642 THEN 'ONLINE SPOTII RABWA Xpress male'
                                                                WHEN t1.inv_center = 103507 THEN 'ONLINE SPOTII Jr ac / Jalmudah'
                                                                WHEN t1.inv_center = 101150 THEN 'ONLINE SPOTII Al Asalah Xpress'
                                                                WHEN t1.inv_center = 101132 THEN 'ONLINE SPOTII Naseem FT'
                                                        END
                                                END                                                                                                                
                                        WHEN t1.crt_type = 1 THEN
                                                CASE
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 100001 THEN 'CASH.BSF.Abdullah Bakshab'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101101 THEN 'CASH.BSF.Bakhashab FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101102 THEN 'CASH.BSF.SAFA FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101103 THEN 'CASH.BSF.NADA FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101105 THEN 'CASH.BSF.MASARRA PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101106 THEN 'CASH.BSF.Gharnata FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101107 THEN 'CASH.BSF.GHARNATA JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101108 THEN 'CASH.BSF.AZIZIA JEDDAH PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101109 THEN 'CASH.BSF.ANDALUS FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101110 THEN 'CASH.BSF SABEEN FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101111 THEN 'CASH.BSF NAEEM FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101112 THEN 'CASH.BSF.OBHUR FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101113 THEN 'CASH.BSF SALAMA FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101114 THEN 'CASH.BSF.SALAMA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101115 THEN 'CASH.BSF.MACARONA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101116 THEN 'CASH.BSF ARBEEN FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101117 THEN 'CASH.BSF ARBEEN PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101118 THEN 'CASH.BSF BASATEEN FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101119 THEN 'NCB.NAJRAN PRO.CASH.RECEIPT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101120 THEN 'CASH.BSF.HAMDANIAH FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101121 THEN 'NCB.SKAKA PRO.CASH.RECEIPT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101122 THEN 'CASH.BSF PALESTINE PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101123 THEN 'CASH.BSF.Samer PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101125 THEN 'CASH.BSF.Taiba PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101127 THEN 'CASH.NCB.Jizan PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101128 THEN 'NCB.BAHA PRO.CASH.RECEIPT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101129 THEN 'CASH.BSF PALESTINE FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101130 THEN 'CASH.BSF KILO14 PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101131 THEN 'CASH.NCB.Samer JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101133 THEN 'CASH.BSF.KING ROAD LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101134 THEN 'CASH.BSF.FAWZ FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101135 THEN 'CASH.BSF.FAWZ FT LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101136 THEN 'CASH.BSF.SAMER LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101137 THEN 'CASH.NCB.HAMDANIAH LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101138 THEN 'CASH.BSF.PALESTINE LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101139 THEN 'CASH.BSF.ARBEIN LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101140 THEN 'CASH.BSF.SALAMA LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101141 THEN 'CASH.BSF.MACARONA LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101142 THEN 'CASH.BSF.KING ROAD FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101144 THEN 'CASH.BSF.Jeddah Azizia Xp'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101145 THEN 'CASH Garnata Ladies Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101146 THEN 'CASH.JAZERA.Najran  XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101201 THEN 'CASH.NCB.TAIF PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101202 THEN 'NCB.SHEHAR FT.CASH.RECEIPT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101203 THEN 'CASH.BSF.GHAZALI PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101301 THEN 'CASH.NCB.TABOUK PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101302 THEN 'CASH.BSF.MUROOJ FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101303 THEN 'CASH.BSF.MUROOJ LADIES FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101401 THEN 'CASH.NCB.KHAMEES MUSHAIT PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101402 THEN 'CASH.NCB.Mazaab FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101501 THEN 'CASH.BSF.MADINA RING ROAD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101502 THEN 'CASH.NCB.AZIZIA MADINA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101503 THEN 'CASH.SABB.Madina Az LD PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101504 THEN 'CASH.SABB.Khalida LD FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101505 THEN 'BSF.SHARQ FT.CASH.RECEIPT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101506 THEN 'CASH.BSF.SHARQ JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101507 THEN 'CASH.BSF.SHARQ PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101508 THEN 'CASH.BSF.Sharq Xpress 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101509 THEN 'CASH Aziziah Med M Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101510 THEN 'CASH.JAZERA.Madina Sharq FTL'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101601 THEN 'NCB.MECCA RING ROAD FT.CASH.RE'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101602 THEN 'BSF.SHARAEI PRO.CASH.RECEIPT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101603 THEN 'CASH.BSF.OMRA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101605 THEN 'CASH.BSF.FAYHA FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101606 THEN 'CASH.BSF.WALI ALAHAD PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101607 THEN 'CASH.BSF.AWALY FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101609 THEN 'CASH.BSF.AWALY PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101611 THEN 'CASH.BSF.FAYHA LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101612 THEN 'CASH.BSF.AWALI LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101613 THEN 'CASH Wali Alahad Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101701 THEN 'CASH.SABB.WATER FRONT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101702 THEN 'CASH.SABB.WATER FRONT LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101801 THEN 'CASH.BSF.ABHA FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102101 THEN 'CASH.SABB.Shafie FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102102 THEN 'CASH.SABB.Ghadeer FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102103 THEN 'CASH.BSF.Ishbilia FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102104 THEN 'CASH.BSF.Rawabi FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102105 THEN 'CASH.BSF.Swedi FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102106 THEN 'CASH.SABB.Rabwa FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102107 THEN 'CASH.SABB.Mansorah PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102108 THEN 'CASH.SABB.Shefa PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102109 THEN 'CASH.SABB.Shobra PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102110 THEN 'CASH.SABB.Taawon FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102111 THEN 'CASH.BSF.Nakheel FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102113 THEN 'CASH.BSF.Buraidah Muntazah PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102114 THEN 'CASH.SABB.King Abdulaziz FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102115 THEN 'CASH.NCB KHARJ PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102116 THEN 'CASH.BSF.Qadasiya PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102117 THEN 'CASH.SABB.Sahafa PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102119 THEN 'CASH.SABB.Ghadeer PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102120 THEN 'CASH.BSF.Wadi PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102121 THEN 'CASH.SABB.Badea FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102123 THEN 'CASH.BSF.Yarmouk FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102125 THEN 'CASH.BSF.Badea 2 PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102126 THEN 'CASH.SABB.RYD Azizia PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102127 THEN 'CASH.SABB.Hitten FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102128 THEN 'CASH.SABB.King Faisal FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102129 THEN 'CASH.BSF.Yasmeen FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102130 THEN 'CASH.NCB YASMEEN JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102131 THEN 'CASH.BSF.Waha FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102132 THEN 'CASH.SABB.Olaya View FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102133 THEN 'CASH.BSF.Nada FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102134 THEN 'CASH.BSF.Khaleej PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102136 THEN 'CASH.SABB.Western RR FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102138 THEN 'CASH.BSF.Jawdah School JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102139 THEN 'CASH.SABB.Laban PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102140 THEN 'CASH.BSF.Moansiah FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102141 THEN 'CASH.BSF.Naseem PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102144 THEN 'CASH.NCB NADWA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102145 THEN 'CASH.SABB.RYD KHOZAMA FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102146 THEN 'CASH.BSF.Riyadh Khozama JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102147 THEN 'CASH.SABB.Shabab FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102149 THEN 'CASH.SABB.FCB Escola Riyadh'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102150 THEN 'CASH.NCB. AZIZIA LADIES PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102153 THEN 'CASH.BSF.Unaizah FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102154 THEN 'CASH.NCB.MOANSIAH LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102155 THEN 'CASH.NCB KHALEEJ PROLADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102156 THEN 'CASH.NCB ORAJIA LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102158 THEN 'CASH.SABB.Aqeeq LD PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102159 THEN 'CASH.NCB MALGA FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102161 THEN 'CASH.BSF.Hamra LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102163 THEN 'CASH.BSF.Falah LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102165 THEN 'CASH.SABB.NUZHA LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102167 THEN 'CASH.SABB.Rahmania LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102172 THEN 'CASH.NCB.KHALEEJ LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102173 THEN 'CASH.NCB.MOANSIAH LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102175 THEN 'CASH.NCB.Badea Ladies FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102176 THEN 'CASH.SABB.PNU LADIES 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102177 THEN 'CASH.BSF.Yasmeen Ladies'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102178 THEN 'CASH.BSF.RIYADH KHOZAMA LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102179 THEN 'CASH.NBC.YARMOUK LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102182 THEN 'CASH.JAZERA.EHSA XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102183 THEN 'CASH Buraida Muntaza LD Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102184 THEN 'CASH.JAZERA.Tuwaiq  LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102185 THEN 'CASH.JAZERA.Tuwaiq Xp'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102186 THEN 'CASH.JAZERA.Marwah LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102187 THEN 'CASH.JAZERA.NASEM GHR XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102188 THEN 'CASH.JAZERA.AZIZIZ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102189 THEN 'CASH.JAZERA.NASEM SHA XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102190 THEN 'CASH.JAZERA.NASEM LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102191 THEN 'CASH.JAZERA.MURJ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102193 THEN 'CASH.JAZERA.KHARJ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102194 THEN 'CASH.JAZERA.KHARJ XP LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102195 THEN 'CASH.JAZERA.RIMAL XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102196 THEN 'CASH.JAZERA.QURTBAH XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102198 THEN 'CASH.JAZERA.Al Shifa Bader  XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102201 THEN 'CASH.NCB.HAIL PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102204 THEN 'CASH.JAZERA. Khamashia XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102205 THEN 'CASH.JAZERA.NUQRH XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102206 THEN 'CASH.JAZERA.NUQRH LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102303 THEN 'CASH.BSF.EASTERN RR Pro 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102401 THEN 'CASH.NCB.DAWADMI PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102402 THEN 'CASH Dawadmi Ladies FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102403 THEN 'CASH Dawadmi Male Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102501 THEN 'CASH.NCB.Arar PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102601 THEN 'CASH.JAZERA.Al Quds RiyadhXP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102602 THEN 'CASH.JAZERA.Uqadh Riyadh XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102608 THEN 'CASH.SABB.Aqeeq PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103101 THEN 'SABB.FAISALIAH FT.CASH.RECEIPT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103102 THEN 'CASH.SABB.SAIHAT PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103103 THEN 'CASH.SABB.GOLDEN BELT FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103104 THEN 'CASH.SABB.NOOR PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103105 THEN 'SABB.OLAYA KHOBAR FT.CASH.RECE'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103107 THEN 'CASH.SABB.OLAYA PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103108 THEN 'SABB.KHZAMA KHOBAR FT.CASH.REC'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103112 THEN 'CASH.SABB.KHBR KHZ LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103113 THEN 'CASH.SABB.OLAYA LD PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103201 THEN 'CASH.NCB.HAFAR AL BATIN'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103301 THEN 'CASH.SABB.CORNICHE FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103304 THEN 'CASH.SABB.Montazah FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103305 THEN 'CASH.SABB.FCB Escola Dammam'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103306 THEN 'CASH.SABB.Golden Belt LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103307 THEN 'CASH.SABB.ZOHOUR LADIES FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103308 THEN 'CASH.SABB JAMAEIN LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103310 THEN 'CASH.JAZERA.Ashulah XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103401 THEN 'CASH.NCB.AHSSA PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103405 THEN 'CASH.NCB.AHSA LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103501 THEN 'CASH.SABB .Jalmudah FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103502 THEN 'CASH.SABB.JALMUDAH JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103503 THEN 'CASH.SABB.Firdwas FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103504 THEN 'CASH.NCB JALMUDAH LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 111001 THEN 'NBD.MAMZER FT GT-501.CASH.REC'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 111004 THEN 'NBD.MAMZER FT LD -506.CASH.REC'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 112001 THEN 'NBD.NAEEM MALL FT GT-901.CASH.REC'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 112002 THEN 'NBD.NAEEM MALL FT LD -901.CASH.REC'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 113001 THEN 'NBD.RASHIDIA PRO-2801.CASH.REC'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 114001 THEN 'NBD.HAZZANA FT GT-901.CASH.REC'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 114002 THEN 'NBD.HAZZANA LD -901.CASH'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102606 THEN 'CASH.JAZ.Iqrah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103407 THEN 'CASH.JAZ.Ahsa Mubarraz FTL'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103406 THEN 'CASH.JAZ.Ahsa Mubarraz FT Male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 113002 THEN 'NBD.AJMAN FT LD-802.CASH.RE'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103408 THEN 'CASH.NCB.Ahsa L FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103309 THEN 'SABB.CASH.Sadaf Khobar Xpress '
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102625 THEN 'SABB.CASH.Ishbilia Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101614 THEN 'SABB.CASH.Al Salehiyah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101615 THEN 'SABB.CASH.Al Salehiyah ladies FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102638 THEN 'SABB.CASH.Kharj Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102640 THEN 'SABB.CASH.Qyrawan Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102642 THEN 'SABB.CASH.RABWA Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103507 THEN 'SABB.CASH.Jr ac / Jalmudah'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101150 THEN 'SABB.CASH.Al Asalah Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101132 THEN 'SABB.CASH.Naseem FT'
                                                END                                                        
                                        WHEN t1.crt_type = 13 THEN
                                                CASE
                                                        --UAE clubs
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 111001 AND (t1.coment LIKE 'PTB%' OR t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') THEN 'ONLINE.MAMZAR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 111004 AND (t1.coment LIKE 'PTB%' OR t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') THEN 'ONLINE.MAMZAR LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 112001 AND (t1.coment LIKE 'PTB%' OR t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') THEN 'ONLINE.NAEEMMALL PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 112002 AND (t1.coment LIKE 'PTB%' OR t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') THEN 'ONLINE.NAEEMMALL LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 113001 AND (t1.coment LIKE 'PTB%' OR t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') THEN 'ONLINE.RASHIDIYA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 113002 AND (t1.coment LIKE 'PTB%' OR t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.AJMAN FT LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 114001 AND (t1.coment LIKE 'PTB%' OR t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') THEN 'ONLINE.HAZZANA GT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 114002 AND (t1.coment LIKE 'PTB%' OR t1.art_info LIKE 'PTB%' OR  t1.transaction_id LIKE 'PTB%') THEN 'ONLINE.HAZZANA LD'
                                                        --KSA clubs
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101101 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.BAKHASHAB FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101102 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SAFA FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101103 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.NADA FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101105 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Masarrah PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101106 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Gharnata.FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101107 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.GHARNATA JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101108 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.AZIZIA JEDDAH PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101109 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.ANDALUS FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101110 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SABEEN FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101111 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.NAEEM FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101112 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.OBHUR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101114 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SALAMA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101116 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.ARBEEN FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101118 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.BASATEEN FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101119 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.NAJRAN PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101121 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SKAKA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101122 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.PALESTINE PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101123 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Samer PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101125 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.TAIBA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101127 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Jizan PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101128 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.BAHA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101130 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.KILO14 PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101133 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.KING ROAD LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101134 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.FAWZ FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101135 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.FAWZ FT LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101136 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SAMER LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101137 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.HAMDANIAH LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101138 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.PALESTINE LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101139 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.ARBEIN LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101140 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SALAMA LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101141 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.MACARONA LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101142 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.KING ROAD FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101144 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE. Jed Az Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101145 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE Garnata Ladies Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101146 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Najran  XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101201 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.TAIF PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101202 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SHEHAR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101203 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.GHAZALI PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101301 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.TABOUK PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101302 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.MUROOJ FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101303 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.MUROOJ LADIES FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101401 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.KHAMEES MUSHAIT PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101402 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Mazaab FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101501 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.MADINA RING ROAD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101502 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.MADINA AZIZIA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101504 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Khalida LD FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101505 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SHARQ FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101506 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SHARQ JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101507 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SHARQ PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101508 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE .Sharq Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101509 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE Aziziah Med M Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101510 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Madina Sharq FTL'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101601 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.MECCA RING ROAD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101602 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.MECCA SHARAE'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101603 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.MECCA OMRA'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101605 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Fayha.FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101606 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.WALI ALAHAD PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101607 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.AWALY FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101609 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.AWALY PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101611 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.FAYHA LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101612 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Aawali LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101613 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE Wali Alahad Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101701 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.WATER FRONT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101702 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.WATER FRONT LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101801 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.ABHA FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102101 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Shafie FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102102 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'SABB.ONLINE.GHADEER FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102103 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Ishbilia FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102104 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Rawabi FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102105 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Swedi FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102106 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Rabwa FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102107 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Mansorah PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102108 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Shefa.PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102109 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Shobra PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102110 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Taawon FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102111 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Nakheel FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102113 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Buraidah Muntazah PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102114 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.King Abdulaziz FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102115 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SABB KHARJ PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102116 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Qadasiya PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102117 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Sahafa PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102119 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Ghadeer PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102120 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Wadi PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102121 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Badea FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102125 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Badea 2 PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102126 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.RYD Azizia PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102127 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Hitten.FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102128 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.King Faisal FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102129 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Yasmeen FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102131 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Waha FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102132 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Olaya View FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102133 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Nada FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102134 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Khaleej PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102136 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Western RR FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102138 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Jawdah School JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102139 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Laban PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102140 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Moansiah FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102141 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Naseem PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102144 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SABB NADWA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102145 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.RYD KHOZAMA FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102150 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SABB AZIZIA LADIES PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102153 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Unaizah.FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102154 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.BSF NAFEL LADIES FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102155 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SABB KHALEEJ PROLADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102156 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SABB ORAJIA LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102158 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Aqeeq LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102159 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SABB MALGALADIES FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102161 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.HAMRA FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102163 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.FALAH LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102165 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.NUZHA FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102167 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.RAHMANIA FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102172 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.KHALEEJ LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102173 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.MOANSIAH LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102175 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.BADEA LADIES FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102176 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.PNU LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102177 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Yasmeen Ladies'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102178 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.RIYADH KHOZAMA LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102179 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.YARMOUK LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102182 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE .AHSA XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102183 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE Buraida Muntaza LD Xpr'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102184 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Tuwaiq  LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102185 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Tuwaiq Xp'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102186 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Marwah LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102187 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.NASEM GHR XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102188 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.AZIZIZ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102189 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.NASEM SHA XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102190 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.NASEM LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102191 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.MURJ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102193 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.KHARJ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102194 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.KHARJ XP LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102195 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.RIMAL XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102196 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.QURTBAH XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102198 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Al Shifa Bader  XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102204 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Khamashia XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102205 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.NUQRH XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102206 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.NUQRH LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102303 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.EASTERN RR Pro 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102401 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.DAWADMI PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102402 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE Dawadmi Ladies FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102403 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE Dawadmi Male Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102501 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Arar.PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102601 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Al Quds RiyadhXP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102602 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Uqadh Riyadh XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102608 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Aqeeq PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103101 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.FAISALIAH FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103102 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SAIHAT PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103103 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.GOLDEN BELT FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103104 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.NOOR PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103105 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.OLAYA KHOBAR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103107 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'Online.OLAYA-PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103108 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.KHOZAMA KHBR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103112 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.KHBR KHOZ LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103201 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.HAFAR AL BATIN'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103301 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.CORNICHE FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103304 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Montazah.FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103306 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Golden Belt LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103307 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.ZOHOUR LADIES FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103308 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SABB JAMAEIN  LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103310 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Ashulah XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103401 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Ahsa.PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103405 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.AHSA LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103501 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.JALMUDAH FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103502 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.JALMUDAH JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103503 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.FIRDAWS FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103504 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.JALMUDAH LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 210001 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.SABB.Corp Sales -Cash'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102606 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'Online. Irqah Male FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103407 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'Online. Ahsa Mubarraz FTL'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103406 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'Online.JAZERA. Ahsa Mubarraz Male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103408 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'BSF Online Sales.Ahsa L FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103309 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Sadaf Khobar Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102625 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Ishbilia Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101614 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Al Salehiyah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101615 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Al Salehiyah ladies FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102638 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Kharj Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102640 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Qyrawan Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102642 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.RABWA Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103507 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Jr ac / Jalmudah'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101150 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Al Asalah Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101132 AND (t1.coment LIKE 'PTS%' OR t1.art_info LIKE 'PTS%' OR  t1.transaction_id LIKE 'PTS%') THEN 'ONLINE.Naseem FT'
                                                        --TAMARA
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101101 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Bakhashab FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101102 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Safa FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101103 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Nahda FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101105 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Masarrah PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101106 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Gharnata FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101109 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Andalus FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101110 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Sabeen FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101111 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Naeem FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101112 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Obhur FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101114 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Salama PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101116 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Arbein FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101118 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Basateen FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101119 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Najran PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101121 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Skaka PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101122 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Palestine PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101123 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Samer PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101125 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Taiba PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101127 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Jizan PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101128 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Baha PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101130 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Kilo14 PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101133 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA King Rd LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101134 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Pr Fawaz FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101135 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Pr Fawz LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101136 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Samer LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101137 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Hmdniah LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101138 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Palstne LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101139 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Arbein LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101140 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Salama LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101141 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Macrona LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101142 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA King Road FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101144 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Jed Az Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101145 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Gnt LD Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101146 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Najran  XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101201 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Taif PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101202 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Shehar FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101302 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Murooj FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101303 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Murooj LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101401 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Khamis PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101402 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Maazab FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101501 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Madina RR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101502 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Madina Az PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101504 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Khalida LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101505 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Sharq FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101508 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Sharq Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101509 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Mdn Az Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101510 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Madina Sharq FTL'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101601 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Mecca RR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101602 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Sharaei PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101603 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Omra PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101605 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Fayha FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101607 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Awaly FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101611 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Fayha LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101612 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Awaly LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101613 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA W Ahad Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101701 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Waterfront FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101702 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA W front LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101801 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Abha FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102101 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Shafie FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102102 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Ghadeer FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102103 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Ishbilia FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102104 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Rawabi FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102105 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Swedi FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102106 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Rabwa FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102107 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Mansorah PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102108 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Shefa PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102109 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Shobra PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102110 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Taawon FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102111 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Nakheel FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102113 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Buraidh M PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102115 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Kharj PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102116 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Qadasiya PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102117 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Sahafa PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102119 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Ghadeer PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102120 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Wadi PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102121 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Badea FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102125 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Badea 2 PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102126 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Riyadh Az PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102127 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Hitten FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102128 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA K Faisal FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102129 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Yasmeen FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102131 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Waha FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102132 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Olaya View FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102133 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Nada FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102134 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Khaleej PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102136 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Western RR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102139 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Laban PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102140 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Moansiah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102141 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Naseem PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102144 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Nadwa PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102145 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Riyadh Kzm FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102150 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA RydAz LD PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102153 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Unaizah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102154 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Nafel LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102155 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Khalij LD PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102156 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Oraija LD PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102159 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Malga LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102161 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Hamra LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102163 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Falah LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102165 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Nuzha LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102167 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Rahmnia LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102172 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Khaleej LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102173 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Monsiah LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102175 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Badea LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102177 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Yasmeen LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102178 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Ryd Kzm LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102179 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Yarmouk LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102182 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA AHSA XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102183 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Brd LD Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102184 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Tuwaiq  LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102185 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Tuwaiq Xp'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102186 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Marwah LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102187 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA NASEM GHR XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102188 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA AZIZIZ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102189 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA NASEM SHA XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102190 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA NASEM LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102191 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA MURJ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102193 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA KHARJ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102194 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA KHARJ XP LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102195 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA RIMAL XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102196 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA QURTBAH XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102198 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Al Shifa Bader'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102204 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Khamashia XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102205 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA NUQRH XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102206 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA NUQRH LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102303 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Eastrn RR Pro'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102402 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Dawadmi L FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102403 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Dawdmi Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102501 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Arar PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102601 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Al Quds RiyadhXP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102602 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Uqadh Riyadh XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102608 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Aqiq +'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103101 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Faisaliah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103102 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Sihat PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103103 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA GoldenBelt FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103104 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Noor PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103105 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Olaya FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103107 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA OLAYA PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103108 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Khobar Kzm FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103112 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Khb Kzm LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103201 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Hafar PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103301 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Corniche FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103304 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Montazah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103306 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Gld Blt LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103307 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Zohoor LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103308 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Jamaeen LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103310 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Ashulah XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103401 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Ahsa PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103408 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Ahsa LD Pro'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103501 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Jalmudah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103503 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Firdaws FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103504 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Jalmudh LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 111001 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Mamzar FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 111004 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Mamzar L FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 112001 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Naeem M PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 112002 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Naeem L PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 113001 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Rash 2. PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 114001 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Hazzana FT '
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 114002 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Hazzana L FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102606 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Iqrah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103407 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Ahsa Mubarraz FTL'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103406 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Ahsa Mubarraz FT Male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 113002 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA AJMAN FT LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103408 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA Ahsa L FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103309 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA.Sadaf Khobar Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102625 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA.Ishbilia Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101614 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA.Al Salehiyah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101615 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA.Al Salehiyah ladies FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102638 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA.Kharj Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102640 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA.Qyrawan Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102642 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA.RABWA Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103507 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA.Jr ac / Jalmudah'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101150 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA.Al Asalah Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101132 AND (t1.coment LIKE 'TM-%' OR t1.art_info LIKE 'TM-%' OR  t1.transaction_id LIKE 'TM-%') THEN 'ONLINE TAMARA.Naseem FT'
                                                        --TABBY
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101101 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Bakhashab FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101102 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Safa FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101103 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Nahda FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101105 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Masarrah PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101106 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Gharnata FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101109 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Andalus FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101110 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Sabeen FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101111 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Naeem FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101112 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Obhur FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101114 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Salama PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101116 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Arbein FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101118 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Basateen FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101119 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Najran PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101121 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Skaka PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101122 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Palestine PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101123 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Samer PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101125 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Taiba PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101127 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Jizan PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101128 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Baha PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101130 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Kilo14 PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101133 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY King Rd LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101134 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Pr Fawaz FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101135 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Pr Fawz LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101136 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Samer LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101137 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Hmdniah LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101138 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Palstne LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101139 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Arbein LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101140 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Salama LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101141 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Macrona LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101142 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY King Road FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101144 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Jed Az Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101145 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Gnt LD Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101146 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Najran  XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101201 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Taif PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101202 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Shehar FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101302 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Murooj FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101303 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Murooj LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101401 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Khamis PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101402 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Maazab FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101501 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Madina RR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101502 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Madina Az PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101504 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Khalida LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101505 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Sharq FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101508 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Sharq Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101509 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Mdn Az Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101510 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Madina Sharq FTL'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101601 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Mecca RR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101602 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Sharaei PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101603 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Omra PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101605 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Fayha FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101607 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Awaly FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101611 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Fayha LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101612 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Awaly LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101613 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY W Ahad Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101701 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Waterfront FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101702 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY W front LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101801 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Abha FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102101 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Shafie FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102102 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Ghadeer FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102103 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Ishbilia FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102104 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Rawabi FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102105 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Swedi FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102106 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Rabwa FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102107 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Mansorah PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102108 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Shefa PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102109 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Shobra PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102110 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Taawon FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102111 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Nakheel FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102113 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Buraidh M PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102115 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Kharj PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102116 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Qadasiya PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102117 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Sahafa PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102119 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Ghadeer PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102120 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Wadi PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102121 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Badea FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102125 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Badea 2 PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102126 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Riyadh Az PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102127 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Hitten FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102128 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY K Faisal FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102129 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Yasmeen FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102131 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Waha FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102132 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Olaya View FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102133 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Nada FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102134 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Khaleej PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102136 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Western RR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102139 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Laban PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102140 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Moansiah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102141 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Naseem PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102144 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Nadwa PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102145 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Riyadh Kzm FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102150 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY RydAz LD PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102153 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Unaizah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102154 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Nafel LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102155 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Khalij LD PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102156 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Oraija LD PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102159 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Malga LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102161 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Hamra LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102163 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Falah LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102165 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Nuzha LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102167 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Rahmnia LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102172 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Khaleej LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102173 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Monsiah LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102175 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Badea LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102177 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Yasmeen LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102178 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Ryd Kzm LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102179 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Yarmouk LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102182 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY AHSA XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102183 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Brd LD Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102184 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Tuwaiq  LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102185 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Tuwaiq Xp'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102186 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Marwah LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102187 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY NASEM GHR XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102188 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY AZIZIZ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102189 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY NASEM SHA XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102190 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY NASEM LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102191 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY MURJ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102193 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY KHARJ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102194 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY KHARJ XP LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102195 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY RIMAL XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102196 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY QURTBAH XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102198 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Al Shifa Bader'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102204 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Khamashia XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102205 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY NUQRH XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102206 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY NUQRH LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102303 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Eastrn RR Pro'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102402 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Dawadmi L FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102403 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Dawdmi Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102501 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Arar PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102601 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Al Quds RiyadhXP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102602 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Uqadh Riyadh XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102608 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Aqiq +'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103101 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Faisaliah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103102 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Sihat PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103103 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY GoldenBelt FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103104 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Noor PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103105 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Olaya FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103107 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY OLAYA PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103108 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Khobar Kzm FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103112 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Khb Kzm LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103201 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Hafar PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103301 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Corniche FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103304 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Montazah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103306 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Gld Blt LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103307 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Zohoor LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103308 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Jamaeen LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103310 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Ashulah XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103401 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Ahsa PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103408 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Al Ahsa Ladies FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103501 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Jalmudah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103503 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Firdaws FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103504 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Jalmudh LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 111001 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Mamzar FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 111004 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Mamzar L FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 112001 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Naeem M PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 112002 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Naeem L PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 113001 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Rash 2. PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 114001 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Hazzana FT '
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 114002 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Hazzana L FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102606 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Iqrah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103407 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Ahsa Mubarraz FTL'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103406 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Ahsa Mubarraz FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 113002 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY AJMAN FT LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103408 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY Al Ahsa Ladies FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103309 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY .Sadaf Khobar Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102625 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY.Ishbilia Xpress '
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101614 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY .Al Salehiyah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101615 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY .Al Salehiyah ladies FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102638 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY.Kharj Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102640 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY.Qyrawan Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102642 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY.RABWA Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103507 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY.Jr ac / Jalmudah'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101150 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY.Al Asalah Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101132 AND (t1.coment LIKE 'TBY-%' OR t1.art_info LIKE 'TBY-%' OR  t1.transaction_id LIKE 'TBY-%') THEN 'ONLINE TABBY.Naseem FT'

                                                ELSE
                                                CASE
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 111001 THEN 'ONLINE SPOTII MAMZAR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 111004 THEN 'ONLINE SPOTII MAMZAR LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 112001 THEN 'ONLINE SPOTII NAEEMMALL PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 113001 THEN 'ONLINE SPOTII RASHIDIYA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 114001 THEN 'ONLINE SPOTII HAZZANA GT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 114002 THEN 'ONLINE SPOTII HAZZANA LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101101 THEN 'ONLINE SPOTII Bakhashab FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101102 THEN 'ONLINE SPOTII Safa FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101103 THEN 'ONLINE SPOTII Nahda FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101105 THEN 'ONLINE SPOTII Masarrah PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101106 THEN 'ONLINE SPOTII Gharnata FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101109 THEN 'ONLINE SPOTII Andalus FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101110 THEN 'ONLINE SPOTII Sabeen FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101111 THEN 'ONLINE SPOTII Naeem FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101112 THEN 'ONLINE SPOTII Obhur FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101114 THEN 'ONLINE SPOTII Salama PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101116 THEN 'ONLINE SPOTII Arbein FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101118 THEN 'ONLINE SPOTII Basateen FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101119 THEN 'ONLINE SPOTII Najran PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101121 THEN 'ONLINE SPOTII Skaka PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101122 THEN 'ONLINE SPOTII Palestine PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101123 THEN 'ONLINE SPOTII Samer PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101125 THEN 'ONLINE SPOTII Taiba PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101127 THEN 'ONLINE SPOTII Jizan PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101128 THEN 'ONLINE SPOTII Baha PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101130 THEN 'ONLINE SPOTII Kilo14 PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101133 THEN 'ONLINE SPOTII King Rd LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101134 THEN 'ONLINE SPOTII Pr Fawaz FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101135 THEN 'ONLINE SPOTII Pr Fawz LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101136 THEN 'ONLINE SPOTII Samer LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101137 THEN 'ONLINE SPOTII Hmdniah LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101138 THEN 'ONLINE SPOTII Palstne LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101139 THEN 'ONLINE SPOTII Arbein LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101140 THEN 'ONLINE SPOTII Salama LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101141 THEN 'ONLINE SPOTII Macrona LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101142 THEN 'ONLINE SPOTII King Road FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101144 THEN 'ONLINE SPOTII Jed Az Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101145 THEN 'ONLINE SPOTII Gnt LD Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101146 THEN 'ONLINE SPOTII Najran  XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101201 THEN 'ONLINE SPOTII Taif PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101202 THEN 'ONLINE SPOTII Shehar FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101203 THEN 'ONLINE SPOTII Ghazali Pro'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101301 THEN 'ONLINE SPOTII Tabuk PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101302 THEN 'ONLINE SPOTII Murooj FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101303 THEN 'ONLINE SPOTII Murooj LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101401 THEN 'ONLINE SPOTII Khamis PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101402 THEN 'ONLINE SPOTII Maazab FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101501 THEN 'ONLINE SPOTII Madina RR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101502 THEN 'ONLINE SPOTII Madina Az PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101504 THEN 'ONLINE SPOTII Khalida LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101505 THEN 'ONLINE SPOTII Sharq FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101506 THEN 'ONLINE SPOTII Sharq JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101508 THEN 'ONLINE SPOTII Sharq Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101509 THEN 'ONLINE SPOTII Mdn Az Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101510 THEN 'ONLINE SPOTII Madina Sharq FTL'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101601 THEN 'ONLINE SPOTII Mecca RR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101602 THEN 'ONLINE SPOTII Sharaei PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101603 THEN 'ONLINE SPOTII Omra PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101605 THEN 'ONLINE SPOTII Fayha FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101607 THEN 'ONLINE SPOTII Awaly FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101611 THEN 'ONLINE SPOTII Fayha LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101612 THEN 'ONLINE SPOTII Awaly LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101613 THEN 'ONLINE SPOTII W Ahad Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101701 THEN 'ONLINE SPOTII Waterfront FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101702 THEN 'ONLINE SPOTII W front LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101801 THEN 'ONLINE SPOTII Abha FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102101 THEN 'ONLINE SPOTII Shafie FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102102 THEN 'ONLINE SPOTII Ghadeer FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102103 THEN 'ONLINE SPOTII Ishbilia FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102104 THEN 'ONLINE SPOTII Rawabi FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102105 THEN 'ONLINE SPOTII Swedi FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102106 THEN 'ONLINE SPOTII Rabwa FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102107 THEN 'ONLINE SPOTII Mansorah PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102108 THEN 'ONLINE SPOTII Shefa PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102109 THEN 'ONLINE SPOTII Shobra PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102110 THEN 'ONLINE SPOTII Taawon FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102111 THEN 'ONLINE SPOTII Nakheel FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102113 THEN 'ONLINE SPOTII Buraidh M PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102115 THEN 'ONLINE SPOTII Kharj PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102116 THEN 'ONLINE SPOTII Qadasiya PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102117 THEN 'ONLINE SPOTII Sahafa PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102119 THEN 'ONLINE SPOTII Ghadeer PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102120 THEN 'ONLINE SPOTII Wadi PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102121 THEN 'ONLINE SPOTII Badea FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102125 THEN 'ONLINE SPOTII Badea 2 PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102126 THEN 'ONLINE SPOTII Riyadh Az PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102127 THEN 'ONLINE SPOTII Hitten FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102128 THEN 'ONLINE SPOTII K Faisal FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102129 THEN 'ONLINE SPOTII Yasmeen FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102131 THEN 'ONLINE SPOTII Waha FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102132 THEN 'ONLINE SPOTII Olaya View FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102133 THEN 'ONLINE SPOTII Nada FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102134 THEN 'ONLINE SPOTII Khaleej PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102136 THEN 'ONLINE SPOTII Western RR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102139 THEN 'ONLINE SPOTII Laban PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102140 THEN 'ONLINE SPOTII Moansiah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102141 THEN 'ONLINE SPOTII Naseem PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102144 THEN 'ONLINE SPOTII Nadwa PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102145 THEN 'ONLINE SPOTII Riyadh Kzm FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102147 THEN 'ONLINE SPOTII Shabab FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102150 THEN 'ONLINE SPOTII RydAz LD PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102153 THEN 'ONLINE SPOTII Unaizah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102154 THEN 'ONLINE SPOTII Nafel LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102155 THEN 'ONLINE SPOTII Khalij LD PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102156 THEN 'ONLINE SPOTII Oraija LD PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102158 THEN 'ONLINE SPOTII Aqeeq LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102159 THEN 'ONLINE SPOTII Malga LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102161 THEN 'ONLINE SPOTII Hamra LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102163 THEN 'ONLINE SPOTII Falah LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102165 THEN 'ONLINE SPOTII Nuzha LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102167 THEN 'ONLINE SPOTII Rahmnia LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102172 THEN 'ONLINE SPOTII Khaleej LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102173 THEN 'ONLINE SPOTII Monsiah LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102175 THEN 'ONLINE SPOTII Badea LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102177 THEN 'ONLINE SPOTII Yasmeen LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102178 THEN 'ONLINE SPOTII Ryd Kzm LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102179 THEN 'ONLINE SPOTII Yarmouk LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102182 THEN 'ONLINE SPOTII AHSA XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102183 THEN 'ONLINE SPOTII Brd LD Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102184 THEN 'ONLINE SPOTII Tuwaiq  LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102185 THEN 'ONLINE SPOTII Tuwaiq Xp'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102186 THEN 'ONLINE SPOTII Marwah LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102187 THEN 'ONLINE SPOTII NASEM GHR XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102188 THEN 'ONLINE SPOTII AZIZIZ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102189 THEN 'ONLINE SPOTII NASEM SHA XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102190 THEN 'ONLINE SPOTII NASEM LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102191 THEN 'ONLINE SPOTII MURJ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102193 THEN 'ONLINE SPOTII KHARJ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102194 THEN 'ONLINE SPOTII KHARJ XP LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102195 THEN 'ONLINE SPOTII RIMAL XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102196 THEN 'ONLINE SPOTII QURTBAH XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102198 THEN 'ONLINE SPOTII Al Shifa Bader'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102201 THEN 'ONLINE SPOTII Hail PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102204 THEN 'ONLINE SPOTII Khamashia XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102205 THEN 'ONLINE SPOTII NUQRH XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102206 THEN 'ONLINE SPOTII NUQRH LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102303 THEN 'ONLINE SPOTII Eastrn RR Pro'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102401 THEN 'ONLINE SPOTII Dawadmi FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102402 THEN 'ONLINE SPOTII Dawadmi LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102403 THEN 'ONLINE SPOTII Dawdmi Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102501 THEN 'ONLINE SPOTII Arar PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102601 THEN 'ONLINE SPOTII Al Quds RiyadhXP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102602 THEN 'ONLINE SPOTII Uqadh Riyadh XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102608 THEN 'ONLINE SPOTII Aqeeq PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103101 THEN 'ONLINE SPOTII Faisaliah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103102 THEN 'ONLINE SPOTII Sihat PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103103 THEN 'ONLINE SPOTII GoldenBelt FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103104 THEN 'ONLINE SPOTII Noor PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103105 THEN 'ONLINE SPOTII Olaya FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103107 THEN 'ONLINE SPOTII OLAYA PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103108 THEN 'ONLINE SPOTII Khobar Kzm FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103112 THEN 'ONLINE SPOTII Khb Kzm LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103113 THEN 'ONLINE SPOTII Olaya LD PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103201 THEN 'ONLINE SPOTII Hafar PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103301 THEN 'ONLINE SPOTII Corniche FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103304 THEN 'ONLINE SPOTII Montazah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103306 THEN 'ONLINE SPOTII Gld Blt LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103307 THEN 'ONLINE SPOTII Zohoor LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103308 THEN 'ONLINE SPOTII Jamaeen LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103310 THEN 'ONLINE SPOTII Ashulah XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103401 THEN 'ONLINE SPOTII Ahsa PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103405 THEN 'ONLINE SPOTII Ahsa LD Pro'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103501 THEN 'ONLINE SPOTII Jalmudah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103502 THEN 'ONLINE SPOTII Jalmudah JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103503 THEN 'ONLINE SPOTII Firdaws FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103504 THEN 'ONLINE SPOTII Jalmudh LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 210001 THEN 'ONLINE SPOTII CORP SALES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102606 THEN 'ONLINE SPOTII Iqrah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103407 THEN 'ONLINE SPOTII Mubarraz FTL'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103406 THEN 'ONLINE SPOTII Mubarraz FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 113002 THEN 'ONLINE SPOTII AJMAN FT LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103408 THEN 'SABB Spotii Sales-Ahsa L FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103309 THEN 'ONLINE SPOTII .Sadaf Khobar Xpress '
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102625 THEN 'ONLINE SPOTII Ishbilia Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101614 THEN 'ONLINE SPOTII Al Salehiyah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101615 THEN 'ONLINE SPOTII Al Salehiyah ladies FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102638 THEN 'ONLINE SPOTII Kharj Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102640 THEN 'ONLINE SPOTII Qyrawan Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102642 THEN 'ONLINE SPOTII RABWA Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103507 THEN 'ONLINE SPOTII Jr ac / Jalmudah'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101150 THEN 'ONLINE SPOTII Al Asalah Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101132 THEN 'ONLINE SPOTII Naseem FT'
                                                END
                                                END  
                                        WHEN t1.crt_type IN (6,7,8) THEN
                                                CASE  
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101101 THEN 'CARD.BSF.Bakhashab FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101102 THEN 'CARD.BSF.SAFA FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101103 THEN 'CARD.BSF.NADA FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101105 THEN 'CARD.BSF.MASARRA PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101106 THEN 'CARD.BSF.Gharnata FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101107 THEN 'CARD.BSF.GHARNATA JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101108 THEN 'CARD.BSF.AZIZIA JEDDAH PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101109 THEN 'CARD.BSF.ANDALUS FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101110 THEN 'CARD.BSF.SABEEN FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101111 THEN 'CARD.BSF.NAEEM FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101112 THEN 'CARD.BSF.OBHUR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101113 THEN 'CARD.BSF SALAMA FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101114 THEN 'CARD.BSF.SALAMA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101115 THEN 'CARD.BSF.MACARONA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101116 THEN 'CARD.BSF.ARBEEN FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101117 THEN 'CARD.BSF.ARBEEN PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101118 THEN 'CARD.BSF.BASATEEN FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101119 THEN 'CARD.NCB.NAJRAN PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101120 THEN 'CARD.BSF.HAMDANIAH FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101121 THEN 'CARD.NCB.SKAKA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101122 THEN 'CARD.BSF.PALESTINE PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101123 THEN 'CARD.BSF.Samer PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101125 THEN 'CARD.BSF.TAIBA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101127 THEN 'CARD.NCB.Jizan PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101128 THEN 'CARD.JAZERA.BAHA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101129 THEN 'CARD.BSF.PALESTINE FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101130 THEN 'CARD.BSF.KILO14 PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101131 THEN 'CARD.NCB.Samer JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101133 THEN 'CARD.BSF.KING ROAD LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101134 THEN 'CARD.BSF.FAWZ FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101135 THEN 'CARD.BSF.FAWZ FT LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101136 THEN 'CARD.BSF.SAMER LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101137 THEN 'CARD.NCB.HAMDANIAH LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101138 THEN 'CARD.BSF.PALESTINE LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101139 THEN 'CARD.BSF.ARBEIN LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101140 THEN 'CARD.BSF.SALAMA LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101141 THEN 'CARD.BSF.MACARONA LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101142 THEN 'CARD.BSF.KING ROAD FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101144 THEN 'CARD.BSF.Jeddah Azizia Xp'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101145 THEN 'CARD Garnata Ladies Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101146 THEN 'CARD.JAZERA.Najran  XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101201 THEN 'CARD.NCB.TAIF PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101202 THEN 'CARD.NCB.SHEHAR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101203 THEN 'CARD.BSF.GHAZALI PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101301 THEN 'CARD.NCB.TABOUK PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101302 THEN 'CARD.BSF.MUROOJ FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101303 THEN 'CARD.BSF.MUROOJ LADIES FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101401 THEN 'CARD.KHAMES MSHAIT PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101402 THEN 'CARD.NCB.Mazaab FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101501 THEN 'CARD.BSF.MADINA RING ROAD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101502 THEN 'CARD.BSF.MADINA AZIZIA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101503 THEN 'CARD.SABB.Madina Az LD PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101504 THEN 'CARD.SABB.Khalida LD FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101505 THEN 'CARD.BSF.SHARQ FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101506 THEN 'CARD.BSF.SHARQ JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101507 THEN 'CARD.BSF.SHARQ PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101508 THEN 'CARD.BSF.Sharq Xpress 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101509 THEN 'CARD Aziziah Med M Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101510 THEN 'CARD.JAZERA.Madina Sharq FTL'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101601 THEN 'CARD.BSF.MECCA RING ROAD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101602 THEN 'CARD.BSF.MECCA SHARAE'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101603 THEN 'CARD.BSF.MECCA OMRA'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101605 THEN 'CARD.BSF.FAYHA FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101606 THEN 'CARD.BSF.WALI ALAHAD PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101607 THEN 'CARD.BSF.AWALY FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101609 THEN 'CARD.BSF.AWALY PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101611 THEN 'CARD.BSF.FAYHA LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101612 THEN 'CARD.BSF.Awali LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101613 THEN 'CARD Wali Alahad Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101701 THEN 'CARD.SABB.WATER FRONT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101702 THEN 'CARD.SABB.WATER FRONT LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101801 THEN 'CARD.BSF.ABHA FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102101 THEN 'CARD.SABB.Shafie FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102102 THEN 'CARD.SABB.Ghadeer FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102103 THEN 'CARD.BSF.Ishbilia FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102104 THEN 'CARD.BSF.Rawabi FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102105 THEN 'CARD.BSF.Swedi FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102106 THEN 'CARD.SABB.Rabwa FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102107 THEN 'CARD.SABB.Mansorah PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102108 THEN 'CARD.SABB.Shefa PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102109 THEN 'CARD.SABB.Shobra PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102110 THEN 'CARD.SABB.Taawon FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102111 THEN 'CARD.BSF.Nakheel FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102113 THEN 'CARD.BSF.Buraidah Muntazah PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102114 THEN 'CARD.SABB.King Abdulaziz FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102115 THEN 'CARD.NCB KHARJ PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102116 THEN 'CARD.BSF.Qadasiya PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102117 THEN 'CARD.SABB.Sahafa PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102119 THEN 'CARD.SABB.Ghadeer PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102120 THEN 'CARD.BSF.Wadi PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102121 THEN 'CARD.SABB.Badea FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102123 THEN 'CARD.BSF.Yarmouk FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102125 THEN 'CARD.BSF.Badea 2 PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102126 THEN 'CARD.SABB.RYD Azizia PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102127 THEN 'CARD.SABB.Hitten FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102128 THEN 'CARD.SABB.King Faisal FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102129 THEN 'CARD.BSF.Yasmeen FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102130 THEN 'CARD.NCB YASMEEN JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102131 THEN 'CARD.BSF.Waha FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102132 THEN 'CARD.SABB.Olaya View FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102133 THEN 'CARD.BSF.Nada FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102134 THEN 'CARD.BSF.Khaleej PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102136 THEN 'CARD.SABB.Western RR FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102138 THEN 'CARD.BSF.Jawdah School JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102139 THEN 'CARD.SABB.Laban PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102140 THEN 'CARD.SABB.Moansiah FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102141 THEN 'CARD.BSF.Naseem PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102144 THEN 'CARD.NCB NADWA PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102145 THEN 'CARD.SABB.RYD KHOZAMA FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102146 THEN 'CARD.BSF.Riyadh Khozama JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102147 THEN 'CARD.SABB.Shabab FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102149 THEN 'CARD.SABB.FCB Escola Riyadh'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102150 THEN 'CARD.NCB. AZIZIA LADIES PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102153 THEN 'CARD.BSF.Unaizah FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102154 THEN 'CARD.BSF.NAFEL LADIES FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102155 THEN 'CARD.NCB KHALEEJ PROLADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102156 THEN 'CARD.NCB ORAJIA LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102158 THEN 'CARD.SABB.Aqeeq LD PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102159 THEN 'CARD.NCB MALGALADIES FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102161 THEN 'CARD.BSF.Hamra LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102163 THEN 'CARD.BSF.Falah LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102165 THEN 'CARD.SABB.NUZHA LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102167 THEN 'CARD.SABB.Rahmania LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102172 THEN 'CARD.NCB.KHALEEJ LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102173 THEN 'CARD.NCB.MOANSIAH LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102175 THEN 'CARD.NCB.BADEA LADIES FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102176 THEN 'CARD.SABB.PNU LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102177 THEN 'CARD.BSF.Yasmeen Ladies'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102178 THEN 'CARD.BSF.RIYADH KHOZAMA LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102179 THEN 'CARD.BSF.YARMOUK LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102182 THEN 'CARD.JAZERA.EHSA XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102183 THEN 'CARD.JAZERA.Bur Muntazah LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102184 THEN 'CARD.JAZERA.Tuwaiq  LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102185 THEN 'CARD.JAZERA.Tuwaiq Xp'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102186 THEN 'CARD.JAZERA.Marwah LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102187 THEN 'CARD.JAZERA.NASEM GHR XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102188 THEN 'CARD.JAZERA.AZIZIZ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102189 THEN 'CARD.JAZERA.NASEM SHA XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102190 THEN 'CARD.JAZERA.NASEM LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102191 THEN 'CARD.JAZERA.MURJ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102193 THEN 'CARD.JAZERA.KHARJ XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102194 THEN 'CARD.JAZERA.KHARJ XP LD'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102195 THEN 'CARD.JAZERA.RIMAL XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102196 THEN 'CARD.JAZERA.QURTBAH XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102198 THEN 'CARD.JAZERA.Al Shifa Bader  XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102201 THEN 'CARD.NCB.HAIL PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102204 THEN 'CARD.JAZERA. Khamashia XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102205 THEN 'CARD.JAZERA.NUQRH XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102206 THEN 'CARD.JAZERA.NUQRH LD XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102303 THEN 'CARD.BSF.EASTERN RR Pro 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102401 THEN 'CARD.NCB.DAWADMI PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102402 THEN 'CARD Dawadmi Ladies FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102403 THEN 'CARD Dawadmi Male Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102501 THEN 'CARD.NCB.Arar PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102601 THEN 'CARD.JAZERA.Al Quds RiyadhXP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102602 THEN 'CARD.JAZERA.Uqadh Riyadh XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102608 THEN 'CARD.SABB.Aqeeq PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103101 THEN 'SABB.FAISALIAH FT.CARD.RECEIPT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103102 THEN 'SABB.SAIHAT PRO.CARD.RECEIPT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103103 THEN 'SABB.GOLDEN BELT FT.CARD.RECEI'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103104 THEN 'CARD.SABB.NOOR PRO'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103105 THEN 'CARD.SABB.OLAYA KHOBAR FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103107 THEN 'SABB.OLAYA PLUS.CARD.RECEIPT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103108 THEN 'SABB.KHZAMA KHOBAR FT.CARD.REC'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103112 THEN 'CARD.SABB.KHBR KHOZ LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103113 THEN 'CARD.SABB.OLAYA LD PLUS'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103201 THEN 'CARD.NCB.HAFAR AL BATIN'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103301 THEN 'CARD.SABB.CORNICHE FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103304 THEN 'CARD.SABB.Montazah FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103305 THEN 'CARD.SABB.FCB Escola Dammam'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103306 THEN 'CARD.SABB.Golden Belt LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103307 THEN 'CARD.SABB.ZOHOUR LADIES FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103308 THEN 'CARD.SABB JAMAEIN LD FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103310 THEN 'CARD.JAZERA.Ashulah XP'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103401 THEN 'CARD.NCB.AHSSA PRO 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103405 THEN 'CARD.NCB.AHSA LADIES'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103501 THEN 'CARD.SABB.JALMUDAH FT 16+'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103502 THEN 'CARD.SABB.JALMUDAH JR'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103503 THEN 'CARD.SABB.FIRDAWS FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103504 THEN 'CARD.NCB.Jalmudah Ladies FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 111001 THEN 'NBD.MAMZER FT GT-501.CARD.REC'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 111004 THEN 'NBD.MAMZER FT LD -506.CARD.REC'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 112001 THEN 'NBD.NAEEM MALL FT GT-901.CARD.REC'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 112002 THEN 'NBD.NAEEM MALL FT LD -901.CARD.REC'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 113001 THEN 'NBD.RASHIDIA PRO-2801.CARD.REC'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 114001 THEN 'NBD.HAZZANA FT GT-901.CARD.REC'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 114002 THEN 'NBD.HAZZANA FT LD-3902.CARD.RE'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102606 THEN 'CARD.JAZERA. Irqah Male FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103407 THEN 'CARD.JAZERA. Ahsa Mubarraz FTL'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103406 THEN 'CARD.JAZERA. Ahsa Mubarraz Male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 113002 THEN 'NBD.AJMAN FT LD-802.CARD.RE'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103408 THEN 'CARD.JAZERA.Ahsa L FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103309 THEN 'SABB.CARD.Sadaf Khobar Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102625 THEN 'SABB.CARD.Ishbilia Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101614 THEN 'SABB.CARD.Al Salehiyah FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101615 THEN 'SABB.CARD.Al Salehiyah ladies FT'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102638 THEN 'SABB.CARD.Kharj Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102640 THEN 'SABB.CARD.Qyrawan Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 102642 THEN 'SABB.CARD.RABWA Xpress male'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 103507 THEN 'SABB.CARD.Jr ac / Jalmudah'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101150 THEN 'SABB.CARD.Al Asalah Xpress'
                                                        WHEN COALESCE(t1.crt_center,t1.inv_center) = 101132 THEN 'SABB.CARD.Naseem FT'
                                                        
                                                END                                                                                                 
                        ELSE 'NEED MAPPING'
                END AS "ReceiptMethodName"
                ,t1."ReceiptNumber"
                ,t1.crt_type
                ,TO_CHAR(longtodatec(t1."ReceiptDate" ,t1.center),'yyyy-MM-dd') AS ReceiptDate
                ,TO_CHAR(longtodatec(t1."GlDate",t1.center),'yyyy-MM-dd') AS GlDate                                                           
                ,CAST(ROUND(t1."Amount",2) AS VARCHAR) AS "Amount"
                ,CASE
                        WHEN t1."CustomerAccountNumber" IS NULL THEN transfer.fullname 
                        ELSE t1."CustomerName"
                END AS "CustomerName"                        
                ,CASE
                        WHEN t1."CustomerAccountNumber" IS NULL THEN transfer.external_id
                        ELSE t1."CustomerAccountNumber"
                END AS "CustomerAccountNumber"
                ,t1."CurrencyCode"
                ,CAST(t1."Club Number" AS VARCHAR) AS "Club Number"
                ,t1."Exerp Invoice ID"
                ,CASE
                        WHEN t1.sex = 'C' THEN 'Company'
                        ELSE 'Individual'
                END AS "Payment Source"
                ,t1.a 
                ,t1.subid                                   
FROM       
       (       
        WITH
          params AS MATERIALIZED
          (
              SELECT
                  datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                  c.id AS CENTER_ID,
                  datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1 AS ToDate
              FROM
                  centers c
         )        
        SELECT
                crt_trans.businessunitname      AS "BusinessUnitName"
                ,crt_trans.gl_account            AS gl_account
                ,crt_trans.crt_type              AS crt_type
                ,crt_trans.crt_center            AS crt_center
                ,crt_trans.inv_center            AS inv_center
                ,crt_trans.coment                AS coment
                ,crt_trans.art_info              AS art_info
                ,crt_trans.transaction_id        AS transaction_id
                ,crt_trans.receiptnumber         AS "ReceiptNumber"
                ,crt_trans.ReceiptDate           AS "ReceiptDate"
                ,crt_trans.GlDate                AS "GlDate"
                ,SUM(crt_trans.Amount)           AS "Amount"
                ,crt_trans.CustomerName          AS "CustomerName"
                ,crt_trans.CustomerAccountNumber AS "CustomerAccountNumber"
                ,crt_trans.pcenter               AS pcenter
                ,crt_trans.pid                   AS pid
                ,crt_trans.CurrencyCode          AS "CurrencyCode"
                ,crt_trans.ClubNumber            AS "Club Number"
                ,crt_trans.ExerpInvoiceID        AS "Exerp Invoice ID"
                ,crt_trans.center
                ,crt_trans.sex
                ,crt_trans.a AS a
                ,crt_trans.subid
        FROM
            (
                SELECT
                    c.org_code2    AS BusinessUnitName 
                    ,ac.external_id AS gl_account 
                    ,CRTTYPE        AS crt_type 
                    ,CASE
                        WHEN CRT.CENTER IN (100,101) THEN INV.CENTER
                        ELSE CRT.CENTER
                    END AS crt_center 
                    ,INV.CENTER     AS inv_center 
                    ,crt.coment     AS coment 
                    ,NULL           AS art_info 
                    ,NULL           AS transaction_id 
                    ,CASE
                        WHEN CRTTYPE = 13 THEN crt.coment
                        WHEN cct.receipt_number IS NOT NULL THEN cct.receipt_number
                        WHEN cct.receipt_number IS NULL AND cct.transaction_id IS NOT NULL THEN cct.transaction_id
                        WHEN cct.receipt_number IS NULL AND cct.transaction_id IS NULL AND inv.center IS NOT NULL THEN inv.center||'inv'||inv.id
                        ELSE cnt.center||'cred'||cnt.id
                    END AS ReceiptNumber 
                    ,CASE
                        WHEN arti.center IS NOT NULL THEN arti.entry_time
                        WHEN artc.center IS NOT NULL THEN artc.entry_time
                        ELSE crt.transtime
                    END AS ReceiptDate 
                    ,CASE
                        WHEN arti.center IS NOT NULL THEN arti.trans_time
                        WHEN artc.center IS NOT NULL THEN artc.trans_time
                        ELSE crt.transtime
                    END AS GlDate 
                    ,CASE
                        WHEN crt.amount > invl.total_amount THEN invl.total_amount
                        ELSE crt.amount
                    END           AS Amount 
                    ,p.fullname    AS CustomerName 
                    ,p.external_id AS CustomerAccountNumber 
                    ,p.center      AS pcenter 
                    ,p.id          AS pid 
                    ,CASE
                        WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                        WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                    END        AS CurrencyCode
                    ,crt.center AS ClubNumber 
                    ,CASE
                        WHEN inv.center IS NOT NULL THEN inv.center||'inv'||inv.id
                        ELSE cnt.center||'cred'||cnt.id
                    END AS ExerpInvoiceID 
                    ,crt.center 
                    ,p.sex 
                    ,crt.subid
                    ,1 AS a
                FROM
                        cashregistertransactions crt
                JOIN
                        centers c
                                ON c.id = crt.center
                JOIN params
                                ON params.CENTER_ID = crt.center
                LEFT JOIN
                        invoices inv
                                ON inv.paysessionid = crt.paysessionid
                                AND inv.cashregister_center = crt.center
                                AND inv.cashregister_id = crt.id
                LEFT JOIN
                        invoice_lines_mt invl
                                ON inv.center = invl.center
                                AND inv.id = invl.id
                LEFT JOIN
                        ar_trans arti
                                ON arti.ref_center = invl.center
                                AND arti.ref_id = invl.id
                                AND arti.ref_subid = invl.subid
                LEFT JOIN
                        credit_notes cnt
                                ON cnt.paysessionid = crt.paysessionid
                                AND cnt.cashregister_center = crt.center
                                AND cnt.cashregister_id = crt.id
                LEFT JOIN
                        credit_note_lines_mt cntl
                                ON cnt.center = cntl.center
                                AND cnt.id = cntl.id
                LEFT JOIN
                        ar_trans artc
                                ON artc.ref_center = cntl.center
                                AND artc.ref_id = cntl.id
                                AND artc.ref_subid = cntl.subid
                                AND artc.ref_type = 'CREDIT_NOTE'
                LEFT JOIN
                        persons p
                                ON p.center = crt.customercenter
                                AND p.id = crt.customerid
                LEFT JOIN
                        creditcardtransactions cct
                                ON cct.gl_trans_center = crt.gltranscenter
                                AND cct.gl_trans_id = crt.gltransid
                                AND cct.gl_trans_subid = crt.gltranssubid
                LEFT JOIN
                        leejam.account_trans act
                                ON act.center = invl.account_trans_center
                                AND act.id = invl.account_trans_id
                                AND act.subid = invl.account_trans_subid
                LEFT JOIN
                        leejam.accounts ac
                                ON ac.center = act.debit_accountcenter
                                AND ac.id = act.debit_accountid
                WHERE
                        crt.center IN (:Scope)
                        AND 
                        crt.transtime BETWEEN params.FromDate AND params.ToDate
                        AND 
                        crt.CRTTYPE NOT IN (4,5,10,11,14,15,16,17,18,19,20,21,100,101)) crt_trans
        GROUP BY
            crt_trans.businessunitname
            ,crt_trans.gl_account
            ,crt_trans.crt_type
            ,crt_trans.crt_center
            ,crt_trans.inv_center
            ,crt_trans.coment
            ,crt_trans.art_info
            ,crt_trans.transaction_id
            ,crt_trans.receiptnumber
            ,crt_trans.ReceiptDate
            ,crt_trans.GlDate
            ,crt_trans.CustomerName
            ,crt_trans.CustomerAccountNumber
            ,crt_trans.pcenter
            ,crt_trans.pid
            ,crt_trans.CurrencyCode
            ,crt_trans.ClubNumber
            ,crt_trans.ExerpInvoiceID
            ,crt_trans.center
            ,crt_trans.sex
            ,crt_trans.a
            ,crt_trans.subid    
        UNION ALL
        SELECT  
                c.org_code2 AS "BusinessUnitName" 
                ,NULL as gl_account
                ,NULL AS crt_type
                ,NULL AS crt_center 
                ,INV.CENTER AS inv_center
                ,NULL AS coment  
                ,art.info AS art_info
                ,NULL AS transaction_id
                ,art.info AS "ReceiptNumber"
                ,art.trans_time AS "ReceiptDate"   
                ,armatch.trans_time AS "GlDate"                                                 
                ,art.amount AS "Amount"
                ,p.fullname AS"CustomerName"
                ,p.external_id AS "CustomerAccountNumber"
                ,p.center as pcenter
                ,p.id as pid
                ,CASE
                        WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                        WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                END AS "CurrencyCode"
                ,art.center AS "Club Number"
                ,inv.center||'inv'||inv.id AS "Exerp Invoice ID"
                ,art.center
                ,p.sex
                ,2 as a
                ,0 AS subid
        FROM 
                account_receivables ar
        JOIN
                ar_trans art   
                        ON art.center = ar.center    
                        AND art.id = ar.id
                        AND art.ref_type = 'ACCOUNT_TRANS' 
        JOIN
                art_match payment
                        ON payment.art_paying_center = art.center
                        AND payment.art_paying_id = art.id
                        AND payment.art_paying_subid = art.subid
        JOIN       
                ar_trans armatch
                        ON payment.art_paid_center = armatch.center
                        AND payment.art_paid_id = armatch.id
                        AND payment.art_paid_subid = armatch.subid
        JOIN
                invoices inv
                        ON armatch.ref_center = inv.center
                        AND armatch.ref_id = inv.id
        JOIN
                centers c
                        ON c.id = art.center
        JOIN
                persons p
                        ON p.center = ar.customercenter
                        AND p.id = ar.customerid
        JOIN 
                params 
                        ON params.CENTER_ID = art.center                                        
        WHERE 
                ar.center IN (:Scope)
                AND
                ar.ar_type IN (1,4)
                AND
                art.employeecenter ||'emp'||art.employeeid in ('100emp2002','100emp4202','100emp12801','100emp23002','100emp23402')
                AND 
                art.text IN ('API Sale Transaction','API Product Sale')
                AND 
                art.trans_time BETWEEN params.FromDate AND params.ToDate 
        UNION ALL
        SELECT  
                c.org_code2 AS "BusinessUnitName" 
                ,debit.external_id as gl_account
                ,NULL AS crt_type
                ,NULL AS crt_center 
                ,NULL AS inv_center
                ,NULL AS coment  
                ,NULL AS art_info
                ,NULL AS transaction_id
                ,debit.name||' '||debit.external_id AS "ReceiptNumber"
                ,payment.trans_time AS "ReceiptDate"   
                ,payment.trans_time AS "GlDate"                                                 
                ,payment.amount AS "Amount"
                ,p.fullname AS"CustomerName"
                ,p.external_id AS "CustomerAccountNumber"
                ,p.center as pcenter
                ,p.id as pid
                ,CASE
                        WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                        WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                END AS "CurrencyCode"
                ,payment.center AS "Club Number"
                ,payment.ref_center||'acc'||payment.ref_id||'tr'||payment.ref_subid AS "Exerp Invoice ID"
                ,payment.center
                ,p.sex
                ,3 as a
                ,0 AS subid
        FROM 
                account_trans act
        JOIN
                centers c                
                        ON c.id = act.center
        JOIN
                ar_trans payment
                        ON act.center = payment.ref_center
                        AND act.id = payment.ref_id
                        AND act.subid = payment.ref_subid
        JOIN
                art_match armatch  
                        ON payment.center = armatch.art_paying_center
                        AND payment.id = armatch.art_paying_id                
                        AND payment.subid = armatch.art_paying_subid                              
        JOIN      
                ar_trans art        
                        ON armatch.art_paid_center = art.center
                        AND armatch.art_paid_id = art.id
                        AND armatch.art_paid_subid = art.subid
                        AND art.ref_type = 'INVOICE'
        JOIN
                invoice_lines_mt invl
                        ON invl.center = art.ref_center
                        AND invl.id = art.ref_id
                        AND invl.subid = art.ref_subid
        JOIN
                invoices inv
                        ON invl.center = inv.center
                        AND invl.id = inv.id                        
        JOIN
                persons p
                        ON p.center = inv.payer_center        
                        AND p.id = inv.payer_id
                        AND p.persontype = 4
        JOIN 
                params 
                        ON params.CENTER_ID = p.center 
        LEFT JOIN
                ACCOUNTS debit
                        ON debit.CENTER = act.DEBIT_ACCOUNTCENTER
                        AND debit.ID = act.DEBIT_ACCOUNTID
        LEFT JOIN
                ACCOUNTS credit
                        ON credit.CENTER = act.CREDIT_ACCOUNTCENTER
                        AND credit.ID = act.CREDIT_ACCOUNTID
        LEFT JOIN
                VAT_TYPES at
                        ON at.CENTER = act.VAT_TYPE_CENTER
                        AND at.id = act.VAT_TYPE_ID                                                               
        WHERE
                act.entry_time BETWEEN params.FromDate AND params.ToDate 
                AND
                act.info_type != 2
                AND 
                act.center IN (:Scope)
        UNION ALL
        SELECT --payment link     
                c.org_code2 AS "BusinessUnitName" 
               	,ac.external_id as gl_account
                ,NULL AS crt_type
                ,NULL AS crt_center 
                ,INV.CENTER AS inv_center
                ,NULL AS coment  
                ,NULL AS art_info
                ,cct.transaction_id AS transaction_id
                ,cct.transaction_id AS "ReceiptNumber"
                ,act.entry_time AS "ReceiptDate"   
                ,act.entry_time AS "GlDate"                                                 
                ,cct.amount AS "Amount"
                ,p.fullname AS "CustomerName"
                ,p.external_id AS "CustomerAccountNumber"
                ,p.center as pcenter
                ,p.id as pid
                ,CASE
                        WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                        WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                END AS "CurrencyCode"
                ,act.center AS "Club Number"
                ,invoice.center||'inv'||invoice.id AS "Exerp Invoice ID"
                ,act.center
                ,p.sex
                ,4 as a
                ,0 AS subid
        FROM
                account_trans act
        JOIN
                creditcardtransactions cct
                        ON cct.gl_trans_center = act.center
                        AND cct.gl_trans_id = act.id
                        AND cct.gl_trans_subid = act.subid
        JOIN
                centers c
                        ON c.id = act.center        
        JOIN
                (SELECT
                        inv.payer_center||'p'||inv.payer_id AS PersonID
                        ,TO_CHAR(longtodatec(inv.trans_time,inv.center), 'YYYY-MM-DD HH') AS InvoiceDate
                        ,sum(invl.total_amount) AS InvoiceAmount
                        ,inv.center
                        ,inv.id
                FROM
                        invoices inv
                JOIN
                        invoice_lines_mt invl
                                ON inv.center = invl.center
                                AND inv.id = invl.id        
                GROUP BY
                        inv.payer_center
                        ,inv.payer_id 
                        ,inv.trans_time
                        ,inv.center
                        ,inv.id
                )invoice
                        ON invoice.PersonID = left(act.text, strpos(act.text, ': ') - 1)
                        AND invoice.InvoiceAmount = act.amount
                        AND invoice.InvoiceDate = TO_CHAR(longtodatec(act.entry_time,act.center), 'YYYY-MM-DD HH')
        JOIN
                invoices inv
                        ON inv.center = invoice.center
                        AND inv.id = invoice.id
        JOIN
                persons p
                        ON p.center = inv.payer_center
                        AND p.id = inv.payer_id
        JOIN
                leejam.accounts ac
                ON ac.center = act.debit_accountcenter
                AND ac.id = act.debit_accountid                         
        JOIN 
                params 
                        ON params.CENTER_ID = act.center                                
        WHERE 
                cct.transaction_state = 2
                AND
                act.center IN (:Scope)
                AND
                act.entry_time BETWEEN params.FromDate AND params.ToDate
        UNION ALL
        SELECT --Manual account trasnactions
                c.org_code2 AS "BusinessUnitName" 
                ,ac.external_id as gl_account
                ,NULL AS crt_type
                ,NULL AS crt_center 
                ,NULL AS inv_center
                ,NULL AS coment  
                ,NULL AS art_info
                ,NULL AS transaction_id
                ,act.text AS "ReceiptNumber"
                ,act.entry_time AS "ReceiptDate"   
                ,act.entry_time AS "GlDate"                                                 
                ,act.amount AS "Amount"
                ,p.fullname AS "CustomerName"
                ,p.external_id AS "CustomerAccountNumber"
                ,p.center as pcenter
                ,p.id as pid
                ,CASE
                        WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                        WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                END AS "CurrencyCode"
                ,act.center AS "Club Number"
                ,NULL AS "Exerp Invoice ID"
                ,act.center
                ,p.sex
                ,5 as a
                ,0 AS subid
        FROM
                account_receivables ar
        JOIN
                persons p             
                ON p.center = ar.customercenter
                AND p.id = ar.customerid
                AND p.sex = 'C'                        
        JOIN
                ar_trans art   
                ON art.center = ar.center    
                AND art.id = ar.id
                AND art.ref_type = 'ACCOUNT_TRANS'
        JOIN
                account_trans act
                ON act.center = art.ref_center
                AND act.id = art.ref_id
                AND act.subid = art.ref_subid
                AND act.info_type NOT IN (1,2)
        JOIN
                centers c
                ON c.id = act.center
        JOIN
                accounts ac
                ON ac.center = act.debit_accountcenter
                AND ac.id = act.debit_accountid
                AND ac.external_id != 'NO_FUSION'                
        JOIN
                params
                ON params.center_id = act.center                                                        
        WHERE
                act.center IN (:Scope)
                AND
                act.entry_time BETWEEN params.FromDate AND params.ToDate
        UNION ALL
        SELECT  --pasrtially used credit notes - Exclude reassignments
                t."BusinessUnitName" 
                ,t.gl_account
                ,min(t.crt_type) AS crt_type 
                ,t.crt_center 
                ,t.inv_center
                ,t.coment  
                ,t.art_info
                ,t.transaction_id
                ,t."ReceiptNumber"
                ,t."ReceiptDate"   
                ,t."GlDate"                                                 
                ,t."Amount" 
                ,t."CustomerName"
                ,t."CustomerAccountNumber"
                ,t.pcenter
                ,t.pid
                ,t."CurrencyCode"
                ,t."Club Number"
                ,t."Exerp Invoice ID"
                ,t.center
                ,t.sex
                ,t.a
                ,0 AS subid
        FROM
        (                
                SELECT DISTINCT
                        c.org_code2 AS "BusinessUnitName" 
                        ,ac.external_id as gl_account
                        ,crt.CRTTYPE AS crt_type
                        ,CASE 
                                WHEN CRT.CENTER IN (100,101) THEN INV.CENTER
                                ELSE CRT.CENTER
                        END AS crt_center 
                        ,INV.CENTER AS inv_center
                        ,crt.coment AS coment  
                        ,NULL AS art_info
                        ,NULL AS transaction_id
                        ,cnt.center||'cred'||cnt.id AS "ReceiptNumber"
                        ,cnt.trans_time AS "ReceiptDate"   
                        ,cnt.trans_time AS "GlDate"                                                 
                        ,CASE
                                WHEN art.center IS NOT NULL THEN -(cntl.total_amount+art.amount)
                                ELSE -crt.amount
                        END AS "Amount" 
                        --,-crt.amount AS "Amount"
                        ,p.fullname AS"CustomerName"
                        ,p.external_id AS "CustomerAccountNumber"
                        ,p.center as pcenter
                        ,p.id as pid
                        ,CASE
                                WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                                WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                        END AS "CurrencyCode"
                        ,cnt.center AS "Club Number"
                        ,inv.center||'inv'||inv.id AS "Exerp Invoice ID"
                        ,cnt.center
                        ,p.sex
                        ,6 as a
                FROM 
                        cashregistertransactions crt
                
                 JOIN 
                        params 
                                ON params.CENTER_ID = crt.center 
                JOIN
                        invoices inv
                                ON inv.paysessionid = crt.paysessionid
                                AND inv.cashregister_center = crt.center
                                AND inv.cashregister_id = crt.id
                JOIN
                        invoice_lines_mt invl  
                                ON inv.center = invl.center
                                AND inv.id = invl.id
                JOIN
                        credit_notes cnt
                                ON cnt.invoice_center = inv.center
                                AND cnt.invoice_id = inv.id
                JOIN
                        centers c
                                ON c.id = cnt.center 
                JOIN 
                        credit_note_lines_mt cntl 
                                ON cnt.center = cntl.center
                                AND cnt.id = cntl.id 
                                AND cntl.reason != 6
                JOIN
                        account_trans act
                                ON act.center = invl.account_trans_center
                                AND act.id = invl.account_trans_id 
                                AND act.subid = invl.account_trans_subid
                JOIN
                        ACCOUNTS ac
                                ON ac.CENTER = act.debit_accountcenter
                                AND ac.ID = act.debit_accountid
                LEFT JOIN
                        persons p
                                ON p.center = crt.customercenter
                                AND p.id = crt.customerid 
               
                LEFT JOIN
                        cashregistertransactions crtcn
                                ON cnt.paysessionid = crtcn.paysessionid
                                AND cnt.cashregister_center = crtcn.center
                                AND cnt.cashregister_id = crtcn.id 
                
                LEFT JOIN
                        ar_trans artc                              
                                ON artc.ref_center = cntl.center
                                AND artc.ref_id = cntl.id
                                AND artc.ref_type = 'CREDIT_NOTE' 
                LEFT JOIN
                        art_match armatch  
                                ON artc.center = armatch.art_paying_center
                                AND artc.id = armatch.art_paying_id                
                                AND artc.subid = armatch.art_paying_subid
                                AND armatch.used_rule = 1
                LEFT JOIN      
                        ar_trans art        
                                ON armatch.art_paid_center = art.center
                                AND armatch.art_paid_id = art.id
                                AND armatch.art_paid_subid = art.subid
                                AND art.ref_type = 'INVOICE'                                             
                WHERE
                        crt.center IN (:Scope)
                        AND
                        cnt.trans_time BETWEEN params.FromDate AND params.ToDate 
                        AND 
                        crt.CRTTYPE NOT IN (5,10,11,15,16,19,20)  
                        AND
                        ac.external_id != 'NO_FUSION'
                        AND
                        cntl.reason != 36 
        )t
        WHERE
                t."Amount" != 0
        GROUP BY
                t."BusinessUnitName" 
                ,t.gl_account
                ,t.crt_center 
                ,t.inv_center
                ,t.coment  
                ,t.art_info
                ,t.transaction_id
                ,t."ReceiptNumber"
                ,t."ReceiptDate"   
                ,t."GlDate"                                                 
                ,t."Amount" 
                ,t."CustomerName"
                ,t."CustomerAccountNumber"
                ,t.pcenter
                ,t.pid
                ,t."CurrencyCode"
                ,t."Club Number"
                ,t."Exerp Invoice ID"
                ,t.center
                ,t.sex
                ,t.a                         
        UNION ALL
        SELECT DISTINCT -- transaction not going through cash register
                c.org_code2 AS "BusinessUnitName" 
                ,ac.external_id as gl_account
                ,0 AS crt_type
                ,0 AS crt_center 
                ,INV.CENTER AS inv_center
                ,NULL AS coment  
                ,art.info AS art_info
                ,NULL AS transaction_id
                ,cnt.center||'cred'||cnt.id AS "ReceiptNumber"
                ,cnt.trans_time AS "ReceiptDate"   
                ,cnt.trans_time AS "GlDate"                                                 
                ,-cntl.total_amount AS "Amount" 
                ,p.fullname AS"CustomerName"
                ,p.external_id AS "CustomerAccountNumber"
                ,p.center as pcenter
                ,p.id as pid
                ,CASE
                        WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                        WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                END AS "CurrencyCode"
                ,cnt.center AS "Club Number"
                ,inv.center||'inv'||inv.id AS "Exerp Invoice ID"
                ,cnt.center
                ,p.sex
                ,7 as a
                ,0 AS subid                    
        FROM
                credit_notes cnt
        JOIN
                credit_note_lines_mt cntl
                ON cnt.center = cntl.center
                AND cnt.id = cntl.id 
                AND cntl.total_amount != 0    
        JOIN
                invoices inv
                ON inv.center = cnt.invoice_center
                AND inv.id = cnt.invoice_id 
        JOIN
                invoice_lines_mt invl
                ON invl.center = inv.center
                AND invl.id = inv.id
                AND invl.reason != 6
        JOIN   
                leejam.account_trans act
                ON act.center = cntl.account_trans_center
                AND act.id = cntl.account_trans_id
                AND act.subid = cntl.account_trans_subid           
        JOIN
                ACCOUNTS ac
                ON ac.CENTER = act.debit_accountcenter
                AND ac.ID = act.debit_accountid  
        JOIN
                centers c
                ON c.id = cnt.center   
        JOIN 
                params 
                ON params.CENTER_ID = cnt.center 
        LEFT JOIN
                persons p
                ON p.center = cnt.payer_center
                AND p.id = cnt.payer_id
        
        LEFT JOIN 
                ar_trans armatch
                ON invl.center = armatch.ref_center
                AND invl.id = armatch.ref_id
                AND armatch.ref_type = 'INVOICE'       
        LEFT JOIN
                art_match payment
                ON payment.art_paid_center = armatch.center
                AND payment.art_paid_id = armatch.id
                AND payment.art_paid_subid = armatch.subid
        LEFT JOIN
                ar_trans art   
                ON payment.art_paying_center = art.center
                AND payment.art_paying_id = art.id
                AND payment.art_paying_subid = art.subid                                                            
        LEFT JOIN
                cashregistertransactions crt
                ON inv.paysessionid = crt.paysessionid
                AND inv.cashregister_center = crt.center
                AND inv.cashregister_id = crt.id                                             
        WHERE
                cnt.trans_time BETWEEN params.FromDate AND params.ToDate
                AND
                crt.center IS NULL  
                AND
                cnt.center IN (:Scope)
                AND
                cntl.reason != 36 
        UNION ALL
        SELECT DISTINCT -- unallocated credit notes
                c.org_code2 AS "BusinessUnitName" 
                ,ac.external_id as gl_account
                ,crt.crttype AS crt_type
                ,CASE
                        WHEN crt.center IN (100,101) THEN invl.center
                        ELSE crt.center
                END AS crt_center 
                ,invl.center AS inv_center
                ,NULL AS coment  
                ,art.info AS art_info
                ,NULL AS transaction_id
                ,cnt.center||'cred'||cnt.id AS "ReceiptNumber"
                ,cnt.trans_time AS "ReceiptDate"   
                ,cnt.trans_time AS "GlDate"                                                 
                ,-cntl.total_amount AS "Amount" 
                ,p.fullname AS"CustomerName"
                ,p.external_id AS "CustomerAccountNumber"
                ,p.center as pcenter
                ,p.id as pid
                ,CASE
                        WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                        WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                END AS "CurrencyCode"
                ,cnt.center AS "Club Number"
                ,invl.center||'inv'||invl.id AS "Exerp Invoice ID"
                ,cnt.center
                ,p.sex
                ,8 as a
                ,0 AS subid                 
        FROM
                credit_notes cnt
        JOIN
                credit_note_lines_mt cntl
                ON cnt.center = cntl.center
                AND cnt.id = cntl.id  
        JOIN
                invoice_lines_mt invl
                ON invl.center = cntl.invoiceline_center
                AND invl.id = cntl.invoiceline_id
                AND invl.subid = cntl.invoiceline_subid
        JOIN   
                leejam.account_trans act
                ON act.center = cntl.account_trans_center
                AND act.id = cntl.account_trans_id
                AND act.subid = cntl.account_trans_subid           
        JOIN
                ACCOUNTS ac
                ON ac.CENTER = act.debit_accountcenter
                AND ac.ID = act.debit_accountid  
        JOIN
                centers c
                ON c.id = cnt.center   
        JOIN 
                params 
                ON params.CENTER_ID = cnt.center 
        LEFT JOIN
                persons p
                ON p.center = cnt.payer_center
                AND p.id = cnt.payer_id
        
        LEFT JOIN 
                ar_trans armatch
                ON invl.center = armatch.ref_center
                AND invl.id = armatch.ref_id
                AND armatch.ref_type = 'INVOICE'       
        LEFT JOIN
                art_match payment
                ON payment.art_paid_center = armatch.center
                AND payment.art_paid_id = armatch.id
                AND payment.art_paid_subid = armatch.subid
        LEFT JOIN
                ar_trans art   
                ON payment.art_paying_center = art.center
                AND payment.art_paying_id = art.id
                AND payment.art_paying_subid = art.subid 
        JOIN
                leejam.invoices inv
                ON inv.center = invl.center
                AND inv.id = invl.id
        JOIN
                cashregistertransactions crt
                ON inv.paysessionid = crt.paysessionid
                AND inv.cashregister_center = crt.center
                AND inv.cashregister_id = crt.id                                                                  
        WHERE
                cnt.trans_time BETWEEN params.FromDate AND params.ToDate
                AND
                cnt.center IN (:Scope)  
                AND
                cnt.invoice_center IS NULL  
                AND
                crt.CRTTYPE NOT IN (5,10,11,15,16,19,20)                                                                                           
        )t1
LEFT JOIN
        persons p
        ON t1.pcenter = p.center
        AND t1.pid = p.id
        AND t1."CustomerAccountNumber" is null
LEFT JOIN
        persons transfer
        ON transfer.center = p.transfers_current_prs_center   
        AND transfer.id = p.current_person_id
WHERE
        t1."Amount" != 0  
)t       
      