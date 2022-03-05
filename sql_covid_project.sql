

SELECT *
FROM covid_deaths_project..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM covid_deaths_project..CovidDeaths
ORDER BY 1,2

-- Looking at Total Case vs Total Deaths

SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM covid_deaths_project..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Popolation

SELECT 
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS PercentPopulationInfected
FROM covid_deaths_project..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT 
	location,
	population,
	MAX (total_cases) AS HighestInfectionCount,
	MAX (total_cases/population)*100 AS PercentPopulationInfected
FROM covid_deaths_project..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population


SELECT 
	location,
	MAX (CONVERT(INT,total_deaths)) AS TotalDeathCount
FROM covid_deaths_project..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- 



-- Showing continents wwith the highest death count per population

SELECT 
	continent,
	MAX (CONVERT(INT,total_deaths)) AS TotalDeathCount
FROM covid_deaths_project..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Number

SELECT 
	SUM(total_cases) AS total_cases,
	SUM(CONVERT (INT, new_deaths)) AS total_deaths,
	SUM(CONVERT (INT, new_deaths)) / SUM(total_cases) *100 AS DeathPercentage
FROM covid_deaths_project..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
) 

INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingPeopleVaccinated
FROM covid_deaths_project..CovidDeaths AS dea
JOIN covid_deaths_project..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *,
	(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Create view

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingPeopleVaccinated
FROM covid_deaths_project..CovidDeaths AS dea
JOIN covid_deaths_project..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date




