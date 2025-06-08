local Config = {
    AquaticPeds = {
        [`popcornrppython`] = true,
        -- Add more aquatic peds/peds that need to survive outside of the water here
    },
    PreSwitchDelay = 50,      -- ms delay BEFORE ped switch
    PostSwitchDelay = 250,    -- ms delay AFTER ped switch
    ReapplyInterval = 1000    -- ms interval to reapply aquatic protections
}

local currentPed = nil
local isSwitchingPeds = false

local function IsPedAquatic(ped)
    if not DoesEntityExist(ped) then return false end
    local model = GetEntityModel(ped)
    return Config.AquaticPeds[model] or false
end

local function SetupAquaticPed(ped)
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end
    SetPedSurvivesBeingOutOfWater(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetEntityProofs(ped, false, false, true, false, false, true, false, false)
    SetPedCanBeKnockedOffVehicle(ped, 1)
    SetPedConfigFlag(ped, 224, true)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
end

exports('SetupAquaticPed', SetupAquaticPed)

local function SafeSwitchToAquaticPed(modelHash)
    isSwitchingPeds = true

    local prevPed = PlayerPedId()
    SetEntityInvincible(prevPed, true)
    Wait(Config.PreSwitchDelay)

    local newPed = CreatePed(4, modelHash, GetEntityCoords(prevPed), GetEntityHeading(prevPed), true, true)
    SetPlayerModel(PlayerId(), modelHash)
    SetPedAsNoLongerNeeded(newPed)

    SetEntityInvincible(newPed, true)
    FreezeEntityPosition(newPed, true)
    Wait(Config.PostSwitchDelay)

    SetupAquaticPed(newPed)

    FreezeEntityPosition(newPed, false)
    SetEntityInvincible(newPed, false)
    DeleteEntity(prevPed)

    currentPed = newPed
    isSwitchingPeds = false
end

function SwitchToModel(modelHash)
    if Config.AquaticPeds[modelHash] then
        SafeSwitchToAquaticPed(modelHash)
    else
        local ped = CreatePed(4, modelHash, GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, true)
        SetPlayerModel(PlayerId(), modelHash)
        SetPedAsNoLongerNeeded(ped)
    end
end

-- One-time setup on switch or spawn
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()

        if not isSwitchingPeds and ped ~= currentPed then
            if IsPedAquatic(ped) then
                SetupAquaticPed(ped)
            elseif currentPed and DoesEntityExist(currentPed) then
                SetPedSurvivesBeingOutOfWater(currentPed, false)
                SetPedDiesWhenInjured(currentPed, true)
            end
            currentPed = ped
        end
    end
end)

-- Continuous protection on every tick
local isAquaticActive = false

-- Smart high-frequency thread that activates only when needed
CreateThread(function()
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        local isAquatic = IsPedAquatic(ped)

        if isAquatic and not isAquaticActive then
            isAquaticActive = true
            -- Start protection thread
            CreateThread(function()
                while isAquaticActive do
                    Wait(0) -- every frame
                    local p = PlayerPedId()
                    if not IsPedAquatic(p) or IsEntityDead(p) then
                        isAquaticActive = false
                        break
                    end
                    SetPedSurvivesBeingOutOfWater(p, true)
                    SetPedDiesWhenInjured(p, false)
                    SetEntityProofs(p, false, false, true, false, false, true, false, false)
                    SetPedCanRagdoll(p, false)
                    SetPedCanBeKnockedOffVehicle(p, 1)
                    SetPedConfigFlag(p, 224, true)
                end
            end)
        elseif not isAquatic and isAquaticActive then
            isAquaticActive = false
        end
    end
end)
