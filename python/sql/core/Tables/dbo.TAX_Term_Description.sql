CREATE TABLE [dbo].[TAX_Term_Description]
(
[TM_DSC_ID] [int] NOT NULL IDENTITY(1, 1),
[Code] [varchar] (21) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[Term] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Definition] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Comments] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AltTerm] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[AltDefinition] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[BiblioRef] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_TAX_Term_Description_CodeLangIDInclTerm] ON [dbo].[TAX_Term_Description] ([Code], [LangID]) INCLUDE ([AltDefinition], [AltTerm], [Definition], [Term]) ON [PRIMARY]

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_TAX_Term_Description_u_Name] ON [dbo].[TAX_Term_Description]
FOR UPDATE AS

SET NOCOUNT ON

DECLARE @TermChangeList TABLE (Code varchar(21) COLLATE Latin1_General_100_CI_AI, LangID smallint)
DECLARE @TermUpdateList TABLE (Code varchar(21) COLLATE Latin1_General_100_CI_AI, LangID smallint)

/* If the French or English Term name has changed, identify records that use that term,
 directly or indirectly through a broader term, and update the SRCH_Taxonomy field. */
IF UPDATE(Term) BEGIN

	/* Confirm that the name has changed */
	INSERT INTO @TermChangeList
		SELECT tm.Code, tm.LangID 
			FROM TAX_Term_Description tm
			INNER JOIN Inserted i 
				ON tm.Code=i.Code AND i.LangID=tm.LangID
			WHERE tm.Term <> i.Term

	/* List of terms updated and their narrower terms */
	INSERT INTO @TermUpdateList
		SELECT tm.Code, tm.LangID FROM TAX_Term_Description tm
		WHERE EXISTS(SELECT * FROM @TermChangeList tc WHERE tc.Code LIKE tm.Code + '%' AND tm.LangID=tc.LangID)

	/* Update SRCH_Taxonomy*/
	UPDATE cbtd
		SET SRCH_Taxonomy_U = 1
		FROM CIC_BaseTable_Description cbtd
		INNER JOIN CIC_BaseTable cbt
			ON cbtd.NUM=cbt.NUM
		INNER JOIN CIC_BT_TAX pr
			ON cbt.NUM=pr.NUM
		INNER JOIN CIC_BT_TAX_TM fr
			ON pr.BT_TAX_ID=fr.BT_TAX_ID
		INNER JOIN @TermUpdateList tl
			ON fr.Code=tl.Code AND cbtd.LangID=tl.LangID
	WHERE cbtd.SRCH_Taxonomy_U <> 1

END

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[TAX_Term_Description] ADD CONSTRAINT [PK_TAX_Term_Description] PRIMARY KEY CLUSTERED  ([TM_DSC_ID]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TAX_Term_Description] ADD CONSTRAINT [FK_TAX_Term_Description_TAX_Term] FOREIGN KEY ([Code]) REFERENCES [dbo].[TAX_Term] ([Code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[TAX_Term_Description] ADD CONSTRAINT [FK_TAX_Term_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[TAX_Term_Description] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[TAX_Term_Description] TO [cioc_login_role]
GO
CREATE FULLTEXT INDEX ON [dbo].[TAX_Term_Description] KEY INDEX [PK_TAX_Term_Description] ON [Taxonomy] WITH STOPLIST [CIOC_DEFAULT_STOPLIST]
GO
ALTER FULLTEXT INDEX ON [dbo].[TAX_Term_Description] ADD ([Term] LANGUAGE 1033)
GO
ALTER FULLTEXT INDEX ON [dbo].[TAX_Term_Description] ADD ([Definition] LANGUAGE 1033)
GO
ALTER FULLTEXT INDEX ON [dbo].[TAX_Term_Description] ADD ([AltTerm] LANGUAGE 1033)
GO
ALTER FULLTEXT INDEX ON [dbo].[TAX_Term_Description] ADD ([AltDefinition] LANGUAGE 1033)
GO
