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
            || LPAD(levels.cnt_lines / 6, 11, '0') -- count 042
            || LPAD(levels.amount*100 / 6, 15, '0') -- amount for recordtype 042
            || LPAD(levels.cnt_lines / 6, 11, '0') -- count 052 and 062
            || LPAD('0', 15, '0') 
            || LPAD(levels.cnt_lines / 6 * 4, 11, '0')  -- count 022
            || LPAD('0', 34, '0') 
        when levels.creditor_id is not null and ch_hf.id = 101 then 'BS012' || lpad(levels.creditor_id, 8, '0') || '0112' || '     ' || lpad(levels.CR_DEBGRPNO, 5, '0') || RPAD(substr(levels.CH_NAME, 1, 15), 15, ' ') || '    ' || to_char(exerpsysdate(), 'DDMMYYYY') || lpad(levels.CR_REGNO, 4, '0') || lpad(levels.CR_ACCNO, 10, '0')
        when levels.creditor_id is not null and ch_hf.id = 102 then 'BS092' || lpad(levels.creditor_id, 8, '0') || '0112' || '00000' || lpad(levels.CR_DEBGRPNO, 5, '0') || '    ' 
            || LPAD(levels.cnt_lines / 6, 11, '0')  -- count 042
            || LPAD(levels.amount*100 / 6, 15, '0')
            || LPAD(levels.cnt_lines / 6, 11, '0')  -- count 052
            || LPAD(' ', 15, ' ') 
            || LPAD(levels.cnt_lines / 6 * 4, 11, '0')  -- count 022

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
                    refunds.amount                                                           AS amount,
                    case 
                        when c.id = 122 then 'BS022' || lpad(cr.FIELD_6, 8, '0') || '0240' || '00001' || lpad(cr.FIELD_5, 5, '0') || lpad(pa.ref, 15, '0') || '000000000' || substr(p.FULLNAME, 1, 35)
                        when c.id = 123 then 'BS022' || lpad(cr.FIELD_6, 8, '0') || '0240' || '00002' || lpad(cr.FIELD_5, 5, '0') || lpad(pa.ref, 15, '0') || '000000000' || substr(p.ADDRESS1, 1, 35)
                        when c.id = 124 then 'BS022' || lpad(cr.FIELD_6, 8, '0') || '0240' || '00003' || lpad(cr.FIELD_5, 5, '0') || lpad(pa.ref, 15, '0') || '000000000' || case when p.country is null or p.country = 'DK' then substr(p.ADDRESS2, 1, 35) else substr(p.ZIPCODE || ' ' || p.CITY, 1, 35) end
                        when c.id = 129 then 'BS022' || lpad(cr.FIELD_6, 8, '0') || '0240' || '00009' || lpad(cr.FIELD_5, 5, '0') || lpad(pa.ref, 15, '0') || '000000000' || lpad(' ', 15, ' ') || case when p.country is null or p.country = 'DK' then nvl(lpad(p.zipcode, 4, '0'), '0000') else '0000' || p.country end

                        when c.id = 142 then 'BS042' || lpad(cr.FIELD_6, 8, '0') || '0280' || '00000' || lpad(cr.FIELD_5, 5, '0') || lpad(pa.ref, 15, '0') || '000000000' || to_char(refunds.refundDate, 'DDMMYYYY') || '2' || lpad(refunds.amount*100, 13, '0') || rpad(to_char(refunds.refundDate, 'YYMMDD'), 30, ' ') || '00'
                        when c.id = 152 then 'BS052' || lpad(cr.FIELD_6, 8, '0') || '0241' || '00001' || lpad(cr.FIELD_5, 5, '0') || lpad(pa.ref, 15, '0') || '000000000' || ' ' || refunds.refundText
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
                        select pag2.center, pag2.id, pag2.subid, :amount as amount, :refund_date as refundDate, :refund_text as refundText
                        from PAYMENT_AGREEMENTS pag2
                        join FW.CLEARINGHOUSES ch2 on ch2.id = pag2.CLEARINGHOUSE
                        where pag2.ref = :ref and ch2.DATASUPPLIER_ID = :datasupplier_id
                    ) refunds
                WHERE
                     pa.CENTER = ar.center and pa.ID = ar.id 
                    and p.center = ar.CUSTOMERCENTER and p.id = ar.CUSTOMERID
                    and pa.CLEARINGHOUSE = ch.id and ch.id = cr.CLEARINGHOUSE and cr.CREDITOR_ID = pa.CREDITOR_ID and
                    c.id IN (122,123,124,129,142,152)
                    and refunds.center = pa.center and refunds.id = pa.id and refunds.subid = pa.subid
--                AND pa.CENTER IN (101,102)
                AND pa.state = 4
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