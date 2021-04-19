SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets records through a junction table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerParamType_GetByTriggerIdFromTanTriggerParam]
(

	@TriggerId uniqueidentifier   
)
AS


SELECT dbo.[TAN_TriggerParamType].[TriggerParamTypeId]
       ,dbo.[TAN_TriggerParamType].[Name]
       ,dbo.[TAN_TriggerParamType].[Description]
       ,dbo.[TAN_TriggerParamType].[Archived]
       ,dbo.[TAN_TriggerParamType].[LastOperation]
  FROM dbo.[TAN_TriggerParamType]
 WHERE EXISTS (SELECT 1
                 FROM dbo.[TAN_TriggerParam] 
                WHERE dbo.[TAN_TriggerParam].[TriggerId] = @TriggerId
                  AND dbo.[TAN_TriggerParam].[TriggerParamTypeId] = dbo.[TAN_TriggerParamType].[TriggerParamTypeId]
                  )
                AND Archived = 0
				SELECT @@ROWCOUNT			
				


GO
