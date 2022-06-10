select c.name, count(i.category_id)
from category as c
         inner join film_category as i on c.category_id = i.category_id
group by c.name
order by count desc;


select count(rental_duration) as "rentals", first_name, last_name
from film,
     actor,
     film_actor
where film.film_id = film_actor.film_id
  and actor.actor_id = film_actor.actor_id
group by first_name, last_name
order by rentals desc limit 10;


with a as (select sum(amount), name
           from payment,
                rental,
                inventory,
                film_category,
                category
           where payment.rental_id = rental.rental_id
             and inventory.inventory_id = rental.inventory_id
             and inventory.film_id = film_category.film_id
             and film_category.category_id = category.category_id
           group by name
           order by sum desc)
select *
from a limit 1;


select title
from film
         left join inventory on film.film_id = inventory.film_id
where inventory.film_id is null;


with b as (with a as (select count(category), first_name, last_name
                      from film,
                           actor,
                           film_actor,
                           category,
                           film_category
                      where category.category_id = film_category.category_id
                        and film_category.film_id = film.film_id
                        and film.film_id = film_actor.film_id
                        and actor.actor_id = film_actor.actor_id
                        and category.name in ('Children')
                      group by first_name, last_name
                      order by count desc)
           select *, dense_rank() over (order by count desc) as "top"
           from a)
select *
from b
where top <= 3;


select city,
       sum(case when customer.active = 1 then 1 else 0 end)  as active,
       sum(case when customer.active <> 1 then 1 else 0 end) as inactive
from address,
     city,
     customer
where city.city_id = address.city_id
  and address.address_id = customer.address_id
group by city
order by inactive desc;


with a as (select sum(extract(epoch from (return_date - rental_date)) / 3600) as hours, name, city
           from rental,
                city,
                category,
                address,
                customer,
                inventory,
                film_category
           where rental.inventory_id = inventory.inventory_id
             and inventory.film_id = film_category.film_id
             and film_category.category_id = category.category_id
             and customer.customer_id = rental.customer_id
             and customer.address_id = address.address_id
             and address.city_id = city.city_id
           group by city, name
           order by hours)
select b.name, b.city, b.hours
from a as b
         left join a as c on b.city = c.city and b.hours < c.hours
where c.hours is NULL
  and b.hours is not NULL
  and (b.city like 'A%' or b.city like '%-%')
order by b.city;