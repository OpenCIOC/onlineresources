SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_LowestUnusedNUM](
	@Agency char(3)
)
RETURNS varchar(8) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 25-Jul-2013
	Action: NO ACTION REQUIRED
*/

DECLARE	@NUMSize tinyint,
		@UseLowestNUM bit,
		@i tinyint,
		@ZeroPad varchar(5),
		@LowNUMint int,
		@LowNUM varchar(8)

SELECT @NUMSize=NUMSize, @UseLowestNUM = UseLowestNUM
	FROM GBL_Agency a
	INNER JOIN STP_Member mem
		ON a.MemberID=mem.MemberID
WHERE AgencyCode=@Agency

SET @Agency = ISNULL(@Agency,'ZZZ')
SET @UseLowestNUM = ISNULL(@UseLowestNUM,1)
SET @NUMSize = ISNULL(@NUMSIZE,5)
SET @ZeroPad = '00000'
SET @LowNUMint = NULL

IF NOT EXISTS(SELECT * FROM GBL_BaseTable bt WHERE NUM_Agency=@Agency) BEGIN
	SET @LowNUMint = 1
END ELSE IF @UseLowestNUM = 0 BEGIN
	SELECT @LowNUMint = MAX(bt.NUM_Number) + 1
		FROM GBL_BaseTable bt
	WHERE NUM_Agency=@Agency
	
	IF @LowNUMint IS NULL BEGIN
		SET @LowNUMint = 1
	END ELSE IF (@NUMSize = 4 AND @LowNUMint > 9999) OR @LowNUMint > 99999 BEGIN
		SET @LowNUMint = NULL
	END
END

IF @LowNUMint IS NULL BEGIN
	IF NOT EXISTS(SELECT * FROM GBL_BaseTable bt WHERE NUM_Agency=@Agency AND NUM_Number=1) BEGIN
		SET @LowNUMint = 1
	END ELSE BEGIN
		SELECT @LowNUMint = MIN(bt.NUM_Number) + 1
			FROM GBL_BaseTable bt
		WHERE NUM_Agency=@Agency
			AND NOT EXISTS(SELECT * FROM GBL_BaseTable bt2
				WHERE bt2.NUM_Agency=@Agency
					AND bt2.NUM_Number = bt.NUM_Number + 1)
	END
END

SET @i = @NUMSize
WHILE @i > 0 BEGIN
	IF @LowNUMint < POWER(10,(@NUMSize-(@i-1))) BEGIN
		SET @ZeroPad = RIGHT(@ZeroPad,(@i-1))
		SET @LowNUM = @Agency + @ZeroPad + CAST(@LowNUMint AS varchar)
		BREAK
	END
	SET @i = @i-1
END

RETURN @LowNUM

END




GO
GRANT EXECUTE ON  [dbo].[fn_GBL_LowestUnusedNUM] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_LowestUnusedNUM] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_LowestUnusedNUM] TO [cioc_vol_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_LowestUnusedNUM] TO [public]
GO
