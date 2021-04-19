CREATE TABLE [dbo].[SiteImportDetail]
(
[SiteImportDetailId] [bigint] NOT NULL IDENTITY(1, 1),
[SiteImportRequestId] [int] NULL,
[WktStr] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GeofenceTypeId] [int] NOT NULL,
[GeofenceCategoryId] [int] NOT NULL,
[Name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SiteId] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recipients] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Radius1] [float] NOT NULL,
[Radius2] [float] NULL,
[CenterLon] [float] NOT NULL,
[CenterLat] [float] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SiteImportDetail] ADD CONSTRAINT [PK_SiteImportDetail] PRIMARY KEY CLUSTERED  ([SiteImportDetailId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SiteImportDetail] WITH NOCHECK ADD CONSTRAINT [FK_SiteImportDetail_Request] FOREIGN KEY ([SiteImportRequestId]) REFERENCES [dbo].[SiteImportRequest] ([SiteImportRequestID])
GO
