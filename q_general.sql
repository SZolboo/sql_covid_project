/* GENERAL QUESTOINS */

-- Countries with Highest Infection Rate compared to Population.
SELECT 
    Location, 
    Population, 
    MAX(total_cases) AS HighestInfectionCount,  
    ROUND(MAX(CAST(total_cases AS DECIMAL(18, 2)) / population * 100), 2) AS PercentPopulationInfected
FROM covid_deaths
GROUP BY 
    Location, 
    Population
ORDER BY 
    PercentPopulationInfected DESC;

-- Countries with Highest Death Count per Population
SELECT 
    Location, 
    MAX(CAST(Total_deaths as INT)) AS TotalDeathCount
FROM 
    covid_deaths
WHERE 
    continent IS NOT NULL 
GROUP BY 
    Location
ORDER BY 
    TotalDeathCount DESC;

-- Continents with Highest Death Count per Population
SELECT 
    continent, 
    MAX(CAST(Total_deaths as INT)) AS TotalDeathCount
FROM 
    covid_deaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    continent
ORDER BY 
    TotalDeathCount DESC;

-- Total Death Count for Locations excluding Certain Income Categories
SELECT 
    location, 
    MAX(Total_deaths) AS TotalDeathCount
FROM 
    covid_deaths
WHERE 
    continent IS NULL AND
    location NOT IN ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY 
    location
ORDER BY 
    TotalDeathCount DESC;

-- Global Numbers
-- Around 0.91% of the total reported COVID-19 cases worldwide have resulted in death.

SELECT 
    SUM(new_cases) AS total_cases_worldwide, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths_worldwide, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL 
        ELSE ROUND((CAST(SUM(new_deaths) AS DECIMAL(18, 2)) / SUM(new_cases)) * 100, 2) 
    END AS DeathPercentage
FROM 
    covid_deaths
WHERE 
    continent IS NOT NULL
ORDER BY 
    total_cases DESC, 
    total_deaths DESC;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least 1 Covid Vaccine.
SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS RollingPeopleVaccinated
FROM 
    covid_deaths cd
INNER JOIN 
    covid_vaccinations cv 
    ON cd.location = cv.location AND cv.date = cd.date
WHERE 
    cd.continent IS NOT NULL
ORDER BY 
    cd.location, cd.date;