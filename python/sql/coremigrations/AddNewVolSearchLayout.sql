DECLARE @LayoutID int
INSERT INTO GBL_Template_Layout
		(CREATED_DATE,
		 CREATED_BY,
		 MODIFIED_DATE,
		 MODIFIED_BY,
		 MemberID,
		 SystemLayout,
		 Owner,
		 LayoutType,
		 DefaultSearchLayout,
		 LayoutCSS,
		 LayoutCSSURL,
		 AlmostStandardsMode,
		 FullSSLCompatible
		)
SELECT GETDATE(),
	   CREATED_BY,
	   GETDATE(),
	   MODIFIED_BY,
	   MemberID,
	   SystemLayout,
	   Owner,
	   LayoutType,
	   DefaultSearchLayout,
	   LayoutCSS,
	   'volsearch_tabbed_browsealternate.css',
	   AlmostStandardsMode,
	   FullSSLCompatible
FROM GBL_Template_Layout
WHERE SystemLayout=1 AND LayoutCSSURL='volsearch_tabbed.css'

SET	@LayoutID = SCOPE_IDENTITY()

INSERT INTO GBL_Template_Layout_Description
		(LayoutID,
		 LangID,
		 CREATED_DATE,
		 CREATED_BY,
		 MODIFIED_DATE,
		 MODIFIED_BY,
		 LayoutName,
		 LayoutHTML,
		 LayoutHTMLURL
		)
SELECT @LayoutID,
	   LangID,
	   GETDATE(),
	   CREATED_BY,
	   GETDATE(),
	   MODIFIED_BY,
	   'Volunteer Tabbed Search - Browse Alternate',
	   LayoutHTML,
	   REPLACE(LayoutHTMLURL, 'volsearch_tabbed', 'volsearch_tabbed_browsealternate')
FROM GBL_Template_Layout_Description
WHERE LayoutName = 'Volunteer Tabbed Search'