SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[ParseConfigData]
	(
		@vhcintid INT,
		@eventdataname VARCHAR(30),
		@eventdatastring VARCHAR(1024)
	) 
	 
	RETURNS @parsedata TABLE (
			IVHIntId INT,
			KeyId INT,
			KeyValue NVARCHAR(MAX)
			)
	AS  
	BEGIN 
	
		INSERT INTO @parsedata
				( IVHIntId, KeyId, KeyValue )

		SELECT i.IVHIntId, k.KeyId, Value
		FROM dbo.Split(@eventdatastring, ',') s
		INNER JOIN dbo.CFG_KeyCommand kc ON s.Id-1 = kc.IndexPos
		INNER JOIN dbo.CFG_Key k ON k.KeyId = kc.KeyId
		INNER JOIN dbo.CFG_Command comm ON kc.CommandId = comm.CommandId
		INNER JOIN dbo.CFG_Category cat ON comm.CategoryId = cat.CategoryId
		INNER JOIN dbo.IVHType it ON comm.IVHTypeId = it.IVHTypeId
		INNER JOIN dbo.IVH i ON it.IVHTypeId = i.IVHTypeId
		INNER JOIN dbo.Vehicle v ON i.IVHId = v.IVHId
		WHERE it.EventDataNamePrefix + comm.CommandRoot + it.EventDataNameSuffix = @eventdataname
		  AND v.VehicleIntId = @vhcintid
		  
		RETURN
	END

GO
