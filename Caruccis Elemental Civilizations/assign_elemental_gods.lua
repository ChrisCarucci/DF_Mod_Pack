-- Dwarf Fortress Lua script to assign elemental god creatures to their corresponding civilizations
-- This script assigns gods to Divine Overseer and Overseer positions for each elemental civilization

local utils = require('utils')

-- Function to find entity by name
function findEntityByName(name)
    for i, entity in ipairs(df.global.world.entities.all) do
        if entity.entity_raw and entity.entity_raw.code == name then
            return entity
        end
    end
    return nil
end

-- Function to find creature by name and caste
function findCreatureType(name, caste)
    for i, creature in ipairs(df.global.world.raws.creatures.all) do
        if creature.creature_id == name then
            if caste then
                for j, c in ipairs(creature.caste) do
                    if c.caste_id == caste then
                        return i, j
                    end
                end
            else
                return i, 0 -- Default caste
            end
        end
    end
    return nil, nil
end

-- Function to assign a creature to a position in an entity
function assignGodToPosition(entity, position_name, creature_type, caste_id, god_caste, ice_caste, storm_caste)
    if not entity or not entity.positions then
        return false
    end
    
    -- Find the position
    local position = nil
    for i, pos in ipairs(entity.positions.own) do
        if pos.code == position_name then
            position = pos
            break
        end
    end
    
    if not position then
        print("Position " .. position_name .. " not found in entity " .. entity.entity_raw.code)
        return false
    end
    
    -- Create a new assignment if none exists
    if not position.assignments then
        position.assignments = {}
    end
    
    -- Check if position is already filled
    if #position.assignments > 0 then
        print("Position " .. position_name .. " in " .. entity.entity_raw.code .. " is already filled")
        return false
    end
    
    -- Create historical figure for the god
    local hf = df.historical_figure:new()
    hf.id = df.global.hist_figure_next_id
    df.global.hist_figure_next_id = df.global.hist_figure_next_id + 1
    
    hf.race = creature_type
    hf.caste = caste_id or 0
    hf.sex = math.random(0, 1) -- Random sex
    hf.appeared_year = df.global.cur_year
    hf.born_year = df.global.cur_year - math.random(100, 500) -- Ancient god
    hf.birth_time = 0
    hf.old_year = -1
    hf.old_seconds = -1
    hf.died_year = -1
    hf.died_seconds = -1
    hf.name.first_name = ""
    hf.name.nickname = ""
    hf.name.words = {}
    hf.name.parts_of_speech = {}
    hf.name.language = entity.entity_raw.translation
    
    -- Generate appropriate name based on creature type
    local creature = df.global.world.raws.creatures.all[creature_type]
    if creature and creature.creature_id == "CYCLOPS" then
        hf.name.first_name = "Earthshaker"
    elseif creature and creature.creature_id == "MINOTAUR" then
        hf.name.first_name = "Stonehorn"
    elseif creature and creature.creature_id == "ELEMENTAL_CIVILIZATION_GODS" then
        if caste_id == god_caste then -- god caste (Fire)
            hf.name.first_name = "Flameheart"
        elseif caste_id == ice_caste then -- ice caste (Water)
            hf.name.first_name = "Frostscale"
        elseif caste_id == storm_caste then -- storm caste
            hf.name.first_name = "Stormwing"
        end
    elseif creature and creature.creature_id == "BIRD_ROC" then
        hf.name.first_name = "Skytalon"
    end
    
    -- Add to historical figures
    utils.insert_sorted(df.global.world.history.figures, hf, 'id')
    
    -- Create position assignment
    local assignment = df.entity_position_assignment:new()
    assignment.id = df.global.entity_next_id
    df.global.entity_next_id = df.global.entity_next_id + 1
    assignment.histfig = hf.id
    assignment.position_id = position.id
    assignment.squad_id = -1
    
    position.assignments:insert('#', assignment)
    
    -- Link historical figure to entity
    if not entity.histfig_ids then
        entity.histfig_ids = {}
    end
    if not entity.hist_figures then
        entity.hist_figures = {}
    end
    
    entity.histfig_ids:insert('#', hf.id)
    entity.hist_figures:insert('#', hf)
    
    -- Add entity link to historical figure
    local link = df.histfig_entity_link_memberst:new()
    link.entity_id = entity.id
    link.link_strength = 100
    link.start_year = df.global.cur_year
    link.end_year = -1
    
    if not hf.entity_links then
        hf.entity_links = {}
    end
    hf.entity_links:insert('#', link)
    
    print("Assigned " .. hf.name.first_name .. " to position " .. position_name .. " in " .. entity.entity_raw.code)
    return true
