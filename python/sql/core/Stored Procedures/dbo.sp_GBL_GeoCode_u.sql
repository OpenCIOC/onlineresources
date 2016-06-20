SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_GeoCode_u]
	@NUM varchar(8),
	@MODIFIED_BY varchar(50),
	@User_ID int,
	@ViewType int,
	@GEOCODE_TYPE smallint,
	@MAP_PIN int,
	@LATITUDE [decimal](11, 7),
	@LONGITUDE [decimal](11, 7),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@GeocodingObjectName nvarchar(60),
		@OrganizationObjectName nvarchar(60),
		@GeocodeTypeObjectName nvarchar(60),
		@LatitudeLongitudeObjectName nvarchar(60)

SET @GeocodingObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Geocoding')
SET @OrganizationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record')
SET @GeocodeTypeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Geocode Type')
SET @LatitudeLongitudeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Latitude and Longitude')

IF NOT EXISTS(SELECT * FROM GBL_MappingCategory WHERE MapCatID=@MAP_PIN) BEGIN
	SET @MAP_PIN = NULL
END

IF @NUM IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationObjectName, NULL)
END ELSE IF @GEOCODE_TYPE IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @GeocodeTypeObjectName, @OrganizationObjectName)
END ELSE IF @GEOCODE_TYPE>0 AND (@LATITUDE IS NULL OR @LONGITUDE IS NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LatitudeLongitudeObjectName, @OrganizationObjectName)
END ELSE IF @GEOCODE_TYPE<>-1 AND NOT EXISTS (SELECT * FROM cioc_shared.dbo.SHR_GBL_GeoCodeType WHERE GCTypeID=@GEOCODE_TYPE) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@GEOCODE_TYPE AS varchar), @GeocodeTypeObjectName)
END ELSE IF @LATITUDE<-180 OR @LATITUDE>180 BEGIN
	SET @Error = 22 -- Invalid Value
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LATITUDE, @LatitudeLongitudeObjectName)
END ELSE IF @LONGITUDE<-180 OR @LONGITUDE>180 BEGIN
	SET @Error = 22 -- Invalid Value
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LONGITUDE, @LatitudeLongitudeObjectName)
END ELSE IF NOT dbo.fn_CIC_CanUpdateRecord(@NUM,@User_ID,@ViewType,@@LANGID,GETDATE())=1 BEGIN
	SET @Error = 6 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationObjectName, NULL)
END ELSE BEGIN
	UPDATE GBL_BaseTable
	SET	MODIFIED_DATE	= GETDATE(),
		MODIFIED_BY		= @MODIFIED_BY,
		GEOCODE_TYPE	= CASE WHEN @GEOCODE_TYPE = -1 THEN GEOCODE_TYPE ELSE @GEOCODE_TYPE END,
		MAP_PIN			= ISNULL(@MAP_PIN,MAP_PIN),
		LATITUDE		= CASE WHEN @GEOCODE_TYPE = -1 THEN LATITUDE ELSE @LATITUDE END,
		LONGITUDE		= CASE WHEN @GEOCODE_TYPE = -1 THEN LONGITUDE ELSE @LONGITUDE END
	WHERE (NUM = @NUM)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @GeocodingObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_GeoCode_u] TO [cioc_login_role]
GO
