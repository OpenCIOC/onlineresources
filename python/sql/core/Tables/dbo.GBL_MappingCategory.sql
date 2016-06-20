CREATE TABLE [dbo].[GBL_MappingCategory]
(
[MapCatID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MapImage] [varchar] (50) COLLATE Latin1_General_CI_AI NULL,
[MapImageCircle] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[MapImageSm] [varchar] (50) COLLATE Latin1_General_CI_AI NULL,
[MapImageSmCircle] [varchar] (50) COLLATE Latin1_General_CI_AI NULL,
[MapImageSmDot] [varchar] (50) COLLATE Latin1_General_CI_AI NULL,
[PinColour] [char] (6) COLLATE Latin1_General_CI_AS NOT NULL,
[TextColour] [char] (6) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_MappingCategory] ADD CONSTRAINT [PK_GBL_MappingCategory] PRIMARY KEY CLUSTERED  ([MapCatID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_MappingCategory_Image] ON [dbo].[GBL_MappingCategory] ([MapImage]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_MappingCategory_Colour] ON [dbo].[GBL_MappingCategory] ([PinColour]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_MappingCategory] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_MappingCategory] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_MappingCategory] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_MappingCategory] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_MappingCategory] TO [cioc_login_role]
GO
