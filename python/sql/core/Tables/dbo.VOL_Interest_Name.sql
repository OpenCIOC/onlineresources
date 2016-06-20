CREATE TABLE [dbo].[VOL_Interest_Name]
(
[AINameID] [int] NOT NULL IDENTITY(1, 1),
[AI_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_VOL_Interest_Name_d] ON [dbo].[VOL_Interest_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE ai
	FROM VOL_Interest ai
	INNER JOIN Deleted d
		ON ai.AI_ID=d.AI_ID
	WHERE NOT EXISTS(SELECT * FROM VOL_Interest_Name ain WHERE ain.AI_ID=ai.AI_ID)
		AND NOT EXISTS(SELECT * FROM VOL_OP_AI pr WHERE pr.AI_ID=ai.AI_ID)

INSERT INTO VOL_Interest_Name (AI_ID,LangID,[Name])
	SELECT d.AI_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM VOL_Interest_Name ain WHERE ain.AI_ID=d.AI_ID)
			AND EXISTS(SELECT * FROM VOL_OP_AI pr WHERE pr.AI_ID=d.AI_ID)

UPDATE vod
	SET	CMP_Interests = dbo.fn_VOL_VNUMToInterest(vo.VNUM, vod.LangID)
	FROM VOL_Opportunity_Description vod
	INNER JOIN VOL_Opportunity vo
		ON vod.VNUM=vo.VNUM
	INNER JOIN VOL_OP_AI pr
		ON vo.VNUM=pr.VNUM
	INNER JOIN Deleted d
		ON pr.AI_ID=d.AI_ID
	WHERE d.LangID=vod.LangID

SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_VOL_Interest_Name_u] ON [dbo].[VOL_Interest_Name]
FOR UPDATE AS

SET NOCOUNT ON

UPDATE vod
	SET	CMP_Interests = dbo.fn_VOL_VNUMToInterest(vo.VNUM, vod.LangID)
	FROM VOL_Opportunity_Description vod
	INNER JOIN VOL_Opportunity vo
		ON vod.VNUM=vo.VNUM
	INNER JOIN VOL_OP_AI pr
		ON vo.VNUM=pr.VNUM
	INNER JOIN Inserted i
		ON pr.AI_ID=i.AI_ID
	INNER JOIN Deleted d
		ON pr.AI_ID=d.AI_ID
	WHERE i.LangID=vod.LangID OR d.LangID=vod.LangID

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[VOL_Interest_Name] ADD CONSTRAINT [PK_VOL_Interest_Name] PRIMARY KEY CLUSTERED  ([AINameID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Interest_Name_UniquePair] ON [dbo].[VOL_Interest_Name] ([AI_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Interest_Name_UniqueName] ON [dbo].[VOL_Interest_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Interest_Name] ADD CONSTRAINT [FK_VOL_Interest_Name_VOL_Interest] FOREIGN KEY ([AI_ID]) REFERENCES [dbo].[VOL_Interest] ([AI_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_Interest_Name] ADD CONSTRAINT [FK_VOL_Interest_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[VOL_Interest_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[VOL_Interest_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Interest_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_Interest_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_Interest_Name] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Interest_Name] TO [cioc_vol_search_role]
GO
CREATE FULLTEXT INDEX ON [dbo].[VOL_Interest_Name] KEY INDEX [PK_VOL_Interest_Name] ON [AreaOfInterest] WITH STOPLIST [CIOC_DEFAULT_STOPLIST]
GO
ALTER FULLTEXT INDEX ON [dbo].[VOL_Interest_Name] ADD ([Name] LANGUAGE 0)
GO
