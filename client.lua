local Config   = Config or {}
local Framework = Config.FrameWork
local QBCore, ESX = nil, nil

if Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Framework == 'esx' or Framework == 'oldesx' then
    if Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    else
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        while ESX == nil do Citizen.Wait(100) end
    end
end

local PlayerJob, PlayerGang = nil, nil

local function debugPrint(...)
    if Config.Debug then print("[WeaponAccess]", ...) end
end

local function tableHas(tbl, val)
    if not tbl or not val then return false end
    val = string.upper(val)
    for _, v in pairs(tbl) do
        if string.upper(v) == val then return true end
    end
    return false
end

local function refreshPlayerData()
    if Framework == 'qb' and QBCore then
        local data = QBCore.Functions.GetPlayerData()
        PlayerJob  = data.job  and data.job.name  or nil
        PlayerGang = data.gang and data.gang.name or nil
    elseif (Framework == 'esx' or Framework == 'oldesx') and ESX then
        local xP = ESX.GetPlayerData and ESX.GetPlayerData() or {}
        PlayerJob  = xP.job  and xP.job.name  or nil
        PlayerGang = xP.gang and xP.gang.name or nil
    end
    debugPrint("Job:", PlayerJob, "Gang:", PlayerGang)
end

RegisterNetEvent('oh-weaponaccess:client:notify', function(msg, ntype)
    if Framework == 'qb' then
        TriggerEvent('QBCore:Notify', msg, ntype or 'error')
    else
        TriggerEvent('esx:showNotification', msg)
    end
end)

local function notify(msg, ntype)
    TriggerEvent('oh-weaponaccess:client:notify', msg, ntype)
end

CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(100) end
    if Framework == 'qb' then while not QBCore do Wait(100) end
    elseif Framework ~= 'none' then while not ESX do Wait(100) end end
    refreshPlayerData()
end)

RegisterNetEvent(Config.PlayerLoadedEventName, refreshPlayerData)
RegisterNetEvent(Config.JobUpdateEventName,  function(job)  PlayerJob  = job  and job.name  or nil end)
if Config.GangUpdateEventName then
    RegisterNetEvent(Config.GangUpdateEventName, function(gang) PlayerGang = gang and gang.name or nil end)
end

CreateThread(function()
    while true do
        Wait(Config.LoopDelay or 1500)

        local ped = PlayerPedId()
        if not IsPedArmed(ped, 6) then goto continue end

        local weaponHash = GetSelectedPedWeapon(ped)
        if weaponHash == 0 then goto continue end

        local rawName
        if QBCore and QBCore.Shared and QBCore.Shared.Weapons
           and QBCore.Shared.Weapons[weaponHash]
           and QBCore.Shared.Weapons[weaponHash].name
        then
            rawName = QBCore.Shared.Weapons[weaponHash].name
        else
            rawName = string.format("WEAPON_%X", weaponHash)
        end
        local weaponName = string.upper(rawName)

        if tableHas(Config.BlackListedWeapons, weaponName) then goto continue end

        local allowed = false
        local rule = Config.RestrictedWeapons[weaponName]

        local hasAllowedJob  = tableHas(Config.AllowedJobs, PlayerJob)
        local hasAllowedGang = tableHas(Config.AllowedGangs, PlayerGang)

        -- Must have gang or allowed job to use ANY weapon
        if (PlayerGang == nil or PlayerGang == 'none') and not hasAllowedJob then
            allowed = false
        else
            if rule then
                local jobOk  = rule.jobs  and tableHas(rule.jobs, PlayerJob)
                local gangOk = rule.gangs and tableHas(rule.gangs, PlayerGang)

                if rule.jobs and not rule.gangs then
                    if jobOk then
                        allowed = true
                    elseif hasAllowedGang and Config.AllowCrimeToUseJobGuns then
                        allowed = true
                    end

                elseif rule.gangs and not rule.jobs then
                    allowed = gangOk

                elseif rule.jobs and rule.gangs then
                    if jobOk then
                        allowed = true
                    elseif gangOk and Config.AllowCrimeToUseJobGuns then
                        allowed = true
                    end
                end
            else
                -- no restriction on this weapon, but player must have gang or job
                if hasAllowedJob or hasAllowedGang then
                    allowed = true
                else
                    allowed = false
                end
            end
        end

        if not allowed then
            print("^1REMOVING WEAPON:", weaponName, "Job:", PlayerJob, "Gang:", PlayerGang)
            RemoveWeaponFromPed(ped, weaponHash)
            notify("❌ אין לך הרשאה להשתמש בנשק הזה", "error")
        end

        ::continue::
    end
end)
