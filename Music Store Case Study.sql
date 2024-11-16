1) Find the artist who has contributed with the maximum no of albums. Display the artist name and the no of albums.

select artist_name, no_of_albums from
(
select a.name as artist_name, count(1) as no_of_albums,
rank() over(order by count(1) desc) as rank
from artist a
join album alb on a.artistid = alb.artistid
group by artist_name
) x
where x.rank = 1

or

with cte as
(
select a.name as artist_name, count(1) as no_of_albums,
rank() over(order by count(1) desc) as rank
from artist a
join album alb on a.artistid = alb.artistid
group by artist_name
) 
select artist_name, no_of_albums 
from cte
where rank = 1

or

select a.name as artist_name, count(1) as no_of_albums
from artist a
join album alb on a.artistid = alb.artistid
group by artist_name
order by 2 desc
limit 1

2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.

select concat(c.firstname,' ', c.lastname) as customer_name, c.email as email, c.country as country
from customer c
join invoice i on c.customerid = i.customerid
join invoiceline il on il.invoiceid = i.invoiceid
join track t on t.trackid = il.trackid
join genre g on g.genreid = t.genreid
where g.name in ('Jazz', 'Rock', 'Pop')


3) Find the employee who has supported the most no of customers. Display the employee name and designation

select employee_name, designation
from
(
select e.firstname||' '||e.lastname as employee_name, e.title as designation, count(1) as no_of_customers,
rank() over(order by count(1) desc) as rank
from employee e
join customer c on c.supportrepid = e.employeeid
group by employee_name, designation
) x
where x.rank = 1

or

with cte as
(
select e.firstname||' '||e.lastname as employee_name, e.title as designation, count(1) as no_of_customers,
rank() over(order by count(1) desc) as rank
from employee e
join customer c on c.supportrepid = e.employeeid
group by employee_name, designation
) 
select employee_name, designation
from cte
where rank = 1

or 

select e.firstname||' '||e.lastname as employee_name, e.title as designation, count(1) as no_of_customers
from employee e
join customer c on c.supportrepid = e.employeeid
group by employee_name, designation
order by 3 desc
limit 1

4) Which city corresponds to the best customers?

select city, customer_expenses
from
(
select city, sum(total) as customer_expenses,
rank() over(order by sum(total) desc) as rank
from invoice i
join customer c on c.customerid = i.customerid
group by city
) x
where x.rank = 1

or

select city, customer_expenses
from
(
select i.billingcity as city, sum(il.unitprice) as customer_expenses,
rank() over(order by sum(il.unitprice) desc) as rank
from customer c
join invoice i on i.customerid = c.customerid
join invoiceline il on il.invoiceid = i.invoiceid
group by i.billingcity
) x
where x.rank = 1


5) The highest number of invoices belongs to which country?

select country, no_of_billings
from
(
select billingcountry as country, count(1) as no_of_billings,
rank() over(order by count(1) desc) as rank 
from invoice i
group by billingcountry
) x
where x.rank = 1

6) Name the best customer (customer who spent the most money)

select cust_name
from
(
select c.firstname||' '||c.lastname as cust_name, sum(total) as cust_expenses,
rank() over(order by sum(total) desc) as rank
from invoice i
join customer c on c.customerid = i.customerid
group by cust_name
) x
where x.rank = 1

or

with cte as
(
select billingcountry as country, count(1) as no_of_billings,
rank() over(order by count(1) desc) as rank 
from invoice i
group by billingcountry
) 
select country, no_of_billings
from cte
where rank = 1

or

select billingcountry as country, count(1) as no_of_billings
from invoice i
group by billingcountry
order by count(1) desc
limit 1

7) Suppose you want to host a rock concert in a city and want to know which location should host it.

select city
from
(
select c.city as city, count(1) as most_rock_fans,
rank() over(order by count(1) desc) as rank
from customer c
join invoice i on c.customerid = i.customerid
join invoiceline il on il.invoiceid = i.invoiceid
join track t on t.trackid = il.trackid
join genre g on g.genreid = t.genreid
where g.name = 'Rock'
group by city
) x
where x.rank = 1

or

select city
from
(
select billingcity as city, count(1) as most_rock_fans,
rank() over(order by count(1) desc) as rank
from invoice i 
join invoiceline il on il.invoiceid = i.invoiceid
join track t on t.trackid = il.trackid
join genre g on g.genreid = t.genreid
where g.name = 'Rock'
group by city
) x
where x.rank = 1


8) Identify all the albums who have less then 5 track under them.
Display the album name, artist name and the no of tracks in the respective album.

select alb.title as album_name, art.name as artist_name, count(1) as no_of_tracks
from artist art
join album alb on art.artistid = alb.artistid
join track t on t.albumid = alb.albumid
group by album_name, artist_name
having count(1) < 5
order by 3 desc


9) Display the track, album, artist and the genre for all tracks which are not purchased

select t.name as track_name, alb.title as album_name, art.name as artist_name, g.name as genre_name
from artist art
join album alb on art.artistid = alb.artistid
join track t on t.albumid = alb.albumid
join genre g on g.genreid = t.genreid
where trackid not in (select trackid from invoiceline)


10) Find artist who have performed in multiple genres. Diplay the aritst name and the genre

