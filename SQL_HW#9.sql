USE sakila;
SET SQL_SAFE_UPDATES=0;

/* Steps 1a - 1b*/
/*1a. Display the first and last names of all actors from the table actor.*/
SELECT  first_name, 
		last_name
FROM actor;

/*1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.*/
ALTER TABLE actor
ADD Actor_Name VARCHAR (30);

UPDATE actor 
SET Actor_Name= Upper(concat(first_name, ' ', last_name)); 
/*verifies results*/
SELECT *
FROM actor;

/* Steps 2a - 2d*/
/*2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information?*/
SELECT  actor_id,
		first_name, 
        last_name 
FROM actor
WHERE first_name = "JOE";

/*2b. Find all actors whose last name contain the letters GEN:*/
SELECT * 
FROM actor	
WHERE last_name LIKE "%GEN%";

/*2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:*/
SELECT *
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

/*2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:*/
SELECT  country_id, 
		country 
FROM country
WHERE country IN ("Afghanistan","Bangladesh","China");


/* Steps 3a - 3b*/
/*3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
as the difference between it and VARCHAR are significant).*/
ALTER TABLE actor
ADD descriptions BLOB ;
/*verifies results*/
SELECT *
From actor;

/*3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.*/
ALTER TABLE actor 
DROP COLUMN descriptionS;
/*verifies results*/
SELECT *
FROM actor;

/* Steps 4a - 4d*/
/*4a. List the last names of actors, as well as how many actors have that last name.*/
SELECT 	last_name, 
		COUNT(last_name)
FROM actor
GROUP BY last_name;

/*4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors*/
SELECT  last_name, 
		COUNT(last_name)
FROM actor
GROUP BY last_name
having count(*) >1;

/*4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.*/
UPDATE actor 
SET first_name='HARPO' 
	/*,Actor_Name='HARPO WILLIAMS'*/
WHERE first_name= 'GROUCHO' 
AND last_name = 'WILLIAMS';
/*Please note this does not change the Actor_Name Column.  
I removed it from the query as the next step is to change the first name back*/

/*4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
It turns out that GROUCHO was the correct name after all! 
In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.*/
UPDATE actor 
SET first_name='GROUCHO '
WHERE first_name= 'HARPO' ;
/*I did NOT add last name to query as their is only one entry for Harpo, 
so this will change all rows wth the first name incorrect 
and given I did not update the actor_name column in the previous step*/

/* Steps 5a */
/*5a. You cannot locate the schema of the address table. Which query would you use to re-create it?*/
SHOW CREATE TABLE address;
/* or use*/
DESCRIBE address; 

/* Steps 6a - 6e*/
/* 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
check tables
select * from staff;
select * from address;*/

SELECT  s.first_name,
		s.last_name,
        a.address
FROM staff s
JOIN address a 
ON s.address_id=a.address_id;

/*6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
check tables
select * from staff;
select * from address;
select * from payment;
*/
SELECT  s.staff_id,
		s.first_name,
        s.last_name,
        SUM(p.amount) AS "total amount rung"
FROM staff s
JOIN payment p
ON s.staff_id=p.staff_id
WHERE p.payment_date BETWEEN "2005-08-01" AND "2005-08-31"
GROUP BY staff_id;
/* Testing Results*/
SELECT  staff_id,
		amount 
FROM payment 
WHERE payment_date 
BETWEEN "2005-08-01" AND "2005-08-31"
GROUP BY staff_id;



/* 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
check tables
select * from film_actor;
select * from film;
*/

SELECT  f.title,
		COUNT(fa.actor_id) AS "number of actors"
FROM film f
INNER JOIN film_actor fa
ON f.film_id=fa.film_id
GROUP BY title
ORDER BY 1,2;

/* 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
check tables
select * from film;
select * from inventory;
*/

SELECT  f.title,
		COUNT(i.inventory_id)
FROM film f
JOIN inventory i
ON f.film_id=i.film_id
WHERE f.title ="Hunchback Impossible"
GROUP BY title;
/* test to verify:
select * from inventory where film_id=439;
*/

/*6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name
check tables
SELECT * FROM PAYMENT;
SELECT * FROM CUSTOMER;
*/
SELECT  c.first_name,
		c.last_name,
        SUM(p.amount) AS "Total Amount Paid"
FROM customer c
JOIN payment p
ON c.customer_id=p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name;

/* Steps 7a - 7h*/
/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.*/
/*check tables
select * from language;
select * from film;
*/
SELECT f.title
FROM film f
WHERE 1=1
	AND f.title LIKE 'K%' 
	OR f.title LIKE 'Q%'
    AND language_id IN (SELECT language_id FROM language WHERE name='English');
