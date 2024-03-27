# Arlington County Parks and Rec Reservations Analysis

This is my final project for the [Data Engineering Zoomcamp course](https://github.com/DataTalksClub/data-engineering-zoomcamp) by DataTalksClub. I built a batch data pipeline that extracts, transforms and loads the [Arlington, Virginia Dept of Parks and Recreation Facility Reservations](https://data.arlingtonva.us/dataset/74) dataset into a data warehouse in  [Google Cloud Platform (GCP)](https://cloud.google.com/). Further transformations are done on the data using [dbt](https://www.getdbt.com/) (data built tool) for preparation of a dashboard.

For the steps of how to reproduce this project, see [recreate-project.md](recreate-project.md).

## Project description

The Arlington Dept of Parks and Recreation manages park, tennis court, rectangular field, picnic shelter, diamond field, community center and other facility reservations. The reservations dataset includes detailed reservation information for each facility. The department would like to analyze this data to understand which spaces are being reserved/utilized the most for each type of facility that they manange. This project aims to develop an streamlined end-to-end data pipeline to transform the dataset into a dashboard that is more suitable for querying and analysis to allow the department to make more informed decisions regarding changing their facilities to better suit the communityu's needs.

This project has the goal of answering the following questions:

1. What is the distribution of reservations broken down by faciltiy type for the entire dataset (records are from 2015-present)?

2. What is the distribution of reservations broken down by faciltiy type per year?

3. Which locations have been reserved the most?


## Project architecture

![](./img/project.png)

### How the data pipeline works

* Mage pipelines:

    1. [ETL API to GCS](./workflows/web_to_gcs/etl_web_to_gcs.py): pulls data from the Arlington Parks and Rec Open Data API and loads the data into a bucket in Google Cloud Storage (GCS) as a parquet file.

    2. [ETL GCS to BigQuery](./workflows/gcs_to_bq/etl_gcs_to_bq.py): extracts the data from the bucket in GCS, transforms string columns by stripping leading and trailing whitespaces, replacing multiple spaces with a single space and bringing all column names to lowercase, and loads the data into a BigQuery dataset.

* dbt models:

    1. [stg_arl_parks_data](./dbt/arl-parks-reservations/models/staging/stg_arl_parks_data.sql): selects a subset of columns from the raw table that was loaded into BigQuery.

    2. [dim_facility_types](./dbt/arl-parks-reservations/models/core/dim_facility_types.sql): selects all data from a seed CSV file that tranlates the facility type codes into more understandable text.  
    
    3. [fact_reservations](./dbt/arl-parks-reservations/models/core/fact_reservations.sql)): selects all data from stg_arl_parks_data and partitions it by day. Here, the partitioning makes it more efficient to query the data and present it on the dashboard. 

### Technologies

