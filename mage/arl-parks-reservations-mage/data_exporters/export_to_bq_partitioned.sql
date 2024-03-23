CREATE OR REPLACE EXTERNAL TABLE `dev-fusion-418001.arl_parks_dataset.external_arl_parks_data`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://arl-parks-bucket/*.parquet']
);