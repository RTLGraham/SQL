CREATE TABLE [dbo].[Vehicle]
(
[VehicleId] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Vehicle_VehicleId] DEFAULT (newsequentialid()),
[VehicleIntId] [int] NOT NULL IDENTITY(1, 1),
[IVHId] [uniqueidentifier] NULL,
[Registration] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MakeModel] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BodyManufacturer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BodyType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChassisNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FleetNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayColour] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Vehicle_DisplayColour] DEFAULT ('000000'),
[IconId] [int] NULL,
[Identifier] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_Vehicle_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_Vehicle_LastOperation] DEFAULT (getdate()),
[ROPEnabled] [bit] NULL CONSTRAINT [DF_Vehicle_ROPEnabled] DEFAULT ((1)),
[Notes] [varchar] (6000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsTrailer] [bit] NULL,
[FuelMultiplier] [float] NULL,
[VehicleTypeID] [int] NULL,
[IsCAN] [bit] NULL CONSTRAINT [DF_Vehicle_IsCAN] DEFAULT ((1)),
[IsPrivate] [bit] NOT NULL CONSTRAINT [DF__Vehicle__IsPriva__67F44373] DEFAULT ((0)),
[ClaimRate] [int] NULL,
[FuelTypeId] [tinyint] NULL,
[EngineSize] [int] NULL,
[MaxPax] [int] NULL,
[EmissionsInd] [tinyint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[trig_IVHUpdate_Vehicle]
ON [dbo].[Vehicle]
AFTER INSERT, UPDATE
AS
	IF EXISTS ((SELECT i.* 
				FROM INSERTED  i
				INNER JOIN DELETED d ON d.VehicleId = i.VehicleId AND ISNULL(d.IVHId, N'00000000-0000-0000-0000-000000000000') != ISNULL(i.IVHId, N'00000000-0000-0000-0000-000000000000')) -- Vehicle IVHId has been updated
		UNION  (SELECT i.*
				FROM INSERTED i
				LEFT JOIN DELETED d ON d.VehicleId = i.VehicleId
				WHERE d.VehicleId IS NULL AND i.IVHID IS NOT NULL)) -- Vehicle has been inserted with an IVHId
	BEGIN

		-- Set the EndDate on the old record (this is regardless of the value (or NULL) of the new IVHId)
		UPDATE dbo.VehicleIVH
		SET EndDate = GETUTCDATE(), LastOperation = GETDATE()
		FROM dbo.VehicleIVH vi
		INNER JOIN DELETED d ON d.VehicleId = vi.VehicleId AND ISNULL(d.IVHId, N'00000000-0000-0000-0000-000000000000') = ISNULL(vi.IVHId, N'00000000-0000-0000-0000-000000000000') AND EndDate IS NULL	

		-- Now add a new row for the new IVH (if the new IVHId is not NULL)
		INSERT INTO dbo.VehicleIVH (VehicleId, IVHId, StartDate, EndDate, LastOperation)
		SELECT i.VehicleId, i.IVHId, GETUTCDATE(), NULL, GETDATE()
		FROM INSERTED i 
		WHERE i.IVHId IS NOT NULL

		-- If new IVH has been moved from a different vehicle set that Vehicle's IVHId to NULL
		UPDATE dbo.Vehicle
		SET IVHId = NULL
		FROM dbo.Vehicle v
		INNER JOIN INSERTED i ON v.VehicleId != i.VehicleId AND v.IVHId = i.IVHId AND v.IVHId IS NOT NULL	

		-- Finally Update the corresponding row in the VehicleIVH table to make the IVHId ended
		UPDATE dbo.VehicleIVH
		SET EndDate = GETUTCDATE(), LastOperation = GETDATE()
		FROM dbo.VehicleIVH vi
		INNER JOIN INSERTED i ON vi.VehicleId != i.VehicleId AND vi.IVHId = i.IVHId AND vi.IVHId IS NOT NULL AND vi.EndDate IS NULL	

	END	
	
	

GO
ALTER TABLE [dbo].[Vehicle] ADD CONSTRAINT [PK_Vehicle] PRIMARY KEY CLUSTERED  ([VehicleId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Vehicle_IVHId] ON [dbo].[Vehicle] ([IVHId], [Archived]) INCLUDE ([VehicleId], [VehicleIntId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Vehicle_Registration] ON [dbo].[Vehicle] ([Registration], [Archived]) INCLUDE ([VehicleIntId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Vehicle_VehicleIntId] ON [dbo].[Vehicle] ([VehicleIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Vehicle] ADD CONSTRAINT [UQ__Vehicle__VehicleIntId] UNIQUE NONCLUSTERED  ([VehicleIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current IVH installed in vehicle - for history see Events table', 'SCHEMA', N'dbo', 'TABLE', N'Vehicle', 'COLUMN', N'IVHId'
GO
