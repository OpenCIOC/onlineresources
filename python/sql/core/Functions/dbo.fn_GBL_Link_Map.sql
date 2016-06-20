
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_Link_Map](
	@NUM varchar(8),
	@RSN int,
	@MAP_ID int,
	@StreetNumber nvarchar(30),
	@Street nvarchar(100),
	@StreetType nvarchar(20),
	@AfterName bit,
	@StreetDir nvarchar(20),
	@City nvarchar(100),
	@Province varchar(2),
	@Country nvarchar(60),
	@PostalCode varchar(10),
	@Latitude [decimal](11, 7),
	@Longitude [decimal](11, 7),
	@LangID smallint
)
RETURNS nvarchar(1500) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@mapLabel varchar(255),
		@defaultProvince char(2),
		@defaultCountry nvarchar(60),
		@newWindow bit,
		@returnStr nvarchar(1500)

SET @LangID = ISNULL(@LangID,@@LANGID)

SET @StreetNumber = RTRIM(LTRIM(@StreetNumber))
IF @StreetNumber = '' SET @StreetNumber = NULL
SET @Street = RTRIM(LTRIM(@Street))
IF @Street = '' SET @Street = NULL
IF @StreetType = '' SET @StreetType = NULL
SET @StreetDir = LTRIM(RTRIM(@StreetDir))
IF @StreetDir = '' SET @StreetDir = NULL
SET @City = RTRIM(LTRIM(@City))
IF @City = '' SET @City = NULL
SET @Province = RTRIM(LTRIM(@Province))
IF @Province = '' SET @Province = NULL
SET @Country = RTRIM(LTRIM(@Country))
IF @Country = '' SET @Country = NULL
SET @PostalCode = RTRIM(LTRIM(@PostalCode))
IF @PostalCode = '' SET @PostalCode = NULL

SELECT @returnStr = mapn.String,
	@mapLabel = mapn.Label,
	@defaultProvince = DefaultProvince,
	@defaultCountry = DefaultCountry,
	@newWindow = NewWindow
	FROM GBL_MappingSystem map
	INNER JOIN GBL_MappingSystem_Name mapn
		ON map.MAP_ID=mapn.MAP_ID AND mapn.LangID=@LangID
WHERE map.MAP_ID=@MAP_ID

IF @returnStr LIKE '%[SITE_ADDRESS]%' BEGIN

	DECLARE	@streetAddress nvarchar(500),		
			@StreetTypeLangID smallint,
			@conStr nvarchar(3),
			@conStr2 nvarchar(3)

	SET @streetAddress = ''
	SET @StreetTypeLangID = @LangID
	SET @conStr = ''
	SET @conStr2 = ''

	SELECT TOP 1 @StreetTypeLangID = LangID, @AfterName = ISNULL(@AfterName,AfterName) FROM GBL_StreetType
		WHERE StreetType=@StreetType
	ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID
	
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
			LEFT JOIN GBL_StreetDir_Name sdn
				ON sd.Dir=sdn.Dir AND LangID=@StreetTypeLangID
		WHERE sd.Dir=@StreetDir
		SET @streetAddress = @streetAddress + @conStr2 + @StreetDir
	END
END

IF (@returnStr LIKE '%[RSN]%' AND @RSN IS NOT NULL) OR (@returnStr LIKE '%[NUM]%' AND @NUM IS NOT NULL) OR (@returnStr LIKE '%[LATITUDE]%' AND @Latitude IS NOT NULL) OR @Street IS NOT NULL OR @PostalCode IS NOT NULL BEGIN
	SET @returnStr = REPLACE(@returnStr,'[RSN]',ISNULL(@RSN,''))
	SET @returnStr = REPLACE(@returnStr,'[NUM]',ISNULL(@NUM,''))
	SET @returnStr = REPLACE(@returnStr,'[SITE_ADDRESS]',ISNULL(@streetAddress,''))
	SET @returnStr = REPLACE(@returnStr,'[SITE_STREET_NUMBER]',ISNULL(@StreetNumber,''))
	SET @returnStr = REPLACE(@returnStr,'[SITE_STREET]',ISNULL(@Street,''))
	SET @returnStr = REPLACE(@returnStr,'[SITE_STREET_TYPE]',ISNULL(@StreetType,''))
	SET @returnStr = REPLACE(@returnStr,'[SITE_STREET_DIR]',ISNULL(@StreetDir,''))
	SET @returnStr = REPLACE(@returnStr,'[SITE_CITY]',ISNULL(@City,''))
	SET @returnStr = REPLACE(@returnStr,'[SITE_PROVINCE]',ISNULL(@Province,@defaultProvince))
	SET @returnStr = REPLACE(@returnStr,'[SITE_POSTAL_CODE]',ISNULL(@PostalCode,''))
	SET @returnStr = REPLACE(@returnStr,'[SITE_COUNTRY]',ISNULL(@Country,@defaultCountry))
	SET @returnStr = REPLACE(@returnStr,'[LATITUDE]',ISNULL(CAST(@Latitude as varchar),''))
	SET @returnStr = REPLACE(@returnStr,'[LONGITUDE]',ISNULL(CAST(@Longitude as varchar),''))
	SET @returnStr = REPLACE(@returnStr,' ','%20')
	SET @returnStr = REPLACE(@returnStr,'%20%20','%20')
END ELSE BEGIN
	SET @returnStr = NULL
END

IF @returnStr = '' BEGIN
	SET @returnStr = NULL
END

IF @returnStr IS NOT NULL BEGIN
	SET @returnStr = '<a href="' + @returnStr + '"' + CASE WHEN @newWindow=1 THEN ' target="_blank"' ELSE '' END + '>' + @mapLabel + '</a>'
END

RETURN @returnStr

END


GO

GRANT EXECUTE ON  [dbo].[fn_GBL_Link_Map] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_Link_Map] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_Link_Map] TO [cioc_vol_search_role]
GO
