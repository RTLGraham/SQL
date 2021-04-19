SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[proc_DIR_GetTemplateForDriver]
(
	@DriverIntId INT,
	@IncidentTypeId SMALLINT
)
AS
BEGIN
--DECLARE @DriverIntId INT,
--		@IncidentTypeId SMALLINT

--SET @DriverIntId = 5900
--SET @IncidentTypeId = 2


SELECT dif.IncidentFieldID,dif.Name,dif.Description
FROM dbo.Driver d
INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
INNER JOIN dbo.DIR_CustomerTemplate ct ON ct.CustomerIntId = c.CustomerIntId
INNER JOIN dbo.DIR_IncidentType it ON it.IncidentTypeId = ct.IncidentTypeId
INNER JOIN dbo.DIR_Template t ON t.CustomerTemplateId = ct.CustomerTemplateId
INNER JOIN dbo.DIR_IncidentField dif ON dif.IncidentFieldID = t.IncidentFieldId 
WHERE d.DriverIntId = @DriverIntId
AND it.IncidentTypeId = @IncidentTypeId

End
GO
