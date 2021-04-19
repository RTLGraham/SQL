CREATE TABLE [dbo].[EventData]
(
[EventDataId] [bigint] NOT NULL,
[EventDataName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDataString] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDataInt] [int] NULL,
[EventDataFloat] [float] NULL,
[EventDataBit] [bit] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_EventData_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_EventData_Archived] DEFAULT ((0)),
[EventDateTime] [datetime] NULL,
[CreationCodeId] [smallint] NULL,
[CustomerIntId] [int] NOT NULL CONSTRAINT [DF_EventData_CustomerIntId] DEFAULT ((0)),
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[EventId] [bigint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trig_CFG_EventData] 
   ON  [dbo].[EventData]
   AFTER INSERT
AS 
BEGIN

-- Process any incoming Config data within the CFG subsystem		
INSERT INTO EventDataCopy
		SELECT	*
		FROM	inserted 
		WHERE	EventDataName IN (SELECT DISTINCT EventDataNamePrefix + CommandRoot + EventDatanameSuffix
								  FROM dbo.CFG_Command
								  INNER JOIN dbo.IVHType ON dbo.CFG_Command.IVHTypeId = dbo.IVHType.IVHTypeId)

END



GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trig_COMND_EventData] 
   ON  [dbo].[EventData]
   AFTER INSERT
AS 
BEGIN
		
	INSERT INTO dbo.EventDataVehicleCommand
	SELECT *
	FROM INSERTED
	WHERE EventDataName = '#COMND' 

END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trig_CopyFaultEventsData] 
   ON  [dbo].[EventData]
   AFTER INSERT
AS 
BEGIN
		
--INSERT INTO EventsDataCopy
--		SELECT	*
--		FROM	inserted 
--		WHERE	CreationCodeId IN (22,40,41)
---- Above filter list is:
---- 22 CAN_FAULT_ACT
---- 40 Enter Geo
---- 41 Exit Geo

---- Temp for broken Destination code
--INSERT INTO EventsDataCopy
--		SELECT	*
--		FROM	inserted 
--		WHERE	CreationCodeId IN (0,32) AND EventsDataName = 'DST'
---- Above filter list is:
---- Destination code entered (NB. reports add 2 eventsdata entries DST and DID)
---- 0 broken from old listener or cals
---- 32 destination code

--INSERT INTO windms_EventsDataCopy
--		--SELECT	distinct ed.*
--		--Added remove non ascii code to windms insert because we occasionally get non printing chars which right royally screw it up!
--		select distinct ed.EventsDataId,ed.EventsDataName,dbo.svf_removeNonASCII(ed.EventsDataString) as EventsDataString,
--			ed.EventsDataInt,ed.EventsDataFloat,ed.EventsDataBit,ed.LastOperation,ed.Archived,
--			ed.CreationCodeId,ed.DepotId,ed.EventId
--		FROM	inserted ed
--		inner join depotsvehicles e on ed.depotid = e.depotid
--		inner join vehicles v on e.vehicleid = v.vehicleid
--		inner join windms_trucksvehicles tv on tv.vehicleid = v.vehicleid and tv.ivhid = v.ivhid
--		WHERE	ed.CreationCodeId IN (40,41) and e.enddate is null
---- Above filter list is:
---- 40 Enter Geo
---- 41 Exit Geo

--INSERT INTO lw_EventsDataCopy
--		SELECT	*
--		FROM	inserted 
--		WHERE	CreationCodeId = 0 AND EventsDataName in ('LW0', 'LW1')
---- Above filter list is:
---- Driver Id provided in DataString
---- 0 creation code
---- LW0 Lone Worker Mode Off
---- LW1 Lone Worker Mode On

INSERT INTO dbo.MessagingEventData
        ( EventDataId ,
          EventDataName ,
          EventDataString ,
          EventDataInt ,
          EventDataFloat ,
          EventDataBit ,
          LastOperation ,
          Archived ,
          CreationCodeId ,
          CustomerIntId ,
          VehicleIntId ,
          driverIntId ,
          EventId
        )
SELECT	  EventDataId ,
          EventDataName ,
          EventDataString ,
          EventDataInt ,
          EventDataFloat ,
          EventDataBit ,
          LastOperation ,
          Archived ,
          CreationCodeId ,
          CustomerIntId ,
          VehicleIntId ,
          driverIntId ,
          EventId