* [Mage](https://docs.mage.ai/introduction/overview) for pipeline development and workflow orchestration.

* [Terraform](https://www.terraform.io/) for managing and provisioning infrastructure (GCS bucket abd BigQuery dataset) in GCP.

* [Docker](https://www.docker.com/) for encapsulating the dataflows and their dependencies into containers, making it easier to deploy them.

* [Data Build Tool (dbt)](https://www.getdbt.com/) for transforming and partitioning the dataset in the data warehouse.

* [Google Cloud Storage](https://cloud.google.com/storage) for storing the dataset.

* [Google Bigquery](https://cloud.google.com/bigquery) for performing SQL analytical queries and data transformations defined in dbt.

* [Google Looker Studio](https://lookerstudio.google.com/) for creating a dashboard to visualize the dataset.

## Results

The dashboard is publicly available in this [link](https://lookerstudio.google.com/s/o_KRHFslJWk).

![](./img/dashboard.png)

### Key findings

* The borough information is null for 32% of the records of each year, on average. One way to circumvent this limitation would be to use the [NYC Borough Boundaries data](https://data.cityofnewyork.us/City-Government/Borough-Boundaries/tqmj-j8zm) for checking where each accident happened based on the reported latitude and longitude pairs and using [Geopandas](https://geopandas.org/en/stable/index.html) to determine the respective borough.

* Considering only records that contain the borough information, brooklyn and queens account for more than 50% of the accidents.

* From 2013 to 2022, the minimum number of people killed in a single year was 231 (in 2018) while the maximum number was 297 (in 2013).

* From 2013 to 2022, the minimum number of people injured in a single year was 44,615 (in 2020) while the maximum number was 61,941 (in 2018).

* Besides "unspecified" (56.7%) and "others" (13.2%), the main contributing factor reported for accidents that involved a single vehicle since 2013 was "driver inattention/distraction" (12.4%).

## How to Recreate This Project

### Set up GCP
1. Create a [GCP account](https://cloud.google.com/?hl=en). You can do a free trial with $300 worth of free credits.
2. Create a new project and note your project ID.
3. Create a GCP service account. From the sidebar, go to "IAM & Admin" -> "Service Accounts" -> "Create Service Account".
    > Note: Grant "BigQuery Admin", "Storage Admin" and "Storage Object Admin" permissions to our service account. In real life, we would not grant such wide permissions to this account, but these should work for the purposes of this project.
4. Generate service-account-keys (.json) for authentication. Terraform and dbt will use this key to integrate with GCS and BigQuery. Under your service account, go to the "Keys" tab, then click on "Add Key" -> "Create New Key" -> "JSON" -> "Create". A JSON source file will be downloaded. Add this file to your project directory.

### Set up Terraform
1. Install [Terraform](https://developer.hashicorp.com/terraform/install?ajs_aid=268d2cbe-21f8-4c6c-9588-849c28f1444b&product_intent=terraform) if you have't already done so.
2. Create a new folder in your project directory called `terraform` and create a `main.tf` file like [this](./terraform/main.tf).
    > Note: You can also create `variables.tf` to store your varibales like [this](./terraform/variabled.tf).
3. Initialize terraform and install any required plugins and settings.
```
cd terraform
terraform init
```
4. Run `terraform plan` to see how terraform will create or modify our infrastructure (i.e. our GCS bucket and BigQUery dataset).
5. Apply the plan with `terraform plan`.
6. Check your GCP project to see that a bucket and dataset have been created.

### Set up Mage
1. The [Mage quickstart repo](https://github.com/mage-ai/compose-quickstart) provides a template for users to have an easy way to deploy a project using Docker. 
2. Run the following commands to copy the quickstart repo to your directory and start running the Mage Docker container.
```
git clone https://github.com/mage-ai/compose-quickstart.git mage-quickstart \
&& cd mage-quickstart \
&& cp dev.env .env && rm dev.env \
&& docker compose up
```
3. Open http://localhost:6789 in your browser to start developing pipelines.
4. Create a pipeline to load the dataset from the API and to move it into a GCS bucket as a parquet file. 
    - The [api_to_gcs.py file](./mage/data_loaders/api_to_gcs.py) is used as a data loader block. 
5. Create a pipeline to load the parquet file from GCS into BigQuery
    - The [gcs_to_bq.py file](./mage/data_exporters/gcs_to_bq.py) is used as a data exporter block.
6. OPTIONAL: The dataset gets updated daily. You can create triggers for these pipelines to run daily to update GCS and BigQuery with the most recent data.

### Set up dbt
1. I used dbt cloud for this project. Create a project called "arl_parks_reervations".
2. Connect the project to your git project repository.
3. Connect the project to BigQuery by providing your Google service-account-keys (.json) file.
4. Create a new branch to start developing models.
5. Add the following models under the staging and core models:
    - staging
        1. [stg_arl_parks_data](./dbt/arl-parks-reservationsmodels/staging/stg_arl_parks_data.sql): selects a subset of columns from the raw table that was loaded into BigQuery.
    - core
        1. [dim_facility_types](./dbt/arl-parks-reservations/models/core/dim_facility_types.sql): selects all data from a seed CSV file that tranlates the facility type codes into more understandable text.  
        
        3. [fact_reservations](./dbt/arl-parks-reservations/models/core/fact_reservations.sql): selects all data from stg_arl_parks_data and partitions it by day. Here, the partitioning makes it more efficient to query the data and present it on the dashboard. 
6. The project lineage graph should look like this.
![](./img/dashboard.png)
7. Run `dbt build` in the command line of the IDE to start building the fact and dimension tables in BigQuery.
    > Note: Running `dbt build` will only add 100 rows to the tables since the variable `is_test_run` is default set to True. Run 
    ```dbt build --select --vars '{'is_test_run': 'false'}'``` to build the fact and dimension tables using the entire dataset.
8. To deploy this project, you must create a production environment. Click on "Deploy" -> "Environments" -> "Create Environment". Enter in the environment details as below. 
9. Go to your newly made Production environment and click on "Create Job" -> "Deploy Job". Edit the job to have a name and enter the job details as below.
    > Note: You can optionally have the job run on a schedule the build the data models with new data. This would be daily since the reservations dataset is updated daily. 
