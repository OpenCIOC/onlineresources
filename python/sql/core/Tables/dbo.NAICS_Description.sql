CREATE TABLE [dbo].[NAICS_Description]
(
[NAICSD_ID] [int] NOT NULL IDENTITY(1, 1),
[Code] [varchar] (6) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Classification] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Description] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_Examples] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SRCH_Anywhere] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Last Modified:		02-Feb-2009
Last Modified By:	Katherine Lambacher
*/
CREATE TRIGGER [dbo].[tr_NAICS_Description_SearchFields] ON [dbo].[NAICS_Description]
FOR INSERT, UPDATE AS

SET NOCOUNT ON

DECLARE @rowCount int
SELECT @rowCount = COUNT(*) FROM Inserted
IF @rowCount > 0 BEGIN
	IF UPDATE(Classification)
		OR UPDATE([Description])
		OR UPDATE(CMP_Examples)
	BEGIN
		UPDATE ncd
			SET	SRCH_Anywhere = ncd.Classification + '  '
				+ ISNULL(ncd.[Description],' ') + '  '
				+ ISNULL(ncd.CMP_Examples,' ')
		FROM 	NAICS_Description ncd
		INNER JOIN Inserted i
			ON ncd.Code = i.Code
	END
END

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[NAICS_Description] ADD CONSTRAINT [PK_NAICS_Description] PRIMARY KEY CLUSTERED  ([NAICSD_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_NAICS_Description] ON [dbo].[NAICS_Description] ([Code], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NAICS_Description] ADD CONSTRAINT [FK_NAICS_Description_NAICS] FOREIGN KEY ([Code]) REFERENCES [dbo].[NAICS] ([Code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[NAICS_Description] ADD CONSTRAINT [FK_NAICS_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[NAICS_Description] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[NAICS_Description] TO [cioc_login_role]
GO
CREATE FULLTEXT INDEX ON [dbo].[NAICS_Description] KEY INDEX [PK_NAICS_Description] ON [NAICS] WITH STOPLIST [CIOC_DEFAULT_STOPLIST]
GO
ALTER FULLTEXT INDEX ON [dbo].[NAICS_Description] ADD ([Classification] LANGUAGE 0)
GO
ALTER FULLTEXT INDEX ON [dbo].[NAICS_Description] ADD ([SRCH_Anywhere] LANGUAGE 0)
GO
