SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Customer_GetAllByName] (
	@custName nvarchar(255)
)
AS
SELECT *, 1
FROM [dbo].[Customer]
WHERE Name LIKE '%' + @custName + '%'

GO
