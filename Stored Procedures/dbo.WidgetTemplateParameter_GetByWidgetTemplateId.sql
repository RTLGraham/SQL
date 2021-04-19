SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WidgetTemplateParameter table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateParameter_GetByWidgetTemplateId]
(

	@WidgetTemplateId uniqueidentifier   
)
AS
--DECLARE @WidgetTemplateId uniqueidentifier

--set @WidgettemplateId = N'8fdd20ea-6814-44eb-b1f7-11cd64378e6c'

				SET ANSI_NULLS OFF
				
				SELECT
					[WidgetTemplateParameterID],
					[WidgetTemplateID],
					[NameID],
					[Value],
					[Archived]
				FROM
					[dbo].[WidgetTemplateParameter]
				WHERE
                            [WidgetTemplateID] = @WidgetTemplateId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
