CREATE TABLE [dbo].[GroupData]
(
[GroupDataId] [int] NOT NULL IDENTITY(1, 1),
[GroupDataTypeId] [int] NOT NULL,
[GroupId] [uniqueidentifier] NULL,
[GroupDataItem] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_GroupData_Archived] DEFAULT ((0)),
[LastModified] [datetime] NULL CONSTRAINT [DF_GroupData_LastModified] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GroupData] ADD CONSTRAINT [PK_GroupData] PRIMARY KEY CLUSTERED  ([GroupDataId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GroupData] ADD CONSTRAINT [FK_GroupData_Group] FOREIGN KEY ([GroupId]) REFERENCES [dbo].[Group] ([GroupId])
GO
ALTER TABLE [dbo].[GroupData] ADD CONSTRAINT [FK_GroupData_GroupDataType] FOREIGN KEY ([GroupDataTypeId]) REFERENCES [dbo].[GroupDataType] ([GroupDataTypeId])
GO
