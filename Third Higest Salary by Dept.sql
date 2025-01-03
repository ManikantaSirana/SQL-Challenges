

--Find the details of the 3rd highest salary in each department, 
--and if a department has less than 3 employees, return the employee with the lowest salary.

CREATE TABLE emp (
 emp_id int ,
 emp_name varchar(50) ,
 salary int ,
 manager_id int ,
 emp_age int ,
 dep_id int ,
 dep_name varchar(20) ,
 gender varchar(10) 
) ;
insert into emp values(1,'Ankit',14300,4,39,100,'Analytics','Female');
insert into emp values(2,'Mohit',14000,5,48,200,'IT','Male');
insert into emp values(3,'Vikas',12100,4,37,100,'Analytics','Female');
insert into emp values(4,'Rohit',7260,2,16,100,'Analytics','Female');
insert into emp values(5,'Mudit',15000,6,55,200,'IT','Male');
insert into emp values(6,'Agam',15600,2,14,200,'IT','Male');
insert into emp values(7,'Sanjay',12000,2,13,200,'IT','Male');
insert into emp values(8,'Ashish',7200,2,12,200,'IT','Male');
insert into emp values(9,'Mukesh',7000,6,51,300,'HR','Male');
insert into emp values(10,'Rakesh',8000,6,50,300,'HR','Male');
insert into emp values(11,'Akhil',4000,1,31,500,'Ops','Male');

with cte as (
select emp_name,emp_id,dep_name,dep_id,salary, row_number() over(partition by dep_id order by salary desc) as Salary_Rank,
count(emp_id) over(partition by dep_id ) as emp_count
from Employee),

Cte2 as (
select 
	case 
		when emp_count<3 then LAST_VALUE(emp_id) over(partition by dep_id order by Salary_Rank rows between current row and unbounded following) 
		when Salary_Rank=3 then emp_id
		Else 0
	end as Emp_id_fiter
from cte)

Select emp_id, emp_name, dep_id,dep_name,salary from Employee where emp_id in ( select * from Cte2)


