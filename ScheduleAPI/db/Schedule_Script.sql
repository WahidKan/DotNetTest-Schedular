
USE [schedule]
GO
/****** Object:  Table [dbo].[Schedule]    Script Date: 10/5/2022 1:44:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Schedule](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NULL,
	[Name] [varchar](500) NULL,
	[StartTime] [time](7) NULL,
	[EndTime] [time](7) NULL,
	[Date] [date] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [date] NULL,
	[Isdeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Slots]    Script Date: 10/5/2022 1:44:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Slots](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ScheduleId] [int] NULL,
	[Name] [varchar](500) NULL,
	[StartTime] [time](7) NULL,
	[EndTime] [time](7) NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [date] NULL,
	[Isdeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[User]    Script Date: 10/5/2022 1:44:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[Email] [varchar](100) NULL,
	[Password] [varchar](100) NULL,
	[CreatedOn] [date] NULL,
	[CreatedBy] [int] NULL,
	[Isdeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Schedule] ON 

INSERT [dbo].[Schedule] ([Id], [UserId], [Name], [StartTime], [EndTime], [Date], [CreatedBy], [CreatedOn], [Isdeleted]) VALUES (3, 1, N'Chat Shift', CAST(N'12:00:00' AS Time), CAST(N'18:00:00' AS Time), CAST(N'2022-10-05' AS Date), 1, CAST(N'2022-10-05' AS Date), 0)
SET IDENTITY_INSERT [dbo].[Schedule] OFF
GO
SET IDENTITY_INSERT [dbo].[Slots] ON 

INSERT [dbo].[Slots] ([Id], [ScheduleId], [Name], [StartTime], [EndTime], [CreatedBy], [CreatedOn], [Isdeleted]) VALUES (1, 3, N'Break', CAST(N'13:30:00' AS Time), CAST(N'13:45:00' AS Time), 1, CAST(N'2022-10-05' AS Date), 0)
INSERT [dbo].[Slots] ([Id], [ScheduleId], [Name], [StartTime], [EndTime], [CreatedBy], [CreatedOn], [Isdeleted]) VALUES (2, 3, N'Break', CAST(N'15:15:00' AS Time), CAST(N'15:30:00' AS Time), 1, CAST(N'2022-10-05' AS Date), 0)
INSERT [dbo].[Slots] ([Id], [ScheduleId], [Name], [StartTime], [EndTime], [CreatedBy], [CreatedOn], [Isdeleted]) VALUES (3, 3, N'Leave', CAST(N'17:00:00' AS Time), CAST(N'18:00:00' AS Time), 1, CAST(N'2022-10-05' AS Date), 0)
SET IDENTITY_INSERT [dbo].[Slots] OFF
GO
SET IDENTITY_INSERT [dbo].[User] ON 

INSERT [dbo].[User] ([Id], [Name], [Email], [Password], [CreatedOn], [CreatedBy], [Isdeleted]) VALUES (1, N'Asif', N'asif@gmail.com', N'######', CAST(N'2022-05-10' AS Date), 1, 0)
SET IDENTITY_INSERT [dbo].[User] OFF
GO
ALTER TABLE [dbo].[Schedule]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Slots]  WITH CHECK ADD FOREIGN KEY([ScheduleId])
REFERENCES [dbo].[Schedule] ([Id])
GO
/****** Object:  StoredProcedure [dbo].[Schedule_Get]    Script Date: 10/5/2022 1:44:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Schedule_Get] 
@ScheduleDate DATETIME
AS
BEGIN
	

DECLARE @TODAYSDATE DATE =FORMAT(@ScheduleDate,'yyyy-MM-dd')


CREATE TABLE #FLAT_SCHEDULE(PersonName VARCHAR(300),ScheduleTitle VARCHAR(100),[Date] date,StartTime time(7),EndTime time(7))

SELECT   ROW_NUMBER() Over (Order by s.Id) As [Sno],s.*,u.Name AS Person
into #Schedule from [dbo].[Schedule] s INNER JOIN [dbo].[User] u  ON u.Id=s.UserId WHERE [Date]=@TODAYSDATE;


DECLARE @ScheduleCount INT=0,@ScheduleInitCount INT=1;

SELECT @ScheduleCount=COUNT(*) FROM #Schedule;

while(@ScheduleCount>=@ScheduleInitCount)
BEGIN
DECLARE @Id INT=0,@ScheduleName VARCHAR(500)='',@PersonName VARCHAR(500)='';

SELECT @Id=Id,@ScheduleName=Name,@PersonName=Person FROM #Schedule WHERE Sno=@ScheduleInitCount;

SELECT   ROW_NUMBER() Over (Order by StartTime) As [Sno],*
into #ScheduleSlot from [dbo].[Slots] WHERE ScheduleId=@Id ORDER BY Sno;

DECLARE @SlotCount INT=0,@SlotInitCount INT=1;


SELECT @SlotCount=COUNT(*) FROM #ScheduleSlot;

DECLARE @StartTime TIME(7)=NULL,@EndTime TIME(7)=NULL;

while(@SlotCount >= @SlotInitCount)
BEGIN
	if(@SlotInitCount=1)
	BEGIN
		SELECT @StartTime=StartTime FROM #Schedule WHERE Sno=@ScheduleInitCount;
		SELECT @EndTime=StartTime FROM #ScheduleSlot WHERE Sno=@SlotInitCount;
	
	END

	IF(@SlotInitCount=@SlotCount)
	BEGIN
	
	SELECT @StartTime=EndTime FROM #ScheduleSlot WHERE Sno=(@SlotInitCount-1);
	SELECT @EndTime=StartTime FROM #ScheduleSlot WHERE Sno=(@SlotInitCount);
	END

	IF((NOT(@SlotInitCount=1)) AND  (NOT(@SlotInitCount=@SlotCount)))
	BEGIN
	
	SELECT @StartTime=EndTime FROM #ScheduleSlot WHERE Sno=(@SlotInitCount-1);
	SELECT @EndTime=StartTime FROM #ScheduleSlot WHERE Sno=@SlotInitCount;
	
	END

	IF(NOT(@StartTime IS NULL) AND NOT (@EndTime IS NULL))
	BEGIN
	INSERT INTO #FLAT_SCHEDULE(PersonName,ScheduleTitle,[Date],StartTime,EndTime)
	VALUES(@PersonName,@ScheduleName,@TODAYSDATE,@StartTime,@EndTime);

	INSERT INTO #FLAT_SCHEDULE(PersonName,ScheduleTitle,[Date],StartTime,EndTime)
	SELECT @PersonName,Name,@TODAYSDATE,StartTime,EndTime FROM #ScheduleSlot WHERE Sno=@SlotInitCount;

	SET @StartTime=null;
	SET @EndTime=null;
	END
	
	SET @SlotInitCount+=1;
END
DROP TABLE #ScheduleSlot;

SET @ScheduleInitCount+=1;
END

SELECT * FROM #FLAT_SCHEDULE;

DROP TABLE #Schedule
DROP TABLE #FLAT_SCHEDULE;

END
GO

