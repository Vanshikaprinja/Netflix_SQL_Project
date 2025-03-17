-- Netflix Project --
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
	(show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	released_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250));

SELECT * FROM netflix;

SELECT 
	COUNT(*) AS total_content 
FROM netflix;

SELECT 
	DISTINCT type
FROM netflix;

-- 1. Count the number of Movies vs TV shows
SELECT 
 	type,
	COUNT(*) 
FROM netflix
GROUP BY 1; 
-- 2. Find the most common rating for movies and TV shows
SELECT 
	type,
 	rating
FROM
	(SELECT
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1,2)AS t1
WHERE ranking = 1;


-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * FROM netflix 
WHERE 
	type = 'Movie'
	AND
	released_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(show_id) as total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- 5. Identify the longest movie or TV show duration.
SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND
	duration =(SELECT MAX(duration) FROM netflix);

-- 6. Find content added in the last 5 years.

SELECT 
	*
FROM netflix
WHERE TO_DATE(date_added,'Month DD, YYYY')
 = CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * 
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix 
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ' , 1)::numeric > 5;

-- 9. Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id)
FROM netflix
GROUP BY 1

-- 10.Find each year and the average numbers of content
-- release in India on netflix.
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(
	COUNT(*)::numeric/
	(SELECT COUNT(*) FROM netflix WHERE country ='India')::numeric * 100,2
	)AS avg_release
FROM netflix 
WHERE country ='India'
GROUP BY 1;


-- 11. List All Movies that are Documentaries
SELECT 
	*
FROM netflix
WHERE 
listed_in ILIKE '%Documentaries%';


-- 12. Find All Content Without a Director

SELECT 
	*
FROM netflix
WHERE director IS NULL;

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT 
	*
FROM netflix 
WHERE 
	casts ILIKE '%Salman Khan%'
	AND
	released_year >= EXTRACT(year from CURRENT_DATE)-10;


-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
	COUNT(*) as total_content
	FROM netflix 
WHERE country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/*
15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
Objective: Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.
*/
SELECT 
	category,
	COUNT(*) as total_content
FROM
(
SELECT  
	CASE
	WHEN 
		description ILIKE 'kill%' OR
			description ILIKE 'violence%'
		THEN 'Bad_Content'
		ELSE 'Good_content'
	END category
FROM netflix
) as Categorized_content
GROUP BY category;
	
