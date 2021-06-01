/* QUERY 1 - query used for first insight */

WITH family_movies AS 
(
   SELECT
      f.film_id,
      f.title,
      cat.name AS cat_name 
   FROM
      category AS cat 
      JOIN
         film_category AS fcat 
         ON cat.category_id = fcat.category_id 
      JOIN
         film AS f 
         ON f.film_id = fcat.film_id 
   WHERE
      cat.name IN 
      (
         'Animation',
         'Children',
         'Classics',
         'Comedy',
         'Family',
         'Music'
      )
)
SELECT
   category_name,
   COUNT(rental_count) AS categroy_count 
FROM
   (
      SELECT
         fm.title AS film_title,
         cat_name AS category_name,
         COUNT(rental_id) AS rental_count 
      FROM
         family_movies AS fm 
         JOIN
            inventory AS inv 
            ON fm.film_id = inv.film_id 
         JOIN
            rental AS ren 
            ON ren.inventory_id = inv.inventory_id 
      GROUP BY
         1,
         2 
   )
   sub 
GROUP BY
   1 
ORDER BY
   2 DESC;






/* QUERY 2 - query used for second insight */

WITH family_movies AS 
(
   SELECT
      f.title,
      cat.name AS category_name,
      f.rental_duration,
      NTILE(4) OVER (
   ORDER BY
      rental_duration) AS standard_quartile 
   FROM
      category AS cat 
      JOIN
         film_category AS fcat 
         ON cat.category_id = fcat.category_id 
      JOIN
         film AS f 
         ON f.film_id = fcat.film_id 
   WHERE
      cat.name IN 
      (
         'Animation',
         'Children',
         'Classics',
         'Comedy',
         'Family',
         'Music'
      )
)
SELECT
   category_name,
   standard_quartile,
   COUNT(*) 
FROM
   family_movies 
GROUP BY
   1,
   2 
ORDER BY
   1,
   2






/* QUERY 3 - query used for third insight */

WITH rents_per_store AS 
(
   SELECT
      rental_date,
      store.store_id 
   FROM
      store 
      JOIN
         staff 
         ON store.store_id = staff.store_id 
      JOIN
         rental 
         ON rental.staff_id = staff.staff_id 
)
SELECT
   DATE_PART('month', rental_date) AS rental_month,
   DATE_PART('year', rental_date) AS rental_year,
   store_id,
   COUNT(*) rental_count 
FROM
   rents_per_store 
GROUP BY
   1,
   2,
   3 
ORDER BY
   4 DESC







/* QUERY 4 - query used for fourth insight */

WITH top_paying_customer AS 
(
   SELECT
      cu.customer_id,
      CONCAT(first_name, ' ', last_name) AS customer_name,
      SUM(amount) AS sum 
   FROM
      customer AS cu 
      JOIN
         payment AS py 
         ON cu.customer_id = py.customer_id 
   GROUP BY
      1,
      2 
   ORDER BY
      3 DESC LIMIT 10
)
SELECT
   tpc.customer_name,
   DATE_TRUNC('month', payment_date) AS payment_month,
   COUNT(amount) AS payment_count_permonth,
   SUM(amount) AS monthly_total 
FROM
   top_paying_customer AS tpc 
   JOIN
      payment AS py 
      ON tpc.customer_id = py.customer_id 
WHERE
   DATE_PART('year', payment_date) = 2007 
GROUP BY
   1,
   2



