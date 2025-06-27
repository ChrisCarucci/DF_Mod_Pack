--@module = true

local eventful = require('plugins.eventful')
local repeatUtil = require('repeat-util')

local GLOBAL_KEY = "med_bench_trigger"

local function drink_potion(reaction, reaction_product, unit, in_items, in_reag, out_items, call_native)
    local syndrome = "drinking "..in_reag[0].code	-- get syndrome name using first reagent name
    dfhack.run_script("modtools/add-syndrome", "--syndrome", syndrome, "--target", tostring(unit.id), "--resetPolicy", "DoNothing")
    call_native.value = false
end

-- Hook a reaction to gas emission
local function activate_trigger(event_name)
    eventful.registerReaction(event_name, drink_potion)
end

-- Register all hookah reactions
local function activate_triggers()
    activate_trigger("MED_BENCH_DRINK_WARBOW_TINCTURE")
    activate_trigger("MED_BENCH_DRINK_GOLDEN_SALVE")
    activate_trigger("MED_BENCH_DRINK_PHILOSOPHERS_LAMENT")
    activate_trigger("MED_BENCH_DRINK_GREEN_DRAGON")
    activate_trigger("MED_BENCH_DRINK_ESSENCE_OF_TUMULT")
end

-- Enable hookah system
function onEnable()
    activate_triggers()
    dfhack.printerr("med_bench_trigger enabled")
end

-- Disable system and clear scheduled flows
function onDisable()
    deactivate_trigger("MED_BENCH_DRINK_WARBOW")
    deactivate_trigger("MED_BENCH_DRINK_GOLDEN_SALVE")
    deactivate_trigger("MED_BENCH_DRINK_PHILOSOPHERS_LAMENT")
    deactivate_trigger("MED_BENCH_DRINK_GREEN_DRAGON")
    deactivate_trigger("MED_BENCH_DRINK_ESSENCE_OF_TUMULT")
    dfhack.printerr("med_bench_trigger disabled")
end