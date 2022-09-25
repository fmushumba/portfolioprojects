Select *
From portfolio_project1..Covid_deaths
order by 3,4

--Select *
--From portfolio_project1..Covid_vaccination
--order by 3,4

--select Data that we are going to be using 
 
 Select location, date, total_cases, new_cases, total_deaths, population
 From portfolio_project1..Covid_deaths
 order by 1,2

 --Looking at Total cases vs population 
 --Shows what percentage of population got covid
 Select location, date, population, total_cases, (total_cases/population)*10 as covidPercentage
 From portfolio_project1..Covid_deaths
 --where location like '%states%'
 order by 1,2


 --Looking at countries with highest infection rate compared to population
 Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as percentPopulationInfected
 From portfolio_project1..Covid_deaths
 Group by Location, population
 order by percentPopulationInfected desc

 --This is showing countries with the highest death count per population

 Select location, MAX(cast(total_deaths as int)) as TotalDeathCounts
  From portfolio_project1..Covid_deaths
  where continent is not NULL
 Group by Location
 order by TotalDeathCounts desc


 --let's use CONTINENTS

 Select continent, MAX(cast(total_deaths as int)) as TotalDeathCounts
 From portfolio_project1..Covid_deaths
 where continent is not NULL
 Group by continent
 order by TotalDeathCounts desc

 --GLOBAL NUMBERS
  Select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) *100 as DeathPercentage 
 From portfolio_project1..Covid_deaths
 --where location like '%states%'
 where continent is not NULL
 Group by date 
 order by 1,2

--looking at Total population vs vaccinations

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as float))  OVER (PARTITION by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
From portfolio_project1..Covid_deaths dea
join portfolio_project1..Covid_vaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
 order by 2,3



 --Use CTE

 with PopvsVac(continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
 as
 (
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as float))  OVER (PARTITION by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
From portfolio_project1..Covid_deaths dea
join portfolio_project1..Covid_vaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
 )
 select * ,(RollingPeopleVaccinated/population *100)
 FROM PopvsVac


 --TEMP TABLE
 DROP table if exists #PercentPopulationVaccinated
 create Table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 
 insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as float))  OVER (PARTITION by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
From portfolio_project1..Covid_deaths dea
join portfolio_project1..Covid_vaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/population *100)
 FROM #PercentPopulationVaccinated


 --creating view to store data for visualization
Create view PercentPopulationVaccinated as
 Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as float))  OVER (PARTITION by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
From portfolio_project1..Covid_deaths dea
join portfolio_project1..Covid_vaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3