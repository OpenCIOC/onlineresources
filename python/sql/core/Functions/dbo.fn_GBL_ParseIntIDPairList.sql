SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_ParseIntIDPairList](
	@IdList varchar(max),
	@Separator char(1),
	@PairSeparator char(1)
)
RETURNS @ParsedList TABLE (
	[LeftID] int,
	[RightID] int NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Item varchar(21),
		@LeftItem varchar(10),
		@RightItem varchar(10),
		@Pos int,
		@PairPos int

IF @IdList IS NOT NULL BEGIN
	SET @IdList = LTRIM(RTRIM(@IdList)) + @Separator
	SET @Pos = CHARINDEX(@Separator,@IdList,1)

	IF REPLACE(@IdList,@Separator,'') <> '' BEGIN
		WHILE @Pos > 0 BEGIN
			SET @Item = LTRIM(RTRIM(LEFT(@IdList,@Pos-1)))
			IF @Item <> '' BEGIN
				SET @PairPos = CHARINDEX(@PairSeparator,@Item, 1)
				IF @PairPos <> 0 BEGIN
					SET @LeftItem = LTRIM(RTRIM(Left(@Item,@PairPos-1)))
					SET @RightItem = LTRIM(RTRIM(SUBSTRING(@Item, @PairPos+1, 21)))
					IF @LeftItem <> '' BEGIN
						INSERT INTO @ParsedList (LeftID, RightID)
						VALUES (CAST(@LeftItem AS int), CASE WHEN @RightItem='' THEN NULL ELSE CAST(@RightItem AS int) END)
					END
				END
			END
			SET @IdList = RIGHT(@IdList, LEN(@IdList)-@Pos)
			SET @Pos = CHARINDEX(@Separator,@IdList,1)
		END
	END
END

RETURN

END

GO
GRANT SELECT ON  [dbo].[fn_GBL_ParseIntIDPairList] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[fn_GBL_ParseIntIDPairList] TO [cioc_login_role]
GO
