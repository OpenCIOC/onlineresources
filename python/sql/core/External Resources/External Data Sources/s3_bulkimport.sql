CREATE EXTERNAL DATA SOURCE [s3_bulkimport] WITH
(
LOCATION = N's3://s3.ca-central-1.amazonaws.com:443/',
CREDENTIAL = [s3_bulk]
)
GO
