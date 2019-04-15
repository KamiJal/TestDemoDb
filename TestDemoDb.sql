---------------PLEASE, launch CREATEs and INSERTs of TABLEs separately from CREATE PROCEDUREs to avoid errors---------------


---------------TABLE CREATION---------------
--CREATE DATABASE test_demo_db;--


USE test_demo_db;

---------------TABLE CREATION---------------
CREATE TABLE RequestTypes (
Id INT NOT NULL IDENTITY(1, 1),
Name NVARCHAR(255) NOT NULL,

CONSTRAINT PK_RequestTypes PRIMARY KEY (Id),
CONSTRAINT UQ_RequestTypes_Name UNIQUE (Name)
);

CREATE TABLE Requests (
Id INT NOT NULL IDENTITY(1, 1),
Name NVARCHAR(255) NOT NULL,
DescriptionInfo NVARCHAR(1024),
PostedDate DATETIME DEFAULT GETDATE(),
RequestTypeId INT NOT NULL,

CONSTRAINT PK_Requests PRIMARY KEY (Id),
CONSTRAINT FK_Requests_RequestTypes FOREIGN KEY (RequestTypeId) REFERENCES RequestTypes(Id)
);

CREATE TABLE DeveloperSpecializations (
Id INT NOT NULL IDENTITY(1, 1),
Name NVARCHAR(255) NOT NULL,

CONSTRAINT PK_DeveloperSpecializations PRIMARY KEY (Id),
CONSTRAINT UQ_DeveloperSpecializations_Name UNIQUE (Name)
);

CREATE TABLE DeveloperLevels (
Id INT NOT NULL IDENTITY(1, 1),
Name NVARCHAR(255) NOT NULL,

CONSTRAINT PK_DeveloperLevels PRIMARY KEY (Id),
CONSTRAINT UQ_DeveloperLevels_Name UNIQUE (Name)
);

CREATE TABLE Developers (
Id INT NOT NULL IDENTITY(1, 1),
Name NVARCHAR(255) NOT NULL,
SpecializationId INT NOT NULL,
LevelId INT NOT NULL,

CONSTRAINT PK_Developers PRIMARY KEY (Id),
CONSTRAINT FK_Developers_DeveloperSpecializations FOREIGN KEY (SpecializationId) REFERENCES DeveloperSpecializations(Id),
CONSTRAINT FK_Developers_DeveloperLevels FOREIGN KEY (LevelId) REFERENCES DeveloperLevels(Id)
);

CREATE TABLE Statuses (
Id INT NOT NULL IDENTITY(1, 1),
Name NVARCHAR(255) NOT NULL,
CONSTRAINT PK_Statuses PRIMARY KEY (Id),
CONSTRAINT UQ_Statuses_Name UNIQUE (Name)
);

CREATE TABLE Backlog (
Id INT NOT NULL IDENTITY(1, 1),
DescriptionInfo NVARCHAR(1024) NOT NULL,
PostedDate DATETIME DEFAULT GETDATE(),
DeadlineDate DATETIME,
RequestId INT NOT NULL,
DeveloperId INT NOT NULL,
StatusId INT NOT NULL,

CONSTRAINT PK_Backlog PRIMARY KEY (Id),
CONSTRAINT FK_Backlog_Requests FOREIGN KEY (RequestId) REFERENCES Requests(Id),
CONSTRAINT FK_Backlog_Developers FOREIGN KEY (DeveloperId) REFERENCES Developers(Id)
);


---------------TABLE INSERTION---------------

INSERT INTO RequestTypes (Name) VALUES ('add'), ('modify'), ('bug fixing');
INSERT INTO DeveloperSpecializations (Name) VALUES ('frontend'), ('backend'), ('db'), ('tester');
INSERT INTO DeveloperLevels (Name) VALUES ('junior'), ('mid'), ('senior');
INSERT INTO Statuses (Name) VALUES ('developing'), ('canceled'), ('done');

INSERT INTO Developers (Name, SpecializationId, LevelId) VALUES ('John Doe', 1, 2);
INSERT INTO Developers (Name, SpecializationId, LevelId) VALUES ('Jane Doe', 2, 3);
INSERT INTO Developers (Name, SpecializationId, LevelId) VALUES ('John Smith', 3, 1);
INSERT INTO Developers (Name, SpecializationId, LevelId) VALUES ('Jane Smith', 4, 2);

INSERT INTO Requests (Name, DescriptionInfo, RequestTypeId) 
VALUES ('Change available char length of some db of some table of some field', null, 2);
INSERT INTO Requests (Name, DescriptionInfo, RequestTypeId) 
VALUES ('Expected local time', 'Some application sets UTC time instead of local', 3);
INSERT INTO Requests (Name, DescriptionInfo, RequestTypeId) 
VALUES ('Add flight booking', 'Some app needs to add flight bookings before generating list of hotels', 1);
INSERT INTO Requests (Name, DescriptionInfo, RequestTypeId) 
VALUES ('Change app design', 'Some company made rebranding', 2);
INSERT INTO Requests (Name, DescriptionInfo, RequestTypeId) 
VALUES ('Some app has to send confirmation email', null, 1);

