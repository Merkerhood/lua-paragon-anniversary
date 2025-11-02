--- Paragon System Constants
-- This module defines all constants used by the paragon system including
-- database configuration, SQL queries, and statistic type enumerations
-- @module paragon_constant

return {
    --- Database name used for paragon system tables
    DB_NAME = "acore_ale",

    --- SQL queries for database operations
    -- Contains all CREATE and SELECT statements for paragon tables
    QUERY = {
        -- Database creation query
        CR_DB = "CREATE DATABASE IF NOT EXISTS `%s`;",

        --- Category Configuration Table
        -- Stores paragon statistic categories (e.g., Combat, Stats, etc.)
        CR_TABLE_CONFIG_CAT = [[
            CREATE TABLE IF NOT EXISTS `%s`.`paragon_config_category` (
                `id` INT NOT NULL AUTO_INCREMENT,
                `name` VARCHAR(50) NOT NULL,

                PRIMARY KEY (`id`)
            );
        ]],

        -- Select all categories
        SEL_CONFIG_CAT = "SELECT `id`, `name` FROM `%s`.`paragon_config_category`",

        --- Statistic Configuration Table
        -- Defines available paragon statistics with their properties
        -- type: AURA, COMBAT_RATING, or UNIT_MODS
        -- factor: Multiplier for each point invested
        -- limit: Maximum points that can be invested
        -- application: How the stat bonus is applied
        CR_TABLE_CONFIG_STAT = [[
            CREATE TABLE IF NOT EXISTS `%s`.`paragon_config_statistic` (
                `id` INT NOT NULL AUTO_INCREMENT,
                `category` INT NOT NULL DEFAULT 1,
                `type` ENUM('AURA','COMBAT_RATING','UNIT_MODS') NOT NULL DEFAULT 'AURA',
                `type_value` INT NOT NULL DEFAULT 0,
                `icon` VARCHAR(50) NOT NULL DEFAULT '0',
                `factor` INT NOT NULL DEFAULT 1,
                `limit` INT(3) NOT NULL DEFAULT 255,
                `application` INT NOT NULL DEFAULT 0,

                PRIMARY KEY (`id`),
                CONSTRAINT `fk_category`
                    FOREIGN KEY (`category`)
                    REFERENCES `%s`.`paragon_config_category`(`id`)
                        ON UPDATE CASCADE
                        ON DELETE NO ACTION
            );
        ]],

        -- Select all statistic configurations
        SEL_CONFIG_STAT = "SELECT `id`, `category`, `type`, `type_value`, `icon`, `factor`, `limit`, `application` FROM `%s`.`paragon_config_statistic`",

        --- General Configuration Table
        -- Stores key-value pairs for general paragon settings
        CR_TABLE_CONFIG = [[
            CREATE TABLE IF NOT EXISTS `%s`.`paragon_config` (
                `id` INT NOT NULL AUTO_INCREMENT,
                `field` VARCHAR(255) NOT NULL,
                `value` VARCHAR(255) NOT NULL,

                PRIMARY KEY (`id`)
            );
        ]],

        -- Select all configuration settings
        SEL_CONFIG = "SELECT `field`, `value` FROM `%s`.`paragon_config`",

        --- Character Paragon Table
        -- Stores each character's paragon level and experience
        CR_TABLE_PARA = [[
            CREATE TABLE IF NOT EXISTS `%s`.`character_paragon` (
                `guid` INT(11) NOT NULL,
                `level` INT(11) NOT NULL DEFAULT 1,
                `experience` INT(11) NOT NULL DEFAULT 0,

                PRIMARY KEY (`guid`)
            );
        ]],

        -- Select paragon level and experience for a character
        SEL_PARA = "SELECT level, experience FROM `%s`.`character_paragon` WHERE guid = %d",

        --- Character Paragon Statistics Table
        -- Stores stat points invested by each character
        CR_TABLE_PARA_STAT = [[
            CREATE TABLE IF NOT EXISTS `%s`.`character_paragon_stats` (
                `guid` INT(11) NOT NULL,
                `stat_id` INT(11) NOT NULL,
                `stat_value` INT(11) NOT NULL,

                PRIMARY KEY (`guid`, `stat_id`)
            );
        ]],

        -- Select all statistics for a character
        SEL_PARA_STAT = "SELECT stat_id, stat_value FROM `%s`.`character_paragon_stats` WHERE guid = %d"
    },

    --- Statistic Type Enumerations
    -- Defines the available statistic types that can be enhanced through the paragon system
    STATISTICS = {
        --- Combat Rating Statistics
        -- These affect combat performance metrics like hit chance, crit, haste, etc.
        COMBAT_RATING = {
            WEAPON_SKILL            = 0,
            DEFENSE_SKILL           = 1,
            DODGE                   = 2,
            PARRY                   = 3,
            BLOCK                   = 4,
            HIT_MELEE               = 5,
            HIT_RANGED              = 6,
            HIT_SPELL               = 7,
            CRIT_MELEE              = 8,
            CRIT_RANGED             = 9,
            CRIT_SPELL              = 10,
            HIT_TAKEN_MELEE         = 11,
            HIT_TAKEN_RANGED        = 12,
            HIT_TAKEN_SPELL         = 13,
            CRIT_TAKEN_MELEE        = 14,
            CRIT_TAKEN_RANGED       = 15,
            CRIT_TAKEN_SPELL        = 16,
            HASTE_MELEE             = 17,
            HASTE_RANGED            = 18,
            HASTE_SPELL             = 19,
            WEAPON_SKILL_MAINHAND   = 20,
            WEAPON_SKILL_OFFHAND    = 21,
            WEAPON_SKILL_RANGED     = 22,
            EXPERTISE               = 23,
            ARMOR_PENETRATION       = 24
        },

        --- Unit Modifier Statistics
        -- These affect base character attributes and resources
        UNIT_MODS = {
            STAT_STRENGTH           = 0,
            STAT_AGILITY            = 1,
            STAT_STAMINA            = 2,
            STAT_INTELLECT          = 3,
            STAT_SPIRIT             = 4,
            HEALTH                  = 5,
            MANA                    = 6,
            RAGE                    = 7,
            FOCUS                   = 8,
            ENERGY                  = 9,
            HAPPINESS               = 10,
            RUNE                    = 11,
            RUNIC_POWER             = 12,
            ARMOR                   = 13,
            RESISTANCE_HOLY         = 14,
            RESISTANCE_FIRE         = 15,
            RESISTANCE_NATURE       = 16,
            RESISTANCE_FROST        = 17,
            RESISTANCE_SHADOW       = 18,
            RESISTANCE_ARCANE       = 19,
            ATTACK_POWER            = 20,
            ATTACK_POWER_RANGED     = 21,
            DAMAGE_MAINHAND         = 22,
            DAMAGE_OFFHAND          = 23,
            DAMAGE_RANGED           = 24,
        },

        --- Aura-based Bonuses
        -- Custom aura IDs for special bonuses like loot, reputation, and experience
        AURA = {
            LOOT                    = 1900000,
            REPUTATION              = 1900001,
            EXPERIENCE              = 1900002
        }
    }
}