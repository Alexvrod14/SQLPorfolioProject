

-- COVID DATA EXPLORATION in SQL

-- Taking a look into key points of the data

SELECT LOCATION, DATE, total_cases, new_cases, total_deaths, population
FROM [Porfolio Project 1]..CovidDeaths$
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

-- Shows the likelihood of dying if you contract Covid in your country.

SELECT LOCATION, DATE, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Porfolio Project 1]..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at the Total Cases vs the Population

SELECT LOCATION, DATE, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM [Porfolio Project 1]..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT LOCATION, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM [Porfolio Project 1]..CovidDeaths$
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with the Highest Death Count per Population

SELECT LOCATION, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Porfolio Project 1]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Porfolio Project 1]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM [Porfolio Project 1]..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent is not null
--GROUP BY Date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM [Porfolio Project 1]..CovidVaccinations$ vac
JOIN [Porfolio Project 1]..CovidDeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2, 3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Porfolio Project 1]..CovidVaccinations$ vac
JOIN [Porfolio Project 1]..CovidDeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulatedVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Porfolio Project 1]..CovidVaccinations$ vac
JOIN [Porfolio Project 1]..CovidDeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Porfolio Project 1]..CovidDeaths$ dea
JOIN [Porfolio Project 1]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2, 3

SELECT *
FROM PercentPopulationVaccinated