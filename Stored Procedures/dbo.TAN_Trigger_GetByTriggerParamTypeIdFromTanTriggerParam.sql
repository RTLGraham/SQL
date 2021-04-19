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


CREATE PROCEDURE [dbo].[TAN_Trigger_GetByTriggerParamTypeIdFromTanTriggerParam]
(

	@TriggerParamTypeId int   
)
AS


SELECT dbo.[TAN_Trigger].[TriggerId]
       ,dbo.[TAN_Trigger].[TriggerTypeId]
       ,dbo.[TAN_Trigger].[Name]
       ,dbo.[TAN_Trigger].[Description]
       ,dbo.[TAN_Trigger].[Disabled]
       ,dbo.[TAN_Trigger].[Archived]
       ,dbo.[TAN_Trigger].[LastOperation]
       ,dbo.[TAN_Trigger].[CustomerId]
       ,dbo.[TAN_Trigger].[CreatedBy]
       ,dbo.[TAN_Trigger].[Count]
  FROM dbo.[TAN_Trigger]
 WHERE EXISTS (SELECT 1
                 FROM dbo.[TAN_TriggerParam] 
                WHERE dbo.[TAN_TriggerParam].[TriggerParamTypeId] = @TriggerParamTypeId
                  AND dbo.[TAN_TriggerParam].[TriggerId] = dbo.[TAN_Trigger].[TriggerId]
                  )
                AND Archived = 0
				SELECT @@ROWCOUNT			
				


GO
