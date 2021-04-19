SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[GetVehicleTypeName]
    (
      @vehicleType INT NULL
    )
RETURNS VARCHAR(1024)
AS 
	BEGIN
		DECLARE @Result VARCHAR(1024)
		IF @vehicleType BETWEEN 1000000 AND 1000005
			SET @Result = 'Car'
		ELSE IF @vehicleType BETWEEN 1000010 AND 1000010
			SET  @Result = 'SUV'
		ELSE IF @vehicleType = 1000011
			SET @Result = '<3.5t. Van (Daily)'
		ELSE IF @vehicleType BETWEEN 1000012 AND 1000014 OR @vehicleType = 1000016
			SET @Result = '<3.5t. Van'
		ELSE IF @vehicleType = 1000015
			SET @Result = '<3.5t. Van (Sprinter)'
		ELSE IF @vehicleType BETWEEN 1500000 AND 1500003 OR @vehicleType = 1500005
			SET @Result = '3.5-7.49t. Van'
		ELSE IF @vehicleType = 1500004
			SET @Result = '3.5-7.49t. Van (Atego)'
		ELSE IF @vehicleType = 1500010
			SET @Result = '3.5-7.49t. Minitruck (Daily)'
		ELSE IF @vehicleType BETWEEN 1500011 AND 1500012
			SET @Result = '3.5-7.49t. Minitruck'
		ELSE IF @vehicleType = 1500013
			SET @Result = '3.5-7.49t. Minitruck (Fuso)'
		ELSE IF @vehicleType = 1500014
			SET @Result = '3.5-7.49t. Minitruck (Vario)'
		ELSE IF @vehicleType = 1500015
			SET @Result = '3.5-7.49t. Minitruck (EuroCargo)'
		ELSE IF @vehicleType BETWEEN 1500020 AND 1500024
			SET @Result = '7.5-11.9t. Lorry'
		ELSE IF @vehicleType = 1500025
			SET @Result = '7.5-11.9t. Lorry (Atego)'
		ELSE IF @vehicleType = 2100000
			SET @Result = '>12t. HGV (Actros)'
		ELSE IF @vehicleType BETWEEN 2100001 AND 2100005
			SET @Result = '>12t. HGV'
		ELSE IF @vehicleType BETWEEN 2200000 AND 2200006
			SET @Result = '>12t. Tanker'
		ELSE IF @vehicleType BETWEEN 3000000 AND 3000005
			SET @Result = 'Bus'
		ELSE IF @vehicleType = 4000000
			SET @Result = 'Trailer'
		ELSE IF @vehicleType = 5000000
			SET @Result = 'Construction Equipment'
		ELSE IF @vehicleType = 5000001
			SET @Result = 'Road roller'
		ELSE IF @vehicleType = 5000002
			SET @Result = 'Motorboat'
		ELSE IF @vehicleType = 6000001
			SET @Result = 'Static Unit'
		ELSE IF @vehicleType = 6000002
			SET @Result = 'Device'
		ELSE IF @vehicleType = 6000003
			SET @Result = 'Lock'
		ELSE
			SET @Result = 'Unknwon'

		RETURN @Result
	END

GO
