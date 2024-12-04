-- # Drop the database
-- Drop database if exists practice;

--# Create new database
-- create database if not exists practice;


-- ____________________________________
--# Use databse
Use master ;

-- ____________________________________
--# create another table which will keep the character other than english using varchar 
--# we are changing the varchar of the table and creating the empty table and then append the original table
-- # this could be done if the foriegn letter is not visible in the table

-- drop table netflix;
-- create table netflix (
--show_id varchar(50) primary key ,
--type varchar(50) null,
--title  nchar(200) null,
--director varchar(500) null,
--cast  varchar(1000)null,
--country  varchar(250) null,
--date_added varchar(50)  null,
--release_year int null,
--rating varchar(10)  null,
--duration varchar(20)  null, 
--listed_in varchar(100) null,
--description varchar(500)  null
-- );


-- ____________________________________
--#data view
select * from netflix;

-- ____________________________________
--#number of rows
select count(*) from netflix;         -- #8807

-- ____________________________________
 --# check for foriegn title
select * from netflix 
-- where title like '#%'
where show_id = 's5023'
order by title;

-- ____________________________________
-- # get number of duplicate ids
select show_id, count(*)
from netflix
group by show_id
having count(*) >1;

-- ___________________________________
-- #get number of duplicated title
select title, count(*)                                     
from netflix
group by title
having count(*) >1;

-- Sin senos sí hay paraíso	2
-- Love in a Puff	2
-- Ares	2
-- Esperando la carroza	2
-- Veronica	2
-- FullMetal Alchemist	2
-- Death Note	2

select * from netflix 
where title in (
select title                                  
from netflix
group by title
having count(*) >1)
order by title;   --  # if the duplicate base on the type, if types are same means they are duplicate

-- _______________________________
--# concate the title and type column to see the duplicate if both are same then remove one 
select * from netflix 
where concat(upper(title) , type)   in (
select concat(upper(title) , type)     --  # concat the two column fo comparisomn                         
from netflix
group by title , type 
having count(*) >1)
order by title;    --# if the duplicate base on the type, if types are same means they are duplicate


-- ____________________________
--# I can see the  Veronica has the same type and tile name but different cast, director , country

-- ____________________________
--# remove duplicates
with cte as (
select *
,row_number() over(partition by title, type order by show_id) as rn
from netflix)

select * from cte where rn =1;

-- ____________________________
--# Create a new table for directr, country and duration columns
 --## One movie directed by multiple director,
 --## Movie released in multiple countries
 --## Bacause in genre drama and international moview are in same row .
 -- 1. new table for directed, listed_in adn genre


 select show_id, trim(value) as director 
 into netflix_directors
 from netflix
 cross apply string_split(director,',');

 select * from netflix_directors;


-- _________________________________
-- Country
select show_id, trim(value) as country
into netflix_country
from netflix
cross apply string_split(country,',');
 select * from netflix_country;
-- _________________________________
-- genre
select show_id, trim(value) as genre
into netflix_genre
from netflix
cross apply string_split(listed_in,',');

select * from netflix_genre;

-- _________________________________
-- Create a main table with choice of columns and date time convertion for date added

with cte as (
select *
,row_number() over(partition by title, type order by show_id) as rn
from netflix)

select show_id, type, title, cast(date_added as date) as date_added, release_year, rating
duration,description
from cte
where rn =1;

-- ___________________________________________\
-- handle the missing values

select  * --show_id, country
from netflix
where country is null;

--_________________________________________________
select * from netflix where director = 'Suhas Kadav';

--__________________________________________________
 -- Join the  netflix country and director tale
 select director, country
from netflix_country as nc
inner join netflix_directors as nd on
nc.show_id = nd.show_id

-- _____________________________________________
insert into netflix_country
select  show_id, map.country
from netflix n

inner join (
select director, country
from netflix_country as nc
inner join netflix_directors as nd on
nc.show_id = nd.show_id
) map 
on n.director = map.director
where n.country is null;


-- desribe in myql
-- EXEC sp_help 'netflix_country';

----------------------------------------------
-- duration null- extract value

select * from netflix 
where duration is null;

-----------------------------------------
-- Handle the null duration values

with cte as (
select *
,row_number() over(partition by title, type order by show_id) as rn
from netflix)

select show_id, type, title, cast(date_added as date) as date_added, release_year, rating,
case when duration is null then rating else duration end as duration,description
into netflix_filtered
from cte
where rn =1;

select * from netflix_filtered;
----------------------------------------------
 -- 1* for each director count the no of movies and tv shows created by them in separate columns for 
 -- directors who have created tv shows and movies both.

  select distinct type from netflix_filtered;

--from netflix_directors ,
--(select count(type) as total_movies, show_id from netflix_filtered where type = 'Movie' group by show_id) as movie,
--(select count(type) as  total_tv_show , show_id  from netflix_filtered where type = 'TV Show' group by show_id) as show
--join netflix_directors nd
-- on nd.show_id = movie.show_id and movie.show_id=show.show_id


 -- get the director name who has both movie and tv show 
select nd.director, count( distinct nf.type) as distinct_type 
from netflix_filtered nf
inner join netflix_directors nd on
nf.show_id=nd.show_id
group by nd.director
having count( distinct nf.type) > 1
order by distinct_type  desc;

------------------------------

select nd.director,
count (distinct case
	  when nf.type='movie' then nf.show_id  end)as no_movies,
count(distinct case when nf.type='tv show' then nf.show_id end) as no_show

from netflix_filtered nf
inner join netflix_directors nd on
nf.show_id=nd.show_id
group by nd.director
having count( distinct nf.type) > 1;


 -- 2* Which country has highest number of comedy movies

 
 select top 1 nc.country, count(distinct ng.show_id) as no_of_movies
 from netflix_country nc
 inner join netflix_genre ng
 on nc.show_id = ng.show_id
 inner join netflix_filtered nf on ng.show_id = nc.show_id
 where ng.genre = 'Comedies' and nf.type='Movie'
 group by nc.country
 order by no_of_movies desc;


 select genre from netflix_genre
 where genre= 'comedy';

 -- 3* for each year(as per date added to netflix), which director has maximum number of movies released


 -- cte (common table expression)
 with cte as(
 select  nd.director, year(date_added) as date_year, count(distinct nf.show_id) as no_of_movies
 from netflix_filtered nf
 inner join netflix_directors nd
 on nf.show_id = nd.show_id
 where nf.type = 'movie'
 group by  year(date_added), nd.director
)
, cte2 as(
 select *
 , row_number()over (partition by date_year order by no_of_movies desc, director) as rn
 from cte

 )
 select * from cte2 where rn=1;


 -- 4* what is average duration of movies in each genre

 
 select  distinct ng.genre ,avg(cast(replace(duration, ' min', '')as int)) as average_duration
 from netflix_filtered as nf
 inner join netflix_genre as  ng
 on nf.show_id = ng.show_id
 where type ='movie'
 group by ng.genre
 order by  average_duration
;

-- 5* find the list of directors who have created horror and comedy movies both.
-- display director names along with number of comedy and horror movies directed by them


select director,
count (distinct case when ng.genre = 'Comedies' then nf.show_id end) as no_of_comedy_movies,
count (distinct case when ng.genre = 'Horro Movies' then nf.show_id end) as no_of_horro_movies
from netflix_filtered nf
inner join netflix_directors nd
on nf.show_id = nd.show_id
inner join netflix_genre ng
on nf.show_id = ng.show_id
where type = 'movie' and genre in( 'Horror Movies' ,'comedies')
group by  director
having count( distinct ng.genre) =2


