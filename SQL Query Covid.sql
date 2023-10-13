Select * 
From CovidPortfolioProject..CovidDeaths
Where continent is not null 
Order by 3,4


--Select * 
--From CovidPortfolioProject..CovidVaccinations
--Order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From CovidPortfolioProject..CovidDeaths
Where continent is not null 
Order by 1,2


--Shows likelihood of dying if you contact covid in the United States

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
Where location like '%states%' 
and continent is not null 
Order by 1,2


--Total Cases vs. Population
Select location, date, population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
From CovidPortfolioProject..CovidDeaths
Where location like '%states%' 
Order by 1,2


--Countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
From CovidPortfolioProject..CovidDeaths
--Where location like '%states%' 
Group by  location, population
Order by PercentofPopulationInfected desc


--Breaking things down by continent

--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
--Where location like '%states%' 
Where continent is not null 
Group by  continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
--Where location like '%states%' 
Where continent is not null 
Group by date
Order by 1,2


--Global total deaths and cases

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
--Where location like '%states%' 
Where continent is not null 
--Group by date
Order by 1,2



--Total Population vs Vaccinations

--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population) * 100
From PopvsVac




--Temp Table

IF OBJECT_ID(N'tempdb..#PercentPopulationVaccinated') IS NOT NULL
BEGIN
DROP TABLE #PercentPopulationVaccinated
END
GO

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population) * 100
From #PercentPopulationVaccinated




--Creating view to store data later for visualization 

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3