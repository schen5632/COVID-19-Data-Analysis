Select *
From PortfolioProject..['CovidDeaths$']
Where continent is not null
Order by 3, 4

-- Select data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['CovidDeaths$']
Order by 1, 2

-- Looking at total cases vs total deaths
-- shows percentage of people with covid that passed away
Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
From PortfolioProject..['CovidDeaths$']
Where location like 'canada'
Order by 1, 2

-- Looking at total cases vs population
-- shows percentage of population that got covid
Select location, date, total_cases, population, (total_cases / population)*100 as PercentPopulatedInfected
From PortfolioProject..['CovidDeaths$']
Where location like 'canada'
Order by 1, 2

-- Looking at countries with highest infection rate compared to population
Select location, population, max(total_cases) as HighestInfectionCount, 
Max(total_cases / population)*100 as PercentPopulatedInfected
From PortfolioProject..['CovidDeaths$']
Group by location, population
Order by 1, 2

-- Showing countries with highest death count per population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths$']
Group by location
Order by TotalDeathCount desc

-- Organizing data into continents
-- Showing continents with highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths$']
Where continent is not null 
Group by continent
Order by TotalDeathCount desc

-- Global Numbers
Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/
Sum(new_cases)*100 as DeathPercentage 
From PortfolioProject..['CovidDeaths$']
Where continent is not null
Group by date
Order by 1, 2

-- Looking at total population vs. vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
As RollingPeopleVaccinated
From PortfolioProject..['CovidDeaths$'] dea 
Join PortfolioProject..['CovidVaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3;

-- Use CTE 
With PopvsVac(continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
As RollingPeopleVaccinated
From PortfolioProject..['CovidDeaths$'] dea 
Join PortfolioProject..['CovidVaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac 

-- Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
As RollingPeopleVaccinated
From PortfolioProject..['CovidDeaths$'] dea 
Join PortfolioProject..['CovidVaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Queries for Tableau
-- 1. 
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage
From PortfolioProject..['CovidDeaths$']
Where continent is not null 
Order by 1,2

--2.
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths$']
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc 

--3. 
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['CovidDeaths$']
Group by Location, Population
order by PercentPopulationInfected desc

--4.
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['CovidDeaths$']
Group by Location, Population, date
order by PercentPopulationInfected desc