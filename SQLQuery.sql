/*

Queries used for Tableau Project

*/



-- 1. 

SELECT 
    SUM(CAST(new_cases AS BIGINT)) AS total_cases, 
    SUM(CAST(new_deaths AS BIGINT)) AS total_deaths, 
    (SUM(total_deaths) / SUM(total_cases)) * 100 AS DeathPercentage
FROM 
    PortfolioProject..[owid-covid-data]
WHERE 
    continent IS NOT NULL 
ORDER BY 
    total_cases, total_deaths;



-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select continent, SUM(cast(new_deaths as int)) as TotalDeathCount
From 
     PortfolioProject..[owid-covid-data]
--Where location like '%states%'
Where continent is not null 
and location not in ('World', 'European Union', 'International')
Group by continent
order by TotalDeathCount desc


-- 3.

SELECT 
    Location, 
    population_density,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(CASE 
            WHEN CAST(population_density AS FLOAT) > 0 THEN (total_cases / CAST(population_density AS FLOAT)) * 100
            ELSE 0 
        END) AS PercentPopulationInfected
FROM 
    PortfolioProject..[owid-covid-data]
--WHERE location LIKE '%states%'
GROUP BY 
    Location, 
    population_density
HAVING 
    MAX(CAST(population_density AS FLOAT)) > 0
ORDER BY 
    PercentPopulationInfected DESC;





-- 4.


SELECT 
    Location, 
    population_density,
    date, 
    MAX(total_cases) AS HighestInfectionCount,
    MAX((CAST(total_cases AS FLOAT) / NULLIF(CAST(population_density AS FLOAT), 0)) * 100) AS PercentPopulationInfected
FROM 
    PortfolioProject..[owid-covid-data]
--WHERE location LIKE '%states%'
GROUP BY 
    Location, 
    population_density, 
    date
ORDER BY 
    PercentPopulationInfected DESC;














-- Queries I originally had, but excluded some because it created too long of video
-- Here only in case you want to check them out


-- 1.

Select dea.continent, dea.location, dea.date, dea.population_density
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..[owid-covid-data] dea
Join PortfolioProject..[CovidVaccinations.csv] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population_density
order by 1,2,3




-- 2.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..[owid-covid-data]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..[owid-covid-data]
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 4.

Select Location, population_density, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population_density))*100 as PercentPopulationInfected
From PortfolioProject..[owid-covid-data]
--Where location like '%states%'
Group by Location, population_density
order by PercentPopulationInfected desc



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select Location, date, population_density, total_cases, total_deaths
From PortfolioProject..[owid-covid-data]
--Where location like '%states%'
where continent is not null 
order by 1,2;


-- 6. 


With PopvsVac (Continent, Location, Date, population_density, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..[owid-covid-data] dea
Join PortfolioProject..[CovidVaccinations.csv] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population_density)*100 as PercentPeopleVaccinated
From PopvsVac;


-- 7. 

Select Location, population_density,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population_density))*100 as PercentPopulationInfected
From PortfolioProject..[owid-covid-data]
--Where location like '%states%'
Group by Location, population_density, date
order by PercentPopulationInfected desc;


