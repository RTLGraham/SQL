CREATE TABLE [dbo].[TescoDriver]
(
[DriverIntId] [int] NOT NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOfBirth] [smalldatetime] NULL,
[Status] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Position] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmployeeNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LicenceType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhotoExpiryDate] [smalldatetime] NULL,
[Points] [smallint] NULL CONSTRAINT [DF__TescoDriv__Point__7A92E1F2] DEFAULT ((0)),
[LicenceReviewDate] [smalldatetime] NULL,
[CPCExpiryDate] [smalldatetime] NULL,
[Notes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssessmentDate] [smalldatetime] NULL,
[BronzeTrainingDate] [smalldatetime] NULL,
[SilverTrainingDate] [smalldatetime] NULL,
[BronzeValidationDate] [smalldatetime] NULL,
[MandateCompletionDate] [smalldatetime] NULL,
[CreatedBy] [uniqueidentifier] NULL,
[ModifiedBy] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TescoDriver] ADD CONSTRAINT [PK_TescoDriver] PRIMARY KEY CLUSTERED  ([DriverIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