/*or*/ 
SELECT f.title
FROM film f
JOIN ( SELECT language_id 
	FROM language 
    WHERE name='English') l
 WHERE 1=1
	AND f.title LIKE 'K%' 
	OR f.title LIKE 'Q%';
   
/*7b. Use subqueries to display all actors who appear in the film Alone Trip.*/
/*check tables
select * from actor;
select * from film_actor;
select * from film;
*/
SELECT a.Actor_Name
FROM actor a
JOIN film_actor fa
ON a.actor_id=fa.actor_id
JOIN (SELECT film_id 
		FROM film 
        WHERE title='Alone Trip') f
ON fa.film_id=f.film_id
ORDER BY Actor_Name;
/*or*/
SELECT a.Actor_Name
FROM actor a
JOIN film_actor fa
ON a.actor_id=fa.actor_id
WHERE film_id in (SELECT film_id FROM film WHERE title='Alone Trip')
ORDER BY Actor_Name;

/*7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
Use joins to retrieve this information.*/
/*check tables
select * from customer;
select * from address;
select * from city;
select * from country;
*/
SELECT 	cust.last_name,
        cust.first_name,
        cust.email
FROM customer cust
JOIN address a
ON cust.address_id=a.address_id
JOIN city ct
ON a.city_id=ct.city_id
JOIN country cy
ON ct.country_id=cy.country_id
WHERE cy.country='Canada'
ORDER BY cust.last_name

/*7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.*/
/*check tables
select * from film_category;
select * from film;
select * from category;
*/;
SELECT f.title
FROM film f
JOIN film_category fc
ON f.film_id=fc.film_id
WHERE fc.category_id IN (SELECT category_id FROM category WHERE name='Family');
/*or*/
SELECT f.title
FROM film f
JOIN film_category fc
ON f.film_id=fc.film_id
JOIN (SELECT category_id FROM category WHERE name='Family') c
ON fc.category_id=c.category_id;

/*7e. Display the most frequently rented movies in descending order.*/
/*check tables
select * from rental;
select * from film;
select * from inventory;
*/
SELECT  f.title,
		count(r.rental_id) AS "Total Rented"
FROM film f
JOIN inventory i
ON f.film_id=i.film_id
JOIN rental r
ON i.inventory_id=r.inventory_id
GROUP BY title
ORDER BY 2 desc;


/*7f. Write a query to display how much business, in dollars, each store brought in.*/
/*check tables
select * from store;
select * from customer;
select * from payment;
*/
SELECT  s.store_id,
		SUM(p.amount) as "Total Business ($)"
FROM store s
JOIN customer c
ON s.store_id=c.store_id
JOIN payment p
ON c.customer_id=p.customer_id
GROUP BY store_id;


/*7g. Write a query to display for each store its store ID, city, and country.*/
/*check tables
select * from store;
select * from address;
select * from city;
select * from country;
*/
SELECT  s.store_id,
		ct.city,
        cy.country
FROM store s
JOIN address a
ON s.address_id=a.address_id
JOIN city ct
ON a.city_id=ct.city_id
JOIN country cy
ON ct.country_id=cy.country_id;
        


/*7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/
/*check tables
select * from category;
select * from film_category;
select * from inventory;
select * from rental;
select * from payment;
*/
SELECT  c.name,
		sum(p.amount) as "Gross Revenue"
FROM category c
JOIN film_category fc
ON c.category_id=fc.category_id
JOIN inventory i
ON fc.film_id=i.film_id
JOIN rental r
ON i.inventory_id=r.inventory_id
JOIN payment p
ON r.customer_id=p.customer_id
GROUP BY name
ORDER BY "Gross Revenue"
Limit 5;



/* Steps 8a - 8c*/
/*8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.*/
CREATE VIEW vw_Top_Genres AS
SELECT  c.name,
		sum(p.amount) as "Gross Revenue"
FROM category c
JOIN film_category fc
ON c.category_id=fc.category_id
JOIN inventory i
ON fc.film_id=i.film_id
JOIN rental r
ON i.inventory_id=r.inventory_id
JOIN payment p
ON r.customer_id=p.customer_id
GROUP BY name
ORDER BY "Gross Revenue"
Limit 5;



/*8b. How would you display the view that you created in 8a?*/
SELECT * 
FROM vw_Top_Genres;

/*8c. You find that you no longer need the view top_five_genres. Write a query to delete it.*/
DROP VIEW vw_Top_Genres;
