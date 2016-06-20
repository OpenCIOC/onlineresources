SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_NUMToMappingSystemLink](
	@NUM varchar(8),
	@RSN int,
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
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	nvarchar(max)

SELECT @returnStr =  COALESCE(@returnStr + '<br>','') + 
		dbo.fn_GBL_Link_Map(
			@NUM,
			@RSN,
			MAP_ID, 
			@StreetNumber,
			@Street,
			@StreetType,
			@AfterName,
			@StreetDir,
			@City,
			@Province,
			@Country,
			@PostalCode,
			@Latitude,
			@Longitude,
			@LangID
		)
	FROM GBL_BT_MAP
WHERE NUM = @NUM

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToMappingSystemLink] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToMappingSystemLink] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToMappingSystemLink] TO [cioc_vol_search_role]
GO
