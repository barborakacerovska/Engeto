
--- FINAL -----

SELECT c.*, 
		le.LIFE_EXP_DIFF, le.median_age_2018, le.POP_DENSITY_CALCULATED, le.population, le.region_in_world, le.surface_area,
		e.GDP_population, e.GINI, e.MORTALITY_5,
		w.AVG_TEMP, w.GUST_MAX, w.RAIN_HOURS 
from t_barbora_kacerovska_SQL_covid c
left join t_barbora_kacerovska_SQL_LE le on c.iso3 = le.iso3 
left join t_barbora_kacerovska_SQL_economy e on c.country = e.country
left join t_barbora_kacerovska_SQL_weather w on c.iso3 = w.iso3 and c.date = w.date
left join t_barbora_kacerovska_SQL_religion r on c.country = r.country;




--- COVID DATA ----- 
create or replace table t_barbora_kacerovska_SQL_covid as
SELECT 
	cb.*,
	case when weekday(date) in (5,6) then 1 else 0 end as weekend,  # 5=sobota,  6=nedele
	case when month(date) in (12, 1, 2) then 0
      when month(date) in (3, 4, 5) then 1
      when month(date) in (6, 7, 8) then 2
      when month(date) in (9, 10, 11) then 3 # mesice
	  end as SEASON
FROM (select * from covid19_basic cb where date='2020-03-03') cb;   #doèasnì, **********ZRUŠIT


-- LIFE EXPECTANCY + BASIC INFO----- 
create or replace table t_barbora_kacerovska_SQL_LE as;
select le1.iso3, c.median_age_2018, ROUND(c.population/c.surface_area,3) as POP_DENSITY_CALCULATED, c.region_in_world, c.population, c.surface_area, round(le1.life_exp_2015-le2.life_exp_1965,2) as LIFE_EXP_DIFF
from (
	select iso3, life_expectancy as 'life_exp_2015'  from life_expectancy le 
	where year = 2015) le1
left join (
	select iso3, life_expectancy as 'life_exp_1965' from life_expectancy le 
	where year = 1965) le2
	on le1.iso3 = le2.iso3
left JOIN (
	select iso3, median_age_2018, region_in_world, population, surface_area
	from countries c 
	where iso3 is not null) c 
	on le1.iso3 = c.iso3 
where le1.iso3 is not null

	
--- RELIGION ----------


create or replace table t_barbora_kacerovska_SQL_religion as
select r2.country, 
	sum(case when r3.religion='Christianity'  then round(r3.population/r2.pop_total*100,2)  else 0 end) as 'Christianity',
	sum(case when r3.religion='Islam'  then round(r3.population/r2.pop_total*100,2)  else 0 end) as 'Islam',
	sum(case when r3.religion='Hinduism'  then round(r3.population/r2.pop_total*100,2)  else 0 end) as 'Hinduism',
	sum(case when r3.religion='Unaffiliated Religions'  then round(r3.population/r2.pop_total*100,2)  else 0 end) as 'Unaffiliated Religions',
	sum(case when r3.religion='Buddhism'  then round(r3.population/r2.pop_total*100,2)  else 0 end) as 'Buddhism',
	sum(case when r3.religion='Folk religions'  then round(r3.population/r2.pop_total*100,2)  else 0 end) as 'Folk religions',
	sum(case when r3.religion='Judaism'  then round(r3.population/r2.pop_total*100,2)  else 0 end) as 'Judaism',
	sum(case when r3.religion='Other Religions'  then round(r3.population/r2.pop_total*100,2)  else 0 end) as 'Other Religions'
from (
	select country, sum(population) as pop_total
	from religions r2
	where year=2020
	group by country) r2
left join (
	select religion, country, population
	from religions r3 
	where year = 2020) r3
	on r2.country=r3.country
group by r2.country;	

--- --WEATHER-------------

create or replace table t_barbora_kacerovska_SQL_weather as;
select capital_city, iso3, rain.date, rain.GUST_MAX, rain.RAIN_HOURS, temp.AVG_TEMP
from countries c
join (
	select city, date, max(gust) as GUST_MAX, sum(case when rain=0 then 0 else 3 end) as RAIN_HOURS
	from weather w3 
	group by city, date) rain
	on capital_city = rain.city
left join (
	select w.city, w.date, avg(w.temp) as AVG_TEMP
	from weather w    
	where w.hour in (6,9,12,15,18)
	group by w.city, w.date) temp
	on capital_city = temp.city
 	and rain.date = temp.date


--- ECONOMY --------

create or replace table t_barbora_kacerovska_SQL_economy as;
select e2.country,round(LAST_VALUE(GDP) over (order by country, `year`)/population) as GDP_population , gini.GINI, mort.MORTALITY_5 #,   COUNT(*) OVER () AS TotalRecords
from economies e2 
LEFT JOIN(
	select country, first_value(gini) over (partition by country) as GINI
	from economies e2 
	where gini is not null and `year`>2015
	group by country) gini
	on e2.country = gini.country
LEFT JOIN(
	SELECT 	country, ROUND(LAST_VALUE(mortaliy_under5) over (order by country, `year`),1) as MORTALITY_5 
	FROM economies e2 
	where mortaliy_under5 is not null and `year`>2015
	group by country) mort
	on e2.country = mort.country
where GDP is not null and `year`>2015
group by e2.country


