 INSERT INTO Venue(venueName, capacity, address) VALUES
('Nokia Arena',800, 'Helsinki'),
('Paasitorni', 200, NULL),
('Ravintola Sade', 50, NULL) 



INSERT INTO Event (eventCode, eventName, eventDate, price, eventStatus, venueName, eventType) VALUES 
('A1234', 'Eurovision', '2023-01-01', 87.99, 'C', 'Nokia Arena', 'Music'),
('B1234', 'Dancing festival', '2023-07-23', 59.99, 'A', 'Paasitorni', 'Dance'),
('C6790', 'Stand up comics', '2023-02-09', 29.99, 'F', 'Ravintola Sade', 'Comedy')

INSERT INTO Performer(surname, firstName, phoneNumber, email, specialRequest) VALUES
('Paul', 'Ida', '+358406790764', 'ida.paul@gmail.com', NULL),
('Nechayeva', 'Elina', '+35854689733', 'elina.nechayeva@gmail.com', 'Champange'),
('Barzilai', 'Netta', '+9726667678', 'netta.Baezilai@hotmail.com', NULL),
('Jahangiri', 'Ali','+3587676779', 'ali_jahangiri@hotmail.com', NULL),
('Gatica', 'Melvin', '+75305068493', 'melvin.gatica@outlook.com', 'Vegan')

INSERT INTO EVENT_PERFORMER (eventCode, performerId) VALUES
('A1234', 1),
('A1234', 2),
('A1234', 3),
('B1234', 5),
('C6790',4)
USE GROUP_2_CASE_ASSIGNMENT

INSERT INTO Booking (bookingDate, numberOfTickets, bookingStatus,phoneNumber,eventCode) VALUES
('2022-12-28', 5, 'P', '+358965357899', 'C6790'),
('2022-11-28', 2, 'U', '+358503039910', 'B1234'),
('2022-12-10', 1, 'U', '+3585030783927', 'B1234'),
('2022-11-01', 2, 'P', '+358503045789', 'C6790'),
('2022-12-12', 4, 'U', '+358588934088', 'B1234')

DELETE FROM Booking
DELETE FROM Event_Performer
DELETE FROM Event
DELETE FROM Venue





