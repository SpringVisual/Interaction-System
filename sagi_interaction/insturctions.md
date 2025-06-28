# Interaction Script Documentation

This document explains how to create custom interaction points using the `sagi_interaction` script. There are two methods available: a simple configuration for server owners and an advanced export for developers.

---

## Method 1: Using `config.lua` (Simple)

This is the easiest way to add new interaction points to your server. You simply add a new entry to the `Config.InteractionZones` table in the `config.lua` file.

### Steps
1.  Open the `config.lua` file located in the `sagi_interaction` resource folder.
2.  Add a new table entry inside `Config.InteractionZones = { ... }`.

### Zone Parameters
Each interaction zone is a table that can have the following properties:

| Parameter        | Type    | Required | Description                                                               |
| ---------------- | ------- | -------- | ------------------------------------------------------------------------- |
| `coords`         | vector3 | Yes      | The XYZ coordinates in the game world for the interaction.                |
| `event`          | string  | Yes      | The name of the server event to trigger upon successful interaction.      |
| `text`           | string  | Yes      | The text that will appear in the label (e.g., "Access Garage").           |
| `icon`           | string  | Yes      | The Font Awesome icon class (e.g., "fa-solid fa-warehouse").              |
| `radius`         | number  | Yes      | How close the player needs to be to see the prompt (in meters).           |
| `duration`       | number  | Yes      | How long the player must hold 'E' (in milliseconds). 1000 = 1 second.     |
| `allowedJobs`    | table   | No       | A list of job names that are **allowed** to see this prompt.              |
| `restrictedJobs` | table   | No       | A list of job names that are **restricted** from seeing this prompt.      |
| `eventData`      | any     | No       | Extra data you want to send with the server event.                        |

### Example
Here is how you would add a new interaction for a police armory in `config.lua`:

```lua
-- in sagi_interaction/config.lua
Config.InteractionZones = {
    -- ... other zones can be here

    {
        coords = vector3(453.8, -981.5, 30.7),
        radius = 1.5,
        duration = 1500,
        text = "Access Armory",
        icon = "fa-solid fa-gun",
        event = "police:server:openArmory", -- This event will be triggered on the server
        allowedJobs = { "police" } -- Only the 'police' job can see this
    }
}

Method 2: Using the Export (For Developers)
This method allows you to create interaction zones dynamically from your other client-side scripts, which is useful for keeping your resources modular.

Steps
Ensure your other resource starts after sagi_interaction. You can do this by adding server_script '@sagi_interaction/server/server.lua' to your other resource's fxmanifest.lua.

In your other resource's client script, call the exported function AddInteractionZone.

Example
Here is how you would add a garage interaction point from a separate my-garage-script/client.lua:

-- in my-garage-script/client.lua

CreateThread(function()
    -- It's good practice to wait a moment to ensure all scripts are loaded.
    Wait(1000)

    -- Access the exports from your interaction script (use your resource folder name).
    local interaction = exports.sagi_interaction 

    if not interaction then
        print("^1[my-garage-script] ERROR: Could not find sagi_interaction exports.")
        return
    end

    -- Call the exported function to add a new zone.
    -- The parameters are the same as in the config file.
    interaction:AddInteractionZone({
        coords = vector3(81.75, -1383.40, 29.29),
        radius = 2.5,
        duration = 2500,
        text = "Access Garage",
        icon = "fa-solid fa-warehouse",
        event = "my-garage-script:server:openMenu",
        eventData = { message = "You have checked in for duty!" },
        allowedJobs = { "police", "ambulance" }
    })
end)

Handling the Triggered Event (Server-Side)
Regardless of which method you use to create the zone, the final step is always the same: you must listen for the event on the server to make the interaction do something.

Example
This code would be placed in the server-side script that should handle the action (e.g., qb-policejob/server.lua or my-garage-script/server.lua).

-- This listener catches the event triggered by the interaction script.
-- The event name must match exactly what you defined in the zone data.

RegisterNetEvent('police:server:openArmory', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.job.name == 'police' then
        -- Your logic to open the armory menu for the player goes here.
        TriggerClientEvent('qb-policejob:client:openArmoryMenu', src) 
    end
end)
