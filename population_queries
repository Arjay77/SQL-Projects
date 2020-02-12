/*All years in data set*/
SELECT DISTINCT year from population_years;

/*largest population in Gabon across all years*/
SELECT max(population) as 'Population(millions)', country, year
from population_years
where country = "Gabon";

/*10 lowest populations in 2005*/
SELECT country, population
from population_years
where year = 2005
order by population asc
limit 10;

/*population in 2010 over 100mil*/
SELECT distinct country, population
from population_years
where year = 2010 and population > 100;

/* # of countries names that contain Islands*/
SELECT count(country) as "Number of Countries Containing Islands"
from population_years
where country like "%Islands%";

/*Population in 2000 & 2010 in Indonesia*/
SELECT population, year
from population_years
where country = "Indonesia" and (year = 2000 or year = 2010);
