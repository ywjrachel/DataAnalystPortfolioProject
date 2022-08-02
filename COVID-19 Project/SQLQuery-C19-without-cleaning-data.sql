----Open C19Death Table (filter continent & income group shows in location column) 
SELECT *
FROM C19Project.dbo.C19Death
WHERE continent is not null
Order by 3,4


----Open C19Vax Table (filter continent & income group shows in location column) 
SELECT *
FROM C19Project.dbo.C19Vax
WHERE continent is not null
Order by 3,4


----Total active row location to be counted 
SELECT COUNT (location) AS total_actual_row_location
FROM C19Project.dbo.C19Vax
WHERE continent is not null


----Total countries
SELECT COUNT (DISTINCT location) AS Total_Countries
FROM C19Project.dbo.C19Death
WHERE continent is not null


----Showing Actual Continent Only
SELECT DISTINCT(continent)
FROM C19Project.dbo.C19Death
WHERE continent is not null
Order By continent


----Checking sum of total_deaths for Oceania
SELECT SUM(cast(total_deaths as INT)) AS Total_Deaths_for_Oceania_Continent
FROM C19Project.dbo.C19Death
WHERE continent = 'Oceania'


SELECT date, location, population, total_cases, new_cases, total_deaths
FROM C19Project.dbo.C19Death
WHERE continent is not null
Order by location


----Total Cases vs Total Deaths
SELECT date, location, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM C19Project.dbo.C19Death
--WHERE location LIKE '%Malaysia%'
WHERE continent is not null
Order by location


----Total Cases vs Population
SELECT date, location, population, total_cases, (total_cases/population)*100 AS Population_Infected_Percentage
FROM C19Project.dbo.C19Death
--WHERE location LIKE '%Malaysia%'
WHERE continent is not null
Order by 2


----Looking at countries with Highest infection rate compares to population
SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX(total_cases/population)*100 AS Population_Infected_Percentage
FROM C19Project.dbo.C19Death
--WHERE location LIKE '%Malaysia%'
WHERE continent is not null
Group by location, population
Order by Population_Infected_Percentage DESC


----Showing countries with highest death count per population 
SELECT location, SUM(cast(total_deaths as int)) AS Total_Death_Count
FROM C19Project.dbo.C19Death
WHERE continent is not null
Group By location
Order by Total_Death_Count DESC


----Showing continents with the highest death count per population
SELECT continent, SUM(cast(total_deaths as INT)) AS Total_Death_Count
FROM C19Project.dbo.C19Death
--WHERE location like %Malaysia%
WHERE continent is not null
Group By continent
Order by Total_Death_Count DESC


---- Global Numbers till 31 July 2022
SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as INT)) AS Total_Deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as Death_Percentage
FROM C19Project.dbo.C19Death
--WHERE location LIKE '%Malaysia%'
WHERE continent is not null
--Group by date
Order by 1,2


-- Total Population vs Vaccinations (shows percentage of population has received minimum 1 COVID-19 Vaccine)
SELECT dea.date, dea.continent, dea.location, dea.population, vax.new_vaccinations
, SUM(CONVERT(BIGINT, vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaxxed
--, (Rolling_People_Vaxxed/population)*100
FROM C19Project.dbo.C19Death AS dea
JOIN C19Project.dbo.C19Vax AS vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent is not null
Order by 3


-- Using CTE to calculate on Partition By in Total Population vs Vaccinations
WITH People_Vs_Vax (continent, location, date, population, new_vaccinations, Rolling_People_Vaxxed)
as 
(
SELECT dea.date, dea.continent, dea.location, dea.population, vax.new_vaccinations
, SUM(CONVERT(BIGINT, vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaxxed
--, (Rolling_People_Vaxxed/population)*100
FROM C19Project.dbo.C19Death AS dea
JOIN C19Project.dbo.C19Vax AS vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent is not null
-- Order by 3
)
SELECT *, (Rolling_People_Vaxxed/population)*100 AS Percentage_People_Vaxxed_Population
FROM People_Vs_Vax


-- Using Temp Table to calculate on Partition By in Total Population vs Vaccinations
DROP TABLE if exists #PercentagePopulationVaxxed
CREATE TABLE #PercentagePopulationVaxxed
(
Date datetime,
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
New_vaccination numeric,
Rolling_People_Vaxxed numeric
)

INSERT into #PercentagePopulationVaxxed
SELECT dea.date, dea.continent, dea.location, dea.population, vax.new_vaccinations
, SUM(CONVERT(BIGINT, vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaxxed
--, (Rolling_People_Vaxxed/population)*100
FROM C19Project.dbo.C19Death AS dea
JOIN C19Project.dbo.C19Vax AS vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent is not null
-- Order by 3

SELECT *, (Rolling_People_Vaxxed/population)*100 AS Percentage_People_Vaxxed_Population
FROM #PercentagePopulationVaxxed


-- Create view for visualisation 
CREATE VIEW PercentagePopulationVaxxed AS
SELECT dea.date, dea.continent, dea.location, dea.population, vax.new_vaccinations
, SUM(CONVERT(BIGINT, vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaxxed
--, (Rolling_People_Vaxxed/population)*100
FROM C19Project.dbo.C19Death AS dea
JOIN C19Project.dbo.C19Vax AS vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent is not null

SELECT *
FROM PercentagePopulationVaxxed