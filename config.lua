--------------------------------------------
--  ___  _               _   ____             
--  / _ \| |__   __ _  __| | |  _ \  _____   __
-- | | | | '_ \ / _` |/ _` | | | | |/ _ \ \ / /
-- | |_| | | | | (_| | (_| | | |_| |  __/\ V / 
--  \___/|_| |_|\__,_|\__,_| |____/ \___| \_/  
--------------------------------------------
-- 
Config = {}

-- פריימוורק:
--  'qb'       : QBCore
--  'esx'      : ESX 1.9+
--  'oldesx'   : ESX 1.8< 
Config.FrameWork = 'qb'

-- זמן בדיקה בין נשקים (לא ממולץ לגעת)
Config.LoopDelay = 10

----------------------------------------------------
-- חוקים לכנופיות: לאפשר לחברי כנופיה להשתמש בנשקי משטרה
-- false = גאנגים/משפחות לא יכולים להשתמש בנשקים כמו משטרה
-- true  = גאנגים/משפחות כן יכולים להשתמש בנשקי משטרה
----------------------------------------------------
Config.AllowCrimeToUseJobGuns = false

----------------------------------------------------
-- עבודות וגאנגים עם גישה כללית
-- שיכולים להשתמש בנשקים **שלא** מופיעים בנשקים מוגבלים
----------------------------------------------------
Config.AllowedJobs = {
    'police',
    'ambulance',
}

Config.AllowedGangs = {
    'solo',
    'heads',
}

----------------------------------------------------
-- נשקים מוגבלים (שליטה מדויקת לפי תפקיד/גאנג)
-- הוסף לפה רק נשקים שדורשים הרשאה מיוחדת
----------------------------------------------------
Config.RestrictedWeapons = {
    -- נשקים רק של משטרה
    ['WEAPON_CARBINERIFLE'] = {
        jobs = { 'police' }
    },

    -- רק לגאנגים
    ['WEAPON_MICROSMG'] = {
        gangs = { 'solo', 'heads' }
    },
    
    -- גישה משותפת (של משטרה/גאנגים)
    ['WEAPON_COMBATPISTOL'] = {
        jobs  = { 'police' },
        gangs = { 'heads' }
    }
}

----------------------------------------------------
-- אזור מסוכן לא לגעת אם אתה לא יודע מה אתה עושה!!
----------------------------------------------------

-- Debug mode
Config.Debug = false
Config.PlayerLoadedEventName = nil
Config.JobUpdateEventName    = nil
Config.GangUpdateEventName   = nil

if Config.FrameWork == 'qb' then
    Config.PlayerLoadedEventName = 'QBCore:Client:OnPlayerLoaded'
    Config.JobUpdateEventName    = 'QBCore:Client:OnJobUpdate'
    Config.GangUpdateEventName   = 'QBCore:Client:OnGangUpdate'
elseif Config.FrameWork == 'esx' or Config.FrameWork == 'oldesx' then
    Config.PlayerLoadedEventName = 'esx:playerLoaded'
    Config.JobUpdateEventName    = 'esx:setJob'
    Config.GangUpdateEventName   = 'esx:gangUpdate' -- אם גרסת ה-ESX שלך תומכת בזה
end