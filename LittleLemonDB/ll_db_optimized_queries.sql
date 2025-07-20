DELIMITER //

CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT MAX(Quantity) AS 'Max Quantity in Order' 
    FROM Orders;
END //

DELIMITER ;

-- To call the procedure:
CALL GetMaxQuantity();

-- Prepare the statement
PREPARE GetOrderDetail FROM '
    SELECT OrderID, Quantity, TotalCost 
    FROM Orders 
    WHERE CustomerID = ?';

-- Set the variable and execute
SET @id = 1;
EXECUTE GetOrderDetail USING @id;

-- (Optional) To deallocate the prepared statement when done)
-- DEALLOCATE PREPARE GetOrderDetail;

DELIMITER //

CREATE PROCEDURE CancelOrder(IN order_id INT)
BEGIN
    -- Declare a variable to check if order exists
    DECLARE order_exists INT DEFAULT 0;
    
    -- Check if the order exists
    SELECT COUNT(*) INTO order_exists 
    FROM Orders 
    WHERE OrderID = order_id;
    
    -- If order exists, delete it and return confirmation
    IF order_exists > 0 THEN
        DELETE FROM Orders WHERE OrderID = order_id;
        SELECT CONCAT('Order ', order_id, ' is cancelled') AS Confirmation;
    ELSE
        SELECT CONCAT('Order ', order_id, ' not found') AS Confirmation;
    END IF;
END //

DELIMITER ;

-- To call the procedure (example with order ID 5):
CALL CancelOrder(5);
