--select * from
--PortfolioProject..CovidDeaths
--order by 3,4

--select * from
--PortfolioProject..CovidVaccination
--order by 3,4

-- Select Data that gonna be using
select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- Show likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where location like '%vietnam%'
and continent is not null
order by 1,2

-- Looking at total cases vs population
-- Show what percentage of population got Covid

select location, date,population, total_cases,  (total_cases/population)*100 as ContractPercentage
from PortfolioProject..CovidDeaths
where location like '%vietnam%'
and continent is not null 
order by 1,2

-- Looking at Countries with Highest infection Rate compared to Population
select location,population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%vietnam%'
group by location,population
order by PercentPopulationInfected desc --descending

-- Looking at how many people actually died 
-- Showing Countries with Highest Death Count per Population
select location, Max(cast(total_deaths as int)) as HighestDeathsCount  --Max((total_deaths/population)*100) as CovidDeathsRate
from PortfolioProject..CovidDeaths
--where location like '%vietnam%'
where continent is not null -- elminate the data group another data
group by location
order by HighestDeathsCount desc 

-- Let's break things down by continent

-- Showing continents with the highest death count per population
select continent, Max(cast(total_deaths as int)) as HighestDeathsCount  --Max((total_deaths/population)*100) as CovidDeathsRate
from PortfolioProject..CovidDeaths
where continent is not null -- elminate the data group another data
group by continent
order by HighestDeathsCount desc



-- Global numbers
select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/Sum(new_cases)  as DeathsPercentage
from PortfolioProject..CovidDeaths
--where location like '%vietnam%'
where continent is not null
--group by date
order by 1,2


-- Looking at total population vs vaccinations
--USE CTE 
with PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated /population)*100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE
Create Table #PercenPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert into #PercenPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated /population)*100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercenPopulationVaccinated



-- Creating view to store data for later visualization
Create view PercenPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated /population)*100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3