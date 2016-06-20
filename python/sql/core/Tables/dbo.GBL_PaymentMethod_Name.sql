CREATE TABLE [dbo].[GBL_PaymentMethod_Name]
(
[PAY_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PaymentMethod_Name] ADD CONSTRAINT [PK_GBL_PaymentMethod_Name] PRIMARY KEY CLUSTERED  ([PAY_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PaymentMethod_Name] ADD CONSTRAINT [FK_GBL_PaymentMethod_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_PaymentMethod_Name] ADD CONSTRAINT [FK_GBL_PaymentMethod_Name_GBL_PaymentMethod] FOREIGN KEY ([PAY_ID]) REFERENCES [dbo].[GBL_PaymentMethod] ([PAY_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_PaymentMethod_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_PaymentMethod_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_PaymentMethod_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_PaymentMethod_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_PaymentMethod_Name] TO [cioc_login_role]
GO
