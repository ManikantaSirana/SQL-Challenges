
--Table Created
CREATE TABLE [dbo].[netflix_raw](
	[show_id] [varchar](10) NULL,
	[type] [varchar](10) NULL,
	[title] [nvarchar](200) NULL,
	[director] [varchar](250) NULL,
	[cast] [varchar](1000) NULL,
	[country] [varchar](150) NULL,
	[date_added] [varchar](20) NULL,
	[release_year] int NULL,
	[rating] [varchar](10) NULL,
	[duration] [varchar](10) NULL,
	[listed_in] [varchar](100) NULL,
	[description] [varchar](500) NULL
) 

--handles foreign languges by placing nvarchar instead of varchar
Select * from netflix_raw where show_id='s5023'

--see the duplicates in the table
select show_id,count(*) from netflix_raw
group by show_id
having count(*)>1 --we see no duplicates.

-- We see that data in show_id is now unique, Hence we trying to show id is unique.
drop TABLE [dbo].[netflix_raw]

CREATE TABLE [dbo].[netflix_raw](
	[show_id] [varchar](10) primary key,
	[type] [varchar](10) NULL,
	[title] [nvarchar](200) NULL,
	[director] [varchar](250) NULL,
	[cast] [varchar](1000) NULL,
	[country] [varchar](150) NULL,
	[date_added] [varchar](20) NULL,
	[release_year] int NULL,
	[rating] [varchar](10) NULL,
	[duration] [varchar](10) NULL,
	[listed_in] [varchar](100) NULL,
	[description] [varchar](500) NULL
) 


select * from netflix_raw

select title,count(*) from netflix_raw
group by title
having count(*)>1

--checking on the duplicates in title based in type
--As we cannot pass multiple values in in we are tteying to concat
select * from netflix_raw 
where concat(Upper(title),type) in (select concat(upper(title),type)
from netflix_raw
group by concat(upper(title),type)
having count(*)>1) order by title

--we found 3 duplicates and trying to remove them
with cte as (
select *,row_number() over (partition by title,type order by show_id) as rn
from netflix_raw)

select * from cte where rn=1

--new table creation director,listedin,cast,country , since we have multiple values in it
select show_id,trim(value) as director
into netflix_director
from netflix_raw
cross apply string_split(director,',');

select show_id,trim(value) as cast
into netflix_cast
from netflix_raw
cross apply string_split(cast,',');

select show_id,trim(value) as country
into netflix_country
from netflix_raw
cross apply string_split(country,',');

select show_id,trim(value) as Listed_in
into netflix_Listed_in
from netflix_raw
cross apply string_split(Listed_in,',');

select * from netflix_raw


--considering only the culumns we need to transaction table from our old query which is used to remove the duplicates

with cte as (
select *,row_number() over (partition by title,type order by show_id) as rn
from netflix_raw)
--changeing datatype of date
select show_id,type,title,cast(date_added as Date) as date_added, release_year, rating, duration, description
from cte where rn=1;

--missing values population country,duration
--based on missing country we are truing to replace if a director has atleast a country trying to populate that country 

select director,country
from netflix_country inner join netflix_director
on netflix_country.show_id=netflix_director.show_id
group by director,country
order by director;

--tring to replace to oroginal table based on mapping table above
insert into netflix_country
select show_id,m.country 
from netflix_raw nr
inner join (
select director,country
from netflix_country inner join netflix_director
on netflix_country.show_id=netflix_director.show_id
group by director,country) m
 on m.director=nr.director where nr.country is null

------------------------- 
--we see that rating is in min which is wrong so we tring to make sure min goes to duration
select * from netflix_raw where duration is null

--tring to replace in original query & storing into a netflix which is a final table
with cte as (
select *,row_number() over (partition by title,type order by show_id) as rn
from netflix_raw)
--changeing datatype of date
select show_id,type,title,cast(date_added as Date) as date_added, release_year, rating,
case when duration is null then rating else duration end  as duration
, description 
into netflix
from cte where rn=1;
/* for each director count the no of movies  and tv shows  created by them in seperate coloumns
for directors who have created both tv shows and movies*/
Select * from netflix;

select d.director,
count(case when n.type='Movie' then n.show_id End) as Movie_Shows,
count(case when n.type='TV Show' then n.show_id End) as TV_Shows
from netflix_director d inner join netflix n 
on n.show_id=d.show_id
group by d.director
having count(distinct n.type)>1
order by count(distinct n.type) desc

--2. which country has the higest comedy movies

select * from netflix_Listed_in;

with cte as(
select c.country,
count(L.Listed_in)  as Comedy_movies_count
from netflix_Listed_in L inner join netflix_country c
on c.show_id=L.show_id
group by C.country)

select country from  cte where Comedy_movies_count=(Select max(Comedy_movies_count) from Cte)


select top 1 c.country, count(L.Listed_in)  as no_of_movies
from netflix_Listed_in L inner join netflix_country c
on c.show_id=L.show_id inner join netflix n on 
n.show_id=c.show_id 
where L.Listed_in='comedies' and n.type='Movie'
group by c.country 
order by no_of_movies desc

-----------------------------
--for each year as per date added netfilx, which director has max  movies relested
with cte as (select  d.director, Year(n.date_added)  as Year,
count(distinct n.show_id) as movie_count
from netflix_director d inner join netflix n 
on d.show_id=n.show_id
where n.type='Movie'
group by d.director, Year(n.date_added) 
),
cte2 as (
select director,Year, movie_count,
row_number() over (partition by Year order by movie_count desc,director) as rn
from cte
--order by Year, movie_count desc
)
select * from cte2 where rn=1

---what is Avg duration of movies in each gener

Select L.Listed_in, avg(cast(replace(n.duration,' min','') as int)) as avg_duration
from netflix_Listed_in L inner join netflix n 
on L.show_id=n.show_id
where n.type='Movie'
group by L.Listed_in


--- find the list of directors who have created comedy movies and horror both
--dispaly director names along with number of comedy and horror  movies directed by them

select d.director,
count(case when L.listed_in='comedies' then n.show_id end) as Comedy_movies,
count(case when L.listed_in='Horror Movies' then n.show_id end) as Horror_movies
from netflix_director d inner join netflix_Listed_in L
on d.show_id=L.show_id inner join netflix n
on n.show_id=d.show_id
where n.type='Movie' and L.listed_in in ('comedies' ,'Horror Movies')
group by d.director
having count( distinct L.listed_in)=2 

select distinct listed_in from netflix_Listed_in;