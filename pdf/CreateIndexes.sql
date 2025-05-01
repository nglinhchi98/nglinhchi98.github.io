-- Creating indexes
USE GROUP_2_CASE_ASSIGNMENT

CREATE INDEX eventCode
ON Booking(eventCode)

CREATE INDEX venueName
ON Event(venueName)

CREATE INDEX eventCode
ON Event_Performer(eventCode)

CREATE INDEX performerId
ON Event_Performer(performerId)