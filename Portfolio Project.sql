select *
from PortfoiloProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfoiloProject..PortfoiloProject
--order by 3,4

-- select Data that we are going to be using 

select location , date , total_cases,new_cases,total_deaths,population
from PortfoiloProject..CovidDeaths
where continent is not null
order by 1,2

-- looking at total cases vs total Deaths
-- shows likelihood of dying if you contract covid in your country
select location , date , total_cases,total_deaths,(cast(total_deaths as int )/total_cases)*100 as DeathPercentage
from PortfoiloProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--looking at total cases vs population
--shows whatpercentage of population got covid

select location , date , total_cases,population,(total_cases/population)*100 as percentpopulationInfected
from PortfoiloProject..CovidDeaths
where location like '%states%'
order by 1,2

-- looking at countries with highest infection rate compared to population

select location,population,max(total_cases) as HighestInfectionCount,max(total_cases/population)*100 as 
percentpopulationInfected
from PortfoiloProject..CovidDeaths
--where location like '%states%'
group by location,population
order by percentpopulationInfected desc

-- showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfoiloProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINET

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfoiloProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- showing continents with the highest death count per population 

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfoiloProject..CovidDeaths 
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- global numbers

select  sum(new_cases)as total_cases,sum(cast(new_deaths as int ))as total_deaths,sum(cast(new_deaths as int))/SUM
(new_cases)*100 as DeathPercentage
from PortfoiloProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vaccination 

select dea.continent , dea.location ,dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.Location order by dea.location,
dea.Date) as RollingPeoplevaccinated
from PortfoiloProject..CovidDeaths dea
join PortfoiloProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccinations,RollingPeoplevaccinated)
as
(
select dea.continent , dea.location ,dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.Location order by dea.location,
dea.Date) as RollingPeoplevaccinated
from PortfoiloProject..CovidDeaths dea
join PortfoiloProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeoplevaccinated/Population)*100
from PopvsVac

-- TEMP TABLE

DROP Table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeoplevaccinated numeric
)

insert into #percentPopulationVaccinated
select dea.continent , dea.location ,dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.Location order by dea.location,
dea.Date) as RollingPeoplevaccinated
from PortfoiloProject..CovidDeaths dea
join PortfoiloProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select*,(RollingPeoplevaccinated/Population)*100
from #percentPopulationVaccinated


--Creating View to store for later visualizations

Create view percentPopulationVaccinated as
select dea.continent , dea.location ,dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.Location order by dea.location,
dea.Date) as RollingPeoplevaccinated
from PortfoiloProject..CovidDeaths dea
join PortfoiloProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentPopulationVaccinated