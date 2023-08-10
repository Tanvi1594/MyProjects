select * from coviddeaths
order by 3,4

Select location, date, total_Cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2

--Looking at total cases vs total deaths

Select location, date, total_Cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
Where location ='Africa'
order by 1,2

--Looking at total cases vs the population
--shows what percentage of population got covid

Select location, date, Population, total_Cases, (total_cases/population)*100 CasesPercentage
from coviddeaths
--Where location ='Africa'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, Population, Max(total_Cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from coviddeaths
Group by location, population
Order by PercentPopulationInfected desc

-- Countries with the highest death count population

Select location, Max(Total_deaths) as TotalDeathCount
from coviddeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

---Let's break things down using continent
--showing continents with highest death counts per population

Select Continent, Max(Total_deaths) as TotalDeathCount
from coviddeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers
[dbo].[CovidVaccinations$]
Select date, SUM(new_Cases), SUM(new_deaths), SUM(new_Deaths)/SUM(new_cases)*100 as PercentPopulationInfected
from coviddeaths
Where continent is not null
Group by date
Order by 1,2

--Looking at total Population vs Vaccinations

Alter table covidvaccinations
Alter column new_vaccinations int

Select dea.continent, dea.location ,dea.date, dea.population,  vac.new_vaccinations
,Sum(vac.new_vaccinations)over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*!00
from coviddeaths dea
Join covidvaccinations vac
on dea.location = vac.location
and dea.date= vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac(continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)as

(Select dea.continent, dea.location ,dea.date, dea.population,  vac.new_vaccinations
,Sum(vac.new_vaccinations)over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*!00
from coviddeaths dea
Join covidvaccinations vac
on dea.location = vac.location
and dea.date= vac.date
Where dea.continent is not null
)

Select *, (rollingpeopleVaccinated/Population)*100
from PopvsVac

--Temp Table
Drop table if exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
Continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric)
Insert into #PercentPeopleVaccinated
Select dea.continent, dea.location ,dea.date, dea.population,  vac.new_vaccinations
,Sum(vac.new_vaccinations)over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*!00
from coviddeaths dea
Join covidvaccinations vac
on dea.location = vac.location
and dea.date= vac.date
Where dea.continent is not null

Select *, (rollingpeopleVaccinated/Population)*100
from #PercentPeopleVaccinated

--creating view to store data for later visualization
Create View PercentPeopleVaccinated as
Select dea.continent, dea.location ,dea.date, dea.population,  vac.new_vaccinations
,Sum(vac.new_vaccinations)over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*!00
from coviddeaths dea
Join covidvaccinations vac
on dea.location = vac.location
and dea.date= vac.date
Where dea.continent is not null

Select * from PercentPeopleVaccinated



