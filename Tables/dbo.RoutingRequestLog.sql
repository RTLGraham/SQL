CREATE TABLE [dbo].[RoutingRequestLog]
(
[RoutingRequestLogId] [bigint] NOT NULL IDENTITY(1, 1),
[MapProvider] [int] NOT NULL,
[UserId] [uniqueidentifier] NOT NULL,
[BatchId] [uniqueidentifier] NOT NULL,
[VehicleId] [uniqueidentifier] NOT NULL,
[StartLat] [float] NULL,
[StartLon] [float] NULL,
[EndLat] [float] NULL,
[EndLon] [float] NULL,
[Heading] [int] NULL,
[IsTruck] [bit] NULL,
[ResultLocations] [int] NULL,
[ExecutionTimeMs] [int] NULL,
[Error] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorInternal] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RoutingRequestLog] ADD CONSTRAINT [PK_RoutingRequestLog] PRIMARY KEY CLUSTERED  ([RoutingRequestLogId]) WITH (IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
