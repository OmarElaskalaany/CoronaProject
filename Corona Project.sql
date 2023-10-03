--Total Cases vs Total Death

Select Location, date, new_Cases, total_deaths, (total_deaths/total_cases)*100 AS rate
From CoronaProject..CovidDeaths
Where location like '%state%'
Order By 1,2 DESC

-- Total Cases vs Population
-- Percentage of population that got covid

Select Location, date, new_Cases, population, (total_cases/population)*100 AS PercentOfPop
From CoronaProject..CovidDeaths
Order By 1,2 DESC

--Highest infection rate compared to population

Select Location, population, Max(new_Cases) as highestInfection, Max((total_cases/population))*100 AS PercentOfInfec
From CoronaProject..CovidDeaths
Group By Location, population
Order By PercentOfInfec DESC

--Highest Death count per population

Select Location, Max(cast(total_deaths as int)) as highestDeath 
From CoronaProject..CovidDeaths 
where continent IS NOT null
Group By Location
Order By highestDeath DESC

-- Joining the two tables

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) Over
(Partition by dea.location order by	dea.location, dea.date) AS RollingPeople
From CoronaProject..CovidDeaths dea
Join CoronaProject..CovidVaccinations vac 
	On dea.date = vac.date 
	AND dea.location = vac.location
	Where dea.continent is not null
	order by 2,3

--using CTE to see the percentage of vacinated people
With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeople)
AS (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) Over
(Partition by dea.location order by	dea.location, dea.date) AS RollingPeople
From CoronaProject..CovidDeaths dea
Join CoronaProject..CovidVaccinations vac 
	On dea.date = vac.date 
	AND dea.location = vac.location
	Where dea.continent is not null
)
Select *, (RollingPeople/population)*100 AS rate
from PopVsVac