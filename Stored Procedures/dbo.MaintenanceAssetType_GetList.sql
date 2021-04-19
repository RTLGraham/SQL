SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[MaintenanceAssetType_GetList]

AS
				
				SELECT AssetTypeId ,
                       Name ,
                       Description ,
                       LastOperation ,
                       Archived
				FROM dbo.MaintenanceAssetType
                WHERE Archived = 0


GO
