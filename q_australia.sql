/* QUESTIONS SPECIFIC TO AUSTRALIA: */

/*
    This query shows the total COVID-19 cases and deaths in Australia over time, along with the death percentage relative to total cases.
*/
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((CAST(total_deaths AS DECIMAL(18, 2)) / total_cases) * 100, 2) AS DeathPercentage
FROM covid_deaths
WHERE 
    location = 'Australia'
ORDER BY  
    date;

/*
    How does Australia's total cases and deaths per million compare to the global average?
*/
-- Australia's total cases and deaths per million 
SELECT 
    ROUND(AVG(total_cases_per_million), 2) AS avg_cases_per_million,
    ROUND(AVG(total_deaths_per_million), 2) AS avg_deaths_per_million
FROM 
    covid_deaths
WHERE 
    location = 'Australia';

-- Global average total cases and deaths per million
SELECT 
    ROUND(AVG(total_cases_per_million), 2) AS global_avg_cases_per_million,
    ROUND(AVG(total_deaths_per_million), 2) AS global_avg_deaths_per_million
FROM 
    covid_deaths;

/*
    This query displays the total COVID-19 cases and the percentage of the population infected in Australia over time.
*/
SELECT 
    location,
    date,
    total_cases,
    population,
    ROUND((CAST(total_cases AS DECIMAL(18, 2)) / population) * 100, 2) AS PercentPopulationInfected
FROM covid_deaths
WHERE 
    location = 'Australia'
ORDER BY date;

/* 
QUESTIONS:
    How many ICU patients and hospitalized patients are there per million people in Australia?
    Has Australia faced any challenges regarding ICU admissions or hospitalizations during the pandemic?
 */

-- Average number of ICU patients per million in Australia over time. 
WITH avg_icu_patients_per_million AS (
    SELECT 
        date,
        ROUND(AVG(icu_patients_per_million), 2) AS avg_icu_patients_per_million
    FROM 
        covid_deaths
    WHERE 
        location = 'Australia'
    GROUP BY 
        date
),

-- Average hospitalized patients per million in Australia over time.
avg_hosp_patients_per_million AS (
    SELECT 
        date,
        ROUND(AVG(hosp_patients_per_million), 2) AS avg_hosp_patients_per_million
    FROM 
        covid_deaths
    WHERE 
        location = 'Australia'
    GROUP BY 
        date
),

-- Identifing periods where ICU admissions or hospitalizations faced challenges
challenging_periods AS (
    SELECT 
        date,
        CASE 
            WHEN icu_patients > (SELECT MAX(icu_patients) * 0.9 FROM covid_deaths WHERE location = 'Australia') THEN 1
            ELSE 0
        END AS challenging_icu,
        CASE 
            WHEN hosp_patients > (SELECT MAX(hosp_patients) * 0.9 FROM covid_deaths WHERE location = 'Australia') THEN 1
            ELSE 0
        END AS challenging_hosp
    FROM 
        covid_deaths
    WHERE 
        location = 'Australia'
)

-- Main query to retrieve results
SELECT 
    aip.date,
    aip.avg_icu_patients_per_million,
    ahp.avg_hosp_patients_per_million,
    cp.challenging_icu,
    cp.challenging_hosp
FROM 
    avg_icu_patients_per_million AS aip
JOIN 
    avg_hosp_patients_per_million AS ahp ON aip.date = ahp.date
JOIN 
    challenging_periods AS cp ON aip.date = cp.date
ORDER BY 
    aip.date;

/* 
QUESTIONS:
    Reproduction Rate in Australia compared to Global Average.
    Fluctuation in Reproduction Rate in Australia Over Time.

RESULT: 
A reproduction rate of 1.10 means that, on average, each infected individual in Australia is infecting approximately 1.10 other individuals. 
This suggests that the transmission of the virus is likely increasing in Australia.

REPRODUCTION RATE:
This represents the AVG number of secondary infections produced by a single infected individual in a population where everyone is susceptible to infection. It's a crucial epidemiological metric used to assess the contagiousness of a disease.
 */

-- Reproduction Rate in Australia compared to Global Average.
WITH global_avg AS (
    SELECT 
        ROUND(AVG(reproduction_rate), 2) AS avg_reproduction_rate
    FROM 
        covid_deaths
),

australia_avg AS (
    SELECT 
        ROUND(AVG(reproduction_rate), 2) AS avg_reproduction_rate
    FROM 
        covid_deaths
    WHERE 
        location = 'Australia'
)

SELECT 
    australia_avg.avg_reproduction_rate AS australia_reproduction_rate,
    global_avg.avg_reproduction_rate AS global_reproduction_rate