INSERT INTO Backlog (DescriptionInfo, PostedDate, DeadlineDate, RequestId, DeveloperId, StatusId) 
VALUES ('Change available char length to 255 of some field', DATEADD(dd,-50, GETDATE()), DATEADD(dd,-49, GETDATE()), 1, 3, 2);

INSERT INTO Backlog (DescriptionInfo, PostedDate, DeadlineDate, RequestId, DeveloperId, StatusId) 
VALUES ('Fix local time', DATEADD(dd,-45, GETDATE()), DATEADD(dd,-40, GETDATE()), 2, 2, 3);
INSERT INTO Backlog (DescriptionInfo, PostedDate, DeadlineDate, RequestId, DeveloperId, StatusId) 
VALUES ('Test fixed local time', DATEADD(dd,-45, GETDATE()), DATEADD(dd,-38, GETDATE()), 2, 4, 3);

INSERT INTO Backlog (DescriptionInfo, DeadlineDate, RequestId, DeveloperId, StatusId) 
VALUES ('Design flight booking form', DATEADD(dd, 5, GETDATE()), 3, 1, 1);
INSERT INTO Backlog (DescriptionInfo, DeadlineDate, RequestId, DeveloperId, StatusId) 
VALUES ('Add flight booking service', DATEADD(dd, 10, GETDATE()), 3, 2, 1);
INSERT INTO Backlog (DescriptionInfo, DeadlineDate, RequestId, DeveloperId, StatusId) 
VALUES ('Add table for flight booking service', DATEADD(dd, 3, GETDATE()), 3, 3, 1);
INSERT INTO Backlog (DescriptionInfo, DeadlineDate, RequestId, DeveloperId, StatusId) 
VALUES ('Test flight booking service', DATEADD(dd, 12, GETDATE()), 3, 4, 1);

INSERT INTO Backlog (DescriptionInfo, DeadlineDate, RequestId, DeveloperId, StatusId) 
VALUES ('Change app design', DATEADD(dd, 10, GETDATE()), 4, 1, 1);
INSERT INTO Backlog (DescriptionInfo, DeadlineDate, RequestId, DeveloperId, StatusId) 
VALUES ('Test changed app design', DATEADD(dd, 12, GETDATE()), 4, 4, 1);

INSERT INTO Backlog (DescriptionInfo, DeadlineDate, RequestId, DeveloperId, StatusId) 
VALUES ('Develop mail service', DATEADD(dd, 5, GETDATE()), 5, 2, 1);
INSERT INTO Backlog (DescriptionInfo, DeadlineDate, RequestId, DeveloperId, StatusId) 
VALUES ('Test mail service', DATEADD(dd, 7, GETDATE()), 5, 4, 1);


---------------PROCEDURES CREATION---------------

CREATE PROCEDURE getAllRequestsByDeveloperId
	@Id INT
AS   
	SELECT dv.Name, ds.Name AS 'Specialization', dl.Name AS 'Level', rq.Name AS 'Request descripiton', 
	rt.Name AS 'Request type'
	FROM Backlog AS bl
	JOIN Requests AS rq
	ON bl.RequestId = rq.Id
	JOIN Developers AS dv
	ON bl.DeveloperId = dv.Id
	JOIN RequestTypes AS rt
	ON rq.RequestTypeId = rt.Id
	JOIN DeveloperSpecializations AS ds
	ON dv.SpecializationId = ds.Id
	JOIN DeveloperLevels AS dl
	ON dv.LevelId = dl.Id
	WHERE dv.Id = @Id;
GO

CREATE PROCEDURE getAllBacklogsByDeveloperId
	@Id INT
AS   
	SELECT dv.Name 'Developer Name', rq.Name AS 'Request descripiton', bl.DescriptionInfo AS 'Backlog Description', 
	bl.PostedDate AS 'Backlog Posted Date', bl.DeadlineDate AS 'Backlog Deadline', st.Name AS 'Backlog Status'
	FROM Backlog AS bl
	JOIN Requests AS rq
	ON bl.RequestId = rq.Id
	JOIN Developers AS dv
	ON bl.DeveloperId = dv.Id
	JOIN Statuses AS st
	ON bl.StatusId = st.Id
	WHERE dv.Id = 2;
GO

CREATE PROCEDURE getRequestCountByRequestType
AS   
	SELECT rt.Name AS 'Request Type', COUNT(rq.id) AS 'Request Count'
	FROM Requests AS rq
	JOIN RequestTypes AS rt
	ON rq.RequestTypeId = rt.Id
	GROUP BY rt.Name;
GO


---------------PROCEDURES EXECUTION---------------

EXEC getAllRequestsByDeveloperId 4;
EXEC getAllBacklogsByDeveloperId 2;
EXEC getRequestCountByRequestType;