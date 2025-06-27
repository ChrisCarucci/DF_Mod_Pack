--@module = true

local eventful = require('plugins.eventful')
local repeatUtil = require('repeat-util')

local GLOBAL_KEY = "hookah_trigger"

-- Configuration
local timeout_time = 200        -- ticks between gas bursts
local base_gas_density = 800       -- density per burst
local gas_bursts = 5            -- number of bursts

local material_flow_type = {
	["mist"] = 2,
	["pipe-weed"] = 9,
	["hemp"] = 9,
	["marijuana"] = 9,
	["hashish"] = 9,
	["shisha"] = 9,
	["green dragon"] = 10,
	["philosophers"] = 10,
	["warbow"] = 10,
	["tumult"] = 10,
	["golden salve"] = 10,
        ["opium"] = 9,
        ["extract"] = 10
}

local material_bursts = {
	["mist"] = 0,
	["pipe-weed"] = 0, -- 6,
	["hemp"] = 0, -- 6,
	["marijuana"] = 0, -- 10,
	["hashish"] = 0, -- 10,
	["shisha"] = 0, --30,
	["green dragon"] = 0, --20,
	["philosophers"] = 0, --20
	["warbow"] = 0, --20
	["tumult"] = 0, --20
	["golden salve"] = 0, --20
	["opium"] = 0, --20
	["extract"] = 0 --20
}

local material_gas_density = {
	["mist"] = 200,
	["pipe-weed"] = base_gas_density,
	["hemp"] = base_gas_density,
	["marijuana"] = base_gas_density,
	["hashish"] = base_gas_density,
	["shisha"] = base_gas_density,
	["green dragon"] = base_gas_density,
	["philosophers"] = base_gas_density,
	["warbow"] = base_gas_density,
	["tumult"] = base_gas_density,
	["golden salve"] = base_gas_density,
	["opium"] = base_gas_density,
	["extract"] = base_gas_density
}

-- Spawns gas or mist at the unit's position over time
local function multispawn_gas(reaction, reaction_product, unit, in_items, in_reag, out_items, call_native)
        local pos = copyall(unit.pos)
        local idx = -1

        for i,v in ipairs(in_reag) do
            if (v and material_flow_type[v.code]) then
                idx = i
                break
            end
        end

        local mat_type = 6
        local mat_index = -1
        local reag_code = "mist"

        if idx > -1 then
            mat_type = in_items[idx].mat_type
            mat_index = in_items[idx].mat_index
            reag_code = in_reag[idx].code
        end

        -- First burst
        local flow_info = dfhack.maps.spawnFlow(pos, material_flow_type[reag_code], mat_type, mat_index, material_gas_density[reag_code])
        flow_info.density = material_gas_density[reag_code]
        flow_info.flags.CREEPING = true

        -- Repeating bursts
        for i = 1, 0 do -- material_bursts[reag_code] do
            dfhack.timeout(timeout_time * i, "ticks", function()
                local flow = dfhack.maps.spawnFlow(pos, material_flow_type[reag_code], mat_type, mat_index, material_gas_density[reag_code])
                flow.density = material_gas_density[reag_code]
                flow.flags.CREEPING = true
            end)
        end

        call_native.value = false
end

-- Hook a reaction to gas emission
local function activate_trigger(event_name)
    eventful.registerReaction(event_name, multispawn_gas)
end

local function deactivate_trigger(event_name)
    -- dfhack.printerr("Currently cannot deactivate: "..event_name)
    -- TODO: find out how to deactivate triggers
end

-- Register all hookah reactions
local function activate_triggers()
    activate_trigger("HOOKAH_MAKE_MIST")
    activate_trigger("HOOKAH_SMOKE_PIPE-WEED")
    activate_trigger("HOOKAH_SMOKE_HEMP")
    activate_trigger("HOOKAH_SMOKE_MARIJUANA")
    activate_trigger("HOOKAH_SMOKE_HASHISH")
    activate_trigger("HOOKAH_SMOKE_SHISHA")
    activate_trigger("HOOKAH_SMOKE_GREEN_DRAGON")
    activate_trigger("HOOKAH_SMOKE_GOLDEN_SALVE")
    activate_trigger("HOOKAH_SMOKE_WARBOW_TINCTURE")
    activate_trigger("HOOKAH_SMOKE_PHILOSOPHERS_LAMENT") 
    activate_trigger("HOOKAH_SMOKE_ESSENCE_OF_TUMULT")
    activate_trigger("HOOKAH_SMOKE_OPIUM")
    activate_trigger("HOOKAH_SMOKE_EXTRACT")
end

-- Unregister all hookah reactions
local function deactivate_triggers()
    deactivate_trigger("HOOKAH_MAKE_MIST")
    deactivate_trigger("HOOKAH_SMOKE_PIPE-WEED")
    deactivate_trigger("HOOKAH_SMOKE_HEMP")
    deactivate_trigger("HOOKAH_SMOKE_MARIJUANA")
    deactivate_trigger("HOOKAH_SMOKE_HASHISH")
    deactivate_trigger("HOOKAH_SMOKE_SHISHA")
    deactivate_trigger("HOOKAH_SMOKE_GREEN_DRAGON")
    deactivate_trigger("HOOKAH_SMOKE_GOLDEN_SALVE")
    deactivate_trigger("HOOKAH_SMOKE_WARBOW_TINCTURE")
    deactivate_trigger("HOOKAH_SMOKE_PHILOSOPHERS_LAMENT") 
    deactivate_trigger("HOOKAH_SMOKE_ESSENCE_OF_TUMULT")
    deactivate_trigger("HOOKAH_SMOKE_OPIUM")
    deactivate_trigger("HOOKAH_SMOKE_EXTRACT")
end

-- Enable hookah system
function onEnable()
    activate_triggers()
    dfhack.printerr("hookah_trigger enabled")
end

-- Disable system and clear scheduled flows
function onDisable()
    deactivate_triggers()
    dfhack.printerr("hookah_trigger disabled")
end