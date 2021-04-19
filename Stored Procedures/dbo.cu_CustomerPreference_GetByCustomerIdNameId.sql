SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the CustomerPreference table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[cu_CustomerPreference_GetByCustomerIdNameId]
(

	@CustomerId uniqueidentifier   ,

	@NameId int   
)
AS

--DECLARE @nameId int,
--		@CustomerId uniqueidentifier

--SET @nameId = 200
--SET @CustomerId = N'4C173651-9B5E-4EB1-871B-85181E40F4B1'

SELECT TOP 1 up.CustomerPreferenceID, up.CustomerID, up.NameID, up.Value, up.Archived, 1
FROM [dbo].[CustomerPreference] up
WHERE ((up.CustomerID IS NULL) OR (up.CustomerID = @CustomerId))
AND up.NameID = @NameId
AND Archived = 0
ORDER BY CustomerID DESC


GO
