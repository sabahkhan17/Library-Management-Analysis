SELECT * FROM MEMBERS
SELECT * FROM BOOKS
SELECT * FROM ISSUED_STATUS
SELECT * FROM EMPLOYEES
SELECT * FROM RETURN_STATUS
SELECT * FROM BRANCH

---PROJECT TASK
--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO BOOKS(ISBN, BOOK_TITLE, CATEGORY, RENTAL_PRICE, STATUS, AUTHOR, PUBLISHER)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM BOOKS

---Task 2: Update an Existing Member's Address

UPDATE MEMBERS
SET MEMBER_ADDRESS = '125 Main St'
WHERE MEMBER_ID = 'C101';

---Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM ISSUED_STATUS
WHERE ISSUED_ID = 'IS121'

--Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT ISSUED_BOOK_NAME, ISSUED_EMP_ID
FROM ISSUED_STATUS
WHERE ISSUED_EMP_ID = 'E101'

--Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT ISSUED_MEMBER_ID, COUNT(ISSUED_ID) AS TOTAL_COUNT
FROM ISSUED_STATUS
GROUP BY 1
HAVING COUNT (ISSUED_ID) > 1

--Task 6: Create Summary Tables: 
--Used CTAS to generate new table based on query results - each book and total book_issued_cnt**

CREATE TABLE ISSUED_BOOKS_COUNT 
AS
SELECT ISBN, B.BOOK_TITLE, COUNT(ISSUED_ID)
FROM BOOKS AS B
JOIN ISSUED_STATUS AS IST ON B.ISBN = IST.ISSUED_BOOK_ISBN
GROUP BY 1, 2

SELECT * FROM ISSUED_BOOKS_COUNT

--Task 7. Retrieve All Books in a Specific Category:

SELECT *
FROM BOOKS
WHERE CATEGORY = 'Classic'

--Task 8: Find Total Rental Income by Category:

SELECT B.CATEGORY, SUM(B.RENTAL_PRICE) AS RENTAL_INCOME, COUNT(ISSUED_ID)
FROM BOOKS AS B
JOIN ISSUED_STATUS AS IST ON B.ISBN = IST.ISSUED_BOOK_ISBN
GROUP BY 1
ORDER BY 2 DESC

--inserting new values

INSERT INTO MEMBERS(MEMBER_ID, MEMBER_NAME, MEMBER_ADDRESS, REG_DATE)
VALUES
('C111', 'William Hykes', '198 Pine St', '2025-01-22'),
('C112', 'Robert Wilson', '123 Oak St', '2025-01-21');

--Task 9: List Members Who Registered in the Last 180 Days:

SELECT *
FROM MEMBERS
WHERE REG_DATE >= CURRENT_DATE - INTERVAL '180 DAYS'

--Task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT E1.EMP_ID, E1.EMP_NAME, B.MANAGER_ID, E2.EMP_NAME AS MANAGER_NAME, B.BRANCH_ID, B.BRANCH_ADDRESS, B.CONTACT_NO
FROM EMPLOYEES AS E1
JOIN BRANCH AS B ON E1.BRANCH_ID = B.BRANCH_ID
JOIN EMPLOYEES AS E2 ON B.MANAGER_ID = E2.EMP_ID

--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE RENT_THRESHOLD
AS
SELECT *
FROM BOOKS
WHERE RENTAL_PRICE > 7

SELECT *
FROM RENT_THRESHOLD

--Task 12: Retrieve the List of Books Not Yet Returned

SELECT *
FROM ISSUED_STATUS AS IST
LEFT JOIN RETURN_STATUS AS RST ON RST.ISSUED_ID = IST.ISSUED_ID
WHERE 
RST.RETURN_ID IS NULL