end

-- Main function to assign gods to civilizations
function assignElementalGods()
    print("Starting assignment of elemental gods...")
    
    -- Get creature types
    local cyclops_id, _ = findCreatureType("CYCLOPS")
    local minotaur_id, _ = findCreatureType("MINOTAUR")
    local dragon_id, god_caste = findCreatureType("ELEMENTAL_CIVILIZATION_GODS", "god")
    local dragon_id2, ice_caste = findCreatureType("ELEMENTAL_CIVILIZATION_GODS", "ice")
    local dragon_id3, storm_caste = findCreatureType("ELEMENTAL_CIVILIZATION_GODS", "storm")
    local roc_id, _ = findCreatureType("BIRD_ROC")
    
    if not cyclops_id or not minotaur_id or not dragon_id or not roc_id or not god_caste or not ice_caste or not storm_caste then
        print("Error: Could not find all required creature types and castes")
        print("Found: cyclops=" .. tostring(cyclops_id) .. ", minotaur=" .. tostring(minotaur_id) .. ", dragon=" .. tostring(dragon_id) .. ", roc=" .. tostring(roc_id))
        print("Castes: god=" .. tostring(god_caste) .. ", ice=" .. tostring(ice_caste) .. ", storm=" .. tostring(storm_caste))
        return
    end
    
    -- Earth Humans - gets both earth gods
    local earth_entity = findEntityByName("Earth_Humans")
    if earth_entity then
        assignGodToPosition(earth_entity, "DIVINE_OVERSEER", cyclops_id, 0, god_caste, ice_caste, storm_caste)
        assignGodToPosition(earth_entity, "OVERSEER", minotaur_id, 0, god_caste, ice_caste, storm_caste)
    else
        print("Warning: Earth_Humans entity not found")
    end
    
    -- Fire Humans - gets fire dragon
    local fire_entity = findEntityByName("Fire_Humans")
    if fire_entity then
        assignGodToPosition(fire_entity, "DIVINE_OVERSEER", dragon_id, god_caste, god_caste, ice_caste, storm_caste)
    else
        print("Warning: Fire_Humans entity not found")
    end
    
    -- Water Humans - gets ice dragon
    local water_entity = findEntityByName("Water_Humans")
    if water_entity then
        assignGodToPosition(water_entity, "DIVINE_OVERSEER", dragon_id, ice_caste, god_caste, ice_caste, storm_caste)
    else
        print("Warning: Water_Humans entity not found")
    end
    
    -- Storm Humans - alternates between roc and storm dragon
    local storm_entity = findEntityByName("Storm_Humans")
    if storm_entity then
        -- Use current year to determine which god to assign (alternating)
        if df.global.cur_year % 2 == 0 then
            assignGodToPosition(storm_entity, "DIVINE_OVERSEER", roc_id, 0, god_caste, ice_caste, storm_caste)
        else
            assignGodToPosition(storm_entity, "DIVINE_OVERSEER", dragon_id, storm_caste, god_caste, ice_caste, storm_caste)
        end
    else
        print("Warning: Storm_Humans entity not found")
    end
    
    print("God assignment complete!")
end

-- Run the assignment
assignElementalGods()
