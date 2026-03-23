if HeapsNReaps == nil then
    HeapsNReaps = class({})
end

require("timers")
require("settings")

-----------------------------------------------------
-- Link Lua Modifiers
-----------------------------------------------------
LinkLuaModifier("modifier_bonus_cast_range", "modifiers/modifier_bonus_cast_range.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_max_health_cap", "modifiers/modifier_max_health_cap.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_vision", "modifiers/modifier_bonus_vision.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cooldown_reduction", "modifiers/modifier_cooldown_reduction.lua", LUA_MODIFIER_MOTION_NONE)


-----------------------------------------------------
-- Precache & Init
-----------------------------------------------------
function Precache(context)
    print("[HEAPS_N_REAPS] Precache started...")

    -- Necro's ultimate
    PrecacheResource("particle", "particles/units/heroes/hero_necrolyte/necrolyte_scythe.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_necrolyt.vsndevts", context)

    -- Clockwerk Hookshot
    PrecacheResource("particle", "particles/units/heroes/hero_rattletrap/rattletrap_hookshot.vpcf", context)

    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_rattletrap.vsndevts", context)

    print("[HEAPS_N_REAPS] Precache complete.")
end

function Activate()
    print("[HEAPS_N_REAPS] Activating game mode...")
    GameRules.HeapsNReaps = HeapsNReaps()
    GameRules.HeapsNReaps:InitGameMode()
end

-----------------------------------------------------
-- Hero Leveling
-----------------------------------------------------
function HeapsNReaps:LevelHero(hero, targetLevel)
    if not IsValidEntity(hero) or not hero:IsRealHero() then return end

    while hero:GetLevel() < targetLevel do
        hero:HeroLevelUp(false)
    end

    -- Max all abilities
    for i = 0, hero:GetAbilityCount() - 1 do
        local ability = hero:GetAbilityByIndex(i)
        if ability and ability:GetMaxLevel() > 0 then
            ability:SetLevel(ability:GetMaxLevel())
        end
    end
end

-----------------------------------------------------
-- Replace Pudge Abilities (Swap one-for-one)
-----------------------------------------------------
function HeapsNReaps:ReplacePudgeAbilities(hero)
    if not IsValidEntity(hero) or not hero:IsRealHero() then return end

    -- Swap Rot -> Hookshot
    if hero:HasAbility("pudge_rot") then
        local hookshot = hero:AddAbility("rattletrap_hookshot")
        if hookshot then
            hookshot:SetLevel(3)
            hero:SwapAbilities("pudge_rot", "rattletrap_hookshot", false, true)
            hero:RemoveAbility("pudge_rot")
        end
    end

    -- Swap Meat Shield -> Arcane Supremacy
    if hero:HasAbility("pudge_flesh_heap") then
        local arcane = hero:AddAbility("rubick_arcane_supremacy")
        if arcane then
            arcane:SetLevel(4)
            hero:SwapAbilities("pudge_flesh_heap", "rubick_arcane_supremacy", false, true)
            hero:RemoveAbility("pudge_flesh_heap")
        end
    end

    -- Swap Dismember -> Reapers Scythe
    if hero:HasAbility("pudge_dismember") then
        local scythe = hero:AddAbility("necrolyte_reapers_scythe")
        if scythe then
            scythe:SetLevel(3)
            hero:SwapAbilities("pudge_dismember", "necrolyte_reapers_scythe", false, true)
            hero:RemoveAbility("pudge_dismember")
        end
    end


end

