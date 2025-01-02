select * from CovidDeaths;


--checking for the fields and sorting on coloumn 1 and 2
Select location,date, total_cases, total_deaths
from CovidDeaths order by 1,2;

--Calculate Death % from Total Cases and Deaths

Select location,date,total_cases,total_deaths, round((total_deaths/total_cases)*100,2) as Death_Percentage
from CovidDeaths 
where location like '%India%'
order by 1,2;

--Total Cases by Population

Select location,date,population,total_cases, round((total_cases/population)*100,2) as Affected_Patients
from CovidDeaths 
where location like '%India%'
order by 1,2;

-- Cal Death percentage in USA by popultion
Select location,date,population,total_deaths, round((total_deaths/population)*100,3) as Death_Patients
from CovidDeaths 
where location like '%states%'
order by 1,2;


--- Top 10 Highest Infected countries
Select top 10 location,population,max(total_cases) as Highest_Effected, round((max(total_Cases)/population)*100,3) as Highest_Effected_perc
from CovidDeaths  
where location not like '%world%' 
group by location,population
order by Highest_Effected_perc desc ;

---
Select location,population,max(total_cases) as Highest_Effected, round((max(total_Cases)/population)*100,3) as Highest_Effected_perc
from CovidDeaths  
where location like '%India%' 
group by location,population
order by 1,2;

----Highest Death Count by country
Select  location,population,max(cast(total_deaths as Int)) as Highest_Deaths_Country, round((max(cast(total_deaths as Int))/population)*100,3) as Highest_Deaths_percentage
from CovidDeaths  
where continent is not null 
group by location,population
order by Highest_Deaths_Country desc ;

-----Based On Location
Select  location,max(cast(total_deaths as Int)) as Highest_Deaths_Country,
round((max(cast(total_deaths as Int))/population)*100,3) as Highest_Deaths_percentage
from CovidDeaths  
where location is not null 
group by location,population
order by Highest_Deaths_Country desc ;


----Highest Population
Select  location,max(cast(total_deaths as Int)) as Highest_Deaths_Country,
round((max(cast(total_deaths as Int))/population)*100,2) as Highest_Deaths_percentage
from CovidDeaths  
where continent is  null 
group by location,population
order by Highest_Deaths_Country desc ;

----looking at Total Population vs Vacination
Select a.location, a.continent, a.date,b.people_vaccinated
from CovidDeaths a join Covidvaccinations b 
on a.location=b.location and a.date= b.date
where a.continent is not null
order by 1,2,3 

--Total Number of Vaccinated Patients  rolling
Select a.location, a.continent,a.population, a.date,b.people_vaccinated,
sum(convert(bigint,coalesce(b.people_vaccinated,0))) over(partition by a.location order by a.location,a.date) as Total_Vactinated_Patients 
from CovidDeaths a join Covidvaccinations b 
on a.location=b.location and a.date= b.date
where a.continent is not null and a.location like'%India%'
order by 1,2,3  

---using CTE

with cte  (location,population,continent,date,Total_Vactinated_Patients,rolling_vaccinations) as (
Select a.location, a.continent,a.population, a.date,b.people_vaccinated as Total_Vactinated_Patients,
sum(convert(bigint,coalesce(b.people_vaccinated,0))) over(partition by a.location order by a.location,a.date) as rolling_vaccinations
from CovidDeaths a join Covidvaccinations b 
on a.location=b.location and a.date= b.date
where a.continent is not null and a.location like'%India%'
)

select * from cte;
--Create a Temp table to store the values from before query
create  table Vaccinated_temp
	(	
		location nvarchar(40),
		population int,
		Total_Vactinated_Patients  int,
		rolling_vaccinations  int,
		continent nvarchar(20),
		date datetime
	);

 alter table Vaccinated_temp  drop column continent 
alter table Vaccinated_temp  drop column date 

select * from Vaccinated_temp
insert into Vaccinated_temp
select * from (
Select a.location,a.population ,b.people_vaccinated as Total_Vactinated_Patients,
sum(convert(bigint,coalesce(b.people_vaccinated,0))) over(partition by a.location order by a.location,a.date) as rolling_vaccinations
from CovidDeaths a join Covidvaccinations b 
on a.location=b.location and a.date= b.date
where a.continent is not null and a.location like'%India%') t

select * from Vaccinated_temp


