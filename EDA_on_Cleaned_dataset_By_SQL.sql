use laptop_dataset;

-- Performing EDA

# 1. Preview of Data
-- head,tail,sample
SELECT * FROM cleaned_laptops ORDER BY index_value ASC limit 5;
SELECT * FROM cleaned_laptops ORDER BY index_value DESC limit 5;
SELECT * FROM cleaned_laptops ORDER BY RAND() limit 5;

# 2. Univariate Analysis On
-- 2.1 Price

-- price summary
SELECT
COUNT(Price) OVER() AS count,
MIN(Price) OVER() AS 'min',
MAX(Price) OVER() AS 'max',
AVG(Price) OVER() AS 'average',
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Price) OVER() AS '25%',
PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Price) OVER() AS 'median',
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Price) OVER() AS '75%'
FROM cleaned_laptops LIMIT 1;

-- count missing values in price
SELECT COUNT(*)
FROM cleaned_laptops WHERE Price IS NULL;

-- outliers
SELECT * FROM (SELECT *,
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q1',
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q3'
FROM cleaned_laptops) t
WHERE t.Price < t.Q1 - (1.5*(t.Q3 - t.Q1)) OR
t.Price > t.Q3 + (1.5*(t.Q3 - t.Q1));

-- Horizontal Histogram distribution
SELECT t.buckets,REPEAT('*',COUNT(*)/5) FROM (SELECT price, 
CASE 
	WHEN price BETWEEN 0 AND 25000 THEN '0-25K'
    WHEN price BETWEEN 25001 AND 50000 THEN '25K-50K'
    WHEN price BETWEEN 50001 AND 75000 THEN '50K-75K'
    WHEN price BETWEEN 75001 AND 100000 THEN '75K-100K'
	ELSE '>100K'
END AS 'buckets'
FROM cleaned_laptops) t
GROUP BY t.buckets;

-- 2.2 Company
-- Frequecy count
SELECT Company, COUNT(Company) FROM cleaned_laptops
GROUP BY Company;

-- Missing value count
select count(*) from cleaned_laptops where Company is null;



-- 3. Bivariate Analysis

-- 3.1 b/w 
SELECT cpu_speed, Price FROM cleaned_laptops;

-- contingency table b/w touchscreen and company
SELECT Company,
SUM(CASE WHEN touchscreen=1 THEN 1 ELSE 0 END) AS "touchscreen_yes",
SUM(CASE WHEN touchscreen=0 THEN 1 ELSE 0 END) AS "touchscreen_no"
FROM cleaned_laptops
GROUP BY Company;

SELECT Company,
SUM(CASE WHEN cpu_brand = 'Intel' THEN 1 ELSE 0 END) AS 'intel',
SUM(CASE WHEN cpu_brand = 'AMD' THEN 1 ELSE 0 END) AS 'amd',
SUM(CASE WHEN cpu_brand = 'Samsung' THEN 1 ELSE 0 END) AS 'samsung'
FROM cleaned_laptops
GROUP BY Company;



select * from cleaned_laptops;









