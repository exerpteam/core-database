SELECT
    CASE
        WHEN FREEZE_CREATED < $$cut_date$$
            AND INVOICED != 'INVOICED'
        THEN 1
        ELSE 0
    END AS WILL_GET_DISCOUNT,
    i1.*
FROM
    (
        SELECT
            sfp.ID FREEZE_PERIOD_ID,
            sfp.TYPE,
            s.CENTER || 'ss' || s.ID                                                                                                                                                ssid,
            s.OWNER_CENTER || 'p' || s.OWNER_ID                                                                                                                                     pid,
            DECODE (s.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN')                                                                                  AS SUB_STATE,
            DECODE (s.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN') AS SUB_SUB_STATE,
            longToDate(sfp.ENTRY_TIME)                                                                                                                                         FREEZE_CREATED,
            sfp.START_DATE                                                                                                                                                             FREEZE_START,
            sfp.END_DATE                                                                                                                                                               FREEZE_END,
            s.BILLED_UNTIL_DATE                                                                                                                                                        SUB_BILLED_UNTIL,
            /* So if the sub has been billed past the end date or if the sub is not ACTIVE, CREATED, OR FROZEN */
            CASE
                WHEN sfp.END_DATE <= s.BILLED_UNTIL_DATE
                    OR s.STATE NOT IN(2,4,8)
                THEN 'INVOICED'
                ELSE 'NOT INVOICED'
            END AS INVOICED
        FROM
            SUBSCRIPTION_FREEZE_PERIOD sfp
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = sfp.SUBSCRIPTION_CENTER
            AND s.id = sfp.SUBSCRIPTION_ID
            /* Get rid of the cash subs */
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND st.ID = s.SUBSCRIPTIONTYPE_ID
            AND st.ST_TYPE = 1
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = st.CENTER
            AND prod.ID = st.ID
            /* the really hidious part */
            AND ( (
                    prod.CENTER IN (5,16,26,53)
                    AND prod.NAME = 'Club Only 12 Month' )
                OR (
                    prod.CENTER IN (6)
                    AND prod.NAME = 'Club Only 16 Plus Annual' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Club Only 16 Plus Flexi' )
                OR (
                    prod.CENTER IN (26)
                    AND prod.NAME = 'Club Only 55 Plus 3 Month' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,17,19,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Club Only 55 Plus Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,26,27,28)
                    AND prod.NAME = 'Club Only 55 Plus Price for Life Flexi' )
                OR (
                    prod.CENTER IN (9)
                    AND prod.NAME = 'Club Only Bradford Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Club Only Club 18-25 6 Month' )
                OR (
                    prod.CENTER IN (46,53,61,73)
                    AND prod.NAME = 'Club Only Club 18-25 6 Month Upfront' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Club Only Corporate Flexi' )
                OR (
                    prod.CENTER IN (73)
                    AND prod.NAME = 'Club Only Corporate Funded Flexi' )
                OR (
                    prod.CENTER IN (73)
                    AND prod.NAME = 'Club Only Corporate Funded Flexi Annual' )
                OR (
                    prod.CENTER IN (26,53)
                    AND prod.NAME = 'Club Only Denton Flexi' )
                OR (
                    prod.CENTER IN (24)
                    AND prod.NAME = 'Club Only Family Bundle 12 Month' )
                OR (
                    prod.CENTER IN (2,5,8,15,16,17,19,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Club Only Flexi' )
                OR (
                    prod.CENTER IN (27)
                    AND prod.NAME = 'Club Only Harlow Flexi' )
                OR (
                    prod.CENTER IN (8,22,26)
                    AND prod.NAME = 'Club Only Joint 12 Month' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Club Only Joint Flexi' )
                OR (
                    prod.CENTER IN (5,6,8,15,16,17,19,24,26,27,28)
                    AND prod.NAME = 'Club Only Legacy Off Peak 12 Month' )
                OR (
                    prod.CENTER IN (5,6,8,15,16,17,19,24,26,27,28)
                    AND prod.NAME = 'Club Only Legacy Off Peak Club 18-25 6 Month' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28)
                    AND prod.NAME = 'Club Only Legacy Off Peak Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Club Only Off Peak 12 Month' )
                OR (
                    prod.CENTER IN (2,6,8,13,15,16,19,22,24,26,27,28,44,53,61)
                    AND prod.NAME = 'Club Only Off Peak 55 Plus Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,13,15,16,17,19,22,24,26,27,28)
                    AND prod.NAME = 'Club Only Off Peak 55 Plus Price for Life Flexi' )
                OR (
                    prod.CENTER IN (44,46,53,61,73)
                    AND prod.NAME = 'Club Only Off Peak Club 18-25 6 Month' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,53,73)
                    AND prod.NAME = 'Club Only Off Peak Flexi' )
                OR (
                    prod.CENTER IN (5,6,19,22)
                    AND prod.NAME = 'Club Only Off Peak Tribe Flexi' )
                OR (
                    prod.CENTER IN (5,61)
                    AND prod.NAME = 'Club Only Price for Life Adult Flexi' )
                OR (
                    prod.CENTER IN (14)
                    AND prod.NAME = 'Club Only Putney Flexi' )
                OR (
                    prod.CENTER IN (73)
                    AND prod.NAME = 'Club Only Staines Flexi' )
                OR (
                    prod.CENTER IN (17,22,26,27,44,46,53,61,73)
                    AND prod.NAME = 'Club Only Student Flexi' )
                OR (
                    prod.CENTER IN (44,46,73)
                    AND prod.NAME = 'HP Legacy Corporate Flexi' )
                OR (
                    prod.CENTER IN (44,46,53,61,73)
                    AND prod.NAME = 'HP Legacy Flexi' )
                OR (
                    prod.CENTER IN (44,46,53)
                    AND prod.NAME = 'HP Legacy Joint Flexi' )
                OR (
                    prod.CENTER IN (46,53,61,73)
                    AND prod.NAME = 'Legacy Off Peak Corporate Flexi' )
                OR (
                    prod.CENTER IN (46,53,61,73)
                    AND prod.NAME = 'Legacy Off Peak Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Multiclub 12 Month' )
                OR (
                    prod.CENTER IN (2,24)
                    AND prod.NAME = 'Multiclub 16 Plus Flexi' )
                OR (
                    prod.CENTER IN (9)
                    AND prod.NAME = 'Multiclub Bradford Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,24,26,27,28)
                    AND prod.NAME = 'Multiclub Club 18-25 6 Month' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Multiclub Corporate 12 Month' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Multiclub Corporate Flexi' )
                OR (
                    prod.CENTER IN (73)
                    AND prod.NAME = 'Multiclub Corporate Funded Flexi' )
                OR (
                    prod.CENTER IN (53)
                    AND prod.NAME = 'Multiclub Denton Flexi' )
                OR (
                    prod.CENTER IN (8,22,26)
                    AND prod.NAME = 'Multiclub Family Bundle 12 Month' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Multiclub Flexi' )
                OR (
                    prod.CENTER IN (27)
                    AND prod.NAME = 'Multiclub Harlow Flexi' )
                OR (
                    prod.CENTER IN (2,8,15,19,26,27,46,73)
                    AND prod.NAME = 'Multiclub Joint Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,13,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Multiclub Legacy VA 12 Month' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28)
                    AND prod.NAME = 'Multiclub Legacy VA 16 Plus Flexi' )
                OR (
                    prod.CENTER IN (6)
                    AND prod.NAME = 'Multiclub Legacy VA 16 Plus Flexi Annual' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28)
                    AND prod.NAME = 'Multiclub Legacy VA 55 Plus Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28)
                    AND prod.NAME = 'Multiclub Legacy VA 55 Plus Price For Life Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Multiclub Legacy VA Corporate 12 Month' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Multiclub Legacy VA Corporate Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Multiclub Legacy VA Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28)
                    AND prod.NAME = 'Multiclub Legacy VA Joint Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,46,73)
                    AND prod.NAME = 'Multiclub Legacy VA Pru 25% Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Multiclub Legacy VA Pru Health 50% Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28)
                    AND prod.NAME = 'Multiclub Legacy VA Student Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Multiclub Legacy VA Tribe 12 Month' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Multiclub Legacy VA Tribe Flexi' )
                OR (
                    prod.CENTER IN (22,46,73)
                    AND prod.NAME = 'Multiclub Pru 25% Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Multiclub Pru Health 50% Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,46,53,61,73)
                    AND prod.NAME = 'Multiclub Pru Legacy 50% Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,24,26,27,28,44,53,61)
                    AND prod.NAME = 'Multiclub Pru Vitality 25% Flexi' )
                OR (
                    prod.CENTER IN (14)
                    AND prod.NAME = 'Multiclub Putney Flexi' )
                OR (
                    prod.CENTER IN (73)
                    AND prod.NAME = 'Multiclub Temporary Flexi' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Multiclub Tribe 12 Month' )
                OR (
                    prod.CENTER IN (2,5,6,8,15,16,17,19,22,24,26,27,28,44,46,53,61,73)
                    AND prod.NAME = 'Multiclub Tribe Flexi' ) )
        WHERE
            sfp.STATE = 'ACTIVE'
			and s.center in ($$scope$$)
            AND s.STATE IN (2,4,8) ) i1

