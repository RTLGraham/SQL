SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AddCategory]
	-- Add the parameters for the function here
	@CategoryName nvarchar(64),
	@LogID int
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @CatID INT
	SELECT @CatID = CategoryID FROM [dbo].[Category] WHERE CategoryName = @CategoryName
	IF @CatID IS NULL
	BEGIN
		INSERT INTO [dbo].[Category] (CategoryName) VALUES(@CategoryName)
		SELECT @CatID = @@IDENTITY
	END

	EXEC InsertCategoryLog @CatID, @LogID 

	RETURN @CatID
END

GO
