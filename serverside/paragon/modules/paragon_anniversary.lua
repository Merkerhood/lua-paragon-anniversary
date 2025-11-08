--[[
    Paragon Anniversary Experience Module

    Central module that manages:
    1. Experience gains and automatic level-ups
    2. Notifications and visual effects
    3. Additional logging and validation
    4. Special bonuses and custom multipliers

    Architecture:
    - ProcessMultipleLevelUps: Handles cascading level-ups
    - OnUpdatePlayerExperience: Main handler for experience gains
    - Mediator hooks for notifications, logging, and validation

    This module is an example of business logic externalization via Mediator.
    Actions are triggered via events rather than hard-coded in paragon_hook.

    Registered mediator events:
    - OnUpdatePlayerExperience: Process experience and handle level-ups
    - OnExperienceCalculated: Custom hook to adjust calculated experience
    - OnParagonStateSync: Hook for special effects during syncs

    Observed mediator events:
    - OnParagonLevelChanged: Notify player of level-up
    - OnParagonExperienceChanged: Track experience changes
    - OnAfterUpdatePlayerExperience: Post-update notifications

    @module paragon_anniversary
    @author iThorgrim
    @license AGL v3
]]

local Config = require("paragon_config")

-- ============================================================================
-- EXPERIENCE MULTIPLIERS & BONUSES
-- ============================================================================

---
--- Tableau de multiplicateurs d'expérience basés sur des conditions.
--- Peut être modifié via Mediator pour ajouter des bonuses dynamiques.
---
local ExperienceMultipliers = {
    events = {},      -- Multiplicateurs pour événements spéciaux
    seasonal = {},    -- Multiplicateurs saisonniers
    realm = {}        -- Multiplicateurs par realm/serveur
}

-- ============================================================================
-- LEVEL-UP PROCESSING
-- ============================================================================

---
--- Traite les montées de niveau en cascade quand l'XP dépasse le seuil.
---
--- Gère les montées successives en :
--- 1. Accumulant l'expérience totale (actuelle + gagnée)
--- 2. Boucle sur chaque seuil de niveau
--- 3. Soustrait l'XP du seuil et incrémente le niveau
--- 4. Recalcule l'expérience requise pour le nouveau niveau
--- 5. Retourne l'expérience restante après les montées
---
--- Exemple: Niveau 1 avec 49/50 XP gagne 150 XP
--- - Total: 49 + 150 = 199 XP
--- - Soustrait 50 (seuil niveau 2): 199 - 50 = 149, Niveau → 2
--- - Soustrait 100 (seuil niveau 3): 149 - 100 = 49, Niveau → 3
--- - État final: Niveau 3 avec 49/150 XP restants
---
--- @param paragon The paragon instance to update
--- @param gained_experience The amount of experience gained
--- @return paragon The updated paragon instance
--- @return levels_gained The number of levels gained
---
local function ProcessMultipleLevelUps(paragon, gained_experience)
    if gained_experience <= 0 then
        return paragon, 0
    end

    -- Accumulate total experience
    local total_experience = paragon:GetExperience() + gained_experience
    local base_max_experience = tonumber(Config:GetByField("BASE_MAX_EXPERIENCE"))
    local levels_gained = 0

    -- Process level-ups while experience exceeds current level's threshold
    while total_experience >= paragon:GetExperienceForNextLevel() and base_max_experience > 0 do
        total_experience = total_experience - paragon:GetExperienceForNextLevel()
        paragon:AddLevel(1)
        levels_gained = levels_gained + 1
    end

    -- Set remaining experience after all level-ups
    paragon:SetExperience(total_experience)

    return paragon, levels_gained
end

-- ============================================================================
-- EXPERIENCE PROCESSING WITH MEDIATOR INTEGRATION
-- ============================================================================

