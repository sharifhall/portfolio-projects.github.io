-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of you dying if you contract Covid in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS Death_Percentage
FROM "CovidDeaths"
WHERE location = 'United States'
ORDER BY location, date;

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases / population)* 100 AS Contracted_Percentage
FROM "CovidDeaths"
WHERE location = 'United States'
ORDER BY location, date;

-- Looking at Countries with Highest Infected Rate compared to Population
SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX(total_cases / population)* 100 AS Contracted_Percentage
FROM "CovidDeaths"
GROUP BY location, population
ORDER BY Contracted_Percentage DESC;

-- Showing countries with the highest death count per population
SELECT location, MAX(total_deaths) AS Total_Death_Count
FROM "CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC;

-- Does Vaccinations have an affect on the number of deaths?
SELECT dea.location, dea.date, dea.new_cases, dea.new_deaths, vac.total_vaccinations
FROM "CovidDeaths" AS dea
JOIN "CovidVaccinations" AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2;

-- SELECT location, MAX(total_deaths) AS Total_Death_Count
-- FROM "CovidDeaths"
-- WHERE continent IS NULL
-- GROUP BY location
-- ORDER BY Total_Death_Count DESC;

-- LET'S BREAK THIS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) AS Total_Death_Count
FROM "CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;

-- Looking at the Total Population vs. Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM "CovidDeaths" AS dea
JOIN "CovidVaccinations" AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2, 3;


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) AS Rolling_People_Vacc, 
FROM "CovidDeaths" AS dea
JOIN "CovidVaccinations" AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2, 3;

-- Drop the table if it exists
DROP TABLE IF EXISTS PercentPopVacc;

-- Create the table
CREATE TABLE PercentPopVacc (
    continent VARCHAR(100),
    location VARCHAR(100),
    date DATE,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rolling_people_vacc NUMERIC
);

-- Insert data into the table
INSERT INTO PercentPopVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS rolling_people_vacc 
FROM "CovidDeaths" AS dea
JOIN "CovidVaccinations" AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Created View for later visualizations
CREATE VIEW PercentPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS rolling_people_vacc 
FROM "CovidDeaths" AS dea
JOIN "CovidVaccinations" AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
