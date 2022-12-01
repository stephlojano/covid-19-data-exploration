-- Select data that we are going to be using
--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..covid_deaths
--ORDER BY 1,2


-- Looking at total cases vs total deaths (in US), aka the amount of people that died in each case

--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
--FROM PortfolioProject..covid_deaths
--WHERE location like '%states%'
--ORDER BY 1,2


-- Looking at total cases vs total population (in US)
-- This shows what percentage of the population got COVID 

--SELECT location, date, total_cases, population, (total_cases/population)*100 AS population_infected
--FROM PortfolioProject..covid_deaths
--WHERE location like '%states%'
--ORDER BY 1,2



-- Looking at countries with the highest infection rate compared to poulation

--SELECT location,population, MAX(total_cases) AS highest_infected_count, MAX((total_cases/population))*100 AS population_infected
--FROM PortfolioProject..covid_deaths
--GROUP BY location, population
--ORDER BY population_infected DESC





-- Looking at countries with the highest infection rate compared to poulation PER DAY	

SELECT location, population, date, MAX(total_cases) AS highest_infected_count, MAX((total_cases/population))*100 AS population_infected
FROM PortfolioProject..covid_deaths
GROUP BY location, population, date
ORDER BY population_infected DESC







-- Showing countries with highest death count 

--SELECT location, MAX(CAST(total_deaths AS BIGINT)) AS highest_death_count
--FROM PortfolioProject..covid_deaths
--WHERE continent IS NOT NULL
--GROUP BY location
--ORDER BY highest_death_count DESC




-- Showing continents, income class, internation, and world with highest death count by continent 

--SELECT location, MAX(CAST(total_deaths AS BIGINT)) AS highest_death_count
--FROM PortfolioProject..covid_deaths
--WHERE continent IS NULL -- we were deleting the NULL values in before queries
--GROUP BY location
--ORDER BY highest_death_count DESC





-- Showing continents with highest death count (excluding those with 'NULL' as continent)

--SELECT continent, MAX(CAST(total_deaths AS BIGINT)) AS highest_death_count
--FROM PortfolioProject..covid_deaths
--WHERE continent IS NOT NULL
--GROUP BY continent
--ORDER BY highest_death_count DESC




-- total death count in each country
-- to do that we cant have words "world, european union, international" in location bc world, international are total sums (not a country)
-- and european union is part of europe

--SELECT location, SUM(CAST(new_deaths AS BIGINT)) AS total_death_count
--FROM PortfolioProject..covid_deaths
--WHERE continent IS NULL
--AND location NOT IN ('World','European Union','International')
--GROUP BY location
--ORDER BY total_death_count DESC








--SELECT continent, MAX(CAST(total_deaths AS BIGINT)) AS highest_death_count
--FROM PortfolioProject..covid_deaths
--WHERE continent IS NOT NULL
--GROUP BY continent
--ORDER BY highest_death_count DESC






-- global numbers per day (all locations and continents except where it is NULL)

--SELECT 
--	date, 
--	SUM(new_cases) as total_cases, 
--	SUM(CAST(new_deaths AS BIGINT)) AS total_deaths,
--	SUM(CAST(new_deaths AS BIGINT))/SUM(new_cases)*100 AS death_percentages
--FROM PortfolioProject..covid_deaths
--WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1,2






-- global numbers (total cases, total deaths, death percentage of all rows (where not null))

--SELECT 
--	SUM(new_cases) AS total_cases, 
--	SUM(CAST(new_deaths AS BIGINT)) AS total_deaths,
--	SUM(CAST(new_deaths AS BIGINT))/SUM(new_cases)*100 AS death_percentages
--FROM PortfolioProject..covid_deaths
--WHERE continent IS NOT NULL






-- Looking at total population vs vaccinations 

--SELECT 
--	dea.continent, 
--	dea.location, 
--	dea.date, dea.population, 
--	vac.new_vaccinations,
--	SUM(CONVERT(BIGINT, new_vaccinations)) OVER (PARTITION BY dea.location) AS vac_count_total, -- total count
--	SUM(CONVERT(BIGINT, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vac_count_rolling -- rolling count
--FROM PortfolioProject..covid_deaths dea 
--JOIN PortfolioProject..vaccinations  vac
--ON dea.location = vac.location
--AND dea.date = vac.date
--WHERE dea.continent IS NOT NULl
--ORDER BY 2,3


-- using CTE (common table expression)

--WITH popVsVac AS
--	(
--	SELECT 
--		dea.continent, 
--		dea.location, 
--		dea.date, 
--		dea.population, 
--		vac.new_vaccinations,
--		SUM(CONVERT(BIGINT, new_vaccinations)) OVER (PARTITION BY dea.location) AS vac_count_total, -- total count
--		SUM(CONVERT(BIGINT, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vac_count_rolling -- rolling count
--	FROM PortfolioProject..covid_deaths dea 
--	JOIN PortfolioProject..vaccinations  vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--	WHERE dea.continent IS NOT NULl
--	--  ORDER BY 2,3
--	)

--SELECT *, (vac_count_rolling/population)*100 AS population_vaccinated
--FROM popVsVac
--ORDER BY 2,3



---- using temp table

--DROP Table if exists #PercentPopulationVaccinated
--CREATE Table #PercentPopulationVaccinated
--(
--continent nvarchar(255),
--location nvarchar(255),
--date nvarchar(255),
--population numeric,
--new_vaccinations numeric, 
--vac_count_total numeric,
--vac_count_rolling numeric
--)

--INSERT into #PercentPopulationVaccinated

--SELECT 
--		dea.continent, 
--		dea.location, 
--		dea.date, 
--		dea.population, 
--		CAST(new_vaccinations AS BIGINT),
--		SUM(CONVERT(BIGINT, new_vaccinations)) OVER (PARTITION BY dea.location) AS vac_count_total, -- total count
--		SUM(CONVERT(BIGINT, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vac_count_rolling -- rolling count
--	FROM PortfolioProject..covid_deaths dea 
--	JOIN PortfolioProject..vaccinations vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--	-- WHERE dea.continent IS NOT NULL
--	--  ORDER BY 2,3

--SELECT *, (vac_count_rolling/population)*100 AS population_vaccinated
--FROM #PercentPopulationVaccinated


---- Creating view to store data for later visualizations

--CREATE VIEW PercentPopulationVaccinated AS
--SELECT
--		dea.continent, 
--		dea.location, 
--		dea.date, 
--		dea.population, 
--		CAST(new_vaccinations AS BIGINT) AS new_vaccinations,
--		SUM(CONVERT(BIGINT, new_vaccinations)) OVER (PARTITION BY dea.location) AS vac_count_total, -- total count
--		SUM(CONVERT(BIGINT, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vac_count_rolling -- rolling count
--FROM PortfolioProject..covid_deaths dea 
--JOIN PortfolioProject..vaccinations vac
--ON dea.location = vac.location
--AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
---- ORDER BY 2,3