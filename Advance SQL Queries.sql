--Advanced SQL Queries
/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period).
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

--ISSUE_STATUS = =MEMBERS == BOOKS == RETURN_STATUS
--filter books which are return
--overdue > 30

SELECT IST.ISSUED_MEMBER_ID,
       M.MEMBER_NAME,
	   B.BOOK_TITLE,
	   IST.ISSUED_DATE,
	   (CURRENT_DATE - IST.ISSUED_DATE) AS OVER_DUE_DAYS
FROM ISSUED_STATUS AS IST
JOIN MEMBERS AS M ON IST.ISSUED_MEMBER_ID = M.MEMBER_ID
JOIN BOOKS AS B ON IST.ISSUED_BOOK_ISBN = B.ISBN
LEFT JOIN RETURN_STATUS AS RST ON IST.ISSUED_ID = RST.ISSUED_ID
WHERE RST.RETURN_DATE IS NULL
   AND (CURRENT_DATE - IST.ISSUED_DATE) > 30
ORDER BY 1;


/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned
(based on entries in the return_status table).
*/

CREATE OR REPLACE PROCEDURE ADD_RETURN_RECORDS(P_RETURN_ID VARCHAR(10), P_ISSUED_ID VARCHAR(10))
LANGUAGE PLPGSQL
AS $$
DECLARE 
     v_isbn VARCHAR(25);
    v_book_name VARCHAR(75);
BEGIN
     INSERT INTO RETURN_STATUS(RETURN_ID, ISSUED_ID, RETURN_DATE)
	 VALUES (P_RETURN_ID, P_ISSUED_ID, CURRENT_DATE);

SELECT 
     issued_book_isbn, 
     issued_book_name
	 INTO
	 v_isbn,
     v_book_name
FROM ISSUED_STATUS
WHERE ISSUED_ID = P_ISSUED_ID;

UPDATE BOOKS
SET status = 'Yes'
WHERE ISBN = V_ISBN;

RAISE NOTICE 'Thank You for returning the book: %', V_BOOK_NAME;
 
END;
$$


CALL ADD_RETURN_RECORDS('RS124', 'IS138');


----TESTING
SELECT * FROM BOOKS
WHERE ISBN = '978-0-307-58837-1'

SELECT * FROM ISSUED_STATUS
WHERE ISSUED_BOOK_ISBN = '978-0-307-58837-1'

SELECT * FROM RETURN_STATUS
WHERE ISSUED_ID = 'IS135'

---END

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch,
showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

CREATE TABLE BRANCH_REPORTS
AS 
   SELECT BCH.BRANCH_ID, 
	       COUNT(IST.ISSUED_ID) AS BOOKS_ISSUED,
		   COUNT(RST.RETURN_ID) AS BOOKS_RETURNED,
		   SUM(B.RENTAL_PRICE) AS TOTAL_REVENUE
	FROM EMPLOYEES AS EMP
	JOIN ISSUED_STATUS AS IST ON EMP.EMP_ID = IST.ISSUED_EMP_ID
	JOIN BRANCH AS BCH ON EMP.BRANCH_ID = BCH.BRANCH_ID
	LEFT JOIN RETURN_STATUS AS RST ON IST.ISSUED_ID = RST.ISSUED_ID
	JOIN BOOKS AS B ON IST.ISSUED_BOOK_ISBN = B.ISBN
	GROUP BY 1
	ORDER BY 1

SELECT *
FROM BRANCH_REPORTS

/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members
containing members who have issued at least one book in the last 10 months.
*/

CREATE TABLE active_members AS
SELECT DISTINCT M.*
FROM MEMBERS AS M
JOIN ISSUED_STATUS AS IST
ON M.MEMBER_ID = IST.ISSUED_MEMBER_ID
WHERE IST.ISSUED_DATE >= CURRENT_DATE - INTERVAL '10 MONTHS';

/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues.
Display the employee name, number of books processed, and their branch.
*/

SELECT E.EMP_NAME AS EMP_NAME,
	   COUNT(IST.ISSUED_ID) AS NO_OF_BOOKS_PROCESSED,
	   B.BRANCH_ID AS BRANCH
FROM EMPLOYEES AS E
JOIN ISSUED_STATUS AS IST ON E.EMP_ID = IST.ISSUED_EMP_ID
JOIN BRANCH AS B ON E.BRANCH_ID = B.BRANCH_ID
GROUP BY 1, 3
ORDER BY 2 DESC
LIMIT 3


/*
Task 19: Stored Procedure Objective:
Create a stored procedure to manage the status of books in a library system.
Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
The procedure should function as follows: The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating
that the book is currently not available.
*/

