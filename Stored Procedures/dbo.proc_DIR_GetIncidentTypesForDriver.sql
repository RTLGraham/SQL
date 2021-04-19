SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[proc_DIR_GetIncidentTypesForDriver]
(
	@DriverIntId INT
)
AS
BEGIN
	
	--DECLARE @DriverIntId INT

	--SET @DriverIntId = 5900


	SELECT it.IncidentTypeId,it.Name,it.Description
	FROM dbo.Driver d
	INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
	INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
	INNER JOIN dbo.DIR_CustomerTemplate ct ON ct.CustomerIntId = c.CustomerIntId
	INNER JOIN dbo.DIR_IncidentType it ON it.IncidentTypeId = ct.IncidentTypeId
	WHERE d.DriverIntId = @DriverIntId


end
GO
