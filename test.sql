--#### Schemas

--```sql
CREATE TABLE artists
(
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks
(
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales
(
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists
    (artist_id, name, country, birth_year)
VALUES
    (1, 'Vincent van Gogh', 'Netherlands', 1853),
    (2, 'Pablo Picasso', 'Spain', 1881),
    (3, 'Leonardo da Vinci', 'Italy', 1452),
    (4, 'Claude Monet', 'France', 1840),
    (5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks
    (artwork_id, title, artist_id, genre, price)
VALUES
    (1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
    (2, 'Guernica', 2, 'Cubism', 2000000.00),
    (3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
    (4, 'Water Lilies', 4, 'Impressionism', 500000.00),
    (5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales
    (sale_id, artwork_id, sale_date, quantity, total_amount)
VALUES
    (1, 1, '2024-01-15', 1, 1000000.00),
    (2, 2, '2024-02-10', 1, 2000000.00),
    (3, 3, '2024-03-05', 1, 3000000.00),
    (4, 4, '2024-04-20', 2, 1000000.00)



----### Section 1: 1 mark each

----1. Write a query to display the artist names in uppercase.
SELECT upper("name") as Name_In_Capitals
from artists

----2. Write a query to find the total amount of sales for the artwork 'Mona Lisa'.

SELECT sum(total_amount) as total
FROM artworks
    JOIN sales ON artworks.artwork_id=sales.artwork_id
where sales.artwork_id=3

----3. Write a query to calculate the price of 'Starry Night' plus 10% tax.

SELECT sum(price +(price*0.1)) as price_tax
from artworks
where title='Starry Night'

----4. Write a query to extract the year from the sale date of 'Guernica'.

SELECT artworks.title, DATEPART(year,sale_date) as yearr
from sales
    JOIN artworks ON sales.artwork_id=artworks.artwork_id
where sales.artwork_id =2

----### Section 2: 2 marks each

----5. Write a query to display artists who have artworks in multiple genres.

SELECT "name"
FROM artworks
    JOIN artists ON artworks.artist_id=artists.artist_id
group by artworks.artwork_id,"name"
having count(genre)>1


--6. Write a query to find the artworks that have the highest sale total for each genre.

GO
with
    cte_topartworks
    as
    (
        SELECT title,
            Rank() over (partition by genre order by total_amount) as rankk
        FROM artworks
            left JOIN sales ON artworks.artwork_id=sales.artwork_id
    )
SELECT *
FROM cte_topartworks
where rankk=1
GO


--7. Write a query to find the average price of artworks for each artist.

SELECT artworks.artist_id
, avg(price) as avg_price
from artworks
    JOIN artists ON artworks.artist_id=artists.artist_id
group by artworks.artist_id


--8. Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.

SELECT top(2)
    rank() over (order by price desc) as top_artworks, title, quantity
from artworks
    JOIN sales ON artworks.artwork_id=sales.artwork_id


--9. Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.

SELECT "name"
from artists
    JOIN artworks ON artists.artist_id=artworks.artist_id
    JOIN sales ON artworks.artwork_id=sales.artwork_id
group by artworks.artist_id
having count(sale_id) >(SELECT count(sale_id) as countt
from sales
group by artwork_id
having avg(countt))


--10. Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.

SELECT "name"
from artists a
where birth_year < all  (select avg(birth_year)
from artists
group by country)


--11. Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.

    SELECT "name"
    FROM artists
        JOIN artworks ON artists.artist_id=artworks.artist_id
    where genre='Cubism'
INTERSECT
    SELECT "name"
    FROM artists
        JOIN artworks ON artists.artist_id=artworks.artist_id
    where genre='Surrealism'


--12. Write a query to find the artworks that have been sold in both January and February 2024.

SELECT *
FROM artworks
SELECT *
FROM sales

SELECT title
from artworks
    LEFT JOIN sales ON artworks.artwork_id=sales.artwork_id
where sale_date='2024-01-15' and sale_date='2024-02-10'

--13. Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.

SELECT "name"
from artists
    JOIN artworks ON artists.artist_id=artworks.artist_id
group by artworks.artist_id,"name"
having avg(price) > (Select price
from artworks
where genre='Renaissance')


--14. Write a query to rank artists by their total sales amount and display the top 3 artists.


SELECT TOP(3)
    "name",
    rank() over (order by total_amount desc)  as rankk
from artists
    left JOIN artworks ON artists.artist_id=artworks.artist_id
    left JOIN sales ON artworks.artwork_id=sales.artwork_id

--15. Write a query to create a non-clustered index on the `sales` table to improve query performance for queries filtering by `artwork_id`.

CREATE INDEX ix_sales
ON sales(artwork_id)

--### Section 3: 3 Marks Questions

--16.  Write a query to find the average price of artworks for each artist and only include artists whose average artwork price is higher than the overall average artwork price.

SELECT "name"
from artworks
    JOIN artists ON artworks.artist_id=artists.artist_id
group by artworks.artist_id,"name"
having avg(price) > (SELECT avg(price)
from artworks)

--17.  Write a query to create a view that shows artists who have created artworks in multiple genres.

GO
CREATE VIEW vw_artworksinmultiplegenres
as
    (
    SELECT "name", count(genre) as genres
    from artists
        JOIN artworks ON artists.artist_id=artworks.artist_id
    group by artworks.artist_id,"name"
    having count(genre)>1
)
GO
SELECT *
FROM vw_artworksinmultiplegenres
--18.  Write a query to find artworks that have a higher price than the average price of artworks by the same artist.

SELECT title
from artworks
    JOIN artists ON artworks.artist_id=artists .artist_id
where artworks.artist_id




--### Section 4: 4 Marks Questions

--19.  Write a query to convert the artists and their artworks into JSON format.

SELECT
    "name" as [artwork.artist_name],
    title as [artwork.artwork_title]
from artists
    JOIN artworks ON artists.artist_id=artworks.artist_id
FOR JSON path,root('Artists')

    --20.  Write a query to export the artists and their artworks into XML format.

    SELECT
        artists.artist_id as [@ArtistID],
        "name" as [artwork/artist_name],
        title as [artwork/artwork_title]
    from artists
        JOIN artworks ON artists.artist_id=artworks.artist_id
    FOR XML path('Artists'),root('Artists')



        --#### Section 5: 5 Marks Questions

        --21. Create a stored procedure to add a new sale and update the total sales for the artwork. Ensure the quantity is positive, and use transactions to maintain data integrity.

        SELECT *
        FROM artworks

GO
        create Procedure AddSaleAndUpdateTotalsales(
            @artwork_id Int,
            @title varchar(30),
            @artist_id Int,
            @genre varchar(30),
            @price Int
        )
        AS
        Begin

            if @price<=0  
throw 60000, 'Price should be positive value', 1;
            DECLARE @currentAvg DECIMAL(10,2);
            DECLARE @AvgPrice DECIMAL(10,2);


            Begin Transaction ;
            Insert Into artworks
                (artwork_id,title,artist_id,genre,price)
            values
                (@artwork_id, @title , @artist_id , @genre, @price )

            select sum(price)
            from artworks
            where artist_id=@artist_id;

            commit transaction;
            BEGIN TRY
UPDATE sales
set total_amount=quantity*@price
end try
Begin Catch
RollBack Transaction;
End Catch
        End
go
        EXEC AddSaleAndUpdateTotalsales
        ( @artwork_id=6, @title ='Star',@artist_id=5,@genre ='fantasy',@price =4000000.00



        --22. Create a multi-statement table-valued function (MTVF) to return the total quantity sold for each genre and use it in a query to display the results.

        CREATE FUNCTION dbo.total()
returns @total_quant
        (@total_quantity decimal
        (10,2) @genre nvarchar
        (30))
as
        begin
            declare @quant DECIMAL(10,2)
            SELECT @quant=quantity
            from artworks
                JOIN sales ON artworks.artwork_id=sales.artwork_id
            where @genre=genre
            return @quant 


--23. Create a scalar function to calculate the average sales amount for artworks in a given genre and write a query to use this function for 'Impressionism'.

GO
        CREATE FUNCTION dbo.avgsales(@genre nvarchar(max))
returns decimal(10,2)
as
begin
            declare @avg_salesamount decimal(10,2)
            SELECT @avg_salesamount=avg(total_amount)
            from artworks
                left JOIN sales ON artworks.artwork_id=sales.artwork_id
            where @genre=genre
            group by sales.artwork_id
            return @avg_salesamount
        end
GO

        SELECT dbo.avgsales('Impressionism')



        --24. Create a trigger to log changes to the `artworks` table into an `artworks_log` table, capturing the `artwork_id`, `title`, and a change description.
        CREATE TRIGGER tg_artworks
ON artworks

        --25. Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.


        SELECT *, ntile(4) as groups
        FROM sales
        case
	when total_amount < 1000000 then 'Below 1Lakh',
	when total_amount between 1000000 and 2000000 then 'between 1 lakh and 2 lakh',
	when total amount between 2000000 and 3000000 then 'between 2 lakh and 3 lakh',
	when total_amount > 3000000 then 'Above 3 Lakh'


        SELECT *
        FROM sales

        --### Normalization (5 Marks)

        --26. **Question:**
        --    Given the denormalized table `ecommerce_data` with sample data:

        --| id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
        --| --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
        --| 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
        --| 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
        --| 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
        --| 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

        --Normalize this table into 3NF (Third Normal Form). Specify all primary keys, foreign key constraints, unique constraints, not null constraints, and check constraints.



        CREATE TABLE Customers
        (
            ID Int primary key identity(1,1),
            customer_name nvarchar(30) not null,
            customer_email nvarchar(30) not null
        )

        CREATE TABLE Products
        (
            Product_iD Int primary key identity(1,1),
            product_name nvarchar(30) not null,
            product_category nvarchar(30) not null,
            product_price decimal(10,2)
        )
        CREATE TABLE Orders
        (
            Order_id Int primary key identity(1,1),
            order_date date not null,
            order_quantity int not null,
            order_total_amount decimal(10,2) not null
        )
        CREATE TABLE all_ids(
	id int primary key,
	ID int foreign key constraint references Customers,
	Product_iD int foreign key constraint references Products,
	Order_id int foreign key constraint references Orders
)

--### ER Diagram (5 Marks)

--27. Using the normalized tables from Question 27, create an ER diagram. Include the entities, relationships, primary keys, foreign keys, unique constraints, not null constraints, and check constraints. Indicate the associations using proper ER diagram notation.
