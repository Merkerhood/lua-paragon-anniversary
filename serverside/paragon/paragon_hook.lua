local Paragon = require("paragon_class")
local Config = require("paragon_config")

local Hook = {
    Addon = {
        Prefix = "ParagonAnniversary",
        Functions = {
            [1] = "OnClientLoadRequest"
        }
    }
}

--- Handles client request to load paragon data
-- Sends the player's paragon level and experience information to the client addon
-- @param player The player object making the request
-- @param _ Unused parameter
function OnClientLoadRequest(player, _)
    local paragon = player:GetData("Paragon")
    if (not paragon) then
        player:SendNotification("Erreur système.")
        return false
    end

    player:SendServerResponse(Hook.Addon.Prefix, 1, paragon:GetLevel())
    player:SendServerResponse(Hook.Addon.Prefix, 2, paragon:GetExperience(), paragon:GetExperienceForNextLevel())
end

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

--- Callback executed when player level data has been loaded from the database
-- Sets the paragon data on the player object and sends it to the client
-- @param guid_low The low part of the player's GUID
-- @param paragon The loaded paragon instance
function Hook.OnPlayerLevelLoad(guid_low, paragon)
    local player = GetPlayerIfExist(guid_low)
    player:SetData("Paragon", paragon)

    OnClientLoadRequest(player)
end

--- Callback executed when player statistics data has been loaded from the database
-- @param guid_low The low part of the player's GUID
-- @param paragon The loaded paragon instance
function Hook.OnPlayerStatLoad(guid_low, paragon)
    local player = GetPlayerIfExist(guid_low)
end

--- Event handler triggered when a player logs into the server
-- Creates a new paragon instance and loads data from the database
-- @param event The event ID (3 = PLAYER_EVENT_ON_LOGIN)
-- @param player The player object that logged in
function Hook.OnPlayerLogin(event, player)
    local paragon = Paragon(player:GetGUIDLow())
    paragon:load(Hook.OnPlayerLevelLoad, Hook.OnPlayerStatLoad)
end

--- Event handler triggered when the server starts
-- @param event The event ID (33 = SERVER_EVENT_ON_START)
function Hook.OnServerStart(event)

end

--- Event handler triggered when a player enters a command
-- Handles testing command for paragon experience simulation
-- @param event The event ID (42 = PLAYER_EVENT_ON_COMMAND)
-- @param player The player object executing the command
-- @param command The command string entered by the player
function Hook.OnPlayerCommand(event, player, command)
    if (command == "test") then
        local paragon = player:GetData("Paragon")
        if not paragon then return false end

        player:SendServerResponse(Hook.Addon.Prefix, 2, paragon:GetExperience() + 50000, paragon:GetExperienceForNextLevel())
        return false
    end
end
RegisterPlayerEvent(42, Hook.OnPlayerCommand)

RegisterPlayerEvent(3, Hook.OnPlayerLogin)
RegisterServerEvent(33, Hook.OnServerStart)
RegisterClientRequests(Hook.Addon)