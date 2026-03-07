/*
Covid 19 Data Exploration

Skilled used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


-- Selecting data:

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Total Cases vs Total Deaths 
-- Showing likelihood of death if Covid is contracted in Australia/'x' country  

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
where location like '%australia%'
and continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of the population is infected with Covid 

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%australia%'
order by 1,2

-- Countries with Highest Infection Rate compared to 

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercectPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%australia%'
Where continent is not null
Group by Location, Population
order by PercectPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Continents with the Highest Death Count per Population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualisations

DROP VIEW IF EXISTS PercentPopulationVaccinated;
GO 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
GO

-- Creating view for latest country snapshot

DROP VIEW IF EXISTS vw_LatestCountryCovidStats;
GO

CREATE VIEW vw_LatestCountryCovidStats AS
WITH LatestDateCTE AS
(
    SELECT 
        location,
        MAX(date) AS LatestDate
    FROM PortfolioProject..CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY location
)
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    dea.total_cases,
    dea.total_deaths,
    dea.total_cases_per_million,
    dea.total_deaths_per_million,
    (dea.total_cases / dea.population) * 100 AS PercentPopulationInfected,
    (CAST(dea.total_deaths AS float) / NULLIF(dea.total_cases, 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths dea
JOIN LatestDateCTE ld
    ON dea.location = ld.location
   AND dea.date = ld.LatestDate
WHERE dea.continent IS NOT NULL;
GO

-- Country Infection Rate

DROP VIEW IF EXISTS vw_CountryInfectionRate;
GO

CREATE VIEW vw_CountryInfectionRate AS
SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population) * 100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population;
GO

-- Country Death Rate
DROP VIEW IF EXISTS vw_CountryDeathCount;
GO

CREATE VIEW vw_CountryDeathCount AS
SELECT 
    location,
    MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location;
GO

-- Continent Summary
DROP VIEW IF EXISTS vw_ContinentSummary;
GO

CREATE VIEW vw_ContinentSummary AS
SELECT 
    continent,
    MAX(CAST(total_deaths AS int)) AS TotalDeathCount,
    MAX(total_cases) AS TotalCases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent;
GO

-- Global Daily Totals
DROP VIEW IF EXISTS vw_GlobalDailyTotals;
GO

CREATE VIEW vw_GlobalRolling7Day AS
WITH DailyTotals AS
(
    SELECT 
        date,
        SUM(new_cases) AS total_cases,
        SUM(CAST(new_deaths AS int)) AS total_deaths
    FROM PortfolioProject..CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY date
)
SELECT
    date,
    total_cases,
    total_deaths,
    AVG(CAST(total_cases AS float)) OVER (
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS Rolling7DayAvgCases,
    AVG(CAST(total_deaths AS float)) OVER (
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS Rolling7DayAvgDeaths
FROM DailyTotals;
GO

