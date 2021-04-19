SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_GetVehicleIdByTrackerPhoneNumber]
	@phoneNumber NVARCHAR(MAX)
AS

	SELECT TOP 1 v.VehicleId
	FROM dbo.Vehicle v
	INNER JOIN dbo.IVH i ON i.PhoneNumber = @phoneNumber AND i.IVHId = v.IVHId	
	WHERE v.Archived = 0 AND i.Archived = 0
				   
	
GO
