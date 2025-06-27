--@module = true

local eventful = require('plugins.eventful')
local repeatUtil = require('repeat-util')

local GLOBAL_KEY = "hookah_trigger"

-- Configuration
local timeout_time = 200        -- ticks between gas bursts
local base_gas_density = 30000       -- density per burst
local gas_bursts = 5            -- number of bursts

local material_flow_type = {
	["mist"] = 2,
	["pipe-weed"] = 9,
	["hemp"] = 9,
	["marijuana"] = 9,
	["hashish"] = 9,
	["shisha"] = 9,
	["green dragon"] = 10,
	["philophers"] = 10,
	["warbow"] = 10,
	["tumult"] = 10,
	["golden salve"] = 10,
        ["opium"] = 9
}

local material_bursts = {
	["mist"] = 0,
	["pipe-weed"] = 2, -- 6,
	["hemp"] = 2, -- 6,
	["marijuana"] = 3, -- 10,
	["hashish"] = 3, -- 10,
	["shisha"] = 4, --30,
	["green dragon"] = 3, --20,
	["philophers"] = 3 --20
	["warbow"] = 3, --20
	["tumult"] = 3, --20
	["golden salve"] = 3, --20
	["opium"] = 3 --20
}

local material_gas_density = {
	["mist"] = 300,
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
	["opium"] = base_gas_density
}

-- Spawns gas or mist at the unit's position over time
local function multispawn_gas(reaction, reaction_product, unit, in_items, in_reag, out_items, call_native)
        local pos = copyall(unit.pos)

        local idx = 0

        for i,v in ipairs(in_reag) do
            if (material_flow_type[v.code]) then
                idx = i
                break
            end
        end

        local mat = in_items[idx]
        local reag = in_reag[idx]
        local type_of_flow, sflow_type, sflow_index

        dfhack.printerr("Inside hookah_trigger multispawn_gas handler: "..reag.code)
        dfhack.printerr("Inside hookah_trigger multispawn_gas handler loop mat_type: "..mat.mat_type)
        dfhack.printerr("Inside hookah_trigger multispawn_gas handler loop mat_index: "..mat.mat_index)

        -- First burst
        local flow_info = dfhack.maps.spawnFlow(pos, material_flow_type[reag.code], mat.mat_type, mat.mat_index, material_gas_density[reag.code])
        flow_info.density = material_gas_density[reag.code]
        flow_info.flags.CREEPING = true

        -- Repeating bursts
        for i = 1, material_bursts[reag.code] do
            dfhack.timeout(timeout_time * i, "ticks", function()
                local flow = dfhack.maps.spawnFlow(pos, type_of_flow, sflow_type, sflow_index, gas_density)
                flow.density = gas_density
                flow.flags.CREEPING = true
            end)
        end

        call_native.value = false
end

-- Hook a reaction to gas emission
local function activate_trigger(event_name)
    eventful.registerReaction(event_name, multispawn_gas)
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
end

-- Enable hookah system
function onEnable()
    activate_triggers()
    dfhack.printerr("hookah_trigger enabled")
end

-- Disable system and clear scheduled flows
function onDisable()
    dfhack.timeout_active(timeout_id, nil)
end