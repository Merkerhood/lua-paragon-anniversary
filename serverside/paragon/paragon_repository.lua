--[[
    Paragon Repository

    Data access layer for paragon system. Manages all interactions with the
    database including schema migrations, configuration queries, and character
    paragon data persistence.

    Responsibilities:
    - Database schema creation and maintenance
    - Configuration data retrieval (categories, statistics, experience)
    - Character-specific paragon data queries and updates
    - Result parsing and data transformation

    Architecture:
    - Singleton pattern (one global instance)
    - Async queries where appropriate for non-blocking database access
    - Result set transformation into Lua tables
    - Constant-based query strings for safety

    @class Repository
    @author iThorgrim
    @license AGL v3
]]

local Constants = require("paragon_constant")

local Repository = Object:extend()
local Instance = nil

-- String format shorthand
local sf = string.format

-- ============================================================================
-- CONSTRUCTOR & MIGRATIONS
-- ============================================================================

---
--- Initializes the Repository and executes database migrations.
---
function Repository:new()
    self:ExecuteMigration()
end

---
--- Executes database schema migrations on initialization.
---
--- Creates all necessary tables and triggers if they don't already exist:
--- 1. paragon_config_category: Category definitions
--- 2. paragon_config_statistic: Stat configs with properties
--- 3. paragon_config: General key-value settings
--- 4. character_paragon: Character level/experience
--- 5. character_paragon_stats: Character stat investments
--- 6. Triggers: Validation for config stat insertions/updates
---
function Repository:ExecuteMigration()
    -- Configuration tables
    CharDBExecute(sf(Constants.QUERY.CR_TABLE_CONFIG_CAT, Constants.DB_NAME))
    CharDBExecute(sf(Constants.QUERY.CR_TABLE_CONFIG_STAT, Constants.DB_NAME, Constants.DB_NAME))
    CharDBExecute(sf(Constants.QUERY.CR_TABLE_CONFIG, Constants.DB_NAME))

    -- Character paragon tables
    CharDBExecute(sf(Constants.QUERY.CR_TABLE_PARA, Constants.DB_NAME))
    CharDBExecute(sf(Constants.QUERY.CR_TABLE_PARA_STAT, Constants.DB_NAME))

    -- Validation triggers
    CharDBExecute(sf(Constants.QUERY.CT_TRIGGER_BU_CONFIG_STAT, Constants.DB_NAME, Constants.DB_NAME))
    CharDBExecute(sf(Constants.QUERY.CT_TRIGGER_BI_CONFIG_STAT, Constants.DB_NAME, Constants.DB_NAME))
end

-- ============================================================================
-- CONFIGURATION QUERIES
-- ============================================================================

---
--- Retrieves all paragon configuration categories from the database.
---
--- @return Table mapping category_id → category_name, or false if query fails
---
function Repository:GetConfigCategories()
    local results = CharDBQuery(sf(Constants.QUERY.SEL_CONFIG_CAT, Constants.DB_NAME))
    if not results then
        return false
    end

    local categories = {}

    repeat
        local cat_id = results:GetUInt32(0)
        local cat_name = results:GetString(1)
        categories[cat_id] = cat_name
    until not results:NextRow()

    return categories
end

---
--- Retrieves all paragon configuration statistics from the database.
---
--- Statistics are organized by category and contain all configuration properties
--- needed to apply the stat bonus to a character.
---
--- @return Table mapping category_id → {stat_id → stat_data}, or false if query fails
---
function Repository:GetConfigStatistics()
    local results = CharDBQuery(sf(Constants.QUERY.SEL_CONFIG_STAT, Constants.DB_NAME))
    if not results then
        return false
    end

    local statistics = {}

    repeat
        local stat_id = results:GetUInt32(0)
        local stat_cat = results:GetUInt32(1)
        local stat_type = results:GetString(2)
        local stat_value = results:GetString(3)
        local stat_icon = results:GetString(4)
        local stat_factor = results:GetUInt32(5)
        local stat_limit = results:GetUInt32(6)
        local stat_application = results:GetUInt32(7)

        statistics[stat_cat] = statistics[stat_cat] or {}
        statistics[stat_cat][stat_id] = {
            type = stat_type,
            value = stat_value,
            icon = stat_icon,
            factor = stat_factor,
            limit = stat_limit,
            application = stat_application
        }
    until not results:NextRow()

    return statistics
end

---
--- Retrieves all general configuration settings.
---
--- Configuration values are key-value pairs for system parameters.
---
--- @return Table mapping field → value, or false if query fails
---
function Repository:GetConfig()
    local results = CharDBQuery(sf(Constants.QUERY.SEL_CONFIG, Constants.DB_NAME))
    if not results then
        return false
    end

    local config = {}

    repeat
        local conf_field = results:GetString(0)
        local conf_value = results:GetString(1)
        config[conf_field] = conf_value
    until not results:NextRow()

    return config