-----------------------------------------------------
-- Apply Modifiers Individually
-----------------------------------------------------
function HeapsNReaps:ApplyModifiers(hero)
    if not hero:HasModifier("modifier_max_health_cap") then
        hero:AddNewModifier(hero, nil, "modifier_max_health_cap", {})
    end
    if not hero:HasModifier("modifier_bonus_cast_range") then
        hero:AddNewModifier(hero, nil, "modifier_bonus_cast_range", {})
    end
    if not hero:HasModifier("modifier_bonus_vision") then
        hero:AddNewModifier(hero, nil, "modifier_bonus_vision", { vision_bonus = BONUS_VISION })
    end
    if not hero:HasModifier("modifier_cooldown_reduction") then
        hero:AddNewModifier(hero, nil, "modifier_cooldown_reduction", {})
    end
    if not hero:HasModifier("modifier_hookshot_speed") then
        hero:AddNewModifier(hero, nil, "modifier_hookshot_speed", {})
    end
end

-----------------------------------------------------
-- Safe Item
-----------------------------------------------------
function HeapsNReaps:GiveItemSafe(hero, itemName)
    if not IsValidEntity(hero) or not hero:IsRealHero() then return end
    local item = CreateItem(itemName, hero, hero)
    if item then hero:AddItem(item) end
end

-----------------------------------------------------
-- Hero Initialization
-----------------------------------------------------
function HeapsNReaps:InitializeHero(hero)
    if not IsValidEntity(hero) or not hero:IsRealHero() then return end
    if hero._hnr_init then return end
    hero._hnr_init = true

    print("[HEAPS_N_REAPS] Initializing hero: " .. hero:GetUnitName())

    -- Level hero & max abilities
    self:LevelHero(hero, HERO_STARTING_LEVEL)

    -- Give starting items
    self:GiveItemSafe(hero, "item_boots")
    self:GiveItemSafe(hero, "item_magic_wand")
    self:GiveItemSafe(hero, "item_aghanims_shard")
    self:GiveItemSafe(hero, "item_magnifying_monocle")

    -- Replace Pudge abilities
    if hero:GetUnitName() == "npc_dota_hero_pudge" then
        Timers:CreateTimer(0.25, function()
            self:ReplacePudgeAbilities(hero)
        end)
    end

    -- Apply modifiers individually
    self:ApplyModifiers(hero)

end

-----------------------------------------------------
-- Game Mode Initialization
-----------------------------------------------------
function HeapsNReaps:InitGameMode()
    print("[HEAPS_N_REAPS] Initializing Game Mode...")

    local mode = GameRules:GetGameModeEntity()
    if not mode then return end

    -- Basic setup
    GameRules:EnableCustomGameSetupAutoLaunch(true)
    GameRules:SetCustomGameSetupAutoLaunchDelay(20)
    GameRules:SetCustomGameSetupRemainingTime(20)
    GameRules:SetCustomGameSetupTimeout(20)

    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, PLAYERS_PER_TEAM)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, PLAYERS_PER_TEAM)


    GameRules:SetHeroSelectionTime(0)
    GameRules:SetStrategyTime(0)
    GameRules:SetShowcaseTime(0)
    GameRules:SetPreGameTime(PRE_GAME_TIME)

    mode:SetCustomScanCooldown(SCAN_COOLDOWN)
    mode:SetCustomScanMaxCharges(SCAN_MAX_CHARGES)

    GameRules:SetHeroRespawnEnabled(true)
    mode:SetBuybackEnabled(true)
    GameRules:GetGameModeEntity():SetFixedRespawnTime(RESPAWN_TIME)

    GameRules:SetStartingGold(STARTING_GOLD)
    GameRules:SetGoldPerTick(GOLD_PER_TICK)
    GameRules:SetGoldTickTime(1)

    GameRules:SetSameHeroSelectionEnabled(true)
    mode:SetCustomGameForceHero("npc_dota_hero_pudge")


    -- NPC Spawn listener
    ListenToGameEvent("npc_spawned", function(event) self:OnNPCSpawned(event) end, nil)

    -- Force always day
    Timers:CreateTimer(1.0, function()
        GameRules:SetTimeOfDay(0.25)
        return 5.0
    end)

    -- Out-of-bounds protection: track last safe position, teleport back if off navmesh
    Timers:CreateTimer(0.5, function()
        for _, hero in pairs(HeroList:GetAllHeroes()) do
            if IsValidEntity(hero) and hero:IsAlive() and hero:IsRealHero() then
                local pos = hero:GetAbsOrigin()
                if GridNav:IsTraversable(pos) then
                    hero._lastSafePos = pos
                else
                    local safePos = hero._lastSafePos
                    if safePos then
                        hero:SetAbsOrigin(safePos)
                        FindClearSpaceForUnit(hero, safePos, true)
                        print("[HEAPS_N_REAPS] Returned " .. hero:GetUnitName() .. " to map bounds.")
                    end
                end
            end
        end
        return 0.5
    end)

    -- Game state listener
    ListenToGameEvent("game_rules_state_change", function()
        local state = GameRules:State_Get()
        if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
            Timers:CreateTimer(GAME_LENGTH, function() self:EndGameCheck(true) end)
        end
    end, nil)

    print("[HEAPS_N_REAPS] Game Mode Initialized!")
