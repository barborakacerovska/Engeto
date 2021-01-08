SELECT 
	cb.*,
	case when weekday(date) in (5,6) then 1 else 0 end as weekend,  # 5=sobota,  6=nedele
	case when month(date) in (12, 1, 2) then 0
      when month(date) in (3, 4, 5) then 1
      when month(date) in (6, 7, 8) then 2
      when month(date) in (9, 10, 11) then 3 # mesice
	  end as season,
	lt.population,
	ROUND(c.population/c.surface_area,3) as pop_density_calculated,
	#e.GDP_population, 
	#e.gini,
	#e.mortaliy_under5,
	c.median_age_2018,
	c.region_in_world,
	le.life_exp_diff
FROM (select * from covid19_basic cb where date='2020-03-03') cb   #doèasnì, **********ZRUŠIT
LEFT JOIN (   							
	select population, country, iso3 
	from lookup_table lt
	where province is null ) lt
	on cb.country = lt.country
LEFT JOIN (
	select iso3, median_age_2018, region_in_world, population, surface_area
	from countries c 
	where iso3 is not null) c 
	on lt.iso3 = c.iso3 
LEFT JOIN (
	select le1.iso3, round(le1.life_exp_2015-le2.life_exp_1965,2) as life_exp_diff
	from (
		select iso3, life_expectancy as 'life_exp_2015'  from life_expectancy le 
		where year = 2015) le1
	left join (
		select iso3, life_expectancy as 'life_exp_1965' from life_expectancy le 
		where year = 1965) le2
		on le1.iso3 = le2.iso3
	where le1.iso3 is not null) le
	on lt.iso3 = le.iso3;



	
--- RELIGION -------------


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

	

--- --WEATHER------------------

###	Prùmìr z teplot (jaká je denní/noèní?)
select city, date, avg(temp), c.iso3
from weather w
left join(
	select capital_city, iso3 
	from countries c
	) c
on w.city = c.capital_city 
group by city, date

### Poèet hodin kdy byly srážky nenulové
select w.city, w.date, sum(case when rain=0 then 0 else 3 end) as rain_hours
from (
	select city, date, hour, temp, rain
	from weather w) w
left join(
	select capital_city, iso3 
	from countries c
	) c
on w.city = c.capital_city 
group by city, date;



--- ECONOMY --------------


# GDP population 2018
select country, 
	round(LAST_VALUE(GDP) over (order by country, `year`)/population) as GDP_population 
from (
	select country, `year` , GDP, population
	from economies e
	where `year` > 2015 and gdp IS not null and population is not null 
	)
	as e_gdp
group by country;

### Gini v posledních 5 letech 
SELECT
	country,
	LAST_VALUE(gini) over (order by country, `year`) as GINI  #, `year` as last_gini_year
FROM (
  	SELECT							
    country,gini, `year` , mortaliy_under5 
  	FROM economies e2
  	where gini is not null and `year` >2015
	)
	as e_g
group by country
;

### Mortality under 5 
SELECT
	country,
	LAST_VALUE(mortaliy_under5) over (order by country, `year`) as MORTALITY_5 #, `year` as last_mort_year
FROM (
  SELECT							
    country,mortaliy_under5 , `year` 
  FROM economies e2
  where mortaliy_under5 is not null 
) as e_mu5
group by country
