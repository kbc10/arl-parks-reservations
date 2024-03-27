CREATE OR REPLACE TABLE dev-fusion-418001.arl_parks_dataset.arl_parks_data
PARTITION BY DATE(TransactionDtm) AS
SELECT * FROM dev-fusion-418001.arl_parks_dataset.external_arl_parks_data;
