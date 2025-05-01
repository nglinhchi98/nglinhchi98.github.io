-- Displaying tables
SELECT * FROM Venue
SELECT * FROM Event
SELECT * FROM Event_Performer
SELECT * FROM Performer
SELECT * FROM Booking

--1. BOOKING TICKETS

--NON-EXISTING EVENT
INSERT INTO Booking (bookingDate, numberOfTickets, bookingStatus,phoneNumber,eventCode) VALUES
('2022-12-01', 2, 'U', '+358503039910', 'A12345')

-- FULL EVENT
INSERT INTO Booking (bookingDate, numberOfTickets, bookingStatus,phoneNumber,eventCode) VALUES		--CORRECT!!!
('2022-12-01', 900, 'U', '+358503039910', 'A1234')

-- NO PHONE NUMBER
INSERT INTO Booking (bookingDate, numberOfTickets, bookingStatus,phoneNumber,eventCode) VALUES
('2022-12-01', 2, 'U', NULL, 'A1234')

-- BOOKING CANCELLED EVENT
INSERT INTO Booking (bookingDate, numberOfTickets, bookingStatus,phoneNumber,eventCode) VALUES		--CORRECT!!!
('2022-12-01', 2, 'U', '+358503039910', 'A1234')

--2. CHANGING THE NUMBER OF TICKETS IN A BOOKING

-- WHEN UNPAID
UPDATE Booking 
SET numberOFTickets = 1 
WHERE bookingNumber = 1

--WHEN PAID																							--CORRECT!!
UPDATE Booking 
SET numberOFTickets = 1 
WHERE bookingNumber = 3

--3. CANCELLING TICKET
--WHEN EVENT IS CANCELLED
UPDATE Booking 
SET bookingStatus = 'C' 
WHERE bookingNumber = 1

--WHEN EVENT IS ONGOING																				--CORRECT!!
UPDATE Booking 
SET bookingStatus = 'C' 
WHERE bookingNumber = 3

--4. CHANING BOOKING STATUS TO PAID
UPDATE Booking 
SET bookingStatus = 'P' 
WHERE bookingNumber = 4

--5. REMOVE UNPURCHASED TICKETS 3 DAYS AFTER BOOKING
--WHEN CURRENT DATE = 1.12.2022
-- We use our function which should be automatically called every day to delete bookings who are older than 3 days.
DELETE 
	FROM Booking 
	WHERE (DATEDIFF(DAY, bookingDate, getDate()) <=3) AND bookingStatus = 'U'

INSERT INTO Booking (bookingDate, numberOfTickets, bookingStatus,phoneNumber,eventCode) VALUES
('2022-11-28', 2, 'U', '+358503039910', 'B1234')

DELETE
	FROM Booking
	WHERE bookingStatus = 'U' AND bookingDate IN (SELECT bookingDate FROM  Booking WHERE DATEDIFF(DAY, bookingDate,GETDATE()) = 3) 
	
SELECT * FROM Booking

--6. CANCELLING AN EVENT

--WITH WRONG EVENTCODE
UPDATE Event 
SET eventStatus = 'C' 
WHERE eventCode = 3

-- WITH CORRECT EVENT CODE
UPDATE Event 
SET eventStatus = 'C' 
WHERE eventCode = 'B1234'

--7. REFUND A CLIENT IN CASE OF CANCELLED EVENT
UPDATE Booking 
SET bookingStatus = 'R' 
WHERE bookingStatus IN (SELECT Event WHERE eventStatus = 'C')

--8. What is Ida Paul's contact email?
SELECT email
	FROM Performer 
	WHERE surname = 'Paul' AND firstName = 'Ida'

--9. What events are coming up this month?

-- ADD an event in december
INSERT INTO Event (eventCode, eventName, eventDate, price, eventStatus, venueName) VALUES 
('H7865', 'Ed Sheeran Concert', '2022-12-28', 130.00, 'A', 'Nokia Arena')

--ADD performer
INSERT INTO Performer(surname, firstName, phoneNumber, email, specialRequest) VALUES
('Sheeran', 'Ed', '+7550749378057', 'ed.sheeran@gmail.com', NULL)

--ADD performer to the event
INSERT INTO EVENT_PERFORMER (eventCode, performerId) VALUES
('H7865', 1002)

-- CHECK
USE GROUP_2_CASE_ASSIGNMENT
SELECT eventName
FROM Event
WHERE MONTH(eventDate) = MONTH(getDATE()) AND DAY(eventDate) > DAY(getDate())

