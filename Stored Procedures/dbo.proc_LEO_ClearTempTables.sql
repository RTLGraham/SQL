SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ==================================================
-- Author:		<Jamie Bartleet>
-- Create date: <26/10/2017>
-- Description:	<Clear down temporary Leopard tables>
-- ==================================================
CREATE PROCEDURE [dbo].[proc_LEO_ClearTempTables]
AS
BEGIN
	SET NOCOUNT ON;
	
	TRUNCATE TABLE [dbo].[LEO_Temp_ConfigurationSetting]
	TRUNCATE TABLE [dbo].[LEO_Temp_Resource]
	TRUNCATE TABLE [dbo].[LEO_Temp_Port]

END

GO
