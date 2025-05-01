USE GROUP_2_CASE_ASSIGNMENT
CREATE TABLE Venue 

( 

venueName VARCHAR (15) NOT NULL, 

capacity INTEGER NOT NULL CHECK(capacity IN(50, 200, 800)), 

CONSTRAINT PK_Venue PRIMARY KEY(venueName) 

) 

-- Adding after first test
ALTER TABLE Venue
ADD address VARCHAR(50)


CREATE TABLE Performer 

( 

performerId INTEGER NOT NULL IDENTITY, 

surname VARCHAR(20) NOT NULL, 

firstName VARCHAR(20) NOT NULL, 

phoneNumber VARCHAR(15) NOT NULL UNIQUE, 

email VARCHAR(50) NOT NULL UNIQUE, 

specialRequest VARCHAR(150) , 

CONSTRAINT PK_Performer PRIMARY KEY(performerId) 

) 
CREATE TABLE Event 
( 
eventCode VARCHAR(15) NOT NULL, 

eventName VARCHAR(100) NOT NULL, 

eventDate DATE NOT NULL, 

price FLOAT NOT NULL, 

eventStatus CHAR(1) NOT NULL CHECK(eventStatus IN('A', 'F', 'C')), 

venueName VARCHAR(15) NOT NULL, 

CONSTRAINT PK_Event PRIMARY KEY(eventCode), 

CONSTRAINT FK_Event_Venue FOREIGN KEY(venueName) REFERENCES Venue(venueName) 

) 

-- Adding after first test
ALTER TABLE Event
ADD eventType VARCHAR(20) NOT NULL

CREATE TABLE Booking 
( 
bookingNumber INTEGER NOT NULL IDENTITY, 

bookingDate DATE NOT NULL, 

numberOfTickets INTEGER NOT NULL, 

bookingStatus CHAR(1) NOT NULL CHECK(bookingStatus IN('P', 'U', 'R')), 

phoneNumber VARCHAR(15) NOT NULL, 

eventCode VARCHAR(15) NOT NULL, 

CONSTRAINT PK_Booking PRIMARY KEY(bookingNumber), 

CONSTRAINT FK_Booking_Event FOREIGN KEY(eventCode) REFERENCES Event(eventCode), 
--Constraint with which only cancelled events can be refunded. Doesnt work but we tried. 
--Error: Subqueries are not allowed in this context. Only scalar expressions are allowed.
CONSTRAINT CHK_Refund  CHECK (eventStatus IN(SELECT eventStatus CASE WHEN eventStatus = 'C' THEN bookingStatus = 'R' END FROM Event JOIN Booking ON (Event.eventCode = Booking.eventCode)),
-- Constraint with which only bookings for ongoing events can be made. Same error
CONSTRAINT CHK_EventStaus CHECK(eventStatus IN(SELECT eventStatus FROM Event WHERE eventStatus = 'A')),
) 

--Add changing ticket constraint only allowed when booking is unpaid
ALTER TABLE BOOKING ADD CONSTRAINT CHK_Ticket ON UPDATE( CHECK(bookingStatus = 'U') )

--Function which should be automatically called every day to delete bookings who are older than 3 days.
DELETE 
	FROM Booking 
	WHERE (DATEDIFF(DAY, bookingDate, getDate()) <=3) AND bookingStatus = 'U'

--Function with which only cancelled events can be refunded - doesn't work, but if it did we could use it in the constraint
CREATE FUNCTION refund (bookingStatus('R'))
RETURNS VARCHAR(5)
AS
BEGIN
	IF EXISTS (SELECT * FROM Event WHERE eventStatus = 'C')
		RETURN 'True'
	RETURN 'False'
END


--Added after first testing
DROP TABLE Booking --Then we edited the code in creating booking table above. 

ALTER TABLE Booking
REPLACE FUNCTION CheckTickets (Booking)
RETURNS boolean
 (numberOfTickets <= 
	((SELECT (Venue.capacity- 
		(SELECT SUM(numberOfTickets) FROM Booking ))FROM Venue JOIN Event ON (Venue.venueName= Event.venueName)GROUP BY eventCode))
-- Booking tickets should be less/equal than the venue capacity and already booked tickets

SELECT SUM(numberOfTickets), eventCode
FROM Booking
GROUP BY eventCode


USE GROUP_2_CASE_ASSIGNMENT																								--DROP AND CREATE CHECK  constraint
ALTER TABLE Booking DROP CONSTRAINT  bookingStatus

USE GROUP_2_CASE_ASSIGNMENT
ALTER TABLE Booking ADD CONSTRAINT CHK_BookingStatus CHECK (bookingStatus IN('P', 'U', 'R'))


  
CREATE TABLE Event_Performer
(
eventCode VARCHAR(15) NOT NULL,
performerId INTEGER NOT NULL,
CONSTRAINT PK_Event_Performer PRIMARY KEY(eventCode, performerId),
CONSTRAINT FK_Event_Performer1 FOREIGN KEY(eventCode) REFERENCES Event(eventCode),
CONSTRAINT FK_Event_Performer2 FOREIGN KEY(performerId) REFERENCES Performer(performerId)
)


  





  

 