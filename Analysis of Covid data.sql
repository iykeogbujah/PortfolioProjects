SELECT *
FROM CovidDeaths
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
order by 1,2;

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage

FROM CovidDeaths
WHERE continent is not null
order by 1,2;

SELECT location, date, total_cases, total_deaths, (total_cases/population)*100 as Percentage_infected

FROM CovidDeaths
WHERE location = 'Nigeria'
WHERE continent is not null
order by 1,2;


-- shows howmany people were infected as percentage of the population--
SELECT location,population, Max(total_cases) as Highest_Infection_Count, max((total_cases/population))*100 as Highest_Percentage_infected

FROM CovidDeaths
WHERE continent is not null
Group by location, population
order by 4 desc


-- shows fatality --

SELECT location,population, Max(total_deaths) as Total_Death_Count, max((total_deaths/population))*100 as Highest_Percentage_Death

FROM CovidDeaths
--WHERE location = 'Nigeria'
Group by location, population
order by 4 desc;

SELECT location, Max(cast(total_deaths as int)) as Total_Death_Count, max((total_deaths/population))*100 as Highest_Percentage_Death

FROM CovidDeaths
WHERE continent is not null
Group by location
order by 2 desc;

SELECT location, Max(cast(total_deaths as int)) as Total_Death_Count

FROM CovidDeaths
WHERE continent is null
Group by location
order by Total_Death_Count desc;

SELECT location, Max(total_deaths) as Total_Death_Count

FROM CovidDeaths
WHERE continent is null
Group by location
order by Total_Death_Count desc


-- Global Deaths--

SELECT SUM(new_cases) as Total_Infected_Count, SUM(cast(new_deaths as int)) as Total_Deaths_Count, 
			(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Highest_Percentage_Death

FROM CovidDeaths
WHERE continent is not null
--Group by location
order by 2 desc;



-- Global population vs Vaccinations--


SELECT dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations
FROM Portfolioprojects..CovidDeaths dea
Join Portfolioprojects..CovidVaccinations vacc
	on dea.location = vacc.location
	and dea.date = vacc.date

WHERE dea.continent is not null
order by 2,3


-- Global vaccination on a roling basis--

SELECT dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations, sum(convert(int,vacc.new_vaccinations)) 
		over (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinations_Count
FROM Portfolioprojects..CovidDeaths dea
Join Portfolioprojects..CovidVaccinations vacc
	on dea.location = vacc.location
	and dea.date = vacc.date

WHERE dea.continent is not null -- and dea.location = 'Albania'--
order by 2,3



--- USE CTE---

With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,Rolling_Vaccinations_Count)

as
(
SELECT dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations, sum(convert(int,vacc.new_vaccinations)) 
		over (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinations_Count
FROM Portfolioprojects..CovidDeaths dea
Join Portfolioprojects..CovidVaccinations vacc
	on dea.location = vacc.location
	and dea.date = vacc.date

WHERE dea.continent is not null -- and dea.location = 'Albania'--
--order by 2,3
)
SELECT *,(Rolling_Vaccinations_Count/population)*100 as Percentage_Vaccinated
FROM PopvsVac


-- USE Temp Table--

Drop table if exists #PercentageVaccinated
Create table #PercentageVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime ,
Population int,
New_Vaccinations int,
Rolling_Vaccinations_Count numeric)

insert into #PercentageVaccinated

SELECT dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations, sum(convert(int,vacc.new_vaccinations)) 
		over (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinations_Count
FROM Portfolioprojects..CovidDeaths dea
Join Portfolioprojects..CovidVaccinations vacc
	on dea.location = vacc.location
	and dea.date = vacc.date

WHERE dea.continent is not null -- and dea.location = 'Albania'--
--order by 2,3

SELECT *,(Rolling_Vaccinations_Count/population)*100 as Percentage_Vaccinated
FROM #PercentageVaccinated


-- Create views for later visualization --

--Drop view if exists PercentageVaccinated

Create view PercentageVaccinated as

SELECT dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations, sum(convert(int,vacc.new_vaccinations)) 
		over (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinations_Count
FROM Portfolioprojects..CovidDeaths dea
Join Portfolioprojects..CovidVaccinations vacc
	on dea.location = vacc.location
	and dea.date = vacc.date

WHERE dea.continent is not null -- and dea.location = 'Albania'--
--order by 2,3