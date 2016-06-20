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
		 LayoutCSSVersionDate,
		 AlmostStandardsMode,
		 FullSSLCompatible
		)
SELECT 
	   GETDATE(),
	   CREATED_BY,
	   GETDATE(),
	   MODIFIED_BY,
	   MemberID,
	   SystemLayout,
	   Owner,
	   LayoutType,
	   DefaultSearchLayout,
	   LayoutCSS,
	   LayoutCSSURL = 'cicsearch_tabbed_widemenu.css',
	   GETDATE(),
	   AlmostStandardsMode,
	   FullSSLCompatible
FROM GBL_Template_Layout WHERE SystemLayout=1 AND LayoutCSSURL='cicsearch_tabbed.css'

SET @LayoutID = SCOPE_IDENTITY()

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
	   LayoutName + ' - Wide Menu',
	   LayoutHTML,
	   REPLACE(LayoutHTMLURL, '_tabbed', '_tabbed_widemenu')
FROM GBL_Template_Layout_Description WHERE LayoutHTMLURL LIKE 'cicsearch_tabbed.%_CA.html'