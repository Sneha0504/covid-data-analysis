SELECT *
FROM project0..CovidDeaths
where continent is not null
order by 3,4

SELECT*
From project0..CovidVaccinations
order by 3,4

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM project0..CovidDeaths
order by 1,2
 looking at the toatal cases vs total deaths
SELECT location,date, total_cases, total_deaths , (total_deaths/total_cases)*100 as Deathpercentage
FROM project0..CovidDeaths
Where location like '%states%'
order by 1,2

-- looking at the total cases vs population
SELECT location,date,  population, total_cases , (total_cases/population)*100 as PercentPopulationInfected
FROM project0..CovidDeaths
--Where location like '%states%'
order by 1,2

 looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectedCount , MAX((total_cases/population))*100 as PercentPopulationInfected
FROM project0..CovidDeaths
Group By location, population
order by PercentPopulationInfected desc

 looking at the countries with highest deathcounts per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM project0..CovidDeaths
where continent is not null
Group By location
order by TotalDeathCount  desc


-- LETS BREAK THINGS DOWN BY CONTINENT



--showing continebs with the highest death counts per population 
SELECT continent , MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM project0..CovidDeaths
where continent is not null
Group By continent
order by TotalDeathCount  desc

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as  DeathPercentage
FROM project0..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by date
order by 1,2

SELECT  SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as  DeathPercentage
FROM project0..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2

-- looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from project0..CovidDeaths dea
join project0..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 -- use CTE
 
 with PopvsVac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from project0..CovidDeaths dea
join project0..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select* ,(Rollingpeoplevaccinated/population)*100
 from PopvsVac


 --TEMP TABLE
DROP Table if exists #PercentpopulationVaccinated

Create Table #PercentpopulationVaccinated
(
 Continent nvarchar (255),
 location nvarchar(255),
 Date datetime,
 population numeric,
 New_vaccinations numeric,
 Rollingpeoplevaccinated numeric
 )

 INSERT into #PercentpopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from project0..CovidDeaths dea
join project0..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3

select* ,(Rollingpeoplevaccinated/population)*100
from #PercentpopulationVaccinated

-- creating view to store data for later visualizations

Create View PercentpopulationVaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from project0..CovidDeaths dea
join project0..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 select*
 from PercentpopulationVaccinated
 