end

-- ============================================================================
-- EXPERIENCE REWARDS QUERIES
-- ============================================================================

---
--- Internal: Processes experience query results into a key-value table.
---
--- @param results The database query result set
--- @return Table mapping entry_id → experience_value
---
local function ProcessExperienceResults(results)
    if not results then
        return {}
    end

    local data = {}

    repeat
        local entry = results:GetUInt32(0)
        local experience = results:GetUInt32(1)
        data[entry] = experience
    until not results:NextRow()

    return data
end

---
--- Retrieves paragon experience rewards for creature kills.
---
--- @return Table mapping creature_entry_id → experience_reward, or empty table if none
---
function Repository:GetConfigCreatureExperience()
    local results = CharDBQuery(sf(Constants.QUERY.SEL_CONFIG_EXP_CREATURE, Constants.DB_NAME))
    return ProcessExperienceResults(results)
end

---
--- Retrieves paragon experience rewards for achievements.
---
--- @return Table mapping achievement_id → experience_reward, or empty table if none
---
function Repository:GetConfigAchievementExperience()
    local results = CharDBQuery(sf(Constants.QUERY.SEL_CONFIG_EXP_ACHIEVEMENT, Constants.DB_NAME))
    return ProcessExperienceResults(results)
end

---
--- Retrieves paragon experience rewards for skill increases.
---
--- @return Table mapping skill_id → experience_reward, or empty table if none
---
function Repository:GetConfigSkillExperience()
    local results = CharDBQuery(sf(Constants.QUERY.SEL_CONFIG_EXP_SKILL, Constants.DB_NAME))
    return ProcessExperienceResults(results)
end

---
--- Retrieves paragon experience rewards for quest completion.
---
--- @return Table mapping quest_id → experience_reward, or empty table if none
---
function Repository:GetConfigQuestExperience()
    local results = CharDBQuery(sf(Constants.QUERY.SEL_CONFIG_EXP_QUEST, Constants.DB_NAME))
    return ProcessExperienceResults(results)
end

-- ============================================================================
-- CHARACTER PARAGON DATA
-- ============================================================================

---
--- Asynchronously retrieves paragon level and experience data for a character.
---
--- Non-blocking query - uses callback to return results.
---
--- @param guid The character's GUID
--- @param callback Function to invoke with {level, current_experience}
---
function Repository:GetParagonByCharacter(guid, callback)
    if not guid or not callback then
        return
    end

    CharDBQueryAsync(sf(Constants.QUERY.SEL_PARA, Constants.DB_NAME, guid), function(results)
        local data = {}
        if results then
            repeat
                data.level = results:GetUInt32(0)
                data.current_experience = results:GetUInt32(1)
            until not results:NextRow()
        end

        callback(data)
    end)
end

---
--- Asynchronously retrieves paragon statistics for a character.
---
--- Fetches all stat investments for a character.
--- Non-blocking query - uses callback to return results.
---
--- @param guid The character's GUID
--- @param callback Function to invoke with {stat_id → stat_value}
---
function Repository:GetParagonStatByCharacter(guid, callback)
    if not guid or not callback then
        return
    end

    CharDBQueryAsync(sf(Constants.QUERY.SEL_PARA_STAT, Constants.DB_NAME, guid), function(results)
        local data = {}
        if results then
            repeat
                local stat_id = results:GetUInt32(0)
                local stat_value = results:GetUInt32(1)
                data[stat_id] = stat_value
            until not results:NextRow()
        end

        callback(data)
    end)
end

---
--- Saves paragon statistics for a character to the database.
---
--- Persists all stat investments, using INSERT...ON DUPLICATE KEY UPDATE
--- for idempotent updates.
---
--- @param guid The character's GUID
--- @param statistics Table mapping stat_id → stat_value
---
function Repository:SaveParagonCharacterStat(guid, statistics)
    if not guid or not statistics then
        return
    end

    for stat_id, stat_value in pairs(statistics) do
        CharDBExecute(sf(Constants.QUERY.INS_PARA_STAT, Constants.DB_NAME, guid, stat_id, stat_value))
    end
end

-- ============================================================================
-- SINGLETON MANAGEMENT
-- ============================================================================

---
--- Gets the singleton instance of the Repository.
---
--- Creates the instance on first call. All subsequent calls return the same
--- cached instance. Ensures migrations run exactly once.
---
--- @return The Repository singleton instance
---
function Repository:GetInstance()
    if not Instance then
        Instance = Repository()
    end

    return Instance
end

return Repository:GetInstance()