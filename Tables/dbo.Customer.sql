CREATE TABLE [dbo].[Customer]
(
[CustomerId] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Customer_CustomerId] DEFAULT (newsequentialid()),
[CustomerIntId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Addr1] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Addr2] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Addr3] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Addr4] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Postcode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryId] [smallint] NULL,
[Tel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_Customer_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_Customer_Archived] DEFAULT ((0)),
[OverSpeedValue] [int] NULL,
[OverSpeedPercent] [float] NULL,
[OverSpeedHighValue] [int] NULL,
[OverSpeedHighPercent] [float] NULL,
[DataDispatcher] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSSOEnabled] [bit] NULL CONSTRAINT [DF__Customer__IsSSOE__723D9313] DEFAULT ((0)),
[SSO_clientId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSO_clientSecret] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSO_directoryId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsIntentEnabled] [bit] NULL CONSTRAINT [DF__Customer__IsInte__19576034] DEFAULT ((0)),
[Intent_ClientId] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Customer] ADD CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED  ([CustomerId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Customer] ADD CONSTRAINT [UQ__Customer__CustomerIntId] UNIQUE NONCLUSTERED  ([CustomerIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
