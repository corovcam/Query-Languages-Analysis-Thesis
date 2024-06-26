# Analysis of Query Languages in Modern Database Systems

NoSQL and multi-model systems represent so-called variety of big data, i.e., enables to represent data in different (or combined) logical models and formats. In addition to the relational model, we also distinguish, e.g., hierarchical (document) and graph data, hence the scope and efficiency of querying over these representations differ.

The goal of this thesis is to focus on various data models (e.g., document, column, graph, relational) and to compare typical query languages for these data models in terms of expressive power and run-time efficiency, taking into account scalability with varying number of stored data.

We will analyze the current state of knowledge. Then, we will select 6 candidates for comparison and statically compare the expressive power of the supported query languages. Next, based on the static comparison, we will propose query scenarios and perform dynamic query comparison over the selected database systems using the proposed queries. Finally, we will suggest appropriate recommendations or discuss open questions and challenges in querying over various data.

## Repository Structure

The top-level repository structure contains folders for all databases used in the thesis. Since we use Docker to set up all DBMS containers, `docker-compose.yml` defines the services, their volumes, and configurations used for testing.

The repository is structure as follows (along with some important files and folders mentioned):

- `common/` - common files and scripts for all databases
  - `docs/` - extra documentation files (e.g. schema diagrams)
  - `thesis-dummy-data-generator/` - TypeScript NPM project for generating pseudo-random relational data using [Faker.js](https://fakerjs.dev/) and [Scramjet](https://docs.scramjet.org/category/framework) framework
  - `count_table_rows.sql` - for MySQL and SQLite
  - `filter_results.ipynb` - Jupyter Notebook for filtering and processing experiment results
  - `results.csv` - a combined CSV file containing all results from experiments with a header: `db,record_volume,query,iteration,time_in_seconds`
  - `db_sizes.csv` - a CSV file containing database sizes in MB for each database system and record volume
  - `filtered_results.csv` - post-processed CSV file
- `mysql/` - MySQL database files and scripts
  - `data/` - configuration files mounted to the MySQL container
  - `dumps/` - MySQL SQL and/or CSV dumps copied from generated `common/thesis-dummy-data-generator/data_<entity_count>*` folder
  - `exports/` - contains (denormalized) exported data from MySQL database (later imported into Cassandra)
  - `queries/` - SQL queries for MySQL
    - `testing/` - individual files with individual queries used for testing
    - **`query.sql`** - complete list of queries and their descriptions (check comments for more details)
    - **`schema.sql`** - complete schema of the MySQL database (check comments for more details)
- `sqlite/` - SQLite database files and scripts (is similar to MySQL structure, so only differences are mentioned)
  - `data/` - database file (`ecommerce.db`) mounted to the SQLite container
  - _`sqlite3-analyzer`_[^1] - binary for analyzing SQLite database and generating statistics about tables called with `sqlite3-analyzer data/ecommerce.db` outside the container, inside `sqlite/` folder
- `neo4j/` - Neo4j database files and scripts
  - `arangodb-json-transform/` - NPM package for transforming exported JSON data from Neo4j to ArangoDB JSON format
  - `dumps/` - Neo4j database dumps (entire database files in compressed binary format)
  - `exports/` - exported JSON documents from Neo4j (later transformed to ArangoDB JSON format)
    - `edges/` - each file inside this folder contains JSON Lines of edges (relationships) generated by `export_to_json.sh`
    - `nodes/` - each file inside this folder contains JSON Lines of nodes (vertices) generated by `export_to_json.sh`
  - `neo4j-etl-tool/` - _Neo4j ETL tool_[^2] files for importing data from CSV files (tested with version 1.6.0)
    - `neo4-etl-cli-1.6.0/` - release files downloaded from above GitHub repository
      - `bin/neo4j-etl` - binary for running ETL tool
  - `queries/` - Cypher queries for Neo4j
    - **`query.cypher`** - complete list of queries and their descriptions (check comments for more details)
- `arangodb/` - ArangoDB database files and scripts
  - `dumps/` - ArangoDB database dumps (copied from exported `neo4j/exports` folder)
  - `queries/` - AQL queries for ArangoDB
    - **`query.js`** - definition of AQL queries and their descriptions (check comments for more details)
    - **`query_testing.js`** - entire testing script with error handling for running AQL queries and generating logs
- `cassandra/` - Cassandra database files and scripts
  - `data/` - configuration file `cassandra.yaml` mounted to the Cassandra container
  - `dsbulk/` - _DataStax Bulk Loader (dsbulk)_[^3] JAR file for loading and counting data in Cassandra (tested with version 1.11.0)
  - `dumps/` - Cassandra CQL dumps or CSV files copied from exported `mysql/exports` folder
  - `queries/` - CQL queries for Cassandra
    - **`query.cql`** - complete list of queries and their descriptions (check comments for more details)
    - **`schema.cql`** - complete schema of the Cassandra database (check comments for more details)
- `mongodb/` - MongoDB database files and scripts
  - `dumps/` - MongoDB database dumps (generated with `dumps.sh`)
  - `queries/` - MongoDB queries for MongoDB
    - **`query.js`** - complete list of queries and their descriptions (check comments for more details)
    - **`query_testing.js`** - entire testing script with error handling similar to ArangoDB
  - `relational-migrator/` - installation and configuration files for _MongoDB Relational Migrator_
    - `mongodb-relational-migrator_1.5.0_amd64.deb` - installation file for Debian based systems (NOTE: **GIT LFS** is required to download this file!)
    - `ecommerce-mapping*.relmig` - these are configuration files used to setup _MongoDB Relational Migrator_[^4] tool (tested with version 1.5.0)

Folders and files common to most of the database directories:

- `logs/` - all logs generated from scripts
  - `queries/` - logs from query testing invoked by `run_queries.sh`
- `queries/` - queries for each database system
  - `testing/` - individual files with individual queries used for testing
- `stats/` - final statistics generated from queries, imports, and exports (later used for analysis)
- `dumps` - database dumps or exported data from other databases (used for importing data)

### Scripts

Some scripts are common for all databases, some are specific to a particular DBMS. Some like `init.sh` and `run_queries.sh` require manual variable editing to select required data directories (see NOTES inside scripts before execution!). If not explicitly specified otherwise (see script comments), scripts must be run inside respective Docker containers, i.e. with `docker exec -it query-languages-analysis-thesis-<service_name>-1 bash` or `docker exec -it query-languages-analysis-thesis-<service_name>-1 sh`.

Common scripts:

- `/run_queries.sh` - convenience script for running all queries for selected databases (in parallel)
- `/init.sh` - convenience script for inializing all databases (creating schemas, importing data, etc.) for selected databases (in parallel)
- `/<dbms>`
  - `run_queries.sh`, `/init.sh` - individual scripts for running queries or initializing (see comments for more details)

Notable scripts and flows:

- `common/thesis-dummy-data-generator/run.sh` - run with `./run.sh <entity_count>` to generate CSV files with `<entity_count>` number as reference count for top-level entities
- `mysql`
  1. Initialization scripts:
    - `csv_init.sh` - initialize with CSV files as source of data
    - `init.sh` - initialize with SQL dump as source of data (older method used with small datasets - see [Legacy generator](#legacy-generator))
  2. `cassandra_export_to_csv.sh` - transform MySQL tables to denormalized CSV files for importing into Cassandra
- `neo4j`
  1. `neo4j-etl-tool/`
    - `import.sh` - automatically run _Neo4j ETL tool CLI_ and subsequently import data using `neo4j-admin database import full` command
  2. `export_to_json.sh` - export Neo4j vertices and relationships to JSON Lines format
  3. `arangodb_transform_json.sh` - transform exported JSON Lines to ArangoDB JSON format
- `cassandra`
  1. Initialization scripts:
    - `dsbulk_init.sh` - initialize Cassandra with CSV files as source of data
    - `init.sh` - initialize with CQL dump as source of data (older method used with small datasets - see [Legacy generator](#legacy-generator)) - **NOTE:** Very slow for large datasets.
  2. `count_table_rows.sh` - count rows in each table in Cassandra using `dsbulk count`
  3. `table_stats.sh` - generate statistics for each table in Cassandra using `nodetool tablestats`

## Getting Started

### ETL Flow

![ETL Flow](common/docs/etl-flowchart.drawio.svg)

### Prerequisites

Tools and software required for running the experiments:
- Docker (tested with v25.0.3)
- Docker Compose (tested with v2.24.5)
- Node.js (v20.8+)
- NPM
- Java (tested with OpenJDK 11.0.22)

Tools that need to be (downloaded and) installed manually: (for reproducibility, binaries and installation files are already included in the respective folders)
- Neo4j ETL Tool (v1.6.0) - download link: https://github.com/neo4j-contrib/neo4j-etl/releases/tag/1.6.0
- DataStax Bulk Loader (dsbulk) (v1.11.0) - download link: https://github.com/datastax/dsbulk/releases/tag/1.11.0
- MongoDB Relational Migrator (v1.5.0) - download link: https://migrator-installer-repository.s3.ap-southeast-2.amazonaws.com/index.html#1.5.0/

Tools and software required for filtering the results:
- Python 3
- Pandas, NumPy
- Jupyter Notebook

### Installation, Configuration, and Initialization

1. Clone the repository:
    ```bash
    git clone https://github.com/corovcam/Query-Languages-Analysis-Thesis.git
    cd Query-Languages-Analysis-Thesis
    ```
2. If not already done, download and install the required tools and software and place them in the respective folders.
    - `mongodb/relational-migrator/mongodb-relational-migrator_1.5.0_amd64.deb` should be installed on the host machine using any Debian package manager (e.g. `sudo apt install ./mongodb-relational-migrator_1.5.o_amd64.deb`)[^5].
3. Run the generator script to generate dummy data for MySQL and SQLite databases:
    ```bash
    cd common/thesis-dummy-data-generator
    ./run.sh <entity_count>
    ```
    where `<entity_count>` is the number of entities to generate (e.g. 1000, 4000, 128000, etc.)
4. Copy the generated data to MySQL and SQLite directories:
    ```bash
    cp -r data_<entity_count>_<timestamp> ../mysql/dumps/data_<entity_count>
    cp -r data_<entity_count>_<timestamp> ../sqlite/dumps/data_<entity_count>
    ```
5. Run the following command in the root project directory to build and start the Docker container/s:
   ```bash
   docker-compose up -d --build <service_name>
   ```
6. For most databases (starting with SQLite and MySQL - see [ETL Flow](#etl-flow)), check `init.sh` script for initializing the database, change required variable parameters, and then run the script inside the respective Docker container:
    ```bash
    docker exec -it query-languages-analysis-thesis-<service_name>-1 bash
    ./init.sh
    ```
    or if bash is not available:
    ```bash
    docker exec -it query-languages-analysis-thesis-<service_name>-1 sh
    ./init.sh
    ```
    - **NOTE:** For MySQL and SQLite, you can use `csv_init.sh` script to initialize the database with CSV files as source of data (which comes default from the generator - see `common/thesis-dummy-data-generator/data-generator-old.js` for legacy import used up until 256k record volume experiments to generate SQL dumps - see [Legacy generator](#legacy-generator)).
    - **NOTE:** For Cassandra, you can use `dsbulk_init.sh` script to initialize the database with CSV files as source of data.
7. For Cassandra, you must generate the CSV files from MySQL data using the `cassandra_export_to_csv.sh` script:
    1. Export the MySQL query outputs to CSV files: (as denormalized tables for Cassandra import)
        ```bash
        docker exec -it query-languages-analysis-thesis-mysql-1 bash
        ./cassandra_export_to_csv.sh
        ```
        - **NOTE:** The script will generate CSV files in the `exports/` folder, where each CSV represents one table in the Cassandra database.
    2. Copy the exported CSV files to the Cassandra container:
        ```bash
        cp -r exports/ ../cassandra/dumps/data_<entity_count>
        ```
    3. Initialize the Cassandra database using the `dsbulk_init.sh` script (inside the Cassandra container):
        ```bash
        docker exec -it query-languages-analysis-thesis-cassandra-1 bash
        ./dsbulk_init.sh
        ```
        - **NOTE:** Change the required variable parameters in the script before running it!
    - **NOTE:** You can also use the `init.sh` script to initialize the database with CQL dump as source of data (which is generated by the legacy generator script - see [Legacy generator](#legacy-generator)).
7. For MongoDB, you must proceed according to the official documentation (https://www.mongodb.com/docs/relational-migrator/installation/install-on-a-local-machine/install-ubuntu/).
    1. After installation, run the binary:
        ```bash
        cd /opt/mongodb-relational-migrator/bin
        ./mongodb-relational-migrator
        ```
        - **NOTE:** The tool will start a GUI interface accessible at http://localhost:8278/
    2. You must configure the tool using the provided configuration files, i.e. `mongodb/relational-migrator/ecommerce-mapping*.relmig`.
        - **NOTE:** `ecommerce-mapping.relmig` was used for **< 256k** record volume experiments and `ecommerce-mapping-modified-orders-types-persons.relmig` for **256k+** record volume experiments.
    2. Import the config file by following offical guide (https://www.mongodb.com/docs/relational-migrator/projects/import-project/).
    3. Run the _Sync Job_ by following official guide (https://www.mongodb.com/docs/relational-migrator/jobs/creating-jobs/).
        - **NOTE:** Both, the MySQL and MongoDB containers must be running before running the sync job.
        - **NOTE:** Use the default settings for the sync job. Use `root` as username and password for MySQL and leave defaults for MongoDB.
        - **NOTE:** `Drop destination collections before migration` must be checked to avoid conflicts with existing data!
    4. Check the import stats and logs for any errors or warnings.
9. For Neo4j, you can use `neo4j-etl-tool/import.sh` script to automatically run the ETL tool and import data into Neo4j.
    1. Run the script inside the Neo4j container:
        ```bash
        docker exec -it query-languages-analysis-thesis-neo4j-1 bash
        cd neo4j-etl-tool
        ./import.sh
        ```
        - **NOTE:** MySQL and Neo4j containers must be running before running the script. (conversely, neo4j database instance must be stopped before running neo4j-admin commands - use `neo4j stop` inside neo4j container).
        - **NOTE:** After running the script, you must manually start the Neo4j database instance using `neo4j start` inside the Neo4j container or by restarting the container to proceed.
9. For ArangoDB, you must do the following:
    1. Export the Neo4j data to JSON format using `export_to_json.sh` script (inside the Neo4j container).
        ```bash
        docker exec -it query-languages-analysis-thesis-neo4j-1 bash
        ./export_to_json.sh
        ```
        - **NOTE:** The script will generate two directories: `nodes/` and `edges/` in the `exports` folder containing JSON Lines files for each node and edge type.
    2. Transform the exported JSON data to ArangoDB JSON format using `arangodb_transform_json.sh` (outside the Neo4j container).
        ```bash
        cd neo4j
        ./arangodb_transform_json.sh
        ```
        - **NOTE:** The script will generate the `exports/transformed_<timestamp>/` directory containing JSON Lines files for each node and edge type in ArangoDB format.
    3. Copy the transformed data to the ArangoDB container:
        ```bash
        cp -r exports/transformed_<timestamp> ../arangodb/dumps/data_<entity_count>
        ```
    4. Initialize the ArangoDB database using the `init.sh` script (inside the ArangoDB container).
        ```bash
        docker exec -it query-languages-analysis-thesis-arangodb-1 sh
        ./init.sh
        ```
        - **NOTE:** Change the required variable parameters in the script before running it!

### Legacy Generator

The legacy generator script is used to generate SQL dumps for MySQL and SQLite databases and CQL dumps for Cassandra database. It was used for generating data for experiments with record volumes up to 256k (included). The script is located in the `common/thesis-dummy-data-generator` folder and is named `data-generator-old.js`. To run the script, use the following command:

```bash
cd common/thesis-dummy-data-generator
./run-old.sh <entity_count> <sql_dump_dir> <cql_dump_dir>
```

where `<entity_count>` is the number of entities to generate (e.g. 1000, 4000, 128000, 256000), `<sql_dump_dir>` and `<cql_dump_dir>` are the directories where the generated SQL and CQL dumps will be saved.

## Query Testing

1. Run the following command in the root project directory to start the Docker container/s:
   ```bash
   docker-compose up -d <service_name>
   ```
2. Either run the `run_queries.sh <service_name>` in the root project directory to run all queries for the selected database systems or run the individual scripts for each database system inside the respective Docker container:
    ```bash
    docker exec -it query-languages-analysis-thesis-<service_name>-1 bash
    ./run_queries.sh
    ```
    or if bash is not available:
    ```bash
    docker exec -it query-languages-analysis-thesis-<service_name>-1 sh
    ./run_queries.sh
    ```
    - **NOTE:** Change the required variable parameters in the script before running it!
3. After running the queries, you can find the results in the `logs/queries/` folder for each database system.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

[^1]: https://www.sqlite.org/sqlanalyze.html
[^2]: https://neo4j.com/labs/etl-tool/
[^3]: https://github.com/datastax/dsbulk
[^4]: https://www.mongodb.com/docs/relational-migrator/
[^5]: https://www.mongodb.com/docs/relational-migrator/installation/install-on-a-local-machine/install-ubuntu/