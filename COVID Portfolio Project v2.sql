SELECT *
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

--SELECT *
--FROM dbo.CovidVaccinations
--ORDER BY 3, 4;

Select Location, date, total_cases,new_cases,total_deaths, population
From dbo.CovidDeaths
ORDER BY 1, 2;

--Looking at total cases vs total deaths
-- Shows the likelihood of dying ig you contract COVID in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From dbo.CovidDeaths
Where location like '%states%'
ORDER BY 1, 2;

--Looking at total cases vs population 
--What percentage of population contracted COVID

Select Location, date, total_cases,population, (total_cases/population)*100 as ContractionPercentage
From dbo.CovidDeaths
Where location like '%states%'
ORDER BY 1, 2

--What countries have the highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionRate, MAX(total_deaths/total_cases)*100 as ContractionPercentage
From dbo.CovidDeaths
--Where location like '%states%'
GROUP BY Location, Population
ORDER BY ContractionPercentage desc;

--Showing countries with highest death count by nation

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc;

--Let's break things down by continent (this is the correct code chunk to use; accurate TotalDeathCount)

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
--Where location like '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc;

-- Showing continents with the highest death count per population (Use this one for Tableau viz)

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

--Global numbers

Select date, SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
group by date
ORDER BY 1, 2;

--Removing date to get total cases 

Select SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
--group by date
ORDER BY 1, 2;

--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location,
dea.date) as RollingCountVaccinated
--,(RollingCountVaccinated/population)*100
from dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac(Continent, Location, Date, Population, New_vaccinations, RollingCountVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location,
dea.date) as RollingCountVaccinated
--,(RollingCountVaccinated/population)*100
from dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingCountVaccinated/Population)*100
from PopvsVac

--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingCountVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location,
dea.date) as RollingCountVaccinated
--,(RollingCountVaccinated/population)*100
from dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

--Creating view to store data for later viz

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location,
dea.date) as RollingCountVaccinated
--,(RollingCountVaccinated/population)*100
from dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--Work View for Tableau Public
Select *
From PercentPopulationVaccinated