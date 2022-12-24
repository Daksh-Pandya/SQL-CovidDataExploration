
select *
from Portfolio_Project.dbo.covid_deaths
where continent is not null
order by 3,4

--select *
--from Portfolio_Project.dbo.covid_vaccinations
--order by 3,4

--select data that we are going to use.
select location,date, total_cases, new_cases, total_deaths, population  
from Portfolio_Project.dbo.covid_deaths
where continent is not null
order by 1,2

-- Looking at the total cases vs total deaths- Death_percentage
select location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Deaths_Pecentage  
from Portfolio_Project.dbo.covid_deaths
where location='Canada' and continent is not null
order by 1,2  

-- Total cases against the population- shows percentage of population got covid 
select location,date,population ,total_cases, (total_cases/population)*100 as percent_population_infected
from Portfolio_Project.dbo.covid_deaths
--where location='Canada'
where continent is not null
order by 1,2

-- countries with highest infection rate compared to population
select location,population ,max(total_cases) as Highest_Infected_Count, max((total_cases/population))*100 as max_percent_population_infected
from Portfolio_Project.dbo.covid_deaths
--where location='Canada'
where continent is not null
group by location,population
order by max_percent_population_infected desc

--Countries with highest death count 
select location,max(cast(total_deaths as int)) as Total_Deaths_Count 
from Portfolio_Project.dbo.covid_deaths
--where location='Canada'
where continent is not null
group by location
order by Total_Deaths_Count desc

--Cotinents with highest death count
select location,max(cast(total_deaths as int)) as Total_Deaths_Count 
from Portfolio_Project.dbo.covid_deaths
--where location='Canada'
where continent is  null
group by location
order by Total_Deaths_Count desc

--global numbers
select  sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths, 
sum(cast(new_deaths as int))/SUM(new_cases)*100 as new_death_percentage
from Portfolio_Project.dbo.covid_deaths
where continent is not null
--group by date
order by 1,2  


--Join covid deaths and covid vaccination data
select * 
from Portfolio_Project.dbo.covid_deaths dea
join Portfolio_Project.dbo.covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	
-- Total population vs vaccination
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,
dea.Date) as total_vaccinated_people
from Portfolio_Project.dbo.covid_deaths dea
join Portfolio_Project.dbo.covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE(Common Table Expression) to count percentage of total_vaccinated_people
with popvsvac (continents, location, date, population, new_vaccination, total_vaccinated_people)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,
dea.Date) as total_vaccinated_people
from Portfolio_Project.dbo.covid_deaths dea
join Portfolio_Project.dbo.covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (total_vaccinated_people/population)*100 as percent_vaccinated_people
from popvsvac

-- TEMP table
create table #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinated_people numeric
)
insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,
dea.Date) as total_people_vaccinated
from Portfolio_Project.dbo.covid_deaths dea
join Portfolio_Project.dbo.covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (total_vaccinated_people/population)*100 as percent_vaccinated_people
from #PercentPeopleVaccinated

-- create view to store data for later visualization 
create View PercentagePopulationVaccinated as 
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,
dea.Date) as total_vaccinated_people
from Portfolio_Project.dbo.covid_deaths dea
join Portfolio_Project.dbo.covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentagePopulationVaccinated