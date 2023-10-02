Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract Covid in your country 

Select location, date, total_cases, total_deaths, (Total_Deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population contracted Covid

Select location, date, total_cases, Population, (Total_Deaths/Population)*100 as PercentofPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Countries with highest infection rate compared to the population

Select Location, Population, max(total_cases) as HighestInfectionCount, max((Total_Deaths/Population))*100 as PercentofPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by Location, population
order by PercentofPopulationInfected desc

--Showing Countries with the highest death count per population

Select Location, max(cast(Total_Deaths as bigint)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Broken down by Continent

Select Continent, max(cast(Total_Deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Continent
Order by TotalDeathCount desc

-- Showing the Continents with the highest death counts

Select Continent, max(cast(Total_Deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Continent
Order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where Continent is not null
--Group by Date
Order by 1,2 


--Loking at Total Population vs Vaccinations

Select Dea.Continent, dea.Location, Dea.Date, Dea.Population, Vac.new_Vaccinations
, SUM(Convert(int,Vac.new_Vaccinations)) Over (Partition by dea.Location Order by Dea.Location, Dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.Location = Vac.Location
	And Dea.Date = Vac.Date
Where Dea.Continent is not null
Order by 2,3


--Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.new_Vaccinations
, SUM(Convert(int,Vac.new_Vaccinations)) Over (Partition by dea.Location Order by Dea.Location, Dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.Location = Vac.Location
	And Dea.Date = Vac.Date
Where Dea.Continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Using a Temp Table

Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.new_Vaccinations
, SUM(Convert(int,Vac.new_Vaccinations)) Over (Partition by dea.Location Order by Dea.Location, Dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.Location = Vac.Location
	And Dea.Date = Vac.Date
Where Dea.Continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.new_Vaccinations
, SUM(Convert(int,Vac.new_Vaccinations)) Over (Partition by dea.Location Order by Dea.Location, Dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.Location = Vac.Location
	And Dea.Date = Vac.Date
Where Dea.Continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated