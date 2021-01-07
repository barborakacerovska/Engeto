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

	



###Jak vytvvoøit prùmìr z teplot podle vzorce (t7+t14+2*t21)/4
select city, date,hour, temp
from weather w
left join(
	select capital_city, iso3 
	from countries c
	) c
on w.city = c.capital_city 
where date = '2020-08-08'
and  `hour` in (6,15,21)
group by city

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
group by city, date



# gini
select country, year, mortaliy_under5, round(GDP/population ) as GDP_population, 
from economies e 



SELECT
	country#,gini, `year` ,#mortaliy_under5, round(GDP/population ) as GDP_population, 
	gini_partition ,MAX(year), FIRST_VALUE(gini) over (partition by gini_partition order by COUNTRY,`year`) as last_gini
FROM (
  SELECT
    country,gini,year,
    mortaliy_under5, GDP,population,
    count(gini) over (order by country,`year`) as gini_partition
  FROM economies e2 
  where gini is not null
  ORDER BY country,`year` asC
) as q
group by country;
#ORDER BY country,`year` DESC;

### gini v posledních 8 letech
SELECT
	country,`year` as last_gini_year,LAST_VALUE(gini) over (order by country, `year`)
FROM (
  SELECT
    country,gini,year
  FROM economies e2
  where gini is not null and `year` >2013
) as e_g
group by country asc
;

SELECT
	country,gini,`year` 
FROM (
  SELECT
    country,gini,year
  FROM economies e2
  where  country in ('Zambia')
) as e_g

