CREATE TABLE [dbo].[DriverMobileActivity]
(
[DriverMobileActivityId] [int] NOT NULL IDENTITY(1, 1),
[DriverId] [uniqueidentifier] NOT NULL,
[StoredProcedure] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[GuidParam] [uniqueidentifier] NULL,
[IntParam] [int] NULL,
[StringParam] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExecutionDateTime] [datetime] NOT NULL CONSTRAINT [DF__DriverMob__Execu__1DE70B27] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DriverMobileActivity] ADD CONSTRAINT [PK_DriverMobileActivity] PRIMARY KEY CLUSTERED  ([DriverMobileActivityId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
