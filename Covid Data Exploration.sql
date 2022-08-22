

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


--data source:https://ourworldindata.org/


--Get a glimpse of the data in our databases;CovidDeaths & CovidVaccinations
Select *
From [Portfolio Project]..CovidDeaths$
Where continent is not null 
order by 3,4

Select *
From [Portfolio Project]..CovidVaccinations$
Where continent is not null 
order by 3,4

--To start with, we perform data exploration on the CovidDeaths database
Select location,date,new_cases,total_cases,total_deaths,population
From [Portfolio Project]..CovidDeaths$
Where continent is not null 
order by 1,2

--Total cases Vs Total deaths

--Show the likelihood of dying if you contact Covid in your country during covid
Select location,date,total_deaths,(total_deaths/total_cases)*100 as PercentageDeaths
From [Portfolio Project]..CovidDeaths$
Where location like '%Kenya%'
and continent is not null
order by PercentageDeaths desc


--Total Cases Vs Total Deaths
-- Shows what percentage of population infected with Covid
Select location, date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths$
order by 1,2


-- Country with the highest to lowest infection rate compared to Population 

Select Location,population,Max(total_cases) as Infected_Cases, Max((total_cases/population))*100 as PercentageOfPopInfected
From [Portfolio Project]..CovidDeaths$
--Where location like '%Kenya%'
Group by location,population
order by PercentageOfPopInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeaths
From [Portfolio Project]..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeaths desc
             

-- BREAKING THINGS DOWN BY CONTINENT

-- show continent with highest number of deaths
Select continent,Max(cast(total_deaths as int)) as TotalDeaths
From [Portfolio Project]..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeaths desc


--Global numbers 

--Daily Global figures of new_cases,new_deaths and % deaths from Covid 19
Select date,SUM(new_cases) as NewDailyInfections, SUM(cast(new_deaths as int)) as DailyDeaths, 
             SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentageDailyDeaths
From [Portfolio Project]..CovidDeaths$
Where continent is not null
Group by date
Order by 1,2

--Join CovidDeaths database with CovidVaccinationsdatabaese
Select *
From [Portfolio Project]..CovidDeaths$ AS d
Join [Portfolio Project]..CovidVaccinations$ AS v
      ON d.date=v.date
	  and d.location=v.location

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select d.date,d.continent,d.location,d.population,v.new_vaccinations,
	   SUM(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.date,d.location)
	   as RollingPopVaccinated
From [Portfolio Project]..CovidDeaths$ AS d
Join [Portfolio Project]..CovidVaccinations$ AS v
      ON d.date=v.date
	  and d.location=v.location
Where d.continent is not null

--USE CTE (method 1)

--to show the propotion of population vaccinated ("RollingPercntgeOfPopVaccination")

With PropotionOfPop(Date,Continent,Location,Population,New_Vaccination,RollingPopVaccinated)
as
(Select d.date,d.continent,d.location,d.population,v.new_vaccinations,
	   SUM(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.date,d.location)
	   as RollingPopVaccinated
From [Portfolio Project]..CovidDeaths$ AS d
Join [Portfolio Project]..CovidVaccinations$ AS v
      ON d.date=v.date
	  and d.location=v.location
Where d.continent is not null
)
Select*,(RollingPopVaccinated/Population)*100 as RollingPercntgeOfPopVaccination
From PropotionOfPop

--Using Temp table (method 2)

-- to calculate the propotion of population vaccinated ("RollingPercntgeOfPopVaccination")

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Date datetime,
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
New_vaccinations numeric,
RollingPopVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.date,d.continent,d.location,d.population,v.new_vaccinations,
	   SUM(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.date,d.location)
	   as RollingPopVaccinated
From [Portfolio Project]..CovidDeaths$ AS d
Join [Portfolio Project]..CovidVaccinations$ AS v
      ON d.date=v.date
	  and d.location=v.location
Where d.continent is not null

Select *,(RollingPopVaccinated/Population)*100 as RollingPercntgeOfPopVaccination
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create View PercentPopVaccinated as
Select d.date,d.continent,d.location,d.population,v.new_vaccinations,
	   SUM(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.date,d.location)
	   as RollingPopVaccinated
From [Portfolio Project]..CovidDeaths$ AS d
Join [Portfolio Project]..CovidVaccinations$ AS v
      ON d.date=v.date
	  and d.location=v.location
Where d.continent is not null

Select *
From PercentPopVaccinated
 

*********************************************************************************************************************************************** 
			 
--DATA EXPLORATION FINDINGS;

--Kenya's likelihood was highest in the months of May 2020 at about 5.4% but dropped to 2.1% after vaccination begun in march 2021.
 

--As of June 2022, the country with highest infected rate of population was;
         1. Faeroe Islands = 65.53%, 
         2. Cyprus = 64.07%, 
         3. Gibraltar = 61.36%
       --Kenya's rate of infection was 0.64%

---- Top 10 Countries with Highest Death Count per Population(as of June 2022)
 --                   Location        TotalsDeaths
                   1  United States	    1041141
                   2  Brazil	        682358
                   3  India          	527332
                   4  Russia	        375725
                   5  Mexico	        328871
                   6  Peru	            215209
                   7  U. Kingdom	    187215
                   8  Italy	            174659
                   9  Indonesia	        157365
                  10  France	        153570

-- No of Deaths by Continent
--                      Continent             TotalDeaths
                      1  North America	         1041141
                      2  South America	         682358
                      3  Asia	                 527332
                      4  Europe	                 375725
                      5  Africa	                 102066
                      6  Oceania	             13360

--Global numbers for Covid 19 as of 1st June 2022;
                       New Daily Infections = 524125
					   Daily Deaths = 1587	
					   Perctge Daily DEATHS = 0.30%

--Overall Global figures since the begining of Covid 19 pandemic;
                       Total Cases = 594588955
					   Total Deaths = 6410461
					   Perctge Total deaths = 1.078%