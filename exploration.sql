Select * 
from CovidDeaths
where Continent is not null
order by 3, 4

Select * 
from CovidVaccinations
order by 3, 4


-- select data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
from Covid_analysis.dbo.CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if a person contract covid in a country
Select Location, date, total_cases, total_deaths, (total_deaths*100/total_cases) as DeathPercentage
from CovidDeaths
where Location = 'India'
order by 1,2

-- Looking at total cases vs population
-- Shows what proportion of population got infected
Select Location, date, total_cases, Population,(total_cases*100/Population) as PositivityRate
from CovidDeaths
where Location = 'India'
order by 1,2

-- Looking at countries with highest positivity rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases*100/Population) as PercentPopulationInfected
from CovidDeaths
where Continent is not null
Group By Location, Population
Order by PercentPopulationInfected Desc


-- Showing the countries the highest death count per population
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where Continent is not null
Group by Location
order by TotalDeathCount Desc


-- Showing the continents with the highest death counts
-- LET'S BREAK DOWN  THINGS BY CONTINENT
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where Continent is not null
Group by continent
order by TotalDeathCount Desc


-- GLOBAL numbers
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))*100/sum(new_cases) as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2




-- USE CTE
WITH PopVsVac as 
(-- Looking at Total Population vs Vaccinations
-- Join Vaccination and deaths
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) Over (Partition By dea.location order by dea.Location,dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac


-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) Over (Partition By dea.location order by dea.Location,dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) Over (Partition By dea.location order by dea.Location,dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null