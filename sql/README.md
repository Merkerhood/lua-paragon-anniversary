# Paragon System - SQL Migration Files

This directory contains all SQL migration files required to set up the Paragon system database.

## Installation Instructions

**IMPORTANT:** You must execute these SQL files manually in the correct order before starting your server with the Paragon system enabled.

### Execution Order

Execute the following files in order using your preferred MySQL client (MySQL Workbench, HeidiSQL, command line, etc.):

1. **01_create_database.sql** - Creates the `acore_ale` database
2. **02_create_config_tables.sql** - Creates configuration tables (categories, statistics, general config)
3. **03_create_experience_tables.sql** - Creates experience reward tables
4. **04_create_paragon_tables.sql** - Creates paragon progression tables
5. **05_create_triggers.sql** - Creates validation triggers for statistics
6. **06_insert_default_config.sql** - Inserts default configuration values

### Quick Installation (All at once)

You can also execute all files at once by running them in sequence, or by creating a master script that sources all files:

```sql
SOURCE 01_create_database.sql;
SOURCE 02_create_config_tables.sql;
SOURCE 03_create_experience_tables.sql;
SOURCE 04_create_paragon_tables.sql;
SOURCE 05_create_triggers.sql;
SOURCE 06_insert_default_config.sql;
```

### Verification

After running all migration files, verify the installation by checking that the following tables exist:

- `acore_ale.paragon_config_category`
- `acore_ale.paragon_config_statistic`
- `acore_ale.paragon_config`
- `acore_ale.paragon_config_experience_creature`
- `acore_ale.paragon_config_experience_achievement`
- `acore_ale.paragon_config_experience_skill`
- `acore_ale.paragon_config_experience_quest`
- `acore_ale.character_paragon`
- `acore_ale.account_paragon`
- `acore_ale.character_paragon_stats`

And verify that default configuration values were inserted:

```sql
SELECT COUNT(*) FROM acore_ale.paragon_config;
-- Should return at least 17 rows
```

## Error Handling

If you start the server without executing these migration files, you will see error messages in the console indicating which tables are missing. Simply execute the required SQL files and reload the Lua scripts using `.reload eluna`.

## Database Name

**Note:** All SQL files are configured to use the database name `acore_ale`. If you need to use a different database name, you must:

1. Update the `DB_NAME` constant in `paragon_constant.lua`
2. Replace all occurrences of `acore_ale` in the SQL files with your database name
