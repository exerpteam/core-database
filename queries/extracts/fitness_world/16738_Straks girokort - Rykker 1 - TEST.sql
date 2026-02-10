-- The extract is extracted from Exerp on 2026-02-08
--  
select rpad(FileLine, 128, ' ') as FileLine, 'END' from (
SELECT 
    case
        when levels.clearinghouse is not null and ch_hf.id = 101 then 'A'
        when levels.clearinghouse is not null and ch_hf.id = 102 then 'Z'
        when levels.creditor_id is not null and ch_hf.id = 101 then 'A-' || levels.creditor_id || '-A'
        when levels.creditor_id is not null and ch_hf.id = 102 then 'A-' || levels.creditor_id || '-Z'
        else 'A-' || levels.creditor_id_2 || '-B-' || LINE_IDX 
    end    as Rank,
    levels.clearinghouse,
    decode(ch_hf.id, 101, 'HEADER', 102, 'FOOTER') as HF,
    levels.CREDITOR_ID,
    levels.Line,
    levels.cnt_lines,
    levels.amount,
    levels.creditor_id_2,
    case
        when levels.clearinghouse is not null and ch_hf.id = 101 then 'BS002' || levels.CH_DATASUPPLIER_ID || 'BS1' || '0601' || to_char(exerpsysdate(), 'DDMMYY') ||  LPAD(levels.FILE_ID, 4, '0') || LPAD(' ', 19, ' ') || to_char(exerpsysdate(), 'DDMMYY')
        when levels.clearinghouse is not null and ch_hf.id = 102 then 'BS992' || levels.CH_DATASUPPLIER_ID || 'BS1' || '0601' 
            || LPAD(levels.cnt_creditor, 11, '0')  -- count sections
            || LPAD(levels.cnt_lines / 9, 11, '0') -- count 042
            || LPAD(levels.amount*100 / 9, 15, '0') -- amount for recordtype 042
            || LPAD(levels.cnt_lines / 9 * 4, 11, '0') -- count 052 and 062
            || LPAD('0', 15, '0') 
            || LPAD(levels.cnt_lines / 9 * 4, 11, '0')  -- count 022
            || LPAD('0', 34, '0') 
        when levels.creditor_id is not null and ch_hf.id = 101 then 'BS012' || lpad(levels.creditor_id, 8, '0') || '0117' || '     ' || lpad(levels.CR_DEBGRPNO, 5, '0') || RPAD(substr(levels.CH_NAME, 1, 15), 15, ' ') || '    ' || to_char(exerpsysdate(), 'DDMMYYYY') || LPAD(' ', 4, ' ') || LPAD(' ', 10, ' ')
        when levels.creditor_id is not null and ch_hf.id = 102 then 'BS092' || lpad(levels.creditor_id, 8, '0') || '0117' || '00000' || lpad(levels.CR_DEBGRPNO, 5, '0') || '    ' 
            || LPAD(levels.cnt_lines / 9, 11, '0')  -- count 042
            || LPAD(levels.amount*100 / 9, 15, '0')
            || LPAD(levels.cnt_lines / 9 * 4, 11, '0')  -- count 052
            || LPAD(' ', 15, ' ') 
            || LPAD(levels.cnt_lines / 9 * 4, 11, '0')  -- count 022

        else Line 
    end    as FileLine
    
FROM
    (
        SELECT
            flat.clearinghouse,
            flat.CREDITOR_ID,
            flat.Line,
            COUNT(*)         AS cnt_lines,
            SUM(flat.amount) AS amount,
            count(distinct flat.creditor_id) as cnt_creditor,
            max(flat.creditor_id) as creditor_id_2,
            max(CR_NAME) as CR_NAME,
            max(CR_REGNO) as CR_REGNO,
            max(CR_ACCNO) as CR_ACCNO,
            max(CR_DEBGRPNO) as CR_DEBGRPNO,
            max(CH_NAME) as CH_NAME,
            max(CH_DATASUPPLIER_ID) as CH_DATASUPPLIER_ID,
            max(LINE_IDX) as LINE_IDX,
			:file_id as FILE_ID
        FROM
            (
                SELECT
                    pa.ref || '-' || c.id as LINE_IDX,
                    pa.CLEARINGHOUSE,
                    cr.FIELD_6 as CREDITOR_ID,
                    requests.amount                                                           AS amount,
                    case 
                        when c.id = 122 then 'BS022' || lpad(cr.FIELD_6, 8, '0') || '0240' || '00001' || lpad(cr.FIELD_5, 5, '0') || lpad(pa.ref, 15, '0') || '000000000' || substr(p.FULLNAME, 1, 35)
                        when c.id = 123 then 'BS022' || lpad(cr.FIELD_6, 8, '0') || '0240' || '00002' || lpad(cr.FIELD_5, 5, '0') || lpad(pa.ref, 15, '0') || '000000000' || substr(p.ADDRESS1, 1, 35)
                        when c.id = 124 then 'BS022' || lpad(cr.FIELD_6, 8, '0') || '0240' || '00003' || lpad(cr.FIELD_5, 5, '0') || lpad(pa.ref, 15, '0') || '000000000' || case when p.country is null or p.country = 'DK' then substr(p.ADDRESS2, 1, 35) else substr(p.ZIPCODE || ' ' || p.CITY, 1, 35) end
                        when c.id = 129 then 'BS022' || lpad(cr.FIELD_6, 8, '0') || '0240' || '00009' || lpad(cr.FIELD_5, 5, '0') || lpad(pa.ref, 15, '0') || '000000000' || lpad(' ', 15, ' ') || case when p.country is null or p.country = 'DK' then nvl(lpad(p.zipcode, 4, '0'), '0000') else '0000' || p.country end

                        when c.id = 142 then 'BS042' || lpad(cr.FIELD_6, 8, '0') || '0285' || '00000' || lpad(cr.FIELD_5, 5, '0') || lpad(pa.ref, 15, '0') || '000000000' || to_char(requests.dueDate, 'DDMMYYYY') || '1' || lpad(requests.amount*100, 13, '0') || rpad('000000', 9, ' ') || '00'
                        when c.id = 152 then 'BS052' || lpad(cr.FIELD_6, 8, '0') || '0241' || '00001' || lpad(cr.FIELD_5, 5, '0') || lpad(pa.ref, 15, '0') || '000000000' || ' ' || substr(requests.line1, 1, 60)
                        when c.id = 153 then 'BS052' || lpad(cr.FIELD_6, 8, '0') || '0241' || '00002' || lpad(cr.FIELD_5, 5, '0') || lpad(pa.ref, 15, '0') || '000000000' || ' ' || substr(requests.line2, 1, 60)
                        when c.id = 154 then 'BS052' || lpad(cr.FIELD_6, 8, '0') || '0241' || '00003' || lpad(cr.FIELD_5, 5, '0') || lpad(pa.ref, 15, '0') || '000000000' || ' ' || substr(requests.line3, 1, 60)
                        when c.id = 155 then 'BS052' || lpad(cr.FIELD_6, 8, '0') || '0241' || '00004' || lpad(cr.FIELD_5, 5, '0') || lpad(pa.ref, 15, '0') || '000000000' || ' ' || substr(requests.line4, 1, 60)
                    end as Line,
--                    pa.CREDITOR_ID || ' - ' || pa.ref || ' - Line ' || (c.id-100) AS Line,
                    cr.CREDITOR_NAME as CR_NAME,
                    cr.FIELD_1 as CR_REGNO,
                    cr.FIELD_3 as CR_ACCNO,
                    cr.FIELD_5 as CR_DEBGRPNO,
                    ch.NAME as CH_NAME,
                    ch.DATASUPPLIER_ID as CH_DATASUPPLIER_ID
                FROM
                    FW.PAYMENT_AGREEMENTS pa,
                    FW.CLEARINGHOUSE_CREDITORS cr,
                    FW.CLEARINGHOUSES ch,
                    centers c,
                    FW.PERSONS p,
                    FW.ACCOUNT_RECEIVABLES ar,
                    /** subquery to get the data **/
                    (

SELECT DISTINCT
        pagr.center,
	pagr.id,
	pagr.subid,
        least(ccc.amount,-ar.BALANCE) AS AMOUNT, 
:due_date
--to_date('2013-01-01', 'YYYY-MM-DD') 
 as dueDate, :line1 as line1, :line2 as line2, :line3 as line3, :line4 as line4

FROM
    CASHCOLLECTIONCASES ccc
JOIN PERSONS p
ON
    p.CENTER = ccc.PERSONCENTER
    AND p.id = ccc.PERSONID
JOIN ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
    AND ar.AR_TYPE = 4
JOIN PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.id
JOIN PAYMENT_AGREEMENTS pagr
ON
    pagr.CENTER = pac.ACTIVE_AGR_CENTER
    AND pagr.ID = pac.ACTIVE_AGR_ID
    AND pagr.SUBID = pac.ACTIVE_AGR_SUBID
JOIN CLEARINGHOUSES ch
ON
    ch.id = pagr.CLEARINGHOUSE
JOIN CLEARINGHOUSE_CREDITORS chc
ON
    chc.CLEARINGHOUSE = ch.id
    AND chc.CREDITOR_ID = pagr.CREDITOR_ID
WHERE
    ccc.MISSINGPAYMENT = 1
    AND ccc.CLOSED = 0
    AND p.sex != 'C'
    AND ar.balance < 0
    AND ch.DATASUPPLIER_ID = :datasupplier_id
    AND p.status < 4
	AND (p.center, p.id) in (:member_ids)
) requests
                WHERE
                     pa.CENTER = ar.center and pa.ID = ar.id 
                    and p.center = ar.CUSTOMERCENTER and p.id = ar.CUSTOMERID
                    and pa.CLEARINGHOUSE = ch.id and ch.id = cr.CLEARINGHOUSE and cr.CREDITOR_ID = pa.CREDITOR_ID and
                    c.id IN (122,123,124,129,142,152,153,154,155)
                    and requests.center = pa.center and requests.id = pa.id and requests.subid = pa.subid
--                AND pa.CENTER IN (101,102)
--                AND pa.state = 4
                ORDER BY
                    1
            )
            flat
        GROUP BY
            GROUPING SETS(flat.clearinghouse, CREDITOR_ID, Line)
    )
    levels
    left join centers ch_hf on line is null and ch_hf.id IN (101,102)
order by 1
)