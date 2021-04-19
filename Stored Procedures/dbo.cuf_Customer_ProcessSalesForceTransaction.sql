SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Customer_ProcessSalesForceTransaction]
(
	@affected_device_sfdc_id NVARCHAR(1024),
    @case_sfdc_id NVARCHAR(1024),
    @transaction_code NVARCHAR(1024),
    @integration_status NVARCHAR(1024),
    @shared_acct_id NVARCHAR(1024),
    @fitted_device_sfdc_id NVARCHAR(1024),
    @device_sfdc_id NVARCHAR(1024),
    @device_type NVARCHAR(1024),
    @imei NVARCHAR(1024),
    @vehicle_sfdc_id NVARCHAR(1024),
    @vrn NVARCHAR(1024),
    @vin NVARCHAR(1024),
    @year NVARCHAR(1024),
    @make NVARCHAR(1024),
    @model NVARCHAR(1024),
    @partner_id NVARCHAR(1024),
    @program_id NVARCHAR(1024),
    @account_no NVARCHAR(1024),
    @companyname NVARCHAR(1024),
    @delivery_addr1 NVARCHAR(1024),
    @delivery_city NVARCHAR(1024),
    @delivery_state NVARCHAR(1024),
    @zipcode NVARCHAR(1024),
    @country NVARCHAR(1024),
    @firstname NVARCHAR(1024),
    @lastname NVARCHAR(1024),
    @main_phone NVARCHAR(1024),
    @primary_contact NVARCHAR(1024),
    @email NVARCHAR(1024),
    @evogi_error_code NVARCHAR(1024)
)
AS
	
	DECLARE @result INT

	SET @result = ABS(Checksum(NewID()) % 8) - 1

	SELECT @result AS ResultCode


GO
