## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_database`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Image](https://github.com/user-attachments/assets/b1e9d3e1-ce7d-45b8-955b-f3a458aec6d6)

## Objectives

1. **Database Schema Design**: Create a relational database schema with tables for:
Branches, Employees, Members, Books, Issued Books (for issued status), Returned Books (for return status).
Populate the tables with relevant data.
2. **Data Manipulation**: Implement CRUD (Create, Read, Update, Delete) operations on the database tables.
3. **Data Transformation:**: Utilize the CTAS (Create Table As Select) statement to create new tables based on the results of SQL queries.
4. **Data Analysis and Retrieval**: Develop and execute advanced SQL queries to analyze data and retrieve specific information from the database.

## Project Structure

### 1. Database Schema Design
![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_database`.
- **Table Creation**: Created tables for branches, employees, members, books, issued_status, and return_status. Each table includes relevant columns and relationships.

```sql
-CREATE DATABASE library_database;

-- Create table 'branch'
DROP TABLE IF EXISTS BRANCH;
CREATE TABLE BRANCH
(
    BRANCH_ID VARCHAR(10) PRIMARY KEY,
    MANAGER_ID VARCHAR(10),
    BRANCH_ADDRESS VARCHAR(50),
    CONTACT_NO VARCHAR(20)
);

-- Create table 'employee'
DROP TABLE IF EXISTS EMPLOYEES;
CREATE TABLE EMPLOYEES
(
    EMP_ID VARCHAR(10) PRIMARY KEY,
    EMP_NAME VARCHAR(30),
    POSITION VARCHAR(20),
    SALARY INT,
    BRANCH_ID VARCHAR(10),
);

-- Create table 'members'
DROP TABLE IF EXISTS MEMBERS;
CREATE TABLE MEMBERS
(
    MEMBER_ID VARCHAR(10) PRIMARY KEY,
    MEMBER_NAME VARCHAR(25),
    MEMBER_ADDRESS VARCHAR(75),
    REG_DATE DATE
);

-- Create table 'books'
DROP TABLE IF EXISTS BOOKS;
CREATE TABLE BOOKS
(
            ISBN VARCHAR(20) PRIMARY KEY,
            BOOK_TITLE VARCHAR(70),
            CATEGORY VARCHAR(25),
            RENTAL_PRICE FLOAT,
            STATUS VARCHAR(15),
            AUTHOR VARCHAR(25),
            PUBLISHER VARCHAR(25)
);

-- Create table 'issued_status'
DROP TABLE IF EXISTS ISSUED_STATUS;
CREATE TABLE ISSUED_STATUS
(
            ISSUED_ID VARCHAR(10) PRIMARY KEY,
            ISSUED_MEMBER_ID VARCHAR(10),
            ISSUED_BOOK_NAME VARCHAR(75),
            ISSUED_DATE DATE,
            ISSUED_BOOK_ISBN VARCHAR(25),
            ISSUED_EMP_ID VARCHAR(10)
);

-- Create table 'return_status'
DROP TABLE IF EXISTS RETURN_STATUS;
CREATE TABLE RETURN_STATUS
(
	RETURN_ID VARCHAR(10) PRIMARY KEY,
	ISSUED_ID VARCHAR(10),
	RETURN_BOOK_NAME VARCHAR(75),
	RETURN_DATE DATE,
	RETURN_BOOK_ISBN VARCHAR(25)
);

---for foreign keys

ALTER TABLE ISSUED_STATUS
ADD CONSTRAINT MEMBERS_FKEY
FOREIGN KEY ISSUED_MEMBER_ID
REFERENCES MEMBERS(MEMBER_ID)

ALTER TABLE ISSUED_STATUS
ADD CONSTRAINT BOOKS_FKEY
FOREIGN KEY ISSUED_BOOK_ISBN
REFERENCES BOOKS(ISBN)

ALTER TABLE ISSUED_STATUS---
ADD CONSTRAINT EMPLOYEES_FKEY
FOREIGN KEY ISSUED_EMP_ID
REFERENCES EMPLOYEES(EMP_ID)

ALTER TABLE EMPLOYEES
ADD CONSTRAINT BRANCH_FKEY
FOREIGN KEY BRANCH_ID
REFERENCES BRANCH(BRANCH_ID)

ALTER TABLE RETURN_STATUS
ADD CONSTRAINT ISSUED_STATUS_FKEY
FOREIGN KEY ISSUED_ID
REFERENCES ISSUED_STATUS(ISSUED_ID)

ALTER TABLE RETURN_STATUS
ADD CONSTRAINT BOOKS_FKEY
FOREIGN KEY ISBN
REFERENCES RETURN_STATUS(RETURN_BOOK_ISBN)

```

### 2. Data Manipulation

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO BOOKS(ISBN, BOOK_TITLE, CATEGORY, RENTAL_PRICE, STATUS, AUTHOR, PUBLISHER)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM BOOKS
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE MEMBERS
SET MEMBER_ADDRESS = '125 Main St'
WHERE MEMBER_ID = 'C101';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM ISSUED_STATUS
WHERE ISSUED_ID = 'IS121'
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

```sql
SELECT ISSUED_BOOK_NAME, ISSUED_EMP_ID
FROM ISSUED_STATUS
WHERE ISSUED_EMP_ID = 'E101'
```

**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT ISSUED_MEMBER_ID, COUNT(ISSUED_ID) AS TOTAL_COUNT
FROM ISSUED_STATUS
GROUP BY 1
HAVING COUNT (ISSUED_ID) > 1
```

### 3. Data Transformation:

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE ISSUED_BOOKS_COUNT 
AS
SELECT ISBN, B.BOOK_TITLE, COUNT(ISSUED_ID)
FROM BOOKS AS B
JOIN ISSUED_STATUS AS IST ON B.ISBN = IST.ISSUED_BOOK_ISBN
GROUP BY 1, 2

SELECT * FROM ISSUED_BOOKS_COUNT
```


### 4. Data Analysis and Retrieval:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT *
FROM BOOKS
WHERE CATEGORY = 'Classic'
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT B.CATEGORY, SUM(B.RENTAL_PRICE) AS RENTAL_INCOME, COUNT(ISSUED_ID)
FROM BOOKS AS B
JOIN ISSUED_STATUS AS IST ON B.ISBN = IST.ISSUED_BOOK_ISBN
GROUP BY 1
ORDER BY 2 DESC
```

```sql
--inserting new values
INSERT INTO MEMBERS(MEMBER_ID, MEMBER_NAME, MEMBER_ADDRESS, REG_DATE)
VALUES
('C111', 'William Hykes', '198 Pine St', '2025-01-22'),
('C112', 'Robert Wilson', '123 Oak St', '2025-01-21');
```

9. **List Members Who Registered in the Last 180 Days**:

```sql
SELECT *
FROM MEMBERS
WHERE REG_DATE >= CURRENT_DATE - INTERVAL '180 DAYS'
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT E1.EMP_ID, E1.EMP_NAME, B.MANAGER_ID, E2.EMP_NAME AS MANAGER_NAME, B.BRANCH_ID, B.BRANCH_ADDRESS, B.CONTACT_NO
FROM EMPLOYEES AS E1
JOIN BRANCH AS B ON E1.BRANCH_ID = B.BRANCH_ID
JOIN EMPLOYEES AS E2 ON B.MANAGER_ID = E2.EMP_ID
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:

```sql
CREATE TABLE RENT_THRESHOLD
AS
SELECT *
FROM BOOKS
WHERE RENTAL_PRICE > 7

SELECT *
FROM RENT_THRESHOLD
```

Task 12: **Retrieve the List of Books Not Yet Returned**

```sql
SELECT *
FROM ISSUED_STATUS AS IST
LEFT JOIN RETURN_STATUS AS RST ON RST.ISSUED_ID = IST.ISSUED_ID
WHERE 
RST.RETURN_ID IS NULL
```

## Advanced SQL Queries

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
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
```

**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

```sql

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

```

**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
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
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 10 months.

```sql
CREATE TABLE active_members AS
SELECT DISTINCT M.*
FROM MEMBERS AS M
JOIN ISSUED_STATUS AS IST
ON M.MEMBER_ID = IST.ISSUED_MEMBER_ID
WHERE IST.ISSUED_DATE >= CURRENT_DATE - INTERVAL '10 MONTHS';
;

SELECT * FROM active_members;
```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT E.EMP_NAME AS EMP_NAME,
	   COUNT(IST.ISSUED_ID) AS NO_OF_BOOKS_PROCESSED,
	   B.BRANCH_ID AS BRANCH
FROM EMPLOYEES AS E
JOIN ISSUED_STATUS AS IST ON E.EMP_ID = IST.ISSUED_EMP_ID
JOIN BRANCH AS B ON E.BRANCH_ID = B.BRANCH_ID
GROUP BY 1, 3
ORDER BY 2 DESC
LIMIT 3
```

**Task 18: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql
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

--calling command
CALL MANAGE_BOOK_STATUS('IS141', 'C109', 'The Guns of August', '978-0-19-280551-1', 'E105')

CALL MANAGE_BOOK_STATUS('IS142', 'C104', 'A Game of Thrones', '978-0-09-957807-9', 'E103')

CALL MANAGE_BOOK_STATUS('IS143', 'C106', 'The Diary of a Young Girl', '978-0-375-41398-8', 'E102')

--testing results
SELECT * FROM BOOKS
WHERE ISBN = '978-0-19-280551-1'

SELECT * FROM BOOKS
WHERE ISBN = '978-0-09-957807-9'

---end
```

**Task 19: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines

```sql
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

```


## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.


## Thank you for your interest in this project!
