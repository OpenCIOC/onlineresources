SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_ParseIntIDList](
	@IdList varchar(max),
	@Separator char(1)
)
RETURNS @ParsedList TABLE (
	[ItemID] int NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@ItemID varchar(10),
		@Pos int

IF @IdList IS NOT NULL BEGIN
	SET @IdList = LTRIM(RTRIM(@IdList)) + @Separator
	SET @Pos = CHARINDEX(@Separator,@IdList,1)

	IF REPLACE(@IdList,@Separator,'') <> '' BEGIN
		WHILE @Pos > 0 BEGIN
			SET @ItemID = LTRIM(RTRIM(LEFT(@IdList,@Pos-1)))
			IF @ItemID <> '' BEGIN
				INSERT INTO @ParsedList (ItemID)
				VALUES (CAST(@ItemID AS int))
			END
			SET @IdList = RIGHT(@IdList, LEN(@IdList)-@Pos)
			SET @Pos = CHARINDEX(@Separator,@IdList,1)
		END
	END
END

RETURN

END

GO
GRANT SELECT ON  [dbo].[fn_GBL_ParseIntIDList] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[fn_GBL_ParseIntIDList] TO [cioc_login_role]
GO