---
--- Processus principal pour gérer les gains d'expérience avec level-ups automatiques.
---
--- Point d'entrée pour les mises à jour d'expérience, délègue à ProcessMultipleLevelUps
--- pour gérer plusieurs level-ups consécutifs.
---
--- Mécanismes d'extensibilité via Mediator :
--- - Permet l'ajustement de l'XP avant traitement
--- - Permet des effets personnalisés après les level-ups
--- - Permet des logs et notifications
---
--- @param player The player object receiving the experience
--- @param paragon The paragon instance to update
--- @param specific_experience The amount of experience to add
--- @return paragon The updated paragon instance
---
local function OnUpdatePlayerExperience(player, paragon, specific_experience)
    -- Convert to number if received as string from database
    if type(specific_experience) == "string" then
        specific_experience = tonumber(specific_experience)
    end

    if not paragon or not specific_experience or specific_experience <= 0 then
        return paragon
    end

    local previous_level = paragon:GetLevel()
    local previous_exp = paragon:GetExperience()

    -- Process cascading level-ups
    paragon, levels_gained = ProcessMultipleLevelUps(paragon, specific_experience)

    -- Store for logging in level change handler
    if paragon then
        paragon._last_levels_gained = levels_gained
        paragon._last_exp_gained = specific_experience
    end

    return paragon
end

-- ============================================================================
-- EXPERIENCE MODIFIER (HOOK EXAMPLE)
-- ============================================================================

---
--- Hook example: Permet aux modules de modifier l'XP calculée.
--- Par exemple, ajouter des bonuses basées sur l'équipement, les buffs, etc.
---
local function OnExperienceCalculatedExample(player, paragon, source_type, specific_experience)
    if not player or not paragon then
        return specific_experience
    end

    -- EXEMPLE: Bonus basé sur le level
    local current_level = paragon:GetLevel()

    -- Bonus diminuant pour les bas niveaux (tutoriel)
    if current_level <= 5 then
        specific_experience = specific_experience * 1.5
    end

    -- Penalty pour les hauts niveaux (scaling)
    if current_level >= 100 then
        specific_experience = specific_experience * 0.8
    end

    -- EXEMPLE: Bonus basé sur des buffs
    if player:HasAura(1234) then  -- Aura de Bonus d'Anniversaire
        specific_experience = specific_experience * 1.25
    end

    -- EXEMPLE: Bonus en event spécial
    if ExperienceMultipliers.events.active then
        specific_experience = specific_experience * ExperienceMultipliers.events.multiplier
    end

    return specific_experience
end

-- ============================================================================
-- LEVEL-UP NOTIFICATION (HOOK EXAMPLE)
-- ============================================================================

---
--- Hook example: Notifie le joueur et ajoute des effects quand il monte de niveau.
--- Externalise le code de notification depuis paragon_hook.
---
local function OnParagonLevelChangedExample(paragon, old_level, new_level)
    if not paragon then
        return
    end

    -- Cette fonction sera appelée automatiquement via le Mediator
    -- quand le niveau change, sans nécessiter de code dans paragon_hook

    -- Les notifications pourraient être ajoutées ici
    -- Des effects spéciaux visuels
    -- Du logging
    -- etc.
end

-- ============================================================================
-- LOGGING & TRACKING (HOOK EXAMPLE)
-- ============================================================================

---
--- Hook example: Logs toutes les mises à jour d'expérience pour audit/debugging.
--- Démontre comment tracker les actions sans modifier paragon_hook.
---
local function OnAfterUpdatePlayerExperienceExample(player, paragon)
    if not player or not paragon then
        return
    end

    -- EXEMPLE: Logging simplifié
    local last_exp = paragon._last_exp_gained or 0
    local last_levels = paragon._last_levels_gained or 0

    if last_exp > 0 then
        -- En production, cela serait une vraie fonction de log
        -- print("Player " .. player:GetName() .. " gained " .. last_exp .. " XP, " .. last_levels .. " levels")
    end
end

-- ============================================================================
-- STAT ALLOCATION VALIDATION (HOOK EXAMPLE)
-- ============================================================================

