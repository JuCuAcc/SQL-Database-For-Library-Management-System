Use master
IF DB_ID('LibraryDatabase') IS NOT NULL
DROP Database LibraryDatabase
GO
-- Cration of database named "LibraryDatabase" with custom properties and default database location.
Use master
DECLARE @location_path nvarchar(255);
SET @location_path = (SELECT SUBSTRING(physical_name, 1, CHARINDEX(N'master.mdf', LOWER(physical_name)) - 1)
      FROM master.sys.master_files
      WHERE database_id = 1 AND file_id = 1);
EXECUTE ('CREATE DATABASE LibraryDatabase
ON PRIMARY(NAME = LibraryDatabase_data, FILENAME = ''' + @location_path + 'LibraryDatabase_data.mdf'', SIZE = 12MB, MAXSIZE = 128MB, FILEGROWTH = 2MB)
LOG ON (NAME = LibraryDatabase_log, FILENAME = ''' + @location_path + 'LibraryDatabase_log.ldf'', SIZE = 10MB, MAXSIZE = 100MB, FILEGROWTH = 1MB)'
);
GO

Use LibraryDatabase
ALTER DATABASE LibraryDatabase MODIFY FILE(Name='LibraryDatabase_data', Size=16MB, MaxSize=512MB, FileGrowth=5%);
GO
ALTER DATABASE LibraryDatabase MODIFY FILE(Name='LibraryDatabase_log', Size=12MB, MaxSize=128MB, FileGrowth=2MB);
GO

--Table Creation

-- Creating BookCategories table

Use LibraryDatabase
CREATE TABLE BookCategories
(
  CategoryID	int NOT NULL PRIMARY KEY,
  Category		varchar(30) NOT NULL
); 
GO
-- Creating Books table

CREATE TABLE Books
(
  BookID		int PRIMARY KEY IDENTITY(100,1) ,
  Title			varchar(100) NOT NULL,
  Author		varchar(120) NOT NULL,
  Description	varchar(140) SPARSE NULL,
  CategoryID	int	FOREIGN KEY REFERENCES BookCategories(CategoryID) ON DELETE SET NULL,
  AddedTime		datetime NOT NULL DEFAULT GETDATE()
); 
GO
--Creating Members table
CREATE TABLE Members
(
	MemberID	int NOT NULL PRIMARY KEY IDENTITY(500,1) ,
	MemberName	varchar(30) NOT NULL,
	MemberStatus varchar(15) -- Student Or Teacher
);
GO
-- Creating Groups table

CREATE TABLE StudentGroup
(
  GroupID		int	PRIMARY KEY,
  GroupName		varchar(15)  NOT NULL
);
GO
-- Creating Students table

CREATE TABLE Students
(
  StudentID		int PRIMARY KEY IDENTITY,
  GroupID		int FOREIGN KEY REFERENCES StudentGroup(GroupID) ON DELETE SET NULL,
  MemberID		int FOREIGN KEY REFERENCES Members(MemberID) ON DELETE CASCADE,
  StudentName	varchar(30) NOT NULL,
  Gender		nvarchar(1) NOT NULL,--'M' for male and 'F' for female
  Email			varchar(50) NOT NULL CHECK (Email LIKE '%@%')
);
GO

CREATE TABLE Teachers
(
  TeacherID		int PRIMARY KEY IDENTITY,
  MemberID		int FOREIGN KEY REFERENCES Members(MemberID) ON DELETE CASCADE,
  TeacherName	varchar(30) NOT NULL,
  Gender		nvarchar(1) NOT NULL, --'M' for male and 'F' for female
  PhoneNumber	varchar(15) NOT NULL CHECK(PhoneNumber LIKE '01%' ),
  Email			varchar(50) NOT NULL CHECK (Email LIKE '%@%')
);

GO
--Creating Liberian table
CREATE TABLE Liberian
(
	 LiberianID		int PRIMARY KEY,
	 LiberianName	varchar(30)

);
GO
-- Creating BookIssue table

CREATE TABLE BookIssue 
(
  IssueID			int PRIMARY KEY IDENTITY,
  BookID			int FOREIGN KEY REFERENCES Books(BookID),
  MemberID			int FOREIGN KEY REFERENCES Members(MemberID),
  IssuedTime		date NOT NULL DEFAULT CURRENT_TIMESTAMP,
  LiberianID		int FOREIGN KEY REFERENCES Liberian(LiberianID)
);
GO
--Creating ReservedBook table
CREATE TABLE ReservedBook
(
	  CategoryID		int FOREIGN KEY REFERENCES BookCategories(CategoryID),
	  AddedTime			date NOT NULL DEFAULT CURRENT_TIMESTAMP,
	  NumberOfBooks		int NOT NULL default 0 
);
GO
--Creating BookIssueLog table

CREATE TABLE BookIssueLog
(
  ID				int,
  MemberID			int FOREIGN KEY REFERENCES Members(MemberID), 
  IssueID			int FOREIGN KEY REFERENCES BookIssue(IssueID),
  IssuedTime		date	NOT NULL, 
  ReturnTime		date	DEFAULT SYSDATETIME()
);
GO
CREATE TABLE FineRecords
(
	 MemberID		int FOREIGN KEY REFERENCES Members(MemberID) ON DELETE CASCADE,
	 StudentID		int SPARSE NULL FOREIGN KEY REFERENCES Students(StudentID),
	 TeacherID		int SPARSE NULL FOREIGN KEY REFERENCES Teachers(TeacherID),
	 FineAmount		money default 0

);
GO
--##Temporary Table Variable##
--Temporary Table variable will run under one batch

DECLARE @TempBook TABLE
(
	TempBookID			 int PRIMARY KEY IDENTITY(30,1) ,
	TempBookTitle		 varchar(100) NOT NULL,
	TempBookAuthor		 varchar(100) NOT NULL,
	TempBookAddedTime	 datetime NULL DEFAULT GETDATE()
)

INSERT INTO @TempBook VALUES('Current News', 'Jashim Uddin',NULL)
SELECT * FROM @TempBook 

GO 

--Local Table

CREATE TABLE #LocalBook
(
		LocalBookID		int PRIMARY KEY IDENTITY,
		LocalBookName	varchar(100)  SPARSE NULL
);

INSERT INTO #LocalBook VALUES('Current Affairs');
SELECT * From #LocalBook
GO
--Global Table

CREATE TABLE ##GlobalBook
(
	GlobalBookID		int PRIMARY KEY IDENTITY,
	GlobalBookName		varchar(100)  SPARSE NULL
);
INSERT INTO ##GlobalBook VALUES('Current Affairs');

SELECT * FROM ##GlobalBook 
GO

TRUNCATE TABLE ##GlobalBook --We can reuse deleted identity with the Keyword 
DELETE ##GlobalBook -- This command will delete all the values within the ##GlobalBook table
DROP TABLE ##GlobalBook --This Command completely delete the ##GlobalBook table
GO
