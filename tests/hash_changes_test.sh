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
echo "Hash changes test:" $(date +"%Y-%m-%d %H:%M:%S") >> $LOG_FILE

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

# Update the value table
psql -c "UPDATE $SCHEMA.$VALUE_TABLE SET col3 = 2 WHERE col1='b'"

psql -h "$DB_HOST" -d "$DB_NAME" -U "$DB_USER" -c "$HASH_SQL_2"


COMPARE_SQL="
SELECT
    old.row_hash
FROM $SCHEMA.$HASH_TABLE_1 old
LEFT JOIN $SCHEMA.$HASH_TABLE_2 new
ON old.row_hash = new.row_hash
WHERE new.row_hash IS NULL

UNION ALL

SELECT
    new.row_hash
FROM $SCHEMA.$HASH_TABLE_2 new
LEFT JOIN $SCHEMA.$HASH_TABLE_1 old
ON new.row_hash = old.row_hash
WHERE old.row_hash IS NULL;
"
COMPARE_RESULT=(`psql -t -h "$DB_HOST" -d "$DB_NAME" -U "$DB_USER" -c "$COMPARE_SQL"`)

if [ ${COMPARE_RESULT[0]} == "59b9dab29c142f9a42f210e50dda8fca" ] && [ ${COMPARE_RESULT[1]} == "63ce65c1f481c988f0c8b16e437935d8" ]; then
    echo Value changed from old val to new val corectly >> $LOG_FILE
else
    echo Value changed from old val to new val incorectly >> $LOG_FILE
    FAILED= true
fi
psql -c "DROP SCHEMA IF EXISTS $SCHEMA CASCADE"
if $FAILED; then
    exit 1
fi