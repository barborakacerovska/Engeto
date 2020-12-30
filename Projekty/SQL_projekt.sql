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
	e.GDP_population, 
	e.gini,
	e.mortaliy_under5,
	c.median_age_2018,
	c.region_in_world,
	le.life_exp_diff
FROM (select * from covid19_basic cb where date='2020-03-03') cb   #do�asn�, **********ZRU�IT
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
	select country, gini, mortaliy_under5, round(GDP/population ) as GDP_population
	from economies e 
	where year = 2018) e
	on cb.country = e.country   #Vy�e�it �esko a dal�� zem�
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



	

select r4.country, sum(r4.Christianity) as 'Christianity', sum(r4.Islam) as Islam, sum(r4.Hinduism) as 'Hinduism' ,
	sum(r4.`Unaffiliated Religions`) as 'Unaffiliated Religions', sum(r4.Buddhism) as 'Buddhism', sum(r4.`Folk Religions`) as 'Folk Regions',
	sum(r4.`Judaism`) as 'Judaism', sum(r4.`Other Religions`) as 'Other Religions'
from (
select r2.country, 
	case when r3.religion='Christianity'  then round(r3.population/r2.pop_total*100,2)  else 0 end as 'Christianity',
	case when r3.religion='Islam'  then round(r3.population/r2.pop_total*100,2)  else 0 end as 'Islam',
	case when r3.religion='Hinduism'  then round(r3.population/r2.pop_total*100,2)  else 0 end as 'Hinduism',
	case when r3.religion='Unaffiliated Religions'  then round(r3.population/r2.pop_total*100,2)  else 0 end as 'Unaffiliated Religions',
	case when r3.religion='Buddhism'  then round(r3.population/r2.pop_total*100,2)  else 0 end as 'Buddhism',
	case when r3.religion='Folk religions'  then round(r3.population/r2.pop_total*100,2)  else 0 end as 'Folk religions',
	case when r3.religion='Judaism'  then round(r3.population/r2.pop_total*100,2)  else 0 end as 'Judaism',
	case when r3.religion='Other Religions'  then round(r3.population/r2.pop_total*100,2)  else 0 end as 'Other Religions'
from (
	select country, sum(population) as pop_total
	from religions r2
	where year=2020
	group by country) r2
left join (
	select religion, country, population
	from religions r3 
	where year = 2020) r3
	on r2.country=r3.country) r4
group by r4.country ;



###Jak vytvvo�it pr�m�r z teplot podle vzorce (t7+t14+2*t21)/4
select city, date,hour, temp
from weather w
left join(
	select capital_city, iso3 
	from countries c
	) c
on w.city = c.capital_city 
where date = '2020-08-08'
and  `hour` in (6,15,21)

### Po�et hodin kdy byly sr�ky nenulov�
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




