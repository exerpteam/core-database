/**
* Creator: Exerp
* Purpose: List changes of classplanning to track changes in
* employees scheduling
*/
SELECT
    book.CREATOR_CENTER || 'p' || book.CREATOR_ID created_by_pid,
    pCre.FULLNAME cre_name,
    p.CENTER || 'p' || p.ID change_pid,
    emp.CENTER || 'emp' || emp.ID changed_by_empId,
    p.FULLNAME changed_by_name,
    bc.TYPE change_type,
    to_char(longToDate(bc.TIME),'yyyy-MM-dd HH24:MI') changed_IME,
    bc.VALUE_BEFORE,
    bc.VALUE_AFTER,
    book.CENTER || 'book' || book.ID booking_Id,
    book.NAME booking_name,
    book.CLASS_CAPACITY booking_capacity,
    book.WAITING_LIST_CAPACITY booking_waiting_list,
    book.DESCRIPTION book_description,
    book.COMENT booking_comment,
    to_char(longToDate(book.CANCELATION_TIME),'yyyy-MM-dd HH24:MI')   booking_CANCELATION_TIME,
    book.CANCELATION_BY_CENTER || 'p' || book.CANCELATION_BY_ID cancelledByEmpId,
    cg.NAME booking_color_group_name,
    to_char(longToDate(book.STARTTIME),'yyyy-MM-dd HH24:MI')  booking_start

FROM
    BOOKINGS book
LEFT JOIN BOOKING_CHANGE bc
ON
    book.CENTER = bc.BOOKING_CENTER
    AND book.ID = bc.BOOKING_ID
LEFT JOIN COLOUR_GROUPS cg
ON
    cg.ID = book.COLOUR_GROUP_ID
LEFT JOIN EMPLOYEES emp
ON
    emp.CENTER = bc.EMPLOYEE_CENTER
    AND emp.ID = bc.EMPLOYEE_ID
LEFT JOIN PERSONS p
ON
    p.CENTER = emp.PERSONCENTER
    AND p.ID = emp.PERSONID


LEFT JOIN PERSONS pCre
ON
    pCre.CENTER = book.CREATOR_CENTER
    AND pCre.ID = book.CREATOR_ID
WHERE
    (
        (
            bc.TIME BETWEEN :startDate AND :endDate
        )
        OR
        (
            book.CANCELATION_TIME BETWEEN :startDate AND :endDate
        )
    )
    AND book.CENTER IN (:scope)
order by book.CENTER, book.ID, bc.TIME





