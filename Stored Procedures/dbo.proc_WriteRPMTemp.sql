SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_WriteRPMTemp] @rpmid int OUTPUT,
	@trackerid varchar(50), @creationDateTime datetime, @text varchar(1000)
AS

DECLARE @vidInt INT, @ivhInt int

SELECT @vidInt = Vehicle.VehicleIntId, @ivhInt = IVH.IVHIntId
FROM dbo.IVH 
	INNER JOIN dbo.Vehicle ON IVH.IVHId = Vehicle.IVHId
WHERE IVH.TrackerNumber = @trackerid AND IVH.Archived = 0 AND Vehicle.Archived = 0

INSERT INTO dbo.RPMTemp (VehicleIntId, IVHIntId, CreationDateTime, text, LastOperation, Archived)
	VALUES (@vidInt, @ivhInt, @creationDateTime, @text, GetDate(), 1)

SET @rpmid = SCOPE_IDENTITY()


GO
