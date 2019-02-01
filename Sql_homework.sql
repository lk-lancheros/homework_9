USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.--
SELECT first_name as 'Actor: First name', last_name as 'Actor: Last name'
FROM actor
ORDER BY first_name ASC;

-- 1b. Display actor first/last name, single column, upper case letters. `Actor Name`--
SELECT CONCAT (UPPER(first_name),' ', UPPER(last_name)) as 'Actor Name'
FROM actor
ORDER BY first_name ASC;

-- 2a. Find the actor ID number, first name ("JOE"), last name --
SELECT actor_ID, first_name, last_name FROM actor
WHERE first_name='JOE';

-- 2b. All actors, last name contain `GEN`--
SELECT first_name as 'Actor: First name', last_name as 'Actor: Last name contains "GEN"'
FROM actor
WHERE last_name LIKE '%GEN%'
ORDER BY last_name ASC;

-- 2c. All actors, last names contain `LI`. Order the rows by last name and first name, in that order:
SELECT last_name as 'Actor: Last name contains "LI"', first_name as 'Actor: First name' 
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name ASC;
 
-- 2d. Using `IN`, display `country_id`/`country` columns Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan','Bangladesh', 'China');

-- 3a. Create a column in the table `actor` named `description` and use the data type `BLOB` 
ALTER TABLE actor
ADD description BLOB;

-- 3b. Delete the `description` column.
ALTER TABLE actor
DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name as 'Actor: Last name', COUNT(last_name) as 'Count'
FROM actor
    GROUP BY last_name
    ORDER BY COUNT(last_name) DESC;

-- 4b.List actor last names/number of actors w/last name, but only for names that are shared by at least two actors
SELECT last_name as 'Actor: Last name', COUNT(last_name) as 'Count'
    FROM actor
    GROUP BY last_name
    HAVING COUNT(last_name)>1
    ORDER BY COUNT(last_name) DESC, last_name ASC;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
UPDATE actor
SET first_name ='HARPO' , last_name = 'WILLIAMS'
WHERE first_name ='GROUCHO' AND last_name = 'WILLIAMS';

SELECT * FROM actor
WHERE first_name='HARPO';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name ='GROUCHO' , last_name = 'WILLIAMS'
WHERE first_name ='HARPO' AND last_name = 'WILLIAMS';

SELECT * FROM actor
WHERE first_name='GROUCHO';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
select *
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='address';

-- 6a. `JOIN`, display staff first and last names, address. Use tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
LEFT JOIN address 
ON staff.address_id=address.address_id;

-- 6b.Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT staff.first_name as 'Staff: First name', staff.last_name as 'Staff: Last name',  
SUM(amount) as 'Sum Payments'
FROM payment
JOIN staff
ON staff.staff_id=payment.staff_id
WHERE payment.payment_date between '2005-08-01 00:00:00' AND '2005-08-31 00:00:00'
GROUP BY payment.staff_id
ORDER BY SUM(amount) DESC;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT title as 'Movie Title', COUNT(actor_id) as 'Count of Actors'
FROM film_actor
INNER JOIN film
ON film.film_id=film_actor.film_id
GROUP BY title
ORDER BY COUNT(actor_id) DESC, title ASC;

-- 6d. How many of the film `Hunchback Impossible` exist in the inventory system?
SELECT title as 'Movie Title', count(inventory_id) as 'Inventory Copies'
FROM inventory
INNER JOIN film
ON inventory.film_id=film.film_id
WHERE title="Hunchback Impossible";

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, sum(payment.amount) as 'Total Payment'
FROM customer
JOIN payment
ON customer.customer_id=payment.customer_id
GROUP BY payment.customer_id
ORDER BY sum(payment.amount) DESC;

-- 7a. Use subqueries to display movie titles starting w/`K` and `Q` whose language is English.
SELECT film.title
FROM film
WHERE language_id 
IN(
  SELECT language_id
  FROM language
  WHERE name='English'
  )
AND (title LIKE 'K%' or title LIKE 'Q%');

-- 7b.  use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name as 'Actor: First name', last_name as 'Actor: Last name'
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title = 'Alone Trip'
    )
)
ORDER BY last_name ASC;

-- 7c. Get names and email addresses of all Canadian customers and Use joins.
SELECT first_name, last_name, email
FROM customer 
INNER JOIN address
    ON customer.address_id =address.address_id
INNER JOIN  city
    ON address.city_id =city.city_id
INNER JOIN country
    ON city.country_id =country.country_id
WHERE country = "Canada";

-- 7d. Identify all movies categorized as _family_ films.
SELECT film.title as 'Movie'
FROM film
WHERE film_id IN
(
  SELECT film_id
  FROM film_category
  WHERE category_id IN
  (
   SELECT category_id
   FROM category
   WHERE name = 'Family'
  )
);
-- 7e. CHECK Display the most frequently rented movies in descending order.
SELECT film.title as 'Movie Title', count(rental.rental_id) as 'Rental Frequency'
FROM rental
    INNER JOIN inventory
        ON rental.inventory_id =inventory.inventory_id
    INNER JOIN  film
        ON inventory.film_id =film.film_id
GROUP BY film.title
ORDER BY count(rental.inventory_id) DESC, title ASC
;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, city.city, country.country, SUM(payment.amount) as 'Sum Rental Payments'
FROM payment
    INNER JOIN staff
        ON payment.staff_id =staff.staff_id
    INNER JOIN  store
        ON staff.store_id =store.store_id
    INNER JOIN  address
        ON store.address_id =address.address_id
    INNER JOIN  city
        ON address.city_id =city.city_id
    INNER JOIN  country
        ON city.country_id =country.country_id
    GROUP BY store.store_id
ORDER BY  SUM(payment.amount) DESC;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
    INNER JOIN address  
    ON store.address_id =address.address_id
        INNER JOIN  city
        ON address.city_id =city.city_id
            INNER JOIN  country
            ON city.country_id =country.country_id
    GROUP BY store.store_id

ORDER BY  store.store_id ASC;

-- 7h. List the top five genres in gross revenue in descending order. 
SELECT category.name as 'Top 5 Movie Genres', sum(payment.amount) as 'Gross revenue'
FROM category
    INNER JOIN film_category  
    ON category.category_id =film_category.category_id
        INNER JOIN  inventory
        ON film_category.film_id =inventory.film_id
            INNER JOIN  rental
            ON inventory.inventory_id =rental.inventory_id
                INNER JOIN  payment
                ON rental.rental_id =payment.rental_id
GROUP BY category.name
ORDER BY sum(payment.amount) DESC
LIMIT 5;


-- 8a. Use the solution from the problem above to create a view.
CREATE VIEW top_5 AS  
SELECT category.name as 'Top 5 Movie Genres', sum(payment.amount) as 'By Gross revenue' 
FROM category     
	INNER JOIN film_category       
	ON category.category_id =film_category.category_id         
		INNER JOIN  inventory         
        ON film_category.film_id =inventory.film_id             
			INNER JOIN  rental             
            ON inventory.inventory_id =rental.inventory_id                 
				INNER JOIN  payment                 
				ON rental.rental_id =payment.rental_id 
GROUP BY category.name 
ORDER BY sum(payment.amount) DESC 
LIMIT 5;


-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_5;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW top_5;