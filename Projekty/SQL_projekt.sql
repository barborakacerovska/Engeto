SELECT 
	cb.country,
	cb.date,
	case when weekday(date) in (5,6) then 1 else 0 end as weekend,  # 5=sobota,  6=nedele
	case when month(date) in (12, 1, 2) then 0
      when month(date) in (3, 4, 5) then 1
      when month(date) in (6, 7, 8) then 2
      when month(date) in (9, 10, 11) then 3 # mesice
	  end as season,
	cb.confirmed,
	cb.recovered,
	cb.deaths,
	lt.code3 ,
	lt.iso3,
	lt.lat,
	lt.`long` ,
	lt.population,
	c.avg_height ,
	c.continent ,
	c.religion ,
	c.elevation ,
	c.government_type ,
	c.independence_date ,
	c.landlocked ,
	c.life_expectancy ,
	c.north ,
	c.east ,
	c.west ,
	c.south ,
	c.population_density ,
	ROUND(c.population/c.surface_area,3) as pop_density_calculated,
	c.region_in_world ,
	c.surface_area ,
	c.yearly_average_temperature ,
	c.median_age_2018,
	e.gini,
	e.mortaliy_under5 ,
	e.GDP_population
FROM (select * from covid19_basic cb where date='2020-03-03') cb   #doèasnì
LEFT JOIN (   							#pridavam informace o statech
	select * 
	from lookup_table lt
	where province is null ) lt
	on cb.country = lt.country
LEFT JOIN (select *
	from countries c 
	where iso3 is not null) c 
	on lt.iso3 = c.iso3 
LEFT JOIN (
	select country, gini, mortaliy_under5, round(GDP/population ) as GDP_population
	from economies e 
	where year = 2018) e
	on cb.country = e.country;   #Vyøešit èesko a další zemì



select * 
from (
	select country,population, GDP, gini, fertility, mortaliy_under5, `index` as economy_index, round(GDP/population ) as GDP_population
	from economies e 
	where year = 2018) e;   # data za rok 2018!

SELECT * 	
FROM (
select iso3,life_expectancy 
from life_expectancy le 
where year = 2018) le;
	
	
select *
from countries c2 ;

select *
from lookup_table lt ;
 