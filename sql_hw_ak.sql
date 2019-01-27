
use sakila;
-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT (first_name,' ',last_name) AS 'Actor Name' FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, 
-- "Joe." What is one query would you use to obtain this information?

SELECT actor_ID, first_name, last_name FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT first_name, last_name FROM actor
WHERE first_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a 
-- column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the 
-- difference between it and `VARCHAR` are significant).
ALTER TABLE actor ADD description BLOB AFTER last_name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP COLUMN description; 

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS LastNameCount
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT COUNT(last_name), first_name
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
SELECT actor_id, first_name, last_name FROM actor
WHERE last_name LIKE 'WILLIAMS';

UPDATE actor
SET first_name='HARPO'
WHERE actor_id=172;

SELECT actor_id, first_name, last_name FROM actor
WHERE last_name LIKE 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name 
-- after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name='GROUCHO'
WHERE actor_id=172;

SELECT actor_id, first_name, last_name FROM actor
WHERE last_name LIKE 'WILLIAMS';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`
SELECT staff.first_name, staff.last_name, address.address 
FROM staff
LEFT JOIN address ON staff.staff_id=address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT s.staff_id, CONCAT(s.first_name, " ", s.last_name) AS name, SUM(amount)
FROM staff s INNER JOIN payment p ON s.staff_id = p.staff_id
WHERE MONTH(payment_date) = 8 AND YEAR(payment_date) = 2005
GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title, COUNT(fa.actor_id) AS 'Number of Actors'
FROM film f INNER JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY f.film_id
ORDER BY f.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.title, COUNT(inventory_id) AS 'Number of Copies'
FROM inventory i INNER JOIN film f ON i.film_id 
WHERE f.title = 'Hunchback Impossible'
GROUP BY f.film_id;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT c.first_name AS 'First Name', c.last_name AS 'Last Name', SUM(amount) AS 'Total Amount Paid'
FROM customer c INNER JOIN payment p ON c.customer_id = p.payment_id
GROUP BY c.last_name, c.first_name
ORDER BY c.last_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles
-- of movies starting with the letters `K` and `Q` whose language is English.

SELECT title
FROM film WHERE title 
LIKE 'K%' OR title LIKE 'Q%'
AND title IN 
(
SELECT title 
FROM film 
WHERE language_id = 1
);

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT CONCAT(a.first_name, " ", a.last_name) AS actor
FROM actor a 
WHERE actor_id IN
	(SELECT fa.actor_id
    FROM film f INNER JOIN film_actor fa ON f.film_id = fa.film_id
    WHERE f.title = 'Alone Trip'
    )

/*7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
of all Canadian customers. Use joins to retrieve this information.
*/
SELECT c.first_name, c.last_name, c.email, cy.country
FROM customer c LEFT JOIN address a ON c.address_id = a.address_id
LEFT JOIN city ci ON a.city_id = ci.city_id
LEFT JOIN country cy ON ci.country_id = cy.country_id
WHERE cy.country = 'Canada'

/*7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as _family_ films.
*/
SELECT f.title
FROM film f 
WHERE f.film_id IN
	(SELECT film_id FROM film_category fc
    WHERE fc.category_id IN
		(SELECT category_id
		FROM category
		WHERE name = 'Family'
		))

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.rental_id) AS 'Number of Rentals'
FROM inventory i LEFT JOIN film f ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY COUNT(rental_id) DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT st.store_id, SUM(p.amount) AS 'Revenue'
FROM store s JOIN staff st ON s.store_id = st.store_id
JOIN payment p ON p.staff_id = st.staff_id
GROUP BY st.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT st.store_id, ct.city, cy.country
FROM store st LEFT JOIN address a ON st.address_id = a.address_id
JOIN city ct ON a.city_id = ct.city_id
JOIN country cy ON ct.country_id = cy.country_id;


/*7h. List the top five genres in gross revenue in descending order. 
(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
*/
SELECT c.name AS 'Genre', SUM(p.amount) AS 'Revenue'
FROM category c JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id 
JOIN rental r ON r.inventory_id = i.inventory_id 
JOIN payment p ON p.rental_id = r.rental_id
group by c.name
order by SUM(p.amount) DESC
LIMIT 5;

/*8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
*/
CREATE VIEW top_5_revenue_by_genre AS
SELECT c.name AS 'Genre', SUM(p.amount) AS 'Revenue'
FROM category c JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id 
JOIN rental r ON r.invstaff_liststaff_liststaff_listentory_id = i.inventory_id 
JOIN payment p ON p.rental_id = r.rental_id
group by c.name
order by SUM(p.amount) DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * 
FROM top_5_revenue_by_genre

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW IF EXISTS top_5_revenue_by_genre;
