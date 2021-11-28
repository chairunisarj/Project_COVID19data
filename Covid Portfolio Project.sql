Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- The Data that are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
Order by 1,2

-- Total Cases vs Total Deaths in Indonesia

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Indonesia'
Order by 1,2

-- Total Cases vs Population in Indonesia

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'Indonesia'
Order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
GROUP BY location, population
Order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
GROUP BY location
Order by TotalDeathCount desc

--Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths
--where continent is null
--and location not like '%income%'
--GROUP BY location
--Order by TotalDeathCount desc
-- by this time, I found an issue in the data. Because it includes 'Upper middle income', 'High income', 'Lower middle income', and 'Low income' as location. So I add location not like '%income%' in where clause.



-- Looking the data by CONTINENT

-- Continents with highest death count per population

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
GROUP BY continent
Order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- Looking at the number of deaths accross the world from the beginning to the end
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2

-- JOIN THE TABLES
-- Total Population vs Vaccinantions

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingNumberVaccinations
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3

-- USE CTE

With PopvsVac ( continent, location, date, population, new_vaccinations, RollingNumberVaccinations )
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingNumberVaccinations
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
)
Select *, (RollingNumberVaccinations/population)*100 as VaccinationPercentage
From PopvsVac



-- TEMP TABLE

DROP table if exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingNumberVaccinations numeric
)

Insert into #PercentPeopleVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingNumberVaccinations
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.location not like '%income%'

Select *, (RollingNumberVaccinations/population)*100 as VaccinationPercentage
From #PercentPeopleVaccinated

-- Create View for Data Visualization

Create View PercentPeopleVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingNumberVaccinations
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.location not like '%income%'
and cd.continent is not null

Select *
From PercentPeopleVaccinated




