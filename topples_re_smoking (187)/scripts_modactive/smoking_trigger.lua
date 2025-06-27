--@module = true

local eventful = require('plugins.eventful')

local GLOBAL_KEY = "smoking_trigger"

local function loose_decay(item)
    if not item.flags.artifact then
        item.fixed_temp = 10050
        item.heatdam_point = 10045
    end
end

local function reset_decay(item)
    if not item.flags.artifact then
        item.fixed_temp = 60001      -- no fixed temp
        item.heatdam_point = 10250
    end
end

local function unitHasItem(unit, target_item)
    for _, inv_item in ipairs(unit.inventory) do
        local subtype = nil
        if df.item_toolst:is_instance(inv_item.item) then
            subtype = inv_item.item.subtype
        end
        if subtype and subtype.id == target_item then
            if target_item == "ITEM_PIPE-WEED_CIGAR" or
               target_item == "ITEM_HEMP_CIGAR" or
               target_item == "ITEM_BLUNT" then
                loose_decay(inv_item.item)
            end
            return true
        end
    end
    return false
end

local function giveUnitSyndrome(unit_id, syndrome)
    return dfhack.run_script("modtools/add-syndrome", "--syndrome", syndrome, "--target", tostring(unit_id), "--resetPolicy", "DoNothing")
end

local function removeUnitSyndrome(unit_id, syndrome)
    return dfhack.run_script("modtools/add-syndrome", "--syndrome", syndrome, "--target", tostring(unit_id), "--eraseAll")
end

local function check_new_unit_is_smoking(unit_id)
    local unit = df.unit.find(unit_id)
    if unitHasItem(unit, "ITEM_HALFLING_PIPE") then giveUnitSyndrome(unit_id, "smoking a pipe") end
    if unitHasItem(unit, "ITEM_CHILLUM") then giveUnitSyndrome(unit_id, "smoking a chillum") end
    if unitHasItem(unit, "ITEM_PIPE-WEED_CIGAR") then giveUnitSyndrome(unit_id, "smoking a pipe-weed cigar") end
    if unitHasItem(unit, "ITEM_HEMP_CIGAR") then giveUnitSyndrome(unit_id, "smoking a hemp cigar") end
    if unitHasItem(unit, "ITEM_BLUNT") then giveUnitSyndrome(unit_id, "smoking a joint") end
end

local function activate_triggers(item_token, syndrome)
    dfhack.run_script("modtools/item-trigger", "--itemType", item_token, "--onEquip",
        "--command", "[", "modtools/add-syndrome", "--syndrome", syndrome,
        "--target", "\\\\UNIT_ID", "--resetPolicy", "DoNothing", "]")

    dfhack.run_script("modtools/item-trigger", "--itemType", item_token, "--onUnequip",
        "--command", "[", "modtools/add-syndrome", "--syndrome", syndrome,
        "--target", "\\\\UNIT_ID", "--eraseAll", "]")
end

local function find_current_smokers()
    for _, unit in ipairs(df.global.world.units.active) do
        if unitHasItem(unit, "ITEM_HALFLING_PIPE") then giveUnitSyndrome(unit.id, "smoking a pipe") end
        if unitHasItem(unit, "ITEM_CHILLUM") then giveUnitSyndrome(unit.id, "smoking a chillum") end
        if unitHasItem(unit, "ITEM_PIPE-WEED_CIGAR") then giveUnitSyndrome(unit.id, "smoking a pipe-weed cigar") end
        if unitHasItem(unit, "ITEM_HEMP_CIGAR") then giveUnitSyndrome(unit.id, "smoking a hemp cigar") end
        if unitHasItem(unit, "ITEM_BLUNT") then giveUnitSyndrome(unit.id, "smoking a joint") end
    end
end

local function remove_smoking_syndromes()
    for _, unit in ipairs(df.global.world.units.active) do
        if unitHasItem(unit, "ITEM_HALFLING_PIPE") then removeUnitSyndrome(unit.id, "smoking a pipe") end
        if unitHasItem(unit, "ITEM_CHILLUM") then removeUnitSyndrome(unit.id, "smoking a chillum") end
        if unitHasItem(unit, "ITEM_PIPE-WEED_CIGAR") then removeUnitSyndrome(unit.id, "smoking a pipe-weed cigar") end
        if unitHasItem(unit, "ITEM_HEMP_CIGAR") then removeUnitSyndrome(unit.id, "smoking a hemp cigar") end
        if unitHasItem(unit, "ITEM_BLUNT") then removeUnitSyndrome(unit.id, "smoking a joint") end
    end
end

local function effect_unit_is_smoking(unit_id, syndrome_index)
    local unit = df.unit.find(unit_id)
    if unit.syndromes.active[syndrome_index] and (unit.syndromes.active[syndrome_index] == "inhaled hemp smoke" or unit.syndromes.active[syndrome_index] == "inhaled marijuana smoke" or unit.syndromes.active[syndrome_index] == "inhaled hashish smoke") then
        if unit.counters2.hunger_timer then
            unit.counters2.hunger_timer = unit.counters2.hunger_timer + 200
        end
    end
end

function onEnable()
    find_current_smokers()

    activate_triggers("ITEM_HALFLING_PIPE", "smoking a pipe")
    activate_triggers("ITEM_CHILLUM", "smoking a chillum")
    activate_triggers("ITEM_PIPE-WEED_CIGAR", "smoking a pipe-weed cigar")
    activate_triggers("ITEM_HEMP_CIGAR", "smoking a hemp cigar")
    activate_triggers("ITEM_BLUNT", "smoking a joint")

    dfhack.run_script("modtools/item-trigger", "--itemType", "ITEM_PIPE-WEED_CIGAR", "--onEquip",
        "--command", "[", "lua", "loose_decay", "\\\\ITEM_ID", "]")
    dfhack.run_script("modtools/item-trigger", "--itemType", "ITEM_HEMP_CIGAR", "--onEquip",
        "--command", "[", "lua", "loose_decay", "\\\\ITEM_ID", "]")
    dfhack.run_script("modtools/item-trigger", "--itemType", "ITEM_BLUNT", "--onEquip",
        "--command", "[", "lua", "loose_decay", "\\\\ITEM_ID", "]")

    eventful.enableEvent(eventful.eventType.UNIT_NEW_ACTIVE, 500)
    eventful.onUnitNewActive[GLOBAL_KEY] = check_new_unit_is_smoking

    eventful.enableEvent(eventful.eventType.Syndrome, 600)
    eventful.onSyndrome[GLOBAL_KEY] = effect_unit_is_smoking
end

function onDisable()
    remove_smoking_syndromes()
    eventful.onUnitNewActive[GLOBAL_KEY] = nil
end