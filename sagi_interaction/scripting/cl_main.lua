local QBCore = exports['qb-core']:GetCoreObject()
local isNearAnyZone = false
local currentZone = nil
local isHolding = false

function AddInteractionZone(zoneData)
    if not zoneData.coords or not zoneData.event then
        return
    end
    table.insert(Config.InteractionZones, zoneData)
end
exports('AddInteractionZone', AddInteractionZone)

RegisterNUICallback('interactionSuccess', function(data, cb)
    if currentZone then
        TriggerServerEvent(currentZone.event, currentZone.eventData)
        isHolding = false
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end
    cb('ok')
end)

CreateThread(function()
    while true do
        local sleep = 1500
        local playerCoords = GetEntityCoords(PlayerPedId())
        local nearestZone = nil
        for _, zone in ipairs(Config.InteractionZones) do
            local distance = #(playerCoords - zone.coords)
            if distance < 50.0 then
                if not nearestZone or distance < nearestZone.distance then
                    nearestZone = { distance = distance, data = zone }
                end
            end
        end
        if nearestZone then
            sleep = 500
            local wasNear = isNearAnyZone
            isNearAnyZone = false
            currentZone = nil
            if nearestZone.distance < nearestZone.data.radius then
                local playerData = QBCore.Functions.GetPlayerData()
                local canSee = true
                if nearestZone.data.allowedJobs and #nearestZone.data.allowedJobs > 0 then
                    canSee = false
                    for _, job in ipairs(nearestZone.data.allowedJobs) do
                        if job == playerData.job.name then
                            canSee = true
                            break
                        end
                    end
                end
                if canSee and nearestZone.data.restrictedJobs and #nearestZone.data.restrictedJobs > 0 then
                    for _, job in ipairs(nearestZone.data.restrictedJobs) do
                        if job == playerData.job.name then
                            canSee = false
                            break
                        end
                    end
                end
                if canSee then
                    isNearAnyZone = true
                    currentZone = nearestZone.data
                end
            end
            if isNearAnyZone and not wasNear then
                SendNUIMessage({ action = "show", text = currentZone.text, icon = currentZone.icon })
            elseif not isNearAnyZone and wasNear then
                isHolding = false
                SendNUIMessage({ action = "hide" })
            end
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 500
        if isNearAnyZone then
            sleep = 0
            if currentZone and not isHolding and IsControlJustPressed(0, 38) then
                isHolding = true
                SendNUIMessage({ action = "startProgress", duration = currentZone.duration })
            end
            if isHolding and (IsControlJustReleased(0, 38) or not isNearAnyZone) then
                isHolding = false
                SendNUIMessage({ action = "cancelProgress" })
            end
        else
            if isHolding then
                isHolding = false
                SendNUIMessage({ action = "cancelProgress" })
            end
        end
        Wait(sleep)
    end
end)

-- CreateThread(function()
--     Wait(1000)
--     local interaction = exports.sagi_interaction 
--     if not interaction then
--         return
--     end
--     interaction:AddInteractionZone({
--         coords = vector3(81.75, -1383.40, 29.29),
--         radius = 2.5,
--         duration = 2500,
--         text = "Access Garage",
--         icon = "fa-solid fa-warehouse",
--         event = "my-garage-script:server:openMenu",
--         eventData = { message = "You have checked in for duty!" },
--         allowedJobs = { "police", "ambulance" }
        
--     })
-- end)