--10. Where will Ed Sheeran's concert take place 2022-12-28
SELECT Event.venueName AS 'Venue for Ed Sheerans concert' --, Venue.address																		--We should add address to venue
	FROM Event
	JOIN Venue ON (Event.venueName = Venue.venueName)
	JOIN Event_Performer ON (Event.eventCode = Event_Performer.eventCode)
	JOIN Performer ON (Event_Performer.performerId = Performer.performerId)
	WHERE surname = 'Sheeran' AND firstname = 'Ed' AND eventDate = '2022-12-28'


--11. What dancing events are coming up this month?				
SELECT Venue.venueName --, Venue.address																		--We should add event type to event table or skip
	FROM Event
	JOIN Venue ON (Event.venueName = Venue.venueName)
	JOIN Event_Performer ON (Event.eventCode = Event_Performer.eventCode)
	JOIN Performer ON (Event_Performer.performerId = Performer.performerId)
	WHERE surname = 'Sheeran' AND firstname = 'Ed' AND DAY(eventDate) > DAY(getdate())


--12. Which artists will perform in the Eurovision 2023-01-01?
SELECT (Performer.surname + ' ' + Performer.firstName) AS 'Eurovision performers 2023-01-01'
FROM Performer
JOIN Event_Performer ON (Performer.performerId = Event_Performer.performerId)
JOIN Event ON (Event_Performer.eventCode = Event.eventCode)
WHERE eventName = 'Eurovision' AND eventDate = '2023-01-01'

--13. How many tickets are there left on the Ed Sheeran concert 2022-12-28?										//CHECK THIS!!

USE GROUP_2_CASE_ASSIGNMENT
SELECT (Venue.capacity- (SELECT SUM(numberOfTickets) FROM Booking WHERE eventCode='H7865'))
FROM Venue JOIN Event ON (Venue.venueName= Event.venueName)
WHERE eventCode='H7865'


SELECT eventCode
FROM Booking


--14. When will Nechayeva Elina perform and what are her special requests?
SELECT eventDate AS 'Date when Nechayeva Elina will perform', specialRequest
FROM Event
JOIN Event_Performer ON (Event.eventCode= Event_Performer.eventCode)
JOIN Performer ON (Event_Performer.performerId = Performer.performerId)
WHERE Performer.surname = 'Nechayeva' AND Performer.firstName = 'Elina'

--15. How many tickets have been sold this far to the Dancing festival 2023-07-23?
SELECT SUM(numberOfTickets) AS 'Number of tickets sold  for the Dancing festival 2023-07-23'
FROM Booking
JOIN  Event ON (Booking.eventCode = Event.eventCode)
WHERE event.eventName = 'Dancing festival' AND eventDate = '2023-07-23'

--16. How much money has Dingwall Society got from sold tickets this year?							
SELECT (SUM(numberOfTickets) * SUM(price)) AS 'Total income this year'
FROM Booking
JOIN Event ON(Booking.eventCode = Event.eventCode)
WHERE  YEAR(eventDate) = YEAR(getDate()) AND bookingStatus = 'P'
GROUP BY price



USE GROUP_2_CASE_ASSIGNMENT

SELECT numberOfTickets, eventCode, bookingStatus
FROM Booking
WHERE bookingStatus = 'P'




SELECT eventCode
FROM Booking


--17. Which artist has sold the highest number of tickets this year?
SELECT (firstName +' '+ surname) AS 'The most popular artist'
FROM Performer 
JOIN Event_Performer ON(Performer.performerId = Event_Performer.performerId) 
JOIN Booking ON( Event_Performer.eventCode = Booking.eventCode)
WHERE numberOfTickets = (SELECT MAX(numberOfTickets) FROM Booking)
--GROUP BY Performer.performerId 
--HAVING MAX(numberOfTickets)

SELECT numberOfTickets, eventCode
FROM Booking
WHERE eventCode='A1234'

--Phase two of testings!
USE GROUP_2_CASE_ASSIGNMENT

--1. BOOKING TICKETS


-- FULL EVENT
INSERT INTO Booking (bookingDate, numberOfTickets, bookingStatus,phoneNumber,eventCode) VALUES		--Still doesn't work (it was hard to do the function)
('2022-12-01', 900, 'U', '+358503039910', 'B1234')

-- BOOKING CANCELLED EVENT
INSERT INTO Booking (bookingDate, numberOfTickets, bookingStatus,phoneNumber,eventCode) VALUES		--Still doesn't work (checking with subquery wasn't allowed)
('2022-12-01', 2, 'U', '+358503039910', 'A1234')

--2. CHANGING THE NUMBER OF TICKETS IN A BOOKING
--WHEN PAID																							--Still doesn't work
UPDATE Booking 
SET numberOFTickets = 1 
WHERE bookingNumber = 3

--3. CANCELLING TICKET
--WHEN EVENT IS ONGOING																				--Still doesn't work
UPDATE Booking 
SET bookingStatus = 'R' 
WHERE bookingNumber = 3


