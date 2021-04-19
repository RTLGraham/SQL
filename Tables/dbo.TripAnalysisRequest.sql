CREATE TABLE [dbo].[TripAnalysisRequest]
(
[TripAnalysisRequestID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [uniqueidentifier] NOT NULL,
[Name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RequestDate] [datetime] NOT NULL,
[ExecutionStartDate] [datetime] NULL,
[CompletionDate] [datetime] NULL,
[Status] [smallint] NOT NULL CONSTRAINT [DF_TripAnalysisRequest_Status] DEFAULT ((1)),
[GeofenceGroupID] [uniqueidentifier] NOT NULL,
[VehicleGroupID] [uniqueidentifier] NOT NULL,
[BaseGeofenceID] [uniqueidentifier] NOT NULL,
[StartDate] [datetime] NOT NULL,
[EndDate] [datetime] NOT NULL,
[LastOperation] [datetime] NOT NULL CONSTRAINT [DF_TripAnalysisRequest_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_TripAnalysisRequest_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripAnalysisRequest] ADD CONSTRAINT [PK_TripAnalysisRequest] PRIMARY KEY NONCLUSTERED  ([TripAnalysisRequestID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripAnalysisRequest] WITH NOCHECK ADD CONSTRAINT [FK_TripAnalysisRequest_Status] FOREIGN KEY ([Status]) REFERENCES [dbo].[TripAnalysisStatus] ([TripAnalysisStatusId])
GO
