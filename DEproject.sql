select *
from DEPROJECT ..CovidDeaths 
where continent is not null
order by 3,4

--select *
--from DEPROJECT ..CovidVaccination 
--order by 3,4

--select what we using 

select location,date,new_cases, total_cases,total_deaths,population
from DEPROJECT ..CovidDeaths 
order by 1,2

--looking at total cases vs total death
select location,date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from DEPROJECT ..CovidDeaths
where continent  is not null 
--where location like '%South Africa%'
order by 1,2

--looking at total cases vs population, shows population percantage of covid cases 

select location,date, total_cases, new_cases,total_deaths,
	(total_deaths/total_cases)*100 as InfectionPercentage
from DEPROJECT ..CovidDeaths 
where location like '%South Africa%'
order by 1,2

--looking at countries with highest infection rate compared to population 

select location,population, max(total_cases) as Highestinfectioncount, 
	max(total_deaths/total_cases)*100 as Percentagepopulationinfection 
from DEPROJECT ..CovidDeaths 
--where location like '%South Africa%'
where continent is not null
group by location, population 
order by Percentagepopulationinfection desc

--looking at countries with highest Death count per population 

select location, max (cast( total_deaths as int )) as Deathcountpercentage 
from DEPROJECT ..CovidDeaths 
--where location like '%South Africa%'
where continent   is not null
group by location, population 
order by Deathcountpercentage desc

--BREAKDOWN RESULTS BY CONTINENT 

--continents with the highest death count per population 



--GLOBAL NUMBERS
 
 select date, sum(new_cases) as TotalCases,sum(cast (new_deaths as int))as TotalDeaths,
	sum (cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
 from DEPROJECT ..CovidDeaths 
 where continent is not null
 group by date  
 order by 1 ,2

 select continent, sum(new_cases) as TotalCases,
 sum(cast (new_deaths as int))as TotalDeaths, sum (cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
 from DEPROJECT ..CovidDeaths 
 where continent is not null
 group by continent 
 --group by date  
 order by 1 ,2


--using the covidVaccination table
select *
from DEPROJECT ..CovidDeaths
order by 3,4

select *
from DEPROJECT ..CovidVaccination 
order by 3,4

--joining the two tables 
select * 
from  DEPROJECT ..CovidDeaths dea
	join  DEPROJECT ..CovidVaccination vac
		on dea.location = vac.location 
	and dea.date = vac.date


--Looking at Total Population vs Vaccinations 
select  dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
from  DEPROJECT ..CovidDeaths dea
	join  DEPROJECT ..CovidVaccination vac
		on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--where vac.location like '%South Africa%' 
order by 2,3


select  dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.Location 
		Order by dea.location,dea.date) as RollingPeopleVaccinated 
from  DEPROJECT ..CovidDeaths dea
join  DEPROJECT ..CovidVaccination vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--where vac.location like '%South Africa%' 
order by 2,3



select  dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.Location 
	Order by dea.location,dea.date) as RollingPeopleVaccinated 
from  DEPROJECT ..CovidDeaths dea
	join  DEPROJECT ..CovidVaccination vac
		on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--or
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.Location 
		Order by dea.location,dea.date) as RollingPeopleVaccinated 
From DEPROJECT..CovidDeaths dea 
	Join DEPROJECT..CovidVaccination vac 
		On dea. location = vac. location and dea.date = vac.date
where dea.continent is not null
	and vac.location like '%South Africa%'
order by 2, 3


--USE CTE
with PopvsVac (continent, location,date,population,new_vaccination, RollingPeopleVaccinated )
as
	(
		Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations, 
			SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location 
			Order by dea.location,dea.date) as RollingPeopleVaccinated 
		From DEPROJECT..CovidDeaths dea 
			Join DEPROJECT..CovidVaccination vac 
			On dea. location = vac. location 
			and dea.date = vac.date
		where dea.continent is not null
			and vac.location like '%South Africa%'
		--order by 2, 3
	)
select *, (RollingPeopleVaccinated /population) *100
from PopvsVac



--TEMP TABLE 
drop table if exists #percetantagepopulationvaccinated 
create table  #percetantagepopulationvaccinated
(
	continent nvarchar(255),
	location nvarchar (255),
	date datetime,
	population numeric,
	new_vaccination numeric,
	RollingPeopleVaccinated numeric
)
insert into #percetantagepopulationvaccinated
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.Location 
		Order by dea.location,dea.date) as RollingPeopleVaccinated 
From DEPROJECT..CovidDeaths dea 
	Join DEPROJECT..CovidVaccination vac 
		On dea. location = vac. location 
		and dea.date = vac.date
where dea.continent is not null
	and vac.location like '%South Africa%'
--order by 2, 3

select *, (RollingPeopleVaccinated /population) *100
from  #percetantagepopulationvaccinated



--creating views for later visualization 

create view populationvaccinated as
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.Location 
		Order by dea.location,dea.date) as RollingPeopleVaccinated 
From DEPROJECT..CovidDeaths dea 
	Join DEPROJECT..CovidVaccination vac 
		On dea. location = vac. location 
		and dea.date = vac.date
where dea.continent is not null
	and vac.location like '%South Africa%'
--order by 2, 3



select * 
from populationvaccinated

drop view popvsvac; 
create view popvsvac as
select continent, max(cast( total_deaths as int )) as Deathcountpercentage 
from DEPROJECT ..CovidDeaths 
--where location like '%South Africa%'
where continent is not null
group by continent 
--order by Deathcountpercentage desc
