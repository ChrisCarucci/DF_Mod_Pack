--@module = true
--@enable = true
--[====[

civ-halfling
===========

Tags: fort | gameplay

Enable halfling civilization submodules for undiggable.

Usage
-----

	enable civ-halfling
	disable civ-halfling
]====]

local undiggable = reqscript("internal/civ-halfling/undiggable")
local GLOBAL_KEY = "civ-halfling"

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

dfhack.onStateChange[GLOBAL_KEY] = function(state)
	if state == SC_MAP_UNLOADED then
		dfhack.run_command("disable", GLOBAL_KEY)
		dfhack.onStateChange[GLOBAL_KEY] = nil
		return
	end

	if state == SC_MAP_LOADED and df.global.gamemode == df.game_mode.DWARF then
		local entsrc = df.historical_entity.find(df.global.plotinfo.civ_id)
		if entsrc == nil then
    			dfhack.printerr("Could not find current entity. No world loaded?")
			return
		end

		if entsrc.entity_raw.code == "HALFLING" then
    			dfhack.run_command("enable", GLOBAL_KEY)
		end
	end
end

if dfhack_flags.module then
	return
end

if not dfhack_flags.enable then
	print(dfhack.script_help())
	print(string.format("Halfling civ lua scripts are currently %q", enabled and "enabled" or "disabled"))
	return
end

local function do_enable()
	undiggable.onLoad()
	print("Halfling civ mod enabled")
end

local function do_disable()
	print("Halfling civ mod disabled")
end

if dfhack_flags.enable_state then
	print("Halfling civ mod enabled")
	enabled = true
else
	print("Halfling civ mod disabled")
	enabled = false
end

if dfhack_flags.enable_state then
    state.enabled = true
    do_enable()
else
    state.enabled = false
    do_disable()
end

persist_state()
