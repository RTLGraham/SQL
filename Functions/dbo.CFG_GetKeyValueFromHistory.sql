SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets Vehicle Uniqueidentifier from The VehicleIntegerId
-- ====================================================================
CREATE FUNCTION [dbo].[CFG_GetKeyValueFromHistory] 
(
	@vid UNIQUEIDENTIFIER,
	@commandroot VARCHAR(255),
	@keyname VARCHAR(255),
	@date DATETIME
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

	DECLARE @KeyValue NVARCHAR(MAX)
	
	SELECT @KeyValue = h.KeyValue

	FROM dbo.Vehicle v
	INNER JOIN dbo.IVH i ON v.ivhid = i.IVHId
	INNER JOIN dbo.IVHType it ON i.IVHTypeId = it.IVHTypeId
	INNER JOIN dbo.CFG_Command c ON it.IVHTypeId = c.IVHTypeId AND c.CommandRoot = @commandroot
	INNER JOIN dbo.CFG_KeyCommand kc ON c.CommandId = kc.CommandId
	INNER JOIN dbo.CFG_Key k ON kc.KeyId = k.KeyId AND k.Name = @keyname
	
	LEFT JOIN dbo.CFG_History h ON i.IVHIntId = h.IVHIntId AND k.KeyId = h.KeyId 
		  AND @date >= h.StartDate AND @date < ISNULL(h.EndDate, '2099-12-31')
		  AND h.Status = 1
		  
	WHERE v.VehicleId = @vid
		  
	RETURN @KeyValue

END

GO
