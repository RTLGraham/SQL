SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_ReportTranslation_AddTranslation]
(
	@widgetTypeId INT,
	@culture NCHAR(5) = NULL,
	@key NVARCHAR(100),
	@value NVARCHAR(1000)
)
AS

	--DECLARE	@widgetTypeId INT,
	--		@culture NCHAR(5) = NULL,
	--		@key NVARCHAR(100),
	--		@value NVARCHAR(1000)

	--SET @widgetTypeId = 104
	--SET @culture = NULL
	--SET @key = 'Drivers'
	--SET @value = 'Drivers'
	

	IF @key IS NULL OR @key = ''
	BEGIN
		RAISERROR ('No key.', -- Message text.
               16, -- Severity.
               1 -- State.
               ); 
	END

	IF @value IS NULL OR @value = ''
	BEGIN
		RAISERROR ('No value.', -- Message text.
               16, -- Severity.
               1 -- State.
               ); 
	END

	IF @culture IS NOT NULL AND @culture NOT IN ('de-DE', 'fr-FR', 'it-IT', 'es-ES', 'pl-PL', 'ru-RU', 'lv-LV')
	BEGIN
		RAISERROR ('Wrong culture.', -- Message text.
               16, -- Severity.
               1 -- State.
               );  
	END

	DECLARE @setId INT

	SELECT TOP 1 @setId = SetID
	FROM dbo.ReportTranslationSet
	WHERE WidgetTypeID = @widgetTypeId
		AND (Culture = @culture OR (Culture IS NULL AND @culture IS NULL))

	IF @setId IS NULL
	BEGIN
		--Create set
		INSERT INTO dbo.ReportTranslationSet
		        ( WidgetTypeID, Culture )
		VALUES  ( @widgetTypeId, @culture )

		SET @setId = SCOPE_IDENTITY()
	END

	IF @setId IS NULL OR @setId = 0
	BEGIN
		RAISERROR ('Could not find/create the Report Translation Set.', -- Message text.
               16, -- Severity.
               1 -- State.
               );  
	END


	INSERT INTO dbo.ReportTranslation
	        ( SetID, [Key], Value )
	VALUES  ( @setId, @key, @value )



GO
