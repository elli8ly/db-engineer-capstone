-- Clear and repopulate Bookings table
USE LittleLemonDB;
TRUNCATE TABLE Bookings;

INSERT INTO Bookings (BookingID, Date, TableNumber, CustomerID) VALUES
(1, '2023-01-15', 5, 1),
(2, '2023-01-18', 3, 1),
(3, '2023-01-22', 2, 1),
(4, '2023-01-15', 3, 2),
(5, '2023-01-20', 7, 2),
(6, '2023-01-16', 7, 3),
(7, '2023-01-24', 4, 3),
(8, '2023-01-17', 2, 4),
(9, '2023-01-18', 8, 5),
(10, '2023-01-25', 1, 5),
(11, '2023-01-19', 4, 6),
(12, '2023-01-20', 6, 7),
(13, '2023-01-23', 9, 7),
(14, '2023-01-21', 1, 8),
(15, '2023-01-22', 9, 9),
(16, '2023-01-24', 5, 9),
(17, '2023-01-23', 10, 10),
(18, '2023-01-24', 5, 11),
(19, '2023-01-25', 3, 12),
(20, '2023-01-16', 8, 12);

-- CheckBooking Procedure
DELIMITER //

DROP PROCEDURE IF EXISTS CheckBooking//
CREATE PROCEDURE CheckBooking(
    IN booking_date DATE, 
    IN table_number INT
)
BEGIN
    DECLARE table_status VARCHAR(50);
    
    IF EXISTS (
        SELECT 1 FROM Bookings 
        WHERE Date = booking_date AND TableNumber = table_number
    ) THEN
        SET table_status = CONCAT('Table ', table_number, ' is already booked on ', booking_date);
    ELSE
        SET table_status = CONCAT('Table ', table_number, ' is available on ', booking_date);
    END IF;
    
    SELECT table_status AS 'Booking Status';
END//

-- AddValidBooking Procedure

DROP PROCEDURE IF EXISTS AddValidBooking//
CREATE PROCEDURE AddValidBooking(
    IN booking_date DATE,
    IN table_number INT,
    IN customer_id INT
)
BEGIN
    DECLARE is_booked INT DEFAULT 0;
    DECLARE booking_status VARCHAR(100);
    
    START TRANSACTION;
    
    SELECT COUNT(*) INTO is_booked
    FROM Bookings
    WHERE Date = booking_date AND TableNumber = table_number;
    
    IF is_booked = 0 THEN
        INSERT INTO Bookings (Date, TableNumber, CustomerID)
        VALUES (booking_date, table_number, customer_id);
        SET booking_status = CONCAT('Table ', table_number, ' booked successfully for ', booking_date);
        COMMIT;
    ELSE
        SET booking_status = CONCAT('Table ', table_number, ' is already booked - booking cancelled');
        ROLLBACK;
    END IF;
    
    SELECT booking_status AS 'Booking Status';
END//

DELIMITER ;

-- Test the procedures
-- View all current bookings
SELECT * FROM Bookings ORDER BY Date, TableNumber;

-- Test edge cases
-- Try to book an available table
CALL AddValidBooking('2023-01-27', 2, 3);

-- Verify the new booking exists
SELECT * FROM Bookings WHERE Date = '2023-01-27';

-- Try to double-book the same table
CALL AddValidBooking('2023-01-27', 2, 5);

USE LittleLemonDB;

-- AddBooking Procedure
DELIMITER //

DROP PROCEDURE IF EXISTS AddBooking//

CREATE PROCEDURE AddBooking(
    IN p_customer_id INT,
    IN p_booking_date DATE,
    IN p_table_number INT
)
BEGIN
    DECLARE table_booked INT DEFAULT 0;
    DECLARE new_booking_id INT;
    
    -- Check if table is already booked
    SELECT COUNT(*) INTO table_booked
    FROM Bookings
    WHERE Date = p_booking_date AND TableNumber = p_table_number;
    
    -- Get the next available booking ID (handles empty table case)
    SELECT IFNULL(MAX(BookingID), 0) + 1 INTO new_booking_id
    FROM Bookings;
    
    -- Insert new booking if table is available
    IF table_booked = 0 THEN
        INSERT INTO Bookings (BookingID, Date, TableNumber, CustomerID)
        VALUES (new_booking_id, p_booking_date, p_table_number, p_customer_id);
        SELECT CONCAT('Booking ', new_booking_id, ' added successfully') AS 'Confirmation';
    ELSE
        SELECT CONCAT('Table ', p_table_number, ' is already booked - reservation not added') AS 'Confirmation';
    END IF;
END//

DELIMITER ;

-- UpdateBooking Procedure
DELIMITER //

-- First drop the procedure if it exists
DROP PROCEDURE IF EXISTS UpdateBooking//

-- Then create the new version
CREATE PROCEDURE UpdateBooking(
    IN p_booking_id INT,
    IN p_new_booking_date DATE
)
BEGIN
    DECLARE booking_exists INT DEFAULT 0;
    
    -- Check if booking exists
    SELECT COUNT(*) INTO booking_exists
    FROM Bookings
    WHERE BookingID = p_booking_id;
    
    -- Update booking if it exists
    IF booking_exists > 0 THEN
        UPDATE Bookings
        SET Date = p_new_booking_date
        WHERE BookingID = p_booking_id;
        SELECT CONCAT('Booking ', p_booking_id, ' updated successfully') AS 'Confirmation';
    ELSE
        SELECT CONCAT('Booking ', p_booking_id, ' not found') AS 'Confirmation';
    END IF;
END//

DELIMITER ;

-- CancelBooking Procedure
DELIMITER //

-- First drop the procedure if it exists
DROP PROCEDURE IF EXISTS CancelBooking//

CREATE PROCEDURE CancelBooking(
    IN p_booking_id INT
)
BEGIN
    DECLARE booking_exists INT DEFAULT 0;
    
    -- Check if booking exists
    SELECT COUNT(*) INTO booking_exists
    FROM Bookings
    WHERE BookingID = p_booking_id;
    
    -- Delete booking if it exists
    IF booking_exists > 0 THEN
        DELETE FROM Bookings
        WHERE BookingID = p_booking_id;
        SELECT CONCAT('Booking ', p_booking_id, ' cancelled successfully') AS 'Confirmation';
    ELSE
        SELECT CONCAT('Booking ', p_booking_id, ' not found') AS 'Confirmation';
    END IF;
END //

DELIMITER ;

-- Test AddBooking
CALL AddBooking(5, '2023-02-14', 4);  -- Should succeed
CALL AddBooking(3, '2023-01-15', 5);  -- Should fail (table already booked)

-- Test UpdateBooking
CALL UpdateBooking(21, '2023-02-15');  -- Should succeed
CALL UpdateBooking(99, '2023-02-15');  -- Should fail (booking doesn't exist)

-- Test CancelBooking
CALL CancelBooking(21);  -- Should succeed
CALL CancelBooking(99);  -- Should fail (booking doesn't exist)

-- Verify all changes
SELECT * FROM Bookings ORDER BY Date;
