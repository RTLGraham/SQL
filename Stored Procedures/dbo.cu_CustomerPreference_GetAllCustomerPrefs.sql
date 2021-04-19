SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_CustomerPreference_GetAllCustomerPrefs]
(
	@CustomerId UNIQUEIDENTIFIER
)
AS
--DECLARE @CustomerId UNIQUEIDENTIFIER

--SET @CustomerId = N'4C173651-9B5E-4EB1-871B-85181E40F4B1'

DECLARE @CustomerPrefs TABLE
(
	CustomerPreferenceId UNIQUEIDENTIFIER,
	CustomerId UNIQUEIDENTIFIER,
	NameId int,
	Value varchar(255)
)

INSERT INTO @CustomerPrefs
	SELECT up.CustomerPreferenceID, up.CustomerID, up.NameID, up.Value
	FROM [dbo].[CustomerPreference] up
	WHERE ((up.CustomerId = @CustomerId) OR (up.CustomerId IS NULL))
	AND Archived = 0
	ORDER BY NameId DESC

SELECT * FROM @CustomerPrefs


GO
