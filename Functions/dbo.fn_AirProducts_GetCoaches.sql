SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_AirProducts_GetCoaches]
(
	@tid UNIQUEIDENTIFIER,
	@cid UNIQUEIDENTIFIER
)
RETURNS NVARCHAR(MAX) 
AS

BEGIN
	--DECLARE @tid UNIQUEIDENTIFIER
	--SET @tid = N'4816CB63-F01C-4F2B-A778-B85069FF0F99'

	DECLARE @Names NVARCHAR(MAX) 

	SELECT @Names = COALESCE(@Names + ', ', '') + CASE WHEN RecipientName = 'Steve Hamblin' THEN 'Stephen Hamblin' ELSE o.RecipientName END	
		--t.TriggerId, t.TriggerTypeId, tt.Name, t.Name, rn.RecipientName, u.Name, u.Surname, rn.RecipientAddress, g.GroupId, g.GroupName,
		--t.Name, g.GroupId, g.GroupName, rn.RecipientName, rn.RecipientAddress
	FROM
	(
		SELECT DISTINCT rn.RecipientName	
		FROM dbo.TAN_Trigger t
			INNER JOIN dbo.TAN_TriggerEntity te ON te.TriggerId = t.TriggerId
			INNER JOIN vehicle v ON te.TriggerEntityId = v.VehicleId
			INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
			INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId AND g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 1
				AND g.GroupName NOT LIKE '%*%' 
				AND g.GroupName NOT LIKE '%Manage%' 
				AND g.GroupName NOT LIKE '%Phil%'
				AND g.GroupName NOT LIKE '%Temporary%'
				AND g.GroupName NOT LIKE '%$%'
			LEFT OUTER JOIN dbo.TAN_NotificationTemplate nt ON nt.TriggerId = t.TriggerId AND nt.Archived = 0 AND nt.Disabled = 0
			LEFT OUTER JOIN dbo.TAN_RecipientNotification rn ON rn.NotificationTemplateId = nt.NotificationTemplateId AND rn.Archived = 0
			LEFT OUTER JOIN dbo.[User] u ON rn.RecipientAddress = u.Email
				AND u.Name NOT IN ('COONEYSCopy')
			INNER JOIN dbo.TAN_TriggerType tt ON tt.TriggerTypeId = t.TriggerTypeId
			INNER JOIN dbo.Customer c ON c.CustomerId = t.CustomerId
		WHERE c.CustomerId = @cid
			AND t.TriggerTypeId = 48
			AND t.Archived = 0
			AND t.Disabled = 0
			AND t.Name LIKE '-%'
			AND t.TriggerId = @tid
			AND (rn.RecipientAddress IS NULL OR rn.RecipientAddress NOT IN ('HALLGI@airproducts.com'))
		--ORDER BY rn.RecipientName
	) o

	--SELECT @Names

	RETURN @Names

END


GO
