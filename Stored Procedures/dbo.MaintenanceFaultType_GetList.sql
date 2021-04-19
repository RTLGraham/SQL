SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[MaintenanceFaultType_GetList]

AS
				
				SELECT FaultTypeId ,
                       Name ,
                       Description ,
                       LastOperation ,
                       Archived
				FROM dbo.MaintenanceFaultType
                WHERE Archived = 0


GO
