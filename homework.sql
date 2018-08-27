
USE sakila;
-- 1a
SELECT first_name, last_name
FROM actor;

-- 1b
SELECT upper(concat(first_name, ' ', last_name)) as 'Actor Name'
FROM actor;

-- 2a
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b
SELECT *
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c
SELECT *
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d
SELECT country_id, country
FROM country
WHERE country IN  ('Afghanistan', 'Bangladesh', 'China') ;

-- 3a
ALTER TABLE actor
ADD description BLOB;

-- 3b
ALTER TABLE actor
DROP description;

-- 4a
SELECT 
	last_name AS 'Last Name',
    COUNT(last_name)  AS COUNT
FROM actor 
GROUP BY last_name;

-- 4b
SELECT *
FROM
	(SELECT 
		last_name AS 'Last Name',
		COUNT(last_name)  AS count
	FROM actor 
	GROUP BY last_name
    )last_name_count
WHERE count > 1;

-- 4c
UPDATE actor 
SET first_name = 'HARPO'
WHERE
	first_name = 'GROUCHO' AND
    last_name = 'WILLIAMS';
    
-- 4d
SET SQL_SAFE_UPDATES = 0;

UPDATE actor 
SET first_name = 'GROUCHO'
WHERE
	first_name = 'HARPO' ;
    
-- 5a    
SHOW CREATE TABLE address;

-- 6a
-- Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT s.first_name, s.last_name, a.address
FROM
	staff AS s JOIN address AS a ON s.address_id = a.address_id;
    
-- 6b
-- Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT s.staff_id, SUM(p.amount)
FROM
	payment AS p JOIN staff AS s ON p.staff_id = s.staff_id
WHERE p.payment_date BETWEEN '2005/8/1' AND '2005/8/31'
GROUP BY s.staff_id;
    
-- 6c
-- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(fa.film_id)
FROM film AS f INNER JOIN film_actor AS fa ON f.film_id = fa.film_id
GROUP BY title;

-- 6d. 
-- How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT COUNT(f.film_id)
FROM film AS f JOIN inventory AS i ON f.film_id = i.film_id
WHERE 
	f.title = 'Hunchback Impossible';
    
-- 6e. 
-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount)
FROM payment AS p
	 JOIN customer AS c ON p.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name ASC;

-- 7a. 
-- The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT f.title, f.language_id
FROM film AS f 
WHERE 
	f.title LIKE 'K%' OR 
    f.title LIKE 'Q%' AND
    f.language_id IN
		(SELECT language_id 
		 FROM language AS l
		 WHERE 
			l.name = 'English'
        );

-- 7b. 
-- Use subqueries to display all actors who appear in the film Alone Trip.

SELECT a.first_name, a.last_name, f.title
FROM film_actor AS fa
INNER JOIN actor AS a ON a.actor_id = fa.actor_id
INNER JOIN film AS f ON f.film_id = fa.film_id
WHERE 
f.film_id IN 
	(SELECT film_id 
	 FROM film
     WHERE title = 'Alone Trip'
     );

-- 7c. 
-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

SELECT c.first_name, c.last_name, c.email, a.address
FROM customer AS c
INNER JOIN address AS a ON c.address_id = a.address_id
WHERE a.city_id IN
	(SELECT city.city_id
     FROM city
     INNER JOIN country ON city.country_id = country.country_id
     WHERE country.country = 'Canada'
     );


-- 7d. 
-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.


SELECT f.title 
FROM film AS f
WHERE f.film_id IN
	(SELECT film_id 
     FROM film_category AS fc
     WHERE fc.category_id IN
		(SELECT c.category_id
         FROM category AS c
		 WHERE c.name = 'Family'
         )
		);

-- 7e
-- Display the most frequently rented movies in descending order.

SELECT film.title, COUNT(inventory.film_id)
	FROM inventory 
    JOIN film ON film.film_id=inventory.film_id
	WHERE inventory_id
    IN (
		SELECT inventory_id 
			FROM rental
            WHERE rental_id
            IN (
				SELECT rental_id
					FROM payment
				)
			)
            GROUP BY inventory.film_id
            ORDER BY COUNT(inventory.film_id) DESC;
            
-- 7f. 
-- Write a query to display how much business, in dollars, each store brought in.

SELECT store.store_id, SUM(payment.amount)
	FROM staff
    JOIN store ON store.store_id = staff.store_id
    JOIN payment ON staff.staff_id = payment.staff_id
    GROUP BY store.store_id;
    
-- 7g. 
-- Write a query to display for each store its store ID, city, and country.-- 

SELECT s.store_id, c.city, co.country
	FROM store s
    JOIN address a ON s.address_id = a.address_id
    JOIN city c On a.city_id = c.city_id
    JOIN country co ON c.country_id = co.country_id;
    
-- 7h 
-- List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)


SELECT c.name, SUM(p.amount)
	FROM category c
    JOIN film_category f ON c.category_id = f.category_id
    JOIN inventory i ON i.film_id = f.film_id
    JOIN rental r ON r.inventory_id = i.inventory_id
    JOIN payment p ON p.rental_id = r.rental_id
    GROUP BY c.name
    ORDER BY SUM(p.amount) DESC
    LIMIT 5;

-- SELECT C.name 
-- 	FROM category
--     WHERE category_id 
-- 		IN (
-- 			SELECT category_id
-- 				FROM film_category
--                 WHERE film_id 
-- 					IN (
-- 						SELECT film_id
-- 							FROM inventory
--                             WHERE inventory_id
-- 								IN (
-- 									SELECT inventory_id
-- 										FROM rental
--                                         WHERE rental_id
--                                          IN (
-- 											SELECT rental_id
-- 												FROM PAYMENT