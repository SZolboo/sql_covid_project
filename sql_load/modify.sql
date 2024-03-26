COPY covid_deaths
FROM '/Users/zolboo/Data Analyst/sql_covid_project/csv_files/Covid_Deaths.csv'
DELIMITER ',' CSV HEADER;

COPY covid_vaccinations
FROM '/Users/zolboo/Data Analyst/sql_covid_project/csv_files/Covid_Vaccinations.csv'
DELIMITER ',' CSV HEADER;


SELECT * FROM covid_vaccinations LIMIT 50;