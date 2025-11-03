local Paragon = require("paragon_class")
local Config = require("paragon_config")
local Constant = require("paragon_constant")

local Hook = {
    Addon = {
        Prefix = "ParagonAnniversary",
        Functions = {
            [1] = "OnClientLoadRequest",
            [2] = "OnClientSendStatistics"
        }
    }
}

-- =================== Local Functions ===================
--- Retrieves a player object if it exists
-- @param guid_low The low part of the player's GUID
-- @return The player object or false if not found
local function GetPlayerIfExist(guid_low)
    local guid = GetPlayerGUID(guid_low)
    if not guid then return false end

    local player = GetPlayerByGUID(guid)
    if not player then return false end

    return player
end

local function UpdatePlayerStatistics(player, paragon, apply)
    if (not apply) then apply = false end

    local statistics = paragon:GetStatistics()

    for stat_id, stat_value in pairs(statistics) do
        local stat_data = Config:GetByStatId(stat_id)
        local constant_stat_type = Constant.STATISTICS[stat_data.type]

        if (stat_data and constant_stat_type) then
            if (stat_data.type == "UNIT_MODS") then
                player:HandleStatModifier(constant_stat_type[stat_data.value], stat_data.application, stat_value, apply)
            end
        end
    end
end

--- Handles client request to load paragon data
-- Sends the player's paragon level and experience information to the client addon
-- @param player The player object making the request
-- @param _ Unused parameter
function OnClientLoadRequest(player, _)
    local paragon = player:GetData("Paragon")
    if (not paragon) then
        Hook.OnPlayerLogin(3, player)
        return false
    end

    player:SendServerResponse(Hook.Addon.Prefix, 1, paragon:GetLevel())
    player:SendServerResponse(Hook.Addon.Prefix, 2, paragon:GetExperience(), paragon:GetExperienceForNextLevel())

    local temp = Config:GetCategories()
    for _, category_data in pairs(temp) do
        local cat_stat = category_data.statistics
        if (cat_stat) then
            for stat_id, stat_data in pairs(cat_stat) do
                stat_data.assigned = paragon:GetStatValue(stat_id)
            end
        end
    end

    player:SendServerResponse(Hook.Addon.Prefix, 3, temp)
end

function OnClientSendStatistics(player, arg_table)
    local data = arg_table[1]
    if (not data) then
        -- Le joueur a tenté d'envoyer un packet vide
        player:SendNotification("ERREUR.")
        return false
    end

    local paragon = player:GetData("Paragon")
    if (not paragon) then return false end

    -- Retire les statistics, le temps du traitement
    UpdatePlayerStatistics(player, paragon, false)

    for _, updated_data in pairs(data) do
        local category_id = updated_data.categoryId
        if (not category_id) then return false end
        
        local categories = Config:GetCategories()
        local category_data = categories[category_id]
        if (not category_data) then return false end

        local statistic_id = updated_data.statId
        if (not statistic_id) then return false end

        local statistic_data = category_data.statistics[statistic_id]
        if (not statistic_data) then return false end

        local statistic_value = updated_data.value
        if (not statistic_value or statistic_value < 0) then return false end
        
        if (statistic_data.limit > 0 and statistic_value > statistic_data.limit) then return false end

        -- TODO: Vérifier que le nombre de point dépensé est bien correct avec le nombre de points disponible.
        print('ok')
        paragon:SetStatValue(statistic_id, statistic_value)
    end

    -- Ont met à jour les statistics aprés le traitement
    UpdatePlayerStatistics(player, paragon, true)
end

--- Callback executed when player statistics data has been loaded from the database
-- @param guid_low The low part of the player's GUID
-- @param paragon The loaded paragon instance
function Hook.OnPlayerStatLoad(guid_low, paragon)
    local player = GetPlayerIfExist(guid_low)
    if (not player) then
        return false
    end

    player:SetData("Paragon", paragon)

    UpdatePlayerStatistics(player, paragon, true)

    -- Final step, update the UI
    OnClientLoadRequest(player)
end

--- Event handler triggered when a player logs into the server
-- Creates a new paragon instance and loads data from the database
-- @param event The event ID (3 = PLAYER_EVENT_ON_LOGIN)
-- @param player The player object that logged in
function Hook.OnPlayerLogin(event, player)
    local paragon = Paragon(player:GetGUIDLow())
    paragon:Load(Hook.OnPlayerStatLoad)

end

function Hook.OnPlayerLogout(event, player)
    local paragon = player:GetData("Paragon")
    if (not paragon) then return end

    UpdatePlayerStatistics(player, paragon, false)
    paragon:Save()
end

function Hook.OnLuaStateOpen(event)
    for _, player in pairs(GetPlayersInWorld()) do
        Hook.OnPlayerLogin(3, player)
    end
end

function Hook.OnLuaStateClose(event)
    for _, player in pairs(GetPlayersInWorld()) do
        Hook.OnPlayerLogout(4, player)
    end
end


function Hook.OnPlayerCommand(event, player, command)
    if (command == "test") then
        local paragon = player:GetData("Paragon")
        UpdatePlayerStatistics(player, paragon, false)

        paragon:AddStatValue(1, 150)
        player:SetData("Paragon", paragon)

        local constant_stat_type = Constant.STATISTICS["UNIT_MODS"]
        UpdatePlayerStatistics(player, paragon, true)
        return false
    end
end
RegisterPlayerEvent(42, Hook.OnPlayerCommand)

-- ================= REGISTER ALE/ELUNA EVENT =================

-- Player Events
RegisterPlayerEvent(3, Hook.OnPlayerLogin)
RegisterPlayerEvent(4, Hook.OnPlayerLogout)

-- Server Events
RegisterServerEvent(33, Hook.OnLuaStateOpen)
RegisterServerEvent(16, Hook.OnLuaStateClose)

-- CSMH Events
RegisterClientRequests(Hook.Addon)