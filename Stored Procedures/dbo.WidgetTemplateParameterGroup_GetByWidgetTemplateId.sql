SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WidgetTemplateParameterGroup table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WidgetTemplateParameterGroup_GetByWidgetTemplateId]
(

	@WidgetTemplateId uniqueidentifier   
)
AS

--DECLARE @WidgetTemplateId uniqueidentifier

--set @WidgettemplateId = N'1353b646-898a-4eac-9517-36b2b257ca5f'
--1353b646-898a-4eac-9517-36b2b257ca5f
--8fdd20ea-6814-44eb-b1f7-11cd64378e6c




				SET ANSI_NULLS OFF
				
				SELECT
					[WidgetTemplateID],
					[GroupID],
					[GroupTypeID]
				FROM
					[dbo].[WidgetTemplateParameterGroup]
				WHERE
                            [WidgetTemplateID] = @WidgetTemplateId
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
