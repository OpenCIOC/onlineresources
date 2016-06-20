SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_VOL_LowestUnusedVNUM](
	@Agency char(3)
)
RETURNS varchar(10) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@VNUMSize tinyint,
		@UseLowestVNUM bit,
		@i tinyint,
		@ZeroPad varchar(5),
		@LowVNUMint int,
		@LowVNUM varchar(8)

SELECT @VNUMSize=VNUMSize, @UseLowestVNUM = UseLowestVNUM
	FROM GBL_Agency a
	INNER JOIN STP_Member mem
		ON a.MemberID=mem.MemberID
WHERE AgencyCode=@Agency

SET @Agency = ISNULL(@Agency,'ZZZ')
SET @UseLowestVNUM = ISNULL(@UseLowestVNUM,1)
SET @VNUMSize = ISNULL(@VNUMSIZE,5)
SET @ZeroPad = '00000'
SET @LowVNUMint = NULL

IF NOT EXISTS(SELECT * FROM VOL_Opportunity vo WHERE VNUM_Agency=@Agency) BEGIN
	SET @LowVNUMint = 1
END ELSE IF @UseLowestVNUM = 0 BEGIN
	SELECT @LowVNUMint = MAX(vo.VNUM_Number) + 1
		FROM VOL_Opportunity vo
	WHERE VNUM_Agency=@Agency
	
	IF @LowVNUMint IS NULL BEGIN
		SET @LowVNUMint = 1
	END ELSE IF (@VNUMSize = 4 AND @LowVNUMint > 9999) OR @LowVNUMint > 99999 BEGIN
		SET @LowVNUMint = NULL
	END
END

IF @LowVNUMint IS NULL BEGIN
	IF NOT EXISTS(SELECT * FROM VOL_Opportunity vo WHERE VNUM_Agency=@Agency AND VNUM_Number=1) BEGIN
		SET @LowVNUMint = 1
	END ELSE BEGIN
		SELECT @LowVNUMint = MIN(vo.VNUM_Number) + 1
			FROM VOL_Opportunity vo
		WHERE VNUM_Agency=@Agency
			AND NOT EXISTS(SELECT * FROM VOL_Opportunity vo2
				WHERE vo2.VNUM_Agency=@Agency
					AND vo2.VNUM_Number = vo.VNUM_Number + 1)
	END
END

SET @i = @VNUMSize
WHILE @i > 0 BEGIN
	IF @LowVNUMint < POWER(10,(@VNUMSize-(@i-1))) BEGIN
		SET @ZeroPad = RIGHT(@ZeroPad,(@i-1))
		SET @LowVNUM = @Agency + @ZeroPad + CAST(@LowVNUMint AS varchar)
		BREAK
	END
	SET @i = @i-1
END

RETURN 'V-' + @LowVNUM

END






GO
GRANT EXECUTE ON  [dbo].[fn_VOL_LowestUnusedVNUM] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_LowestUnusedVNUM] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_LowestUnusedVNUM] TO [cioc_vol_search_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_LowestUnusedVNUM] TO [public]
GO
