CREATE TABLE [dbo].[Driver]
(
[DriverId] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Driver_DriverId] DEFAULT (newsequentialid()),
[DriverIntId] [int] NOT NULL IDENTITY(1, 1),
[Number] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumberAlternate] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumberAlternate2] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleNames] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_Driver_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_Driver_Archived] DEFAULT ((0)),
[LanguageCultureId] [smallint] NULL CONSTRAINT [DF_Driver_Language] DEFAULT ((1)),
[LicenceNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssuingAuthority] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LicenceExpiry] [smalldatetime] NULL,
[MedicalCertExpiry] [smalldatetime] NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlayInd] [bit] NULL,
[DriverType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmpNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsADSyncDisabled] [bit] NULL CONSTRAINT [DF__Driver__IsADSync__7331B74C] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Driver] ADD CONSTRAINT [PK_Driver] PRIMARY KEY CLUSTERED  ([DriverId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Driver] ADD CONSTRAINT [UQ__Driver__DriverIntId] UNIQUE NONCLUSTERED  ([DriverIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Driver_DriverIntId] ON [dbo].[Driver] ([DriverIntId]) INCLUDE ([DriverId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Driver_Number] ON [dbo].[Driver] ([Number]) INCLUDE ([Archived], [DriverId], [DriverIntId], [LastOperation]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Driver_NumberAlternate] ON [dbo].[Driver] ([NumberAlternate]) INCLUDE ([Archived], [DriverId], [DriverIntId], [LastOperation]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Driver_NumberAlternate2] ON [dbo].[Driver] ([NumberAlternate2]) INCLUDE ([Archived], [DriverId], [DriverIntId], [LastOperation]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Driver_Surname] ON [dbo].[Driver] ([Surname]) INCLUDE ([Number], [NumberAlternate], [NumberAlternate2], [Password], [DriverId], [FirstName]) ON [PRIMARY]
GO
