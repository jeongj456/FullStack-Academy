-- 1 --
/*
Create a SQLite database called SQT_HR
*/
-- 2 --
/*
Create tables then import data_science_team.csv proj_table.csv and 
emp_record_table.csv into the employee database from the given resources
*/
CREATE TABLE IF NOT EXISTS emp_record_table(
	EMP_ID VARCHAR(255)
	, FIRST_NAME VARCHAR(255)
	, LAST_NAME VARCHAR(255)
	, GENDER VARCHAR(255)
	, ROLE VARCHAR(255)
	, DEPT  VARCHAR(255)
	, EXP INTEGER
	, COUNTRY VARCHAR(255)
	, CONTINENT VARCHAR(255)
	, SALARY INTEGER
	, EMP_RATING INTEGER
	, MANAGER_ID VARCHAR(255)
	, PROJ_ID VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS data_science_team (
	EMP_ID  VARCHAR(255)
	, FIRST_NAME VARCHAR(255)
	, LAST_NAME VARCHAR(255)
	, GENDER VARCHAR(255)
	, ROLE VARCHAR(255)
	, DEPT  VARCHAR(255)
	, EXP INTEGER
	, COUNTRY VARCHAR(255)
	, CONTINENT VARCHAR(255)
	, FOREIGN KEY (EMP_ID) REFERENCES emp_record_table(EMP_ID)
);

CREATE TABLE IF NOT EXISTS proj_table(
	PROJECT_ID VARCHAR(255)
	, PROJ_NAME VARCHAR(255)
	, DOMAIN  VARCHAR(255)
	, START_DATE VARCHAR(255)
	, CLOSURE_DATE  VARCHAR(255)
	, DEV_QTR VARCHAR(255)  
	, STATUS VARCHAR(255)
	, FOREIGN KEY (PROJECT_ID) REFERENCES emp_record_table(PROJ_ID)
);

-- 3 --
/*
Create an ER diagram for the given employee database.
*/
-- 4 --
/*
Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, 
and DEPARTMENT from the employee record table, and make a 
list of employees and details of their department.
*/
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT
FROM emp_record_table ;

-- 5 --
/*
Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, 
GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is: 
less than two return "Below Average", greater than four 
return "Above Average", and between two and four return "Average".
*/
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT
, CASE WHEN EMP_RATING < 2 THEN 'Below Average'
WHEN EMP_RATING < 4 THEN 'Average'
ELSE 'Above Average' END AS EMP_RATING
FROM emp_record_table;

-- 6 --
/*
Write a query to concatenate the FIRST_NAME and the LAST_NAME 
of employees in the Finance department from the employee table 
and then give the resultant column alias as NAME.
*/
SELECT DEPT, (FIRST_NAME||' '||LAST_NAME) AS NAME
FROM emp_record_table
WHERE DEPT LIKE '%FINANCE%';

-- 7 --
/*
Write a query to list only those employees who have someone 
reporting to them. Also, show the number of reporters 
(including the President).
*/
WITH CTE AS(
	SELECT DISTINCT MANAGER_ID, COUNT(MANAGER_ID) AS num_of_subordinates
	FROM emp_record_table
	GROUP BY MANAGER_ID
)
SELECT FIRST_NAME||' '||LAST_NAME AS MANAGERS, ROLE, ert.EMP_ID AS EMP_ID, CTE.num_of_subordinates
FROM CTE
LEFT JOIN emp_record_table ert ON CTE.MANAGER_ID = ert.EMP_ID
WHERE CTE.MANAGER_ID = ert.EMP_ID;

-- 8 --
/*
Write a query to list all the employees from the healthcare
 and finance departments using union. Take data from the 
 employee record table.
*/
SELECT *
FROM emp_record_table
WHERE DEPT LIKE '%HEALTHCARE%'
UNION ALL
SELECT *
FROM emp_record_table
WHERE DEPT LIKE '%FINANCE';

-- 9 --
/*
Write a query to list employee details such as EMP_ID, 
FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING. 
Include the respective employee rating along with the max 
emp rating for each department.
*/
SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, EMP_RATING
, MAX(EMP_RATING) OVER (PARTITION BY DEPT) AS max_rating_per_dept
FROM emp_record_table;

-- 10 --
/*
Write a query to calculate the minimum and the maximum salary
 of the employees in each role. Take data from the employee record table.
*/
SELECT ROLE, ('$'||MIN(SALARY)) AS min_salary, ('$'||MAX(SALARY))
AS max_salary
FROM emp_record_table
GROUP BY ROLE;

-- 11 --
/*
Write a query to assign ranks to each employee based on their 
experience. Take data from the employee record table.
*/
SELECT DENSE_RANK() OVER (PARTITION BY ROLE ORDER BY EXP DESC) AS rank_by_experience, *
FROM emp_record_table;

-- 12 --
/*
Write a query to create a view that displays employees in 
various countries whose salary is more than six thousand. 
Take data from the employee record table.
*/
SELECT *
FROM emp_record_table
WHERE SALARY > 6000;

-- 13 --
/*
Write a nested query to find employees with experience of
 more than ten years. Take data from the employee record table.
*/
SELECT subque.EMP_ID, subque.FIRST_NAME||' '||subque.LAST_NAME AS Name, subque.ROLE, subque.EXP
FROM 
(
	SELECT *
	FROM emp_record_table
	WHERE EXP > 10
) subque;


-- 14 --
/*
Write a query to check whether the job profile assigned to each employee
in the data science team matches the organization’s set standard.The standard being:
For an employee with experience less than or equal to 2 years assign 'JUNIOR DATA SCIENTIST',
For an employee with the experience of 2 to 5 years assign 'ASSOCIATE DATA SCIENTIST',
For an employee with the experience of 5 to 10 years assign 'SENIOR DATA SCIENTIST',
For an employee with the experience of 10 to 12 years assign 'LEAD DATA SCIENTIST',
For an employee with the experience of 12 to 16 years assign 'MANAGER'.
*/
SELECT *
, CASE WHEN EXP <= 2 THEN IIF(ROLE = 'JUNIOR DATA SCIENTIST', 'Standard met', 'Standard not met')
WHEN EXP <=5 THEN IIF(ROLE = 'ASSOCIATE DATA SCIENTIST', 'Standard met', 'Standard not met')
WHEN EXP <=10 THEN IIF(ROLE = 'SENIOR DATA SCIENTIST', 'Standard met', 'Standard not met')
WHEN EXP <=12 THEN IIF(ROLE = 'LEAD DATA SCIENTIST', 'Standard met', 'Standard not met')
WHEN EXP <=16 THEN IIF(ROLE = 'MANAGER', 'Standard met', 'Standard not met')
END AS standard_match
FROM data_science_team;

-- 15 --
/*
Write a query to calculate the bonus for all the employees, based on 
their ratings and salaries (Use the formula: 5% of salary * employee
 rating).
*/
SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, EMP_RATING, '$'||SALARY AS Salary, '$'||((SALARY * 0.05) * EMP_RATING) AS Bonus
FROM emp_record_table;

-- 16 --
/*
Write a query to calculate the average salary distribution based on 
the continent and country. Take data from the employee record table.
*/
SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, CONTINENT, COUNTRY
, '$'||SALARY AS Salary
, '$'||AVG(SALARY) OVER (PARTITION BY CONTINENT) AS Avg_continent_salary
, '$'||AVG(SALARY) OVER (PARTITION BY COUNTRY) AS Avg_country_salary
FROM emp_record_table;
