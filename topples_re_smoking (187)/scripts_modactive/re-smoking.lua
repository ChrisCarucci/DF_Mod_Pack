--@module = true
--@enable = true

--[====[
re-smoking
===========

Tags: gameplay | mod

Enable and disable dfhack scripts associated with Topples' smoking.


Usage
-----

	enable re-smoking
	disable re-smoking
]====]

local itrigger = reqscript("internal/re-smoking/smoking_trigger")
local htrigger = reqscript("internal/re-smoking/hookah_trigger")
local mtrigger = reqscript("internal/re-smoking/med_bench_trigger")
local GLOBAL_KEY = "re-smoking"

local function get_default_state()
    return {
        enabled=true,
        somevar=0,
        somesubtable={
            someothervar=0,
        },
    }
end
state = state or get_default_state()

local function persist_state()
    dfhack.persistent.saveSiteData(GLOBAL_KEY, state)
end

function isEnabled()
    return state.enabled
end

local function do_enable()
    itrigger.onEnable()
    htrigger.onEnable()
    mtrigger.onEnable()
end

local function do_disable()
    itrigger.onDisable()
    htrigger.onDisable()
    mtrigger.onDisable()
end

dfhack.onStateChange[GLOBAL_KEY] = function(sc)
    if sc == SC_MAP_UNLOADED then
        do_disable()
        dfhack.onStateChange[GLOBAL_KEY] = nil
        return
    end

    if sc == SC_MAP_LOADED and (df.global.gamemode == df.game_mode.DWARF or df.global.gamemode == df.game_mode.ADVENTURE) then
        -- dfhack.run_command("enable", GLOBAL_KEY)
        state = get_default_state()
        do_enable()
    end
end

if dfhack_flags.module then
    return
end

if not dfhack_flags.enable then
    print(dfhack.script_help())
    print()
    print(('Smoking is currently %s'):format(
            state.enabled and 'enabled' or 'disabled'))
    return
end

if dfhack_flags.enable_state then
    print("Smokin mod enabled")
    state.enabled = true
    do_enable()
else
    print("Smoking mod disabled")
    state.enabled = false
    do_disable()
end
if dfhack_flags.module then
	return
end