UPDATE btd
	SET CMP_LocDescriptionShort = CASE WHEN btd.LOCATION_DESCRIPTION IS NULL THEN NULL ELSE LTRIM(LEFT(
			REPLACE(REPLACE(REPLACE(
					REPLACE(REPLACE(REPLACE(cioc_shared.dbo.RegexReplace(REPLACE(REPLACE(btd.LOCATION_DESCRIPTION, '<li>', ' * '),'<LI>', ' * '),'<[^>]+>',' '), CHAR(10), ' '), CHAR(9), ' '), CHAR(13), ' '),
				'  ', ' ' + CHAR(1)), CHAR(1) + ' ', ''), CHAR(1), '')
		,200)) + CASE WHEN LEN(btd.LOCATION_DESCRIPTION) > 200 THEN ' ...' ELSE '' END END
	FROM GBL_BaseTable_Description btd
	WHERE btd.LOCATION_DESCRIPTION IS NOT NULL