with temp as
(
select distinct art.name as artist_name, g.name as genre
from artist art
join album alb on alb.artistid = art.artistid
join track t on t.albumid = alb.albumid
join genre g on g.genreid = t.genreid
),
temp2 as
(
select artist_name, count(1) as no_genres
from temp
group by artist_name
having count(1) > 1
)
select t.*
from temp t
join temp2 t1 on t1.artist_name = t.artist_name
order by 1,2 desc


11) Which is the most popular and least popular genre?
Popularity is defined based on how many times it has been purchased.

with popular_genre as
(
select distinct g.name as genre,count(1) as no_of_purchases,
rank() over(order by count(1) desc) as rank        
from InvoiceLine il
join track t on t.trackid = il.trackid
join genre g on g.genreid = t.genreid
group by genre
order by 2 desc
),        
maximum_rank as
(
select max(rank) as max_rank from popular_genre
)
select genre,
case when rank = 1 then 'most popular' else 'least popular' end as popular
from popular_genre
cross join maximum_rank
where rank = 1 or rank = max_rank




12) Identify if there are tracks more expensive than others. If there are then
    display the track name along with the album title and artist name for these expensive tracks.

select t.name as track_name,alb.title as album_title, art.name as artist_name
from artist art
join album alb on alb.artistid = art.artistid
join track t on t.albumid = alb.albumid
where t.unitprice > (select min(unitprice) from invoiceline)

or

select t.name as track_name, al.title as album_name, art.name as artist_name
from Track t
join album al on al.albumid = t.albumid
join artist art on art.artistid = al.artistid
where unitprice > (select min(unitprice) from Track)


    
13) Identify the 5 most popular artist for the most popular genre.
    Popularity is defined based on how many songs an artist has performed in for the particular genre.
    Display the artist name along with the no of songs.
    [Reason: Now that we know that our customers love rock music, we can decide which musicians to invite to play at the concert.
    Lets invite the artists who have written the most rock music in our dataset.]

with popular_genre as 
(
select genre 
from
(
select distinct g.name as genre,count(1) as no_of_purchases,
rank() over(order by count(1) desc) as rank        
from InvoiceLine il
join track t on t.trackid = il.trackid
join genre g on g.genreid = t.genreid
group by genre
order by 2 desc
) x
where x.rank = 1
),
popular_artists as
(
select  art.name as artist_name, count(1) as no_of_songs,
rank() over(order by count(1) desc) as rank 
from artist art
join album alb on alb.artistid = art.artistid
join track t on t.albumid = alb.albumid
join genre g on g.genreid = t.genreid
where g.name in (select genre from popular_genre)
group by artist_name
)
select artist_name, no_of_songs
from
popular_artists
where rank <= 5

or

with popular_genre as 
(
select genre 
from
(
select distinct g.name as genre,count(1) as no_of_purchases,
rank() over(order by count(1) desc) as rank        
from InvoiceLine il
join track t on t.trackid = il.trackid
join genre g on g.genreid = t.genreid
group by genre
order by 2 desc
) x
where x.rank = 1
)
select  art.name as artist_name, count(1) as no_of_songs,
rank() over(order by count(1) desc) as rank 
from artist art
join album alb on alb.artistid = art.artistid
join track t on t.albumid = alb.albumid
join genre g on g.genreid = t.genreid
where g.name in (select genre from popular_genre)
group by artist_name
limit 5



14) Find the artist who has contributed with the maximum no of songs/tracks. 
Display the artist name and the no of songs.

select art.name as artist_name, count(1) as no_of_songs
from artist art
join album alb on alb.artistid = art.artistid
join track t on t.albumid = alb.albumid
group by artist_name
order by 2 desc
limit 1

or 

select artist_name, no_of_songs
from
(
select art.name as artist_name, count(1) as no_of_songs,
rank() over(order by count(1) desc) as rank
from artist art
join album alb on alb.artistid = art.artistid
join track t on t.albumid = alb.albumid
group by artist_name
) x
where x.rank = 1

or 

with cte as
(
select art.name as artist_name, count(1) as no_of_songs,
rank() over(order by count(1) desc) as rank
from artist art
join album alb on alb.artistid = art.artistid
join track t on t.albumid = alb.albumid
group by artist_name
)
select artist_name, no_of_songs
from cte
where rank = 1



15) Are there any albums owned by multiple artist?

select albumid, count(1) as no_of_albums 
from album
group by albumid
having count(1) > 1



16) Is there any invoice which is issued to a non existing customer?

select count(*) from invoice i
where customerid not in (select customerid from customer c)

or

select * from Invoice i
where not exists (select 1 from customer c 
                where c.customerid = i.customerid)


17) Is there any invoice line for a non existing invoice?

select count(*) from invoiceline il
where invoiceid not in (select invoiceid from invoice i)

or

select * from invoiceline il
where not exists (select 1 from invoice i
				 where i.invoiceid = il.invoiceid)


18) Are there albums without a title?

select count(title) from album
where title = 'null'

or

select count(*) from album
where title = 'null'



19) Are there invalid tracks in the playlist?

select count(*) from playlisttrack
where trackid not in (select trackid from track)

or

select count(*) from playlisttrack pt
where not exists (select 1 from track t
				 where pt.trackid = t.trackid)