end

-----------------------------------------------------
-- NPC Spawn Handler
-----------------------------------------------------
function HeapsNReaps:OnNPCSpawned(event)
    local hero = EntIndexToHScript(event.entindex)
    if not hero or not hero:IsRealHero() or hero._hnr_init then return end

    print("[HEAPS_N_REAPS] NPC Spawned: "..hero:GetUnitName())
    self:InitializeHero(hero)
end

-----------------------------------------------------
-- Entity Killed Listener
-----------------------------------------------------
ListenToGameEvent("entity_killed", function(event)
    local killed = EntIndexToHScript(event.entindex_killed or -1)
    local attacker = EntIndexToHScript(event.entindex_attacker or -1)
    if not (killed and killed:IsRealHero()) then return end

    if attacker and attacker:IsRealHero() and attacker:GetUnitName() == "npc_dota_hero_pudge" then
        -- Track personal kills for scaling
        attacker._hnr_kills = (attacker._hnr_kills or 0) + 1
        -- Grow model size
        attacker:SetModelScale(attacker:GetModelScale() + KILL_SIZE_SCALING)
    end

    GameRules.HeapsNReaps:EndGameCheck()
end, nil)

-----------------------------------------------------
-- Game End Check
-----------------------------------------------------
function HeapsNReaps:EndGameCheck(forceTimerCheck)
    forceTimerCheck = forceTimerCheck or false
    if self.gameEnded then return end

    local pudgeKills, cmKills = 0, 0
    for _, hero in pairs(HeroList:GetAllHeroes()) do
        if hero:IsRealHero() then
            if hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
                pudgeKills = pudgeKills + (hero:GetKills() or 0)
            elseif hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
                cmKills = cmKills + (hero:GetKills() or 0)
            end
        end
    end

    local winner
    if pudgeKills >= KILL_STOPPAGE then
        winner = DOTA_TEAM_BADGUYS
    elseif cmKills >= KILL_STOPPAGE then
        winner = DOTA_TEAM_GOODGUYS
    elseif forceTimerCheck then
        if pudgeKills > cmKills then winner = DOTA_TEAM_BADGUYS
        elseif cmKills > pudgeKills then winner = DOTA_TEAM_GOODGUYS
        else winner = DOTA_TEAM_NOTEAM end
    else return end

    self.gameEnded = true

    if winner == DOTA_TEAM_BADGUYS then
        GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
        GameRules:SetCustomVictoryMessage("Dire wins with " .. pudgeKills .. " kills!")
    elseif winner == DOTA_TEAM_GOODGUYS then
        GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
        GameRules:SetCustomVictoryMessage("Radiant wins with " .. cmKills .. " kills!")
    else
        GameRules:SetSafeToLeave(true)
        GameRules:MakeTeamLose(DOTA_TEAM_BADGUYS)
        GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS)
        GameRules:SetCustomVictoryMessage("It's a tie! Both teams have " .. pudgeKills .. " kills!")
    end

    GameRules:SetCustomVictoryMessageDuration(10)
end