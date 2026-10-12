alter table orders ADD CONSTRAINT CustomerID  foreign key (CustomerID) references customers(CustomerID);
alter table orders ADD CONSTRAINT ProductID  foreign key (ProductID) references products(ProductID);


    WITH productsales AS (
    SELECT 
        p.Category,
        p.ProductName,
        SUM(o.Quantity * p.SellingPrice * (1 - o.DiscountPct)) AS TotalSales,
        DENSE_RANK() OVER (
            PARTITION BY p.Category 
            ORDER BY SUM(o.Quantity * p.SellingPrice * (1 - o.DiscountPct)) DESC
        ) AS CategoryRank
    FROM Orders o
    JOIN Products p ON o.ProductID = p.ProductID
    GROUP BY p.Category, p.ProductName
)
SELECT 
    Category,
    ProductName,
    ROUND(TotalSales, 2) AS TotalSales,
    CategoryRank
FROM productsales
WHERE CategoryRank <= 3
ORDER BY Category, CategoryRank;

WITH CustomerOrderCounts AS (
    
    SELECT 
        c.CustomerID,
        COUNT(o.OrderID) AS TotalOrders
    FROM Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
    GROUP BY c.CustomerID
),
CustomerSegments AS (
    
    SELECT 
        CustomerID,
        TotalOrders,
        CASE 
            WHEN TotalOrders = 0 THEN 'Never Purchased'
            WHEN TotalOrders = 1 THEN 'One-Time Buyer'
            ELSE 'Repeat Buyer'
        END AS BuyerType
    FROM CustomerOrderCounts
)

SELECT 
    BuyerType,
    COUNT(CustomerID) AS TotalCustomers

FROM CustomerSegments
GROUP BY BuyerType
ORDER BY TotalCustomers DESC;

ALTER TABLE dbo.[calendar]
ALTER COLUMN [Date] DATE NOT NULL;

ALTER TABLE calendar ADD CONSTRAINT pk_date PRIMARY KEY([Date]);
ALTER TABLE orders ADD CONSTRAINT OrderDate FOREIGN KEY (OrderDate) REFERENCES calendar([Date]);
select year(c.[Date]) as order_year,month(c.[Date]) as order_moth,sum(o.Quantity*p.SellingPrice*(1-DiscountPct)) as total_sales from orders o join calendar c on o.[OrderDate]=c.[Date] join products p
on o.ProductID=p.ProductID group by year(c.[Date]),Month(c.[Date]) order by year(c.[Date]);