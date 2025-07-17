
-- Task 1: Create OrdersView Virtual Table: 
-- Create a virtual table (view) for orders with quantity > 2
CREATE OR REPLACE VIEW OrdersView AS
SELECT 
    OrderID, 
    Quantity, 
    TotalCost AS Cost
FROM 
    Orders
WHERE 
    Quantity > 2;
    
SELECT * FROM OrdersView;

-- Task 2: JOIN Query for High-Value Orders (>$30)

SELECT 
    c.CustomerID,
    c.FullName,
    o.OrderID,
    o.TotalCost AS Cost,
    m.MenuName,
    mi.CourseName,
    mi.StarterName
FROM 
    Customers c
JOIN 
    Orders o ON c.CustomerID = o.CustomerID
JOIN 
    Menus m ON o.MenuID = m.MenuID
JOIN 
    MenuItems mi ON m.MenuID = mi.MenuID
WHERE 
    o.TotalCost > 150
ORDER BY 
    o.TotalCost ASC;
    
-- Task 3: Subquery for Popular Menu Items
SELECT 
    m.MenuName
FROM 
    Menus m
WHERE 
    m.MenuID = ANY (
        SELECT 
            o.MenuID 
        FROM 
            Orders o 
        WHERE 
            o.Quantity > 2
    );