FROM
    global_avg, australia_avg;

-- Fluctuation in Reproduction Rate in Australia Over Time.
WITH australia_repro AS (
    SELECT 
        date, 
        reproduction_rate
    FROM 
        covid_deaths
    WHERE 
        location = 'Australia'
    ORDER BY date
)
SELECT 
    date,
    reproduction_rate,
    LAG(reproduction_rate) OVER (ORDER BY date) AS previous_repro_rate,
    reproduction_rate - LAG(reproduction_rate) OVER (ORDER BY date) AS rate_change
FROM 
    australia_repro;

/*
    How has the introduction of vaccination impacted the number of cases and deaths in Australia?
*/
SELECT
    cd.date,
    cd.location AS country,
    cd.new_cases,
    cd.total_cases,
    cd.new_deaths,
    cd.total_deaths, 
    cv.people_vaccinated,
    cv.people_fully_vaccinated,
    cv.total_vaccinations
FROM covid_deaths AS cd 
INNER JOIN covid_vaccinations AS cv
    ON cv.location = cd.location AND cv.date = cd.date
WHERE cd.location = 'Australia' AND cd.date >= '2021-02-22'
ORDER BY cv.date;

/*
    How have governmental policies and interventions affected the spread of COVID-19 in Australia?
*/
SELECT 
    cd.location AS country,
    cd.date,
    cd.total_cases,
    cd.new_cases,
    cd.total_deaths,
    cd.new_deaths,
    cv.stringency_index
FROM 
    covid_deaths AS cd
INNER JOIN 
    covid_vaccinations AS cv 
    ON cd.location = cv.location AND cd.date = cv.date
WHERE 
    cd.location = 'Australia' AND cd.date >= '2021-02-22'
ORDER BY 
    cd.date;

/*
    Comparison of Australia's Testing Rate Over Time with Other Continents.
*/
WITH australia_testing AS (
    SELECT 
        date, 
        total_tests_per_thousand
    FROM 
        covid_vaccinations
    WHERE 
        location = 'Australia'
),
continents_testing AS (
    SELECT 
        location, 
        date, 
        total_tests_per_thousand
    FROM 
        covid_vaccinations
    WHERE 
        continent IS NOT NULL
)
SELECT 
    ct.location AS continent,
    ROUND(AVG(ct.total_tests_per_thousand), 2) AS avg_testing_rate,
    ROUND(AVG(at.total_tests_per_thousand), 2) AS australia_testing_rate
FROM 
    continents_testing ct
JOIN 
    australia_testing at
ON 
    ct.date = at.date
GROUP BY 
    ct.location;

/*
    How does Australia's vaccination coverage (people vaccinated per hundred) compare with other continents?
*/
WITH continent_vaccination_coverage AS (
    SELECT 
        continent,
        ROUND(AVG(people_vaccinated_per_hundred), 2) AS avg_vaccination_coverage
    FROM 
        covid_vaccinations
    WHERE 
        people_vaccinated_per_hundred IS NOT NULL
    GROUP BY 
        continent
)

SELECT 
    c.continent,
    c.avg_vaccination_coverage,
    CASE 
        WHEN c.avg_vaccination_coverage > AVG(cv.people_vaccinated_per_hundred) THEN 'Above Average'
        WHEN c.avg_vaccination_coverage < AVG(cv.people_vaccinated_per_hundred) THEN 'Below Average'
        ELSE 'Equal'
    END AS comparison_with_global_average
FROM 
    continent_vaccination_coverage AS c
INNER JOIN 
    covid_vaccinations AS cv ON c.continent = cv.continent
WHERE cv.location = 'Australia'
GROUP BY 
    c.continent, 
    c.avg_vaccination_coverage;

/*
    How does Australia's stringency index (a measure of pandemic response measures) compare to the global average?
*/
WITH global_average AS (
    SELECT 
        date,
        ROUND(AVG(stringency_index), 2) AS global_avg_stringency
    FROM 
        covid_vaccinations
    WHERE 
        stringency_index IS NOT NULL
    GROUP BY 
        date
),
australia_data AS (
    SELECT 
        date,
        stringency_index
    FROM 
        covid_vaccinations
    WHERE 
        iso_code = 'AUS'
        AND stringency_index IS NOT NULL
)
SELECT 
    australia_data.date,
    australia_data.stringency_index AS australia_stringency_index,
    global_avg_stringency
FROM 
    australia_data
INNER JOIN 
    global_average ON australia_data.date = global_average.date
ORDER BY australia_data.date;