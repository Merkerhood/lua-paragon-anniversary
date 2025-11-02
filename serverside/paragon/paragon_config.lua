local Repository = require("paragon_repository")

local Config = Object:extend()
local Instance = nil

--- Constructor for the Config
-- Initializes the service by building paragon data and loading configuration
function Config:new()
    -- Build category / stat data
    self:BuildParagonData()

    local config_data = Repository:GetConfig()
    self.config = config_data
end

--- Retrieves a configuration value by field name
-- @param field The configuration field name to retrieve
-- @return The configuration value or nil if not found
function Config:GetByField(field)
    return self.config[field] or nil
end

--- Retrieves all paragon categories
-- @return Table containing all categories with their statistics
function Config:GetCategories()
    return self.categories
end

--- Retrieves a specific category by its ID
-- @param id The category ID to retrieve
-- @return The category data or nil if not found
function Config:GetByCategoryId(id)
    return self.categories[id] or nil
end

--- Retrieves a specific statistic by its ID across all categories
-- @param id The statistic ID to search for
-- @return The statistic data or nil if not found
function Config:GetByStatId(id)
    for cat_id, cat_data in pairs(self.categories) do
        local stat_data = cat_data.statistics[id]
        if(stat_data) then
            return stat_data
        end
    end
    return nil
end

--- Builds the paragon data structure by combining categories and statistics
-- Retrieves data from the repository and organizes it into a unified structure
function Config:BuildParagonData()
    local statistics_data = Repository:GetConfigStatistics()
    local categories_data = Repository:GetConfigCategories()

    local data = {}
    for cat_id, cat_name in pairs(categories_data) do
        data[cat_id] = {
            name = cat_name,
            statistics = statistics_data[cat_id]
        }
    end
    self.categories = data
end

--- Gets the singleton instance of Config
-- Creates a new instance if one doesn't exist yet
-- @return The Config singleton instance
function Config:GetInstance()
    if (not Instance) then
        Instance = Config()
    end

    return Instance
end

return Config:GetInstance()