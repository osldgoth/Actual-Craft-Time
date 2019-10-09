--[[local inserterEntityCopies = {}
local inserterItemCopies = {}

for _,v in pairs(data.raw.inserter) do
	if v.name:find("inserter") and not v.name:find("filter") and not v.name:find("long") and not v.name:find("burner") and not v.name:find("miniloader") then
		log("making copy of entity "..v.name.."-ACT-copy")
		inserterEntityCopies[v.name] = table.deepcopy(v)
		inserterEntityCopies[v.name].name = v.name.."-ACT-copy"
		inserterEntityCopies[v.name].max_health = v.rotation_speed
	end
end

for _,v in pairs(inserterEntityCopies) do
	data:extend({v})
end

for _,v in pairs(data.raw.item) do
	if v.name:find("inserter") and not v.name:find("filter") and not v.name:find("long") and not v.name:find("burner") and inserterEntityCopies[v.name] then
		log("making copy of item "..v.name.."-ACT-copy")
		inserterItemCopies[v.name.."-ACT-copy"] = table.deepcopy(v)
		inserterItemCopies[v.name.."-ACT-copy"].name = v.name.."-ACT-copy"
		inserterItemCopies[v.name.."-ACT-copy"].flags = {"hidden"}
		inserterItemCopies[v.name.."-ACT-copy"].place_result = inserterItemCopies[v.name.."-ACT-copy"].name
	end
end

for _,v in pairs(inserterItemCopies) do
	data:extend({v})
end
--]]