CREATE OR REPLACE PROCEDURE 
		MANAGE_BOOK_STATUS(P_ISSUED_ID VARCHAR(10), P_ISSUED_MEMBER_ID VARCHAR(10), P_ISSUED_BOOK_NAME VARCHAR(75), P_ISSUED_BOOK_ISBN VARCHAR(25), P_ISSUED_EMP_ID VARCHAR(10))
LANGUAGE PLPGSQL
AS $$
DECLARE
V_STATUS VARCHAR(15);
BEGIN
--checking if the book is availabe
   SELECT STATUS
   INTO V_STATUS
   FROM BOOKS
   WHERE ISBN = P_ISSUED_BOOK_ISBN;
   
   IF V_STATUS = 'yes' THEN
   
       INSERT INTO ISSUED_STATUS(ISSUED_ID, ISSUED_MEMBER_ID, ISSUED_BOOK_NAME, ISSUED_DATE, ISSUED_BOOK_ISBN, ISSUED_EMP_ID)
       VALUES (P_ISSUED_ID,P_ISSUED_MEMBER_ID ,P_ISSUED_BOOK_NAME,CURRENT_DATE,P_ISSUED_BOOK_ISBN,P_ISSUED_EMP_ID);
	 
   UPDATE BOOKS
   SET STATUS = 'no'
   WHERE ISBN = P_ISSUED_BOOK_ISBN;
   
       RAISE NOTICE 'Your book % hase been isSued successfully', P_ISSUED_BOOK_NAME;
	   
   ELSE
	RAISE NOTICE 'Sorry: % is currently not available.', P_ISSUED_BOOK_NAME;
   END IF;
   
END;
$$

--testing procedure

SELECT * FROM BOOKS
-- 978-0-19-280551-1 ---YES STATUS
-- 978-0-09-957807-9 ---YES STATUS
-- 978-0-375-41398-8 --- NO STATUS

SELECT * FROM ISSUED_STATUS
WHERE ISSUED_BOOK_ISBN = '978-0-19-280551-1'


CALL MANAGE_BOOK_STATUS('IS141', 'C109', 'The Guns of August', '978-0-19-280551-1', 'E105')

CALL MANAGE_BOOK_STATUS('IS142', 'C104', 'A Game of Thrones', '978-0-09-957807-9', 'E103')

CALL MANAGE_BOOK_STATUS('IS143', 'C106', 'The Diary of a Young Girl', '978-0-375-41398-8', 'E102')

--testing results
SELECT * FROM BOOKS
WHERE ISBN = '978-0-19-280551-1'

SELECT * FROM BOOKS
WHERE ISBN = '978-0-09-957807-9'

/*
Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member
and the books they have issued but not returned within 30 days.
The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
The number of books issued by each member. 
The resulting table should show: Member ID Number of overdue books total fines.
*/

CREATE TABLE OVERDUE_BOOKS_FINES 
AS
	SELECT 
	    IST.ISSUED_MEMBER_ID AS MEMBER_ID,
	    COUNT(CASE
		---to check if the book is not returned
	            WHEN (RST.RETURN_DATE IS NULL AND CURRENT_DATE > IST.ISSUED_DATE + INTERVAL '30 DAYS')
		---to check if the book is returned late
	                 OR (RST.RETURN_DATE > IST.ISSUED_DATE + INTERVAL '30 DAYS') 
	            THEN 1
	         END) AS OVERDUE_BOOKS,
	    SUM(CASE
		---fine for the books that are not returned yet or returned late
	            WHEN (RST.RETURN_DATE IS NULL AND CURRENT_DATE > IST.ISSUED_DATE + INTERVAL '30 DAYS') 
		---using extract to draw number of days only and not the interval
	            THEN EXTRACT(DAY FROM (CURRENT_DATE - (IST.ISSUED_DATE + INTERVAL '30 DAYS'))) * 0.50
	            WHEN (RST.RETURN_DATE > IST.ISSUED_DATE + INTERVAL '30 DAYS') 
	            THEN EXTRACT(DAY FROM (RST.RETURN_DATE - (IST.ISSUED_DATE + INTERVAL '30 DAYS'))) * 0.50
	            ELSE 0
	        END) AS TOTAL_FINES,
	    COUNT(IST.ISSUED_ID) AS TOTAL_BOOKS_ISSUED
FROM 
	ISSUED_STATUS AS IST
LEFT JOIN 
	RETURN_STATUS AS RST 
ON 
	IST.ISSUED_ID = RST.ISSUED_ID
GROUP BY 
	IST.ISSUED_MEMBER_ID;


---END PROJECT---
