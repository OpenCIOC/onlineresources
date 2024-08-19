CREATE TABLE [dbo].[GBL_Community]
(
[CM_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_Community_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_Community_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[CM_GUID] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_GBL_Community_CM_GUID] DEFAULT (newid()),
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[ParentCommunity] [int] NULL,
[ProvinceState] [int] NULL,
[AlternativeArea] [bit] NOT NULL CONSTRAINT [DF_GBL_Community_AlternativeArea] DEFAULT ((0)),
[Source] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[Authorized] [bit] NOT NULL CONSTRAINT [DF_GBL_Community_Authorized] DEFAULT ((0)),
[PrimaryAreaType] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_Community_iu] ON [dbo].[GBL_Community]
FOR INSERT, UPDATE AS 
BEGIN
	SET NOCOUNT ON

	IF UPDATE(ProvinceState) BEGIN
		UPDATE cmn
			SET ProvinceStateCache = i.ProvinceState
		FROM GBL_Community_Name cmn
		INNER JOIN inserted i
			ON i.CM_ID=cmn.CM_ID
		WHERE ProvinceStateCache <> i.ProvinceState
	END

	SET NOCOUNT OFF
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_Community_iud_Search] ON [dbo].[GBL_Community] 
FOR INSERT, UPDATE, DELETE AS

SET NOCOUNT ON

IF UPDATE(ParentCommunity) BEGIN

	WITH ParentList (CM_ID, Parent_CM_ID) AS
	(
		SELECT CM_ID, ParentCommunity
			FROM GBL_Community
			WHERE ParentCommunity IS NOT NULL
		UNION
		SELECT aas.Search_CM_ID, aas.CM_ID
			FROM GBL_Community_AltAreaSearch aas
		UNION
		SELECT aas.CM_ID, cm.ParentCommunity
			FROM GBL_Community_AltAreaSearch aas
			INNER JOIN GBL_Community cm
				ON aas.Search_CM_ID=cm.CM_ID AND cm.ParentCommunity IS NOT NULL
		UNION ALL
			SELECT cm1.CM_ID, p.Parent_CM_ID
			FROM GBL_Community cm1
			INNER JOIN ParentList p
				ON cm1.ParentCommunity=p.CM_ID
	)
	
	MERGE INTO GBL_Community_ParentList AS cmpl
	USING ParentList p
	ON cmpl.CM_ID=p.CM_ID AND cmpl.Parent_CM_ID=p.Parent_CM_ID
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (CM_ID, Parent_CM_ID) VALUES (p.CM_ID, p.Parent_CM_ID)
	WHEN NOT MATCHED BY SOURCE
		THEN DELETE
	OPTION (MAXRECURSION 30);

	MERGE INTO GBL_Community_ParentList AS cmpl
	USING (
		SELECT DISTINCT aas.CM_ID, pl.Parent_CM_ID
			FROM GBL_Community_AltAreaSearch aas
			INNER JOIN GBL_Community_ParentList pl
				ON pl.CM_ID=aas.Search_CM_ID AND pl.Parent_CM_ID<>aas.CM_ID
			) p
		ON cmpl.CM_ID=p.CM_ID AND cmpl.Parent_CM_ID=p.Parent_CM_ID
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (CM_ID, Parent_CM_ID) VALUES (p.CM_ID, p.Parent_CM_ID)
		;

END

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[GBL_Community] ADD CONSTRAINT [PK_GBL_Community] PRIMARY KEY CLUSTERED ([CM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Community] ADD CONSTRAINT [IX_GBL_Community] UNIQUE NONCLUSTERED ([CM_GUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_Community_CMID] ON [dbo].[GBL_Community] ([CM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Community] ADD CONSTRAINT [FK_GBL_Community_GBL_Community] FOREIGN KEY ([ParentCommunity]) REFERENCES [dbo].[GBL_Community] ([CM_ID])
GO
ALTER TABLE [dbo].[GBL_Community] ADD CONSTRAINT [FK_GBL_Community_GBL_Community_Type] FOREIGN KEY ([PrimaryAreaType]) REFERENCES [dbo].[GBL_Community_Type] ([Code]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Community] ADD CONSTRAINT [FK_GBL_Community_GBL_ProvinceState] FOREIGN KEY ([ProvinceState]) REFERENCES [dbo].[GBL_ProvinceState] ([ProvID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_Community] TO [cioc_cic_search_role]
GO
GRANT DELETE ON  [dbo].[GBL_Community] TO [cioc_login_role]
GO
GRANT INSERT ON  [dbo].[GBL_Community] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[GBL_Community] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[GBL_Community] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[GBL_Community] TO [cioc_vol_search_role]
GO
