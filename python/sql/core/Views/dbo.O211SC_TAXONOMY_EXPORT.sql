SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[O211SC_TAXONOMY_EXPORT]
AS
SELECT
	tt.Code,
	"record" = (SELECT
		"code" = tt.Code,
		"names" = (SELECT
					td.Term "value",
					sl.Culture "culture"
				FROM TAX_Term_Description td
				INNER JOIN STP_Language sl
					ON td.LangID=sl.LangID
				WHERE td.Code=tt.Code
				FOR XML PATH('name'), TYPE
			),
		"use_references" = 
			(SELECT
					tu.Term "value",
					sltu.Culture "culture"
				FROM TAX_Unused tu
				INNER JOIN STP_Language sltu
					ON tu.LangID=sltu.LangID
				WHERE tu.Code=tt.Code
				FOR XML PATH('name'), TYPE
			)
		FOR XML PATH('term'), TYPE
	)
FROM TAX_Term tt

GO
GRANT SELECT ON  [dbo].[O211SC_TAXONOMY_EXPORT] TO [cioc_login_role]
GO
