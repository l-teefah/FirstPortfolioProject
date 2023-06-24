-- Data exploration
Select *
From PortfolioProject..CovidDeaths
Where continent is not NULL
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- select data that we'll be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths 
Order by 1,2

-- Looking at the total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country e.g US
--Alex's code
Select Location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
Order by 1,2

--What worked for me
SELECT Location, date, total_cases, total_deaths, 
CASE WHEN CAST(total_cases as int)= 0 THEN NULL ELSE (CAST(total_deaths as int) * 100 / CAST(total_cases as int)) END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2

-- Looking at the total cases vs the population
-- Shows what percentage of the population has gotten covid e.g US
Select Location, date, population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where Location like '%states%'
Order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, population
Order by PercentPopulationInfected desc

-- Showing countries with highest death count per population
Select Location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by Location, population
Order by TotalDeathCount desc

-- Lets break things down by continent
-- Showing continents with highest death counts
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by continent
Order by TotalDeathCount desc

-- correct data we'll be using
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is NULL
Group by location
Order by TotalDeathCount desc

-- Global numbers
--Alex's code
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by date
Order by 1,2 

--What worked for me
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
CASE WHEN SUM(new_cases) = 0 THEN NULL ELSE (SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0)) * 100 END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not NULL
--Group by date
Order by 1,2 

-- Looking at total population vs vaccination
Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date

--Use CTE(columns in the CTE has to be the same with the one in the code embedded)
With PopVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not NULL
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopVsVac

--Temp table (didn't work)
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not NULL

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating view to store data later for visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not NULL

--
Select *
From PercentPopulationVaccinated