---
--- Hook example: Valide les allocations de stats avec règles personnalisées.
--- Montre comment implémenter des règles métier via le Mediator.
---
local function OnBeforeStatisticChangeExample(player, paragon, stat_id, stat_value)
    if not player or not paragon or not stat_id then
        return paragon, stat_id, stat_value
    end

    -- EXEMPLE: Limite les stats en PvP
    if player:IsInPvP() and stat_value > 50 then
        stat_value = 50
    end

    -- EXEMPLE: Valide que le joueur a assez de points
    local current_value = paragon:GetStatValue(stat_id)
    local point_difference = stat_value - current_value
    local available_points = paragon:GetPoints()

    if point_difference > available_points then
        -- Rejette silencieusement ou restreint
        stat_value = current_value + available_points
    end

    return paragon, stat_id, stat_value
end

-- ============================================================================
-- STAT APPLICATION EFFECTS (HOOK EXAMPLE)
-- ============================================================================

---
--- Hook example: Ajoute des effects spéciaux quand les stats sont appliquées.
--- Par exemple, des auras visuelles, des sons, des animations.
---
local function OnAfterUpdatePlayerStatisticsExample(player, paragon, apply)
    if not player or not paragon then
        return
    end

    -- EXEMPLE: Aura visuelle quand les stats sont appliquées
    if apply and paragon:GetUsedPoints() > 0 then
        -- player:AddAura(12345, player)  -- Aura visuelle de buff paragon
    end

    -- EXEMPLE: Notification au joueur
    if apply then
        -- player:SendBroadcastMessage("Paragon bonuses applied!")
    end
end

-- ============================================================================
-- MODULE REGISTRATION
-- ============================================================================

---
--- Enregistre le handler d'expérience principal avec le Mediator.
--- C'est la seule fonction OBLIGATOIRE pour le fonctionnement du système.
---
RegisterMediatorEvent("OnUpdatePlayerExperience", OnUpdatePlayerExperience)

---
--- Les hooks d'exemple suivants sont OPTIONNELS et montrent
--- comment étendre le système via le Mediator.
--- Ils peuvent être activés/désactivés selon les besoins.
---

-- HOOK: Modifie l'XP calculée avec des bonus/multiplicateurs
-- Décommenter pour activer:
-- RegisterMediatorEvent("OnExperienceCalculated", OnExperienceCalculatedExample)

-- HOOK: Notification de level-up
-- Décommenter pour activer:
-- RegisterMediatorEvent("OnParagonLevelChanged", OnParagonLevelChangedExample)

-- HOOK: Logging des actions
-- Décommenter pour activer:
-- RegisterMediatorEvent("OnAfterUpdatePlayerExperience", OnAfterUpdatePlayerExperienceExample)

-- HOOK: Validation personnalisée des stats
-- Décommenter pour activer:
-- RegisterMediatorEvent("OnBeforeStatisticChange", OnBeforeStatisticChangeExample)

-- HOOK: Effects spéciaux à l'application des stats
-- Décommenter pour activer:
-- RegisterMediatorEvent("OnAfterUpdatePlayerStatistics", OnAfterUpdatePlayerStatisticsExample)

-- ============================================================================
-- PUBLIC API (Optional - for manual triggering or testing)
-- ============================================================================

---
--- API publique pour déclencher manuellement des actions.
--- Utile pour les tests, les commandes admin, etc.
---
return {
    --- Déclenche manuellement un level-up
    TriggerLevelUp = function(paragon)
        if paragon then
            paragon:AddLevel(1)
        end
    end,

    --- Déclenche manuellement un gain d'XP
    TriggerExperienceGain = function(player, paragon, amount)
        if player and paragon and amount then
            OnUpdatePlayerExperience(player, paragon, amount)
        end
    end,

    --- Ajoute un multiplicateur d'XP temporaire (événement spécial)
    SetEventMultiplier = function(multiplier, duration)
        ExperienceMultipliers.events.active = true
        ExperienceMultipliers.events.multiplier = multiplier
        -- Duration handling would require a timer system
    end,

    --- Retire le multiplicateur d'événement
    ClearEventMultiplier = function()
        ExperienceMultipliers.events.active = false
        ExperienceMultipliers.events.multiplier = 1
    end,
}
