-- Data Selection 

select * from  CovidDeaths 
where continent is not NULL
order by 3,4;



-- Liklehood of conracting COVID in your country 

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 2) AS DeathPercentage
FROM
    CovidDeaths
WHERE
    location LIKE '%EGY%'
        AND continent IS NOT NULL
ORDER BY 1 , 2;

-- Total cases Vs Population 

SELECT 
    location,
    date,
    population,
    total_cases,
    ROUND((total_cases / population) * 100, 2) AS COVID_cases_percentage
FROM
    CovidDeaths
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;


-- Countries with highest infection rate compared to population

SELECT 
    location,
    population,
    MAX(total_cases) Highest_infection_count,
    MAX(ROUND((total_cases / population) * 100, 2)) AS Infected_Percentage
FROM
    CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY location , population
ORDER BY Infected_Percentage DESC;


-- Continents with Highest death count 

SELECT 
    continent, MAX(total_deaths) AS Total_death_count
FROM
    CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY Total_death_count DESC;

-- breaking it down by continent

SELECT 
    location, MAX(total_deaths) AS Total_death_count
FROM
    CovidDeaths
WHERE
    continent IS NULL
GROUP BY location
ORDER BY Total_death_count DESC;



-- Global Numbers - Total Deaths as a Percentage of Cases aggregated by Date


SELECT 
    date,
    SUM(new_cases) AS Total_New_Cases,
    SUM(new_deaths) AS Total_New_Deaths,
    ROUND((SUM(new_deaths) / SUM(new_cases) * 100),
            2) AS TotalDeath_asPercentage_TotalCases
FROM
    CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY date
ORDER BY 1 , 2;


SELECT 
    SUM(new_cases) AS Total_New_Cases,
    SUM(new_deaths) AS Total_New_Deaths,
    ROUND((SUM(new_deaths) / SUM(new_cases) * 100),
            2) AS TotalDeath_asPercentage_TotalCases
FROM
    CovidDeaths
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;



-- Join

SELECT 
    *
FROM
    CovidDeaths D
        JOIN
    Vaccinations V ON d.location = v.location
        AND D.date = v.date;

-- Total Population Vs Vaccinations

SELECT 
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations
FROM
    CovidDeaths D
        JOIN
    Vaccinations V ON d.location = v.location
        AND D.date = v.date
WHERE
    d.continent IS NOT NULL
ORDER BY 2 , 3;

-- Cumulative New_Vaccinations  

SELECT 
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations, 
    sum(new_vaccinations) over (Partition by d.location order by d.location, d.date) as Cumulative_New_Vaccinations
    
FROM
    CovidDeaths D
        JOIN
    Vaccinations V ON d.location = v.location
        AND D.date = v.date
WHERE
    d.continent IS NOT NULL
ORDER BY 2 , 3;


--  CTE ~ Population Vs Vaccinations

with PopVsVac (continent, location, date, population, new_vaccinations, Cumulative_New_Vaccinations)
as
(SELECT 
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations, 
    sum(new_vaccinations) over (Partition by d.location order by d.location, d.date) as Cumulative_New_Vaccinations 
FROM
    CovidDeaths D
        JOIN
    Vaccinations V ON d.location = v.location
        AND D.date = v.date
WHERE
    d.continent IS NOT NULL
)
select *, round((Cumulative_New_Vaccinations/population), 4)*100
 from PopVsVac;
 
 
-----------------
-- Create a temp Table 

Drop table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
continent varchar(255), 
location varchar (255),
date datetime, 
population int, 
new_vaccinations float, 
Cumulative_New_Vaccinations float);

insert into PercentPopulationVaccinated
SELECT 
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations, 
    sum(new_vaccinations) over (Partition by d.location order by d.location, d.date) as Cumulative_New_Vaccinations
FROM
    CovidDeaths D
        JOIN
    Vaccinations V ON d.location = v.location
        AND D.date = v.date
WHERE
    d.continent IS NOT NULL
ORDER BY 2 , 3;

select *, round((Cumulative_New_Vaccinations/population), 4)*100
 from PercentPopulationVaccinated;


-- Creating Views for Data Viz

create view PercentPopulationVaccinated as 
SELECT 
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations, 
    sum(new_vaccinations) over (Partition by d.location order by d.location, d.date) as Cumulative_New_Vaccinations
FROM
    CovidDeaths D
        JOIN
    Vaccinations V ON d.location = v.location
        AND D.date = v.date
WHERE
    d.continent IS NOT NULL
ORDER BY 2 , 3;

select * from percentpopulationvaccinated




