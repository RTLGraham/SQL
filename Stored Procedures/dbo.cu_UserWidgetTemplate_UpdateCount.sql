SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_UserWidgetTemplate_UpdateCount]
(
	@widgetTemplateId UNIQUEIDENTIFIER,
	@userId UNIQUEIDENTIFIER
)
AS
	--DECLARE @widgetTemplateId UNIQUEIDENTIFIER,
	--		@userId UNIQUEIDENTIFIER

	--SET @userId = N'BE513ADB-F6D0-45C4-9806-56FAD431ABC6'
	--SET @widgetTemplateId = N'8B3E83C8-0FDE-4783-8E0E-1600CBEB49DF'

	UPDATE [dbo].[UserWidgetTemplate]
	SET UsageCount = UsageCount + 1
	WHERE WidgetTemplateId = @widgetTemplateId
	AND @userId = @userId

GO
