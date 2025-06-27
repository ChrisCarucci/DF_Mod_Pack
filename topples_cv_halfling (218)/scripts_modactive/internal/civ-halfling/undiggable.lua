--@module = true

local utils = require("utils")

local function findInorganic(name)
 for _,inorganic in ipairs(df.global.world.raws.inorganics) do
  if inorganic.id == name then
   return inorganic
  end
 end
end

function makeStoneUndiggable()
 for _,inorganics in ipairs(df.global.world.raws.inorganics.all) do
  if inorganics.material.flags.IS_STONE == true then
   inorganics.material.flags.UNDIGGABLE = true
  end
 end
end

function enableMining()
 for _,entities in ipairs(df.global.world.raws.entities) do
  if entities.code == "HALFLING" then
   table.insert(entities.raws, "[DIGGER:ITEM_WEAPON_PICK]")
   table.insert(entities.raws, "[PERMITTED_JOB:MINER]")
  end
 end
end

function onLoad()
 makeStoneUndiggable()
end