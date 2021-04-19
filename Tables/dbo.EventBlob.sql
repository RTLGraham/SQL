CREATE TABLE [dbo].[EventBlob]
(
[EventBlobId] [bigint] NOT NULL,
[EventId] [bigint] NOT NULL,
[CustomerIntId] [int] NULL CONSTRAINT [DF_EventBlob_CustomerIntId] DEFAULT ((0)),
[EventDateTime] [datetime] NOT NULL,
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[CreationCodeId] [smallint] NULL,
[SeverityId] [smallint] NULL,
[Blob] [varbinary] (max) NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_EventBlob_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_EventBlob_Archived] DEFAULT ((0))
) ON [PRIMARY]
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
CREATE TRIGGER [dbo].[trig_TAN_EventBlob] ON [dbo].[EventBlob]
    AFTER INSERT
AS
    BEGIN
		
        INSERT  INTO dbo.TAN_TriggerEvent
                ( TriggerEventId ,
                  CreationCodeId ,
                  EventId ,
                  CustomerIntId ,
                  VehicleIntID ,
                  DriverIntId ,
                  ApplicationId ,
                  Long ,
                  Lat ,
                  Heading ,
                  Speed ,
                  TripDistance ,
                  TriggerDateTime ,
                  ProcessInd ,
                  DataString
                  --DataName ,
                  --DataInt ,
                  --DataFloat ,
                  --DataBit ,
                  --LastOperation ,
                  --GeofenceId
                )
                SELECT  NEWID(),
                        eb.CreationCodeId,
                        eb.EventId,
                        eb.CustomerIntId,
                        eb.VehicleIntId,
                        eb.DriverIntId,
                        2,
                        e.Long,
                        e.Lat,
                        e.Heading,
                        e.Speed,
                        e.OdoGPS,
                        eb.EventDateTime,
                        0,
                        dbo.GetBlobDescription(eb.Blob)
                FROM    inserted eb
                        INNER JOIN Event e ON eb.CustomerIntId = e.CustomerIntId
                                               AND eb.EventId = e.EventId
                        INNER JOIN TAN_TriggerType tt ON eb.CreationCodeId = tt.CreationCodeId
		-- Any creation codes existing in TAN_TriggerType will cause an insert to TAN_TriggerEvent

    END













GO
ALTER TABLE [dbo].[EventBlob] ADD CONSTRAINT [PK_EventBlob] PRIMARY KEY CLUSTERED  ([EventBlobId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