FROM INSERTED
WHERE CreationCodeId = 110 AND EventDataName IN ('DMSGD', 'DMSGR')
-- Above filter list is:
-- Creation code is 110
-- DMSGD - Driver Stop / Geo message
-- DMSGR - Driver Response

END



GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trig_DNF_EventData] 
   ON  [dbo].[EventData]
   AFTER INSERT
AS 
BEGIN
		
-- Update the latest software version id on IVH table
	INSERT INTO dbo.DriverNotification
	        ( VehicleId ,
	          Status ,
	          LastOperation ,
	          Archived ,
	          UserId ,
	          CommandId ,
	          EventId ,
	          Long ,
	          Lat
	        )
	SELECT	v.VehicleId, 
			CASE inserted.CreationCodeId
				WHEN 120 THEN 15 --received
				WHEN 121 THEN 17 --acknowledged
				WHEN 122 THEN 16 --timeout
				ELSE 6 END,
			GETDATE(),
			0,
			NULL,
			NULL,
			INSERTED.EventId,
			e.Long,
			e.Lat 
	FROM INSERTED
		INNER JOIN dbo.Event e ON e.EventId = INSERTED.EventId AND e.VehicleIntId = INSERTED.VehicleIntId
		INNER JOIN dbo.Vehicle v ON inserted.VehicleIntId = v.VehicleIntId
		INNER JOIN IVH i ON v.IVHId = i.IVHId
	WHERE EventDataName = 'DNF'
	
	UPDATE dbo.VehicleLatestEvent
	SET AnalogIoAlertTypeId =	CASE INSERTED.CreationCodeId
								WHEN 120 THEN 15 --received
								WHEN 121 THEN 17 --acknowledged
								WHEN 122 THEN 16 --timeout
								ELSE 6 END
	FROM INSERTED							
	WHERE EventDataName = 'DNF'
		AND VehicleId = dbo.GetVehicleIdFromInt(INSERTED.VehicleIntId)
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trig_DriverLogin_EventData] 
   ON  [dbo].[EventData]
   AFTER INSERT
AS 
BEGIN
		
	INSERT INTO dbo.EventData_DriverLogin
	SELECT *
	FROM INSERTED
	WHERE EventDataName = 'DID'
	  AND CreationCodeId = 61
	  AND EventDataString != 'No ID' 

END


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Modified by GKP 5/1/16 to only update FirmwareVersion on IVH if it has changed, plus record the datetime of the change
-- =============================================
CREATE TRIGGER [dbo].[trig_DSW_EventData] 
   ON  [dbo].[EventData]
   AFTER INSERT
AS 
BEGIN

-- For Cheetah Units only update the date we upgraded past 1.4.147
	UPDATE dbo.IVH
	SET Firmware147Date = EventDateTime
	FROM INSERTED
	INNER JOIN dbo.Vehicle v ON inserted.VehicleIntId = v.VehicleIntId
	INNER JOIN IVH i ON v.IVHId = i.IVHId
	WHERE inserted.EventDataName = 'DSW'
		AND i.IVHTypeId = 5 -- Cheetah Only
		AND ISNULL(i.FirmwareVersion, '') != ISNULL(inserted.EventDataString, '')
		AND ((CAST(dbo.fnParseString(3,'.',i.FirmwareVersion) AS INT) < 147 AND CAST(dbo.fnParseString(2,'.',i.FirmwareVersion) AS INT) <= 4) OR i.FirmwareVersion IS NULL)
		AND ((CASE WHEN ISNUMERIC(dbo.fnParseString(3,'.',inserted.EventDataString) + '.e0') = 1 AND LEN(inserted.EventDataString) < 12 THEN CAST(dbo.fnParseString(3,'.',inserted.EventDataString) AS BIGINT) ELSE 0 END >= 147 
		AND CASE WHEN ISNUMERIC(dbo.fnParseString(2,'.',inserted.EventDataString) + '.e0') = 1 AND LEN(inserted.EventDataString) < 12 THEN CAST(dbo.fnParseString(2,'.',inserted.EventDataString) AS BIGINT) ELSE 0 END = 4) 
		 OR CASE WHEN ISNUMERIC(dbo.fnParseString(2,'.',inserted.EventDataString) + '.e0') = 1 AND LEN(inserted.EventDataString) < 12 THEN CAST(dbo.fnParseString(2,'.',inserted.EventDataString) AS BIGINT) ELSE 0 END > 4) -- firmware version >= 1.4.147	

-- Add update for Firmware147Date for the case where the date hasn't previously been set (e.g. pre-installed)
	UPDATE dbo.IVH
	SET Firmware147Date = GETUTCDATE()
	FROM INSERTED
	INNER JOIN dbo.Vehicle v ON inserted.VehicleIntId = v.VehicleIntId
	INNER JOIN IVH i ON v.IVHId = i.IVHId
	WHERE inserted.EventDataName = 'DSW'
	  AND IVHTypeId = 5 -- Cheetah only
	  AND Firmware147Date IS NULL
	  AND (CAST(dbo.fnParseString(3,'.',FirmwareVersion) AS INT) >= 147 OR CAST(dbo.fnParseString(2,'.',FirmwareVersion) AS INT) >= 5)
		
-- Update the latest software version and date on IVH table, if it has changed
	UPDATE dbo.IVH
	SET FirmwareVersion = EventDataString, FirmwareDate = EventDateTime
	FROM INSERTED
	INNER JOIN dbo.Vehicle v ON inserted.VehicleIntId = v.VehicleIntId
	INNER JOIN IVH i ON v.IVHId = i.IVHId
	WHERE EventDataName = 'DSW'
	  AND ISNULL(i.FirmwareVersion, '') != ISNULL(inserted.EventDataString, '')

-- Insert row for DSW processing for non-development Cheetah units
	INSERT INTO dbo.CFG_DSW_Vehicle (VehicleId, ProcessInd, LastOperation)
	SELECT v.VehicleId, 0, GETDATE()
	FROM INSERTED
	INNER JOIN dbo.Vehicle v ON INSERTED.VehicleIntId = v.VehicleIntId
	INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId AND cv.Archived = 0 AND cv.EndDate IS NULL
	INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
	INNER JOIN dbo.IVHType it ON i.IVHTypeId = it.IVHTypeId
	WHERE EventDataName = 'DSW' 
		AND it.IVHTypeId = 5 /*Cheetah only*/
		AND ISNULL(i.IsDev, 0) = 0

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <2013-09-09>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trig_ENGI_EventData] 
   ON  [dbo].[EventData]
   AFTER INSERT
AS 
BEGIN
		
-- Update the latest software version id on IVH table
	INSERT INTO dbo.StarterInhibit
	        ( VehicleId ,
	          Status ,
	          LastOperation ,
	          Archived ,
	          UserId ,
	          CommandId ,
	          EventId ,
	          Long ,
	          Lat
	        )
	SELECT	v.VehicleId, 
			CASE INSERTED.EventDataString
				WHEN 'ENGI,0' THEN 22 --not inhibited
				WHEN 'ENGI,1' THEN 21 --inhibited
				ELSE 23 END, 
			GETDATE(),
			0,
			NULL,
			NULL,
			INSERTED.EventId,
			e.Long,
			e.Lat 
	FROM INSERTED
		INNER JOIN dbo.Event e ON e.EventId = INSERTED.EventId AND e.VehicleIntId = INSERTED.VehicleIntId
		INNER JOIN dbo.Vehicle v ON inserted.VehicleIntId = v.VehicleIntId
		INNER JOIN IVH i ON v.IVHId = i.IVHId
	WHERE EventDataName = 'RES' AND EventDataString LIKE 'ENGI,%'
	
	UPDATE dbo.VehicleLatestEvent
	SET AnalogIoAlertTypeId = CASE INSERTED.EventDataString
				WHEN 'ENGI,0' THEN 22 --not inhibited
				WHEN 'ENGI,1' THEN 21 --inhibited
				ELSE 23 END
	FROM INSERTED							
	WHERE EventDataName = 'RES' AND EventDataString LIKE 'ENGI,%'
		AND VehicleId = dbo.GetVehicleIdFromInt(INSERTED.VehicleIntId)
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trig_Firmware_EventData] 
   ON  [dbo].[EventData]
   AFTER INSERT
AS 
BEGIN

-- Copy any incoming Firmware eventdataname data to a process table
INSERT INTO	dbo.EventDataVehicleFirmware
SELECT *
FROM INSERTED
WHERE EventDataName IN ('CFG', '+RTLF:', '+RTLW:', '+RTLV:', '+RTLK:', '+CTCD:', '+CTCE:')

END



GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trig_FMDL_EventData] 
   ON  [dbo].[EventData]
   AFTER INSERT
AS 
BEGIN

-- Copy any incoming Garmin Dawsons eventdata data to a process table
INSERT INTO	dbo.EventDataFMDL
SELECT *
FROM INSERTED
WHERE CreationCodeId IN (102, 103, 106, 107, 401)

END


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trig_JCM_EventData] 
   ON  [dbo].[EventData]
   AFTER INSERT
AS 
BEGIN

-- Copy any incoming Garmin Dawsons eventdata data to a process table
INSERT INTO	dbo.EventDataJCM
SELECT *
FROM INSERTED
WHERE CreationCodeId = 170
  AND EventDataName = 'GAR20'

END




GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trig_PassCount_EventData] 
   ON  [dbo].[EventData]
   AFTER INSERT
AS 
BEGIN

-- Copy any incoming Firmware eventdataname data to a process table
INSERT INTO	dbo.EventDataPassengerCount
SELECT *
FROM INSERTED
WHERE CreationCodeId = 46
  AND EventDataName = 'PDA'

END



GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trig_Tachograph_EventData] 
   ON  [dbo].[EventData]
   AFTER INSERT
AS 
BEGIN

-- Copy any incoming Garmin Dawsons eventdata data to a process table
INSERT INTO	dbo.EventDataTachograph
SELECT *
FROM INSERTED
WHERE CreationCodeId = 79
  AND Inserted.EventDataName = 'WRK'

END



GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ============================================================================================
-- Author:		Graham Pattison
-- Create date: 09/03/2011
-- Description:	Any EventsData rows with CreationCodeId matching TAN_TriggerType.CreationCodeId
--				will be inserted into TAN_TriggerEvent to be analysed by the TAN process.
-- ============================================================================================
CREATE TRIGGER [dbo].[trig_TAN_EventData] 
   ON  [dbo].[EventData]
   AFTER INSERT
AS 
BEGIN
		
INSERT INTO TAN_TriggerEvent (
				TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntId, DriverIntId, ApplicationId, 
				Long, Lat, Heading, Speed, TripDistance, DataName, DataString,
				DataInt, DataFloat, DataBit, TriggerDateTime, ProcessInd)
		SELECT	NEWID(), ed.CreationCodeId, ed.EventId, ed.CustomerIntId, ed.VehicleIntId, ed.DriverIntId, 1, 
				e.Long, e.Lat, e.Heading, e.Speed, e.OdoGPS, ed.EventDataname, ed.EventDataString,
				ed.EventDataInt, ed.EventDataFloat, ed.EventdataBit, e.EventDateTime, 0 
		FROM	inserted ed
		INNER JOIN Event e ON ed.EventId = e.EventId
		INNER JOIN TAN_TriggerType tt ON ed.CreationCodeId = tt.CreationCodeId AND tt.Archived = 0
		WHERE ed.CreationCodeId NOT IN (3,4,5,39,42,111,112,113,114,115,116,117,118,180,181,182,183,184,185,186,187)
		-- Any creation codes existing in TAN_TriggerType will cause an insert to TAN_TriggerEvent
		-- The exclusion list must complement the CreationCodeId list in proc_TAN_ProcessEvents to avoid duplication

END

















GO
ALTER TABLE [dbo].[EventData] ADD CONSTRAINT [PK_EventData] PRIMARY KEY CLUSTERED  ([EventDataId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EventData_DriverDate] ON [dbo].[EventData] ([DriverIntId], [EventDateTime], [EventDataName]) INCLUDE ([EventDataString], [CreationCodeId], [VehicleIntId], [EventId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EventsData_EventId] ON [dbo].[EventData] ([EventId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EventsData_VehicleIntId_EventDateTime] ON [dbo].[EventData] ([VehicleIntId], [EventDateTime]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EventData_VhcDateName] ON [dbo].[EventData] ([VehicleIntId], [EventDateTime], [EventDataName]) INCLUDE ([EventDataString], [CreationCodeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EventsData_VehicleIntId_LastOperation] ON [dbo].[EventData] ([VehicleIntId], [LastOperation]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
