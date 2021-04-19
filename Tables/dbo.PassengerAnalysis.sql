CREATE TABLE [dbo].[PassengerAnalysis]
(
[PassengerAnalysisId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleId] [uniqueidentifier] NOT NULL,
[RouteId] [int] NOT NULL,
[RouteStartDateTime] [smalldatetime] NULL,
[Leg1Passengers] [int] NULL,
[Leg2Passengers] [int] NULL,
[Leg3Passengers] [int] NULL,
[RoutePassengers] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PassengerAnalysis] ADD CONSTRAINT [PK_PassengerAnalysis] PRIMARY KEY CLUSTERED  ([PassengerAnalysisId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PassengerAnalysis] WITH NOCHECK ADD CONSTRAINT [FK_PassengerAnalysis_RouteId] FOREIGN KEY ([RouteId]) REFERENCES [dbo].[Route] ([RouteID])
GO
ALTER TABLE [dbo].[PassengerAnalysis] WITH NOCHECK ADD CONSTRAINT [FK_PassengerAnalysis_VehicleId] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
