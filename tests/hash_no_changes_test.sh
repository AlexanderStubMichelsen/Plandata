# Determine the base directory of the script
BASE_DIR=$(dirname "$(realpath "$0")")

# Load the environment variables
export $(cat "$BASE_DIR/../.env" | xargs)

SCHEMA=plandata_hash_test
VALUE_TABLE=valuetable
HASH_TABLE_1=hash1
HASH_TABLE_2=hash2

LOG_FILE=../tests/logs/test_log.txt
FAILED=false

psql -c "DROP SCHEMA IF EXISTS $SCHEMA CASCADE"
psql -c "CREATE SCHEMA $SCHEMA"


echo "------------------------"  >> $LOG_FILE
echo "Hash no changes test:" $(date +"%Y-%m-%d %H:%M:%S") >> $LOG_FILE

# Setup tables
SETUP_SQL="
    DROP TABLE if EXISTS $SCHEMA.$VALUE_TABLE;
    CREATE TABLE $SCHEMA.$VALUE_TABLE(
        col1 VARCHAR(10),
        col2 VARCHAR(10),
        col3 int
    );
    INSERT INTO $SCHEMA.$VALUE_TABLE(col1, col2, col3)
    VALUES
        ('a','aa',1),
        ('b','bb',1),
        ('c','cc',1),
        ('d','dd',1),
        ('e','ee',1);
    DROP TABLE if EXISTS $SCHEMA.$HASH_TABLE_1;
    CREATE TABLE $SCHEMA.$HASH_TABLE_1(
        row_hash TEXT NOT NULL
    );
    DROP TABLE if EXISTS $SCHEMA.$HASH_TABLE_2;
    CREATE TABLE $SCHEMA.$HASH_TABLE_2(
        row_hash TEXT NOT NULL
    );"

psql -h "$DB_HOST" -d "$DB_NAME" -U "$DB_USER" -c "$SETUP_SQL"


# First hash
HASH_SQL_1="
INSERT INTO $SCHEMA.$HASH_TABLE_1 (row_hash)
SELECT md5(
    COALESCE(CAST(col1 AS TEXT), '') || '|' ||
    COALESCE(CAST(col2 AS TEXT), '') || '|' ||
    COALESCE(CAST(col3 AS TEXT), '')
    )
    AS row_hash
FROM $SCHEMA.$VALUE_TABLE;
"
# Second hash
HASH_SQL_2="
INSERT INTO $SCHEMA.$HASH_TABLE_2 (row_hash)
SELECT md5(
    COALESCE(CAST(col1 AS TEXT), '') || '|' ||
    COALESCE(CAST(col2 AS TEXT), '') || '|' ||
    COALESCE(CAST(col3 AS TEXT), '')
    )
    AS row_hash
FROM $SCHEMA.$VALUE_TABLE;
"

psql -h "$DB_HOST" -d "$DB_NAME" -U "$DB_USER" -c "$HASH_SQL_1"

psql -h "$DB_HOST" -d "$DB_NAME" -U "$DB_USER" -c "$HASH_SQL_2"

# Counts how may rows have the same hash, here we expect 5
NUM_SAME_VALUES=`psql -AXqtc "SELECT count(*) FROM $SCHEMA.$HASH_TABLE_1 h1 JOIN $SCHEMA.$HASH_TABLE_2 h2 ON h1.row_hash = h2.row_hash"`
if [ "$NUM_SAME_VALUES" = 5 ]; then
    echo "All rows have the same hash" >> $LOG_FILE
else
    echo "Something went wrong with the hashing" >> $LOG_FILE
    FAILED= true
fi
psql -c "DROP SCHEMA IF EXISTS $SCHEMA CASCADE"
if $FAILED; then
    exit 1
fi
