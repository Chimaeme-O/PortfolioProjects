select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data to work with
select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Comparing Total Cases to Total Deaths to show likelihood of dying if you get covid in canada
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'canada'
where continent is not null
order by 3,4,5


--Comparing Total Cases to Population to show population percentage with covid per country
select location, date, population, total_cases, (total_cases/population)*100 as CovidPopPercentage
From PortfolioProject..CovidDeaths
-- Where location = 'canada'
where continent is not null
order by 1,2

-- Comparing Infection rate to population Per country
select location, population, MAX(total_cases) AS MaxInfectionCount, Max((total_cases/population))*100 as CovidPopPercentage
From PortfolioProject..CovidDeaths
-- Where location = 'canada'
where continent is not null
Group by location, population
order by CovidPopPercentage desc

-- Showing countries with highest death count per population
select location, population, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location = 'canada'
where continent is not null
Group by location, population
order by TotalDeathCount desc

-- Breaking down by continent to show highest death count (Correct Way)
select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location = 'canada'
where continent is null
Group by location
order by TotalDeathCount desc


-- Breaking down by continent (Slightly Correct Way)
select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location = 'canada'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Drilling down to view per continent per location
select continent,location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location = 'canada'
where continent is not null
Group by continent, location
order by TotalDeathCount desc


-- Global breakdown
select SUM(new_cases) as total_global_cases, SUM(cast(new_deaths as int)) as total_global_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths
-- Where location = 'canada'
where continent is not null
-- group by date
order by 1,2


-- Global breakdown with date
select date, SUM(new_cases) as total_global_cases, SUM(cast(new_deaths as int)) as total_global_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths
-- Where location = 'canada'
where continent is not null
group by date
order by 1,2


-- Covid vaccinations table
select *
from PortfolioProject..CovidVaccinations


--Joining Both tables
select *
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Comparing total population to total vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- Rolling count of new vaccinations (instead of using total vac)
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as TotalVac
-- So the rolling sum changes per new location. Also note use of convert instead of cast
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- using CTE
with PopVsVac (continent, location, date, population, new_vaccinations, TotalVac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as TotalVac
-- So the rolling sum changes per new location. Also note use of convert instead of cast
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (TotalVac/population)*100
from PopVsVac



-- Using Temp table
Drop table if exists #percentpopulationVaccinated
Create Table #percentpopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
TotalVac numeric
)
-- when using temp table you indicate the data type for the columns as well
Insert into #percentpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as TotalVac
-- So the rolling sum changes per new location. Also note use of convert instead of cast
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
-- order by 2,3

Select *, (TotalVac/population)*100
from #percentpopulationVaccinated


--creating View to store data for future visualization
create view percentpopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as TotalVac
-- So the rolling sum changes per new location. Also note use of convert instead of cast
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

-- Seeing new view/table
select *
from percentpopulationVaccinated

