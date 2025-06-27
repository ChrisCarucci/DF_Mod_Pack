--@module = true

local eventful = require('plugins.eventful')
local repeatUtil = require('repeat-util')

local GLOBAL_KEY = "med_bench_trigger"

-- Inflict "drinking" syndrome on worker
local function drink_potion(reaction, reaction_product, unit, in_items, in_reag, out_items, call_native)
    for i,_ in pairs(in_items) do
        for _,v in ipairs(dfhack.matinfo.decode(in_items[i].mat_type, in_items[i].mat_index).material.syndrome.syndrome) do
            -- dfhack.printerr("Checking syn_name: "..tostring(v.syn_name))
            if v.flags.SYN_INGESTED then
                -- dfhack.printerr("Found effect as syn_name: "..tostring(v.syn_name))
                pcall(dfhack.run_script("modtools/add-syndrome", "--syndrome", tostring(v.syn_name), "--target", tostring(unit.id), "--resetPolicy", "DoNothing"))
            end
        end
    end
    
    call_native.value = false
end

-- Hook a reaction to drink extract
local function activate_trigger(event_name)
    eventful.registerReaction(event_name, drink_potion)
end

local function deactivate_trigger(event_name)
    -- TODO, Remove triggers
    -- eventful.onReaction[reaction_name] = nil
end

-- Register all hookah reactions
local function activate_triggers()
    activate_trigger("MED_BENCH_DRINK_WARBOW_TINCTURE")
    activate_trigger("MED_BENCH_DRINK_GOLDEN_SALVE")
    activate_trigger("MED_BENCH_DRINK_PHILOSOPHERS_LAMENT")
    activate_trigger("MED_BENCH_DRINK_GREEN_DRAGON")
    activate_trigger("MED_BENCH_DRINK_ESSENCE_OF_TUMULT")
    activate_trigger("MED_BENCH_DRINK_EXTRACT")
end

local function deactivate_triggers()
    deactivate_trigger("MED_BENCH_DRINK_WARBOW_TINCTURE")
    deactivate_trigger("MED_BENCH_DRINK_GOLDEN_SALVE")
    deactivate_trigger("MED_BENCH_DRINK_PHILOSOPHERS_LAMENT")
    deactivate_trigger("MED_BENCH_DRINK_GREEN_DRAGON")
    deactivate_trigger("MED_BENCH_DRINK_ESSENCE_OF_TUMULT")
    deactivate_trigger("MED_BENCH_DRINK_EXTRACT")
end

-- Enable hookah system
function onEnable()
    activate_triggers()
    dfhack.printerr("med_bench_trigger enabled")
end

-- Disable system and clear scheduled flows
function onDisable()
    deactivate_triggers()
    dfhack.printerr("med_bench_trigger disabled")
end