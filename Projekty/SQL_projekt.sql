SELECT cb.country,
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
	lt.iso2 ,
	lt.iso3,
	lt.lat,
	lt.`long` ,
	lt.population,
	c.avg_height ,
	c.continent ,
	c.religion ,
	c.elevation ,
	c.north ,
	c.south ,
	c.west,
	c.east,
	c.government_type ,
	c.independence_date ,
	c.landlocked ,
	c.life_expectancy ,
	c.population_density ,
	ROUND(c.population/c.surface_area,3) as pop_density_calculated,
	c.region_in_world ,
	c.surface_area ,
	c.yearly_average_temperature ,
	c.median_age_2018 
FROM (select * from covid19_basic cb where date='2020-03-03') cb   #doèasnì
LEFT JOIN (   							#pridavam informace o statech
	select * 
	from lookup_table lt
	where province is null ) lt
	on cb.country = lt.country
LEFT JOIN (select * from countries c where iso3 is not null) c
	on lt.iso3 = c.iso3   # JE LEPŠÍ TAM NECHAT VŠECHNO NEBO JENOM JEDEN KLÍÈ?
	#and c.abbreviation  = lt.iso2    
	#and c.iso_numeric = lt.code3 
order by cb.country ;





select *
from countries c2 ;

select *
from lookup_table lt ;
 