SELECT distinct
    q1.members_club,
	q1.person_status,
	q1.member_id,
	q1.title,	
	q1.firstname,
	q1.Lastname,
	q1.add_on_type,
	q1.start_date,
	q1.end_date,
	q1.binding_end_date
/* 	CASE
		WHEN q1.member_price IS NULL THEN Headline_Price 
		ELSE member_price
		END as memberprice,
	q1.headline_price */
    --ar_debt.BALANCE
FROM
    (
        SELECT DISTINCT
--            mpr.id       mpr_id,
--            mpr.GLOBALID mpr_global_id,
--            sa.CENTER_ID center__id,
--            prod.NAME    cat,
--            mpr2.ID      mpr2_id,
            c.id,
            c.SHORTNAME                                                                                                                                                                        members_club,
            DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS person_STATUS,
            p.CENTER || 'p' || p.ID                                                                                                                                                            member_id,
            mpr.CACHED_PRODUCTNAME                                                                                                                                                             add_on_type,
            sa.START_DATE,
            sa.END_DATE,
            sa.BINDING_END_DATE,
            /* sa.INDIVIDUAL_PRICE_PER_UNIT Member_price,
            mpr2.CACHED_PRODUCTPRICE     headline_price,
            CASE
                WHEN mpr2.PRODUCT IS NULL
                THEN NULL
                WHEN FIRST_VALUE(to_date(q.changeDate,'yyyy-MM-dd')) OVER (PARTITION BY mpr2.id ORDER BY to_date(q.changeDate,'yyyy-MM-dd') desc ) > SYSDATE
                THEN FIRST_VALUE(to_number(q.price,'9999.99')) OVER (PARTITION BY mpr2.id ORDER BY to_date(q.changeDate,'yyyy-MM-dd') desc )
                ELSE NULL
            END AS NEXT_PRICE_CHANGE_CLUB,
            CASE
                WHEN mpr2.PRODUCT IS NULL
                THEN NULL
                WHEN FIRST_VALUE(to_date(q.changeDate,'yyyy-MM-dd')) OVER (PARTITION BY mpr2.id ORDER BY to_date(q.changeDate,'yyyy-MM-dd') desc ) > SYSDATE
                THEN FIRST_VALUE(to_date(q.changeDate,'yyyy-MM-dd')) OVER (PARTITION BY mpr2.id ORDER BY to_date(q.changeDate,'yyyy-MM-dd') desc )
                ELSE NULL
            END AS NEXT_PRICE_CHANGE_DATE_CLUB,
            CASE
                WHEN FIRST_VALUE(to_date(q2.changeDate,'yyyy-MM-dd')) OVER (PARTITION BY mpr2.id ORDER BY to_date(q2.changeDate,'yyyy-MM-dd') desc ) > SYSDATE
                THEN FIRST_VALUE(to_number(q2.price,'9999.99')) OVER (PARTITION BY mpr2.id ORDER BY to_date(q2.changeDate,'yyyy-MM-dd') desc )
                ELSE NULL
            END AS NEXT_PRICE_CHANGE_DEF,
            CASE
                WHEN FIRST_VALUE(to_date(q2.changeDate,'yyyy-MM-dd')) OVER (PARTITION BY mpr2.id ORDER BY to_date(q2.changeDate,'yyyy-MM-dd') desc ) > SYSDATE
                THEN FIRST_VALUE(to_date(q2.changeDate,'yyyy-MM-dd')) OVER (PARTITION BY mpr2.id ORDER BY to_date(q2.changeDate,'yyyy-MM-dd') desc )
                ELSE NULL
            END                                            AS NEXT_PRICE_CHANGE_DATE_DEF , */

            --cc.AMOUNT                                                                                                                       CC_AMOUNT,
            ROUND(months_between(SYSDATE,sa.START_DATE),2)                                                                                  months_from_start,
            atts.TXTVALUE                                                                                                                   title,
            p.FIRSTNAME,
            p.LASTNAME,
            p.ADDRESS1,
            p.ADDRESS2,
            p.ADDRESS3,
            p.ZIPCODE,
            p.CITY,
            m.FULLNAME     manager_name,
            c.PHONE_NUMBER club_phone_number ,
            sa.QUANTITY,
            oldId.TXTVALUE legacySystemId,
            mpr.INFO_TEXT,
            m.CENTER || 'p' || m.ID manager_pid,
            p.CENTER                p_center,
            p.ID                    p_id,
			sa.center_id addon_center,
			sa_c.shortname pt_by_dd_club_name
        FROM
            SUBSCRIPTION_ADDON sa
		left join centers sa_c on sa_c.id = sa.CENTER_ID
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = sa.SUBSCRIPTION_CENTER
            AND s.ID = sa.SUBSCRIPTION_ID
        JOIN
            PERSONS p
        ON
            p.CENTER = s.OWNER_CENTER
            AND p.ID = s.OWNER_ID
        LEFT JOIN
            PERSON_EXT_ATTRS atts
        ON
            atts.PERSONCENTER = p.CENTER
            AND atts.PERSONID = p.ID
            AND atts.NAME = '_eClub_Salutation'
        LEFT JOIN
            PERSON_EXT_ATTRS oldId
        ON
            oldId.PERSONCENTER = p.CENTER
            AND oldId.PERSONID = p.ID
            AND oldId.NAME = '_eClub_OldSystemPersonId'
        JOIN
            CENTERS c
        ON
            c.ID = p.CENTER
        LEFT JOIN
            PERSONS m
        ON
            m.CENTER = c.MANAGER_CENTER
            AND m.ID = c.MANAGER_ID
        JOIN
            MASTERPRODUCTREGISTER mpr
        ON
            mpr.ID = sa.ADDON_PRODUCT_ID
        LEFT JOIN
            MASTERPRODUCTREGISTER mpr2
        ON
            mpr2.GLOBALID = mpr.GLOBALID
            AND mpr2.SCOPE_TYPE = 'C'
            AND mpr2.SCOPE_ID = sa.CENTER_ID
/*         LEFT JOIN
            xmltable('//product/prices/price' passing xmltype(UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(NVL(mpr2.PRODUCT,mpr.PRODUCT), 4000,1), 'UTF8')) columns price VARCHAR2(21) path 'normalPrice' , changeDate VARCHAR2(21) path '@start' ) q
        ON
            (
                1=1)
            
        LEFT JOIN
            xmltable('//product/prices/price' passing xmltype(UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(mpr.PRODUCT, 4000,1), 'UTF8')) columns price VARCHAR2(21) path 'normalPrice' , changeDate VARCHAR2(21) path '@start' ) q2
        ON
            (
                1=1) */
            
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = sa.SUBSCRIPTION_CENTER
            AND prod.GLOBALID = mpr.GLOBALID
   /*      LEFT JOIN
            CASHCOLLECTIONCASES cc
        ON
            cc.PERSONCENTER = p.CENTER
            AND cc.PERSONID = p.ID
            AND cc.CLOSED = 0
            AND cc.SUCCESSFULL = 0
            AND cc.MISSINGPAYMENT = 1 */
        WHERE
			sa.CENTER_ID IN($$Scope$$) AND
            (
                sa.END_DATE >= SYSDATE
                OR sa.END_DATE IS NULL )
            AND sa.CANCELLED = 0
            AND EXISTS
            (
                SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK link
                WHERE
                    link.PRODUCT_CENTER = prod.CENTER
                    AND link.PRODUCT_ID = prod.ID
                    AND link.PRODUCT_GROUP_ID = 284 ) )q1


