
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_FullAddress](
	@NUM varchar(8),
	@RSN int,
	@Building nvarchar(100),
	@StreetNumber nvarchar(30),
	@Street nvarchar(200),
	@StreetType nvarchar(20),
	@AfterName bit,
	@StreetDir nvarchar(20),
	@Suffix nvarchar(150),
	@City nvarchar(100),
	@Province varchar(2),
	@Country nvarchar(60),
	@PostalCode varchar(20),
	@CareOf nvarchar(100),
	@BoxType nvarchar(20),
	@POBox nvarchar(20),
	@Latitude [decimal](11, 7),
	@Longitude [decimal](11, 7),
	@LangID smallint,
	@WebEnable bit
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6.3
	Checked by: CL
	Checked on: 12-May-2015
	Action: NO ACTION REQUIRED
*/

SET @LangID = ISNULL(@LangID,@@LANGID)

DECLARE	@streetAddress		nvarchar(500),
		@StreetTypeLangID	smallint,
		@conStr				nvarchar(5),
		@conStr2			nvarchar(5),
		@returnStr			nvarchar(max),
		@newLine			varchar(5)

SET @Building = RTRIM(LTRIM(@Building))
IF @Building = '' SET @Building = NULL
SET @StreetNumber = RTRIM(LTRIM(@StreetNumber))
IF @StreetNumber = '' SET @StreetNumber = NULL
SET @Street = RTRIM(LTRIM(@Street))
IF @Street = '' SET @Street = NULL
IF @StreetType = '' SET @StreetType = NULL
SET @StreetDir = LTRIM(RTRIM(@StreetDir))
IF @StreetDir = '' SET @StreetDir = NULL
SET @Suffix = RTRIM(LTRIM(@Suffix))
IF @Suffix = '' SET @Suffix = NULL
SET @City = RTRIM(LTRIM(@City))
IF @City = '' SET @City = NULL
SET @Province = RTRIM(LTRIM(@Province))
IF @Province = '' SET @Province = NULL
SET @Country = RTRIM(LTRIM(@Country))
IF @Country = '' SET @Country = NULL
SET @PostalCode = RTRIM(LTRIM(@PostalCode))
IF @PostalCode = '' SET @PostalCode = NULL
SET @CareOf = RTRIM(LTRIM(@CareOf))
IF @CareOf = '' SET @CareOf = NULL

SET @BoxType = RTRIM(LTRIM(@BoxType))
IF @BoxType = '' SET @BoxType = NULL
SET @POBox = RTRIM(LTRIM(@POBox))
IF @POBox = '' SET @POBox = NULL
IF @POBox IS NULL
	SET @BoxType = NULL
ELSE IF @BoxType IS NULL
	SET @BoxType = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('PO Box',@LangID)

SET @streetAddress = ''
SET @StreetTypeLangID = @LangID
SET @returnStr = ''
SET @conStr = ''
SET @conStr2 = ''

SET @newLine = CASE WHEN @WebEnable=1 THEN '<br>' ELSE CHAR(13) + CHAR(10) END

IF @CareOf IS NOT NULL BEGIN
	SET @returnStr = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('c/o',@LangID) + ' ' + @CareOf
	SET @conStr = @newLine
END
IF @POBox IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @BoxType + ' ' + @POBox
	SET @conStr = @newLine
END
IF @Building IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @Building
	SET @conStr = @newLine
END

SELECT TOP 1	@StreetTypeLangID = LangID,
				@AfterName = ISNULL(@AfterName,AfterName)
	FROM GBL_StreetType
	WHERE StreetType=@StreetType AND (AfterName=@AfterName OR @AfterName IS NULL)
ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID

SET @StreetTypeLangID = ISNULL(@StreetTypeLangID,@LangID)
SET @AfterName = ISNULL(@AfterName,CASE WHEN @LangID=2 THEN 0 ELSE 1 END)

IF @StreetNumber IS NOT NULL BEGIN
	SET @streetAddress = @StreetNumber
	IF @LangID = 2 SET @conStr2 = ', ' ELSE SET @conStr2 = ' '
END

IF @Street IS NOT NULL BEGIN
	IF @StreetType IS NOT NULL AND @AfterName=0 BEGIN
		SET @streetAddress = @streetAddress + @conStr2 + @StreetType
		SET @conStr2 = ' '
	END
	SET @streetAddress = @streetAddress + @conStr2 + @Street
	SET @conStr2 = ' '
	IF @StreetType IS NOT NULL AND @AfterName=1 BEGIN
		SET @streetAddress = @streetAddress + @conStr2 + @StreetType
		SET @conStr2 = ' '
	END
END
IF @StreetDir IS NOT NULL BEGIN
	SELECT @StreetDir = ISNULL(sdn.Name,sd.Dir)
		FROM GBL_StreetDir sd
		INNER JOIN GBL_StreetDir_Name sdn
			ON sd.Dir=sdn.Dir AND LangID=@StreetTypeLangID
	WHERE sd.Dir=@StreetDir
	SET @streetAddress = @streetAddress + @conStr2 + @StreetDir
END
IF @Suffix IS NOT NULL BEGIN
	IF @streetAddress <> '' SET @conStr2 = ', '
	SET @streetAddress = @streetAddress + @conStr2 + @Suffix
END
IF @streetAddress <> '' BEGIN
	SET @returnStr = @returnStr + @conStr + @streetAddress
	SET @conStr = @newLine
END
IF @City IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @City
	SET @conStr = ', '
END
IF @Province IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @Province
END
IF @Country IS NOT NULL BEGIN
	IF @returnStr <> '' SET @conStr = @newLine
	SET @returnStr = @returnStr + @conStr + @Country
END
IF @returnStr <> '' AND (@City IS NOT NULL OR @Province IS NOT NULL OR @Country IS NOT NULL) SET @conStr = '     '
IF @PostalCode IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @PostalCode
END

IF @returnStr <> '' AND @returnStr IS NOT NULL AND @WebEnable=1 BEGIN
	SET @streetAddress = dbo.fn_GBL_NUMToMappingSystemLink(@NUM,@RSN,@StreetNumber,@Street,@StreetType,@AfterName,@StreetDir,@City,@Province,@Country,@PostalCode,@Latitude,@Longitude,@LangID)
	IF @streetAddress IS NOT NULL BEGIN	
		SET @returnStr = @returnStr + '<br>&nbsp;<br>' + @streetAddress
	END	
END

IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr
END

GO


GRANT EXECUTE ON  [dbo].[fn_GBL_FullAddress] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FullAddress] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FullAddress] TO [cioc_vol_search_role]
GO
