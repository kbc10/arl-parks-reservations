-- Replace your-project-nams with the name of your GCP project
CREATE OR REPLACE TABLE your-project-name.arl_parks_dataset.arl_parks_data AS
SELECT * FROM {{ df_1 }};
