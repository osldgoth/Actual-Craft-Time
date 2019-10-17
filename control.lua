local function truncateNumber(nu, digit)
	local k = 1
	while nu > k do
		k = k * 10
		digit = digit + 1
	end
	nu = string.format("%."..digit.."f", nu / k) * k
	return nu
end

local function getLocalisedName(name)
	if game.recipe_prototypes[name] then
		return game.recipe_prototypes[name].localised_name
	end 
	if game.entity_prototypes[name] then
		return game.entity_prototypes[name].localised_name
	end
	if game.fluid_prototypes[name] then
		return game.fluid_prototypes[name].localised_name
	end
	if game.item_prototypes[name] then
		return game.item_prototypes[name].localised_name
	end
	return name
end

local function globalSliderStorage(playerName, recipeName)
	if not global.ACT_slider then
		global.ACT_slider = {}
	end
	if not global.ACT_slider[playerName] then
		global.ACT_slider[playerName] = {}
	end
	if not global.ACT_slider[playerName][recipeName] then
		global.ACT_slider[playerName][recipeName] = {value = 1}
	end
end

local function pbarTraits(IPS, playerName)
	IPS = tonumber(IPS)
	local belt = ""
	local color = {}
	local value = 0
	local tool = ""
	-- may contain mod belts, bob's/better etc.
	if bltsInts[playerName].source["basic-transport-belt"] and --Bobs
		IPS <= bltsInts[playerName].source["basic-transport-belt"] then
		belt = "basic-transport-belt"
		color = {r = 0.15, g = 0.15, b = 0.15} --38, 38, 38
		value = IPS / bltsInts[playerName].source["basic-transport-belt"]
		tool = { "tooltips.percent-of", tostring(truncateNumber(IPS / bltsInts[playerName].source["basic-transport-belt"] * 100, 2)),  game.item_prototypes[belt].localised_name}
	elseif IPS <= bltsInts[playerName].source["transport-belt"] then --vanilla 
		belt = "transport-belt"
		color = {r = 0.98, g = 0.73, b = 0.0} -- 250, 186, 0
		value = IPS / bltsInts[playerName].source["transport-belt"]
		tool = { "tooltips.percent-of", tostring(truncateNumber(IPS / bltsInts[playerName].source["transport-belt"] * 100, 2)),  game.item_prototypes[belt].localised_name}
	elseif IPS <= bltsInts[playerName].source["fast-transport-belt"] then --vanilla 
		belt = "fast-transport-belt"
		color = {r = 0.98, g = 0.27, b = 0.06} -- 250, 69, 15
		value = IPS / bltsInts[playerName].source["fast-transport-belt"]
		tool = { "tooltips.percent-of", tostring(truncateNumber(IPS / bltsInts[playerName].source["fast-transport-belt"] * 100, 2)), game.item_prototypes[belt].localised_name}
	elseif IPS <= bltsInts[playerName].source["express-transport-belt"] then --vanilla 
		belt = "express-transport-belt"
		color = {r = 0.15, g = 0.67, b = 0.71} -- 38, 171, 181
		value = IPS / bltsInts[playerName].source["express-transport-belt"]
		tool = { "tooltips.percent-of", tostring(truncateNumber(IPS / bltsInts[playerName].source["express-transport-belt"] * 100, 2)), game.item_prototypes[belt].localised_name}
	elseif bltsInts[playerName].source["5d-mk4-transport-belt"] and --5dim
			   IPS <= bltsInts[playerName].source["5d-mk4-transport-belt"] then
		belt = "5d-mk4-transport-belt"
		color = {r = 0.08, g = 0.66, b = 0.14} -- 20, 168, 36
		value = IPS / bltsInts[playerName].source["5d-mk4-transport-belt"]
		tool = { "tooltips.percent-of", tostring(truncateNumber(IPS / bltsInts[playerName].source["5d-mk4-transport-belt"] * 100, 2)), game.item_prototypes[belt].localised_name}
	elseif bltsInts[playerName].source["turbo-transport-belt"] and --Bobs
				 IPS <= bltsInts[playerName].source["turbo-transport-belt"] then
		belt = "turbo-transport-belt"
		color = {r = 0.97, g = 0.07, b = 1.0} -- 247, 18, 255  purple
		value = IPS / bltsInts[playerName].source["turbo-transport-belt"]
		tool = { "tooltips.percent-of", tostring(truncateNumber(IPS / bltsInts[playerName].source["turbo-transport-belt"] * 100, 2)), game.item_prototypes[belt].localised_name}
	elseif bltsInts[playerName].source["5d-mk5-transport-belt"] and --5dim
				 IPS <= bltsInts[playerName].source["5d-mk5-transport-belt"] then
		belt = "5d-mk5-transport-belt"
		color = {r = 0.89, g = 0.91, b = 0.96} -- 227, 232, 245
		value = IPS / bltsInts[playerName].source["5d-mk5-transport-belt"]
		tool = { "tooltips.percent-of", tostring(truncateNumber(IPS / bltsInts[playerName].source["5d-mk5-transport-belt"] * 100, 2)), game.item_prototypes[belt].localised_name}
	elseif bltsInts[playerName].source["ultimate-transport-belt"] and --Bobs
				 IPS <= bltsInts[playerName].source["ultimate-transport-belt"] then
		belt = "ultimate-transport-belt"
		color = {r = 0.07, g = 1.0, b = 0.62} -- 18, 255, 158 green
		value = IPS / bltsInts[playerName].source["ultimate-transport-belt"]
		tool = { "tooltips.percent-of", tostring(truncateNumber(IPS / bltsInts[playerName].source["ultimate-transport-belt"] * 100, 2)), game.item_prototypes[belt].localised_name}	
	elseif bltsInts[playerName].source["BetterBelts_ultra-transport-belt"] and --Better Belts
				 IPS <= bltsInts[playerName].source["BetterBelts_ultra-transport-belt"] then
		belt = "BetterBelts_ultra-transport-belt"
		color = {r = .22, g = .84, b = .11} --56, 213, 27 green
		value = IPS / bltsInts[playerName].source["BetterBelts_ultra-transport-belt"]
		tool = { "tooltips.percent-of", tostring(truncateNumber(IPS / bltsInts[playerName].source["BetterBelts_ultra-transport-belt"] * 100, 2)), game.item_prototypes[belt].localised_name}
	else
		belt = "express-transport-belt"
		color = {r = 1, g = 1, b = 1} --white
		value = IPS / bltsInts[playerName].source["express-transport-belt"]
		tool = {'', tostring(truncateNumber(IPS / bltsInts[playerName].source["express-transport-belt"], 2)), " ", game.item_prototypes[belt].localised_name, "s"}--plural will be a problem
	end
	return {belt = belt, color = color, value = value, tool = tool}
end

local function expandIngredients(ingredients, sec, playerName, recipeName)
	if not playerName then
		return {} --hopefully this never happens
	end
	local ingredientTable = {}
	for k,ingredient in pairs(ingredients) do
		local IPS = ingredient.amount / sec
		ingredientTable[k] = ingredient
		ingredientTable[k].localised_name = getLocalisedName(ingredient.name)
		ingredientTable[k].ips = IPS
		ingredientTable[k].pbar = pbarTraits(IPS * global.ACT_slider[playerName][recipeName].value, playerName)
	end
	return ingredientTable
end

local function expandProducts(products, sec, playerName, effects, recipeName)
	if not playerName then
		return {} --hopefully this never happens
	end
	local productTable = {}
	local playerForce = game.players[playerName].force
	for k,product in pairs(products) do
		local amount = product.amount or product.max_amount or 1
		local IPS = (amount * (effects.productivity.bonus + 1) * (playerForce.mining_drill_productivity_bonus + 1)) / sec
		productTable[k] = product
		productTable[k].localised_name = getLocalisedName(product.name)
		productTable[k].ips = IPS
		productTable[k].pbar = pbarTraits(IPS * global.ACT_slider[playerName][recipeName].value, playerName)
	end
	if recipeName == "rocket-part" then
		local IPS = (10 * (effects.productivity.bonus + 1) * (playerForce.mining_drill_productivity_bonus + 1)) / sec
		productTable[#products+1] = {amount = 10,
																 name = "space-science-pack",
																 type = "item",
																 localised_name = getLocalisedName("space-science-pack"),
																 ips = IPS,
																 pbar = pbarTraits(IPS * global.ACT_slider[playerName][recipeName].value, playerName)}
	end
	return productTable
end

local function getEffects(entity)	
	local effects = {
					consumption = {bonus = 0.0},
					speed = {bonus = 0.0},
					productivity = {bonus = 0.0},
					pollution = {bonus = 0.0}
				}
	if entity.effects then
		if entity.effects.speed	then
			effects.speed.bonus = entity.effects.speed.bonus
		end
		if entity.effects.productivity then
			effects.productivity.bonus = entity.effects.productivity.bonus
		end
	end
	return effects
end

local function getRecipeFromEntity(entity, playerName)
	if entity.type:find("assembling%-machine") or
		 entity.type:find("rocket%-silo") then
		local recipe = entity.get_recipe()
		if recipe then
			globalSliderStorage(playerName, recipe.name)
			local effects = getEffects(entity)
			local sec = recipe.energy / (entity.prototype.crafting_speed * (effects.speed.bonus + 1)) --x(y+1)
			return {name = recipe.name,
							localised_name = recipe.localised_name,
							ingredients = expandIngredients(recipe.ingredients, sec, playerName, recipe.name),
							products = expandProducts(recipe.products, sec, playerName, effects, recipe.name),
							seconds = sec,
							effects = effects
							}
		end
	end
end

local function getRecipeFromFurnaceOutput(entity, playerName)
	if entity.type:find("furnace") then
		for item,_ in pairs(entity.get_output_inventory().get_contents()) do --can get several *oil*?
			local recipe = game.recipe_prototypes[item]
			if recipe then
				globalSliderStorage(playerName, recipe.name)
				local effects = getEffects(entity)
				local sec = recipe.energy / (entity.prototype.crafting_speed * (effects.speed.bonus + 1)) --x(y+1)
				return {name = recipe.name,
								localised_name = recipe.localised_name,
								ingredients = expandIngredients(recipe.ingredients, sec, playerName, recipe.name),
								products = expandProducts(recipe.products, sec, playerName, effects, recipe.name),
								seconds = sec,
								effects = effects
								}
			end
		end
	end
	return nil
end

local function getRecipeFromFurnace(entity, playerName)
	if entity.type:find("furnace") then
		local recipe = entity.previous_recipe
		if recipe then
			globalSliderStorage(playerName, recipe.name)
			local effects = getEffects(entity)
			local sec = recipe.energy / (entity.prototype.crafting_speed * (effects.speed.bonus + 1)) --x(y+1)
			return {name = recipe.name,
							localised_name = recipe.localised_name,
							ingredients = expandIngredients(recipe.ingredients, sec, playerName, recipe.name),
							products = expandProducts(recipe.products, sec, playerName, effects, recipe.name),
							seconds = sec,
							effects = effects
							}
		end
	else
		return nil
	end
end

local function getRecipeFromLab(entity, playerName)
	if entity.type:find("lab") then
		local research = entity.force.current_research
		if research then
			globalSliderStorage(playerName, research.name)
			local effects = getEffects(entity)
			local sec = (research.research_unit_energy / 60) / ((entity.prototype.researching_speed * (entity.force.laboratory_speed_modifier + 1)) * (effects.speed.bonus + 1))
			return {name = research.name,
							localised_name = research.localised_name,
							ingredients = expandIngredients(research.research_unit_ingredients, sec, playerName, research.name),
							seconds = sec,
							effects = effects
						  }
		end
	end
end

local function getRecipeFromMiningTarget(entity, playerName)
	if entity.type:find("mining%-drill") then
		local miningTarget = entity.mining_target
		if miningTarget then
			globalSliderStorage(playerName, miningTarget.name)
			local effects = getEffects(entity)
			local sec = miningTarget.prototype.mineable_properties.mining_time / (entity.prototype.mining_speed * (effects.speed.bonus + 1))
			local recipe = {name = miningTarget.name,
											localised_name = miningTarget.localised_name,
											products = expandProducts(miningTarget.prototype.mineable_properties.products, sec, playerName, effects, miningTarget.name),
											seconds = sec,
											effects = effects
											}
			if miningTarget.prototype.mineable_properties.fluid_amount then
				recipe.ingredients = expandIngredients({{name = miningTarget.prototype.mineable_properties.required_fluid,
																								 amount = miningTarget.prototype.mineable_properties.fluid_amount / 10,
																								 type = "fluid"
																							 }},
																							 sec, playerName, miningTarget.name)
			end
			if entity.name:find("pumpjack") then
				recipe.products[1].extra = (miningTarget.amount / 30000)
			end
			return recipe
		end
	end
end

local function getRecipe(entity, PlayerName)
	return getRecipeFromEntity(entity, PlayerName) or getRecipeFromFurnaceOutput(entity, PlayerName) or getRecipeFromFurnace(entity, PlayerName) or getRecipeFromLab(entity, PlayerName) or getRecipeFromMiningTarget(entity, PlayerName) or nil
end

local function spriteCheck(player, spritePath)
	if spritePath then
		if player.gui.is_valid_sprite_path("item/"..spritePath) then
			return "item/"..spritePath
		elseif player.gui.is_valid_sprite_path("entity/"..spritePath) then
			return "entity/"..spritePath
		elseif player.gui.is_valid_sprite_path("technology/"..spritePath) then
			return "technology/"..spritePath
		elseif player.gui.is_valid_sprite_path("recipe/"..spritePath) then
			return "recipe/"..spritePath
		elseif player.gui.is_valid_sprite_path("fluid/"..spritePath) then
			return "fluid/"..spritePath
		elseif player.gui.is_valid_sprite_path("utility/"..spritePath) then
			return "utility/"..spritePath
		end
	end
	return "utility/questionmark"
end

local function findPrototypeData(playerName)
	if not bltsInts then
		bltsInts = {}
	end
	if not bltsInts[playerName] then
		bltsInts[playerName] = {source = {}}
	end
	for k,v in pairs(game.entity_prototypes) do
		if k:find("transport%-belt") and not k:find("ground") and v.belt_speed then
			bltsInts[playerName].source[k] = ((60 * v.belt_speed) / (1/8)) -- I don't remember why it needs 8/64(1/8) but it does: 8 items per tile?
		end
	end
end

local function addNextInfoWrap(parent_section, i)
	local player = game.players[parent_section.player_index]
	if not player then return end
	parent_section.add{type = "flow"--[[X--]], name = "infoWrap"..i, direction = "horizontal", visible = false --[[*--]]}
		local parent_section_infoWrap = parent_section["infoWrap"..i]
		parent_section_infoWrap.add{type = "flow"--[[X--]], name = "itemBeltBarWrap", direction = "vertical", visible = false --[[*--]]}
			parent_section_infoWrap.itemBeltBarWrap.add{type = "flow"--[[X--]], name = "itemIPSWrap", visible = false --[[*--]]}
				parent_section_infoWrap.itemBeltBarWrap.itemIPSWrap.add{type = "sprite-button", name = "item_sprite", tooltip = "", visible = false --[[*--]], style = ACT_buttons}
				parent_section_infoWrap.itemBeltBarWrap.itemIPSWrap.add{type = "label", name = "IPSLabel", tooltip = "", caption = "", visible = false --[[*--]]}
			parent_section_infoWrap.itemBeltBarWrap.add{type = "progressbar", name = "item_Bar", tooltip = "", visible = false --[[*--]] }
end

local function guiDescendFind(currentGuiSection, tooltip, message, spritePath)
	for _,v in pairs(currentGuiSection.children) do
		if next(v.children) then
			guiDescendFind(v, tooltip, message, spritePath)
		elseif v.name == "recipeSprite" then
			v.tooltip = tooltip
			v.sprite = spritePath
		elseif v.name == "recipeCraftTime" then
			v.caption = message
		end
	end
end

local function guiVisibleAttrAscend(currentGuiSection, bool)
	if currentGuiSection == nil then --top level gui element or other ("top" or "left" (or "center"))
		return
	end
	if currentGuiSection.visible == bool then --currentGuiSection is already true/false (assume parent is as well if a parent?)
		return
	end
	
	currentGuiSection.visible = bool
	if not currentGuiSection.parent then
		return
	end
	guiVisibleAttrAscend(currentGuiSection.parent, bool)
end

local function guiVisibleAttrDescend(currentGuiSection, bool)
	if currentGuiSection == nil or not next(currentGuiSection) then --invalid or an enpty table
		return
	end
	local player = game.players[currentGuiSection.player_index]
	if not player then return end
	if currentGuiSection.parent and currentGuiSection.parent.visible ~= bool and not(currentGuiSection.parent.name == global.settings[player.name]["gui-location"]) and  currentGuiSection.parent.name ~= "ACT_frame_"..currentGuiSection.player_index then
		guiVisibleAttrAscend(currentGuiSection.parent, bool)
	end
	currentGuiSection.visible = bool
	for _,v in pairs(currentGuiSection.children) do
		guiVisibleAttrDescend(v, bool)
	end
end

local function settings(player)
	if not player then return end
	if not global.settings then
		global.settings = {}
	end
	if not global.settings[player.name] then
		global.settings[player.name] = {
			["gui-location"] = player.mod_settings["ACT-Gui-Location"].value,
			["simple-text"] = player.mod_settings["ACT-simple-text"].value,
			["max-slider-value"] = player.mod_settings["ACT-max-slider-value"].value,
			["sensitivity-value"] = player.mod_settings["ACT-slider-sensitivity"].value,
		}
	else --check for changes
		if global.settings[player.name]["gui-location"] ~= player.mod_settings["ACT-Gui-Location"].value then
			global.settings[player.name]["gui-location"] = player.mod_settings["ACT-Gui-Location"].value
		end
		if global.settings[player.name]["simple-text"] ~= player.mod_settings["ACT-simple-text"].value then
			global.settings[player.name]["simple-text"] = player.mod_settings["ACT-simple-text"].value
		end
		if global.settings[player.name]["max-slider-value"] ~= player.mod_settings["ACT-max-slider-value"].value then
			global.settings[player.name]["max-slider-value"] = player.mod_settings["ACT-max-slider-value"].value
		end	
		if global.settings[player.name]["sensitivity-value"] ~= player.mod_settings["ACT-slider-sensitivity"].value then
			global.settings[player.name]["sensitivity-value"] = player.mod_settings["ACT-slider-sensitivity"].value
		end
	end
end

local function closeGui(event)
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player then return end
	settings(player)
	local guiLocation = global.settings[player.name]["gui-location"]
	local playersGui = player.gui[guiLocation]
	guiVisibleAttrDescend(playersGui["ACT_frame_"..playersGui.player_index], false)
end

local function updateRecipe(currentGuiSection, tooltip, message, spritePath)
	guiVisibleAttrDescend(currentGuiSection, true)
	guiDescendFind(currentGuiSection, tooltip, message, spritePath)
end

local function updateItem(recipe, items, current_section)
	local player = current_section.gui.player
	if not player then return end
	if not items then return end
	for k,v in pairs(items) do
		if not current_section["infoWrap"..k] then
			addNextInfoWrap(current_section, k)
		end
		current_section.visible = true
		current_section.sectionLabel.visible = true
		local guiElementInfoWrap_K = current_section["infoWrap"..k]
		
		guiElementInfoWrap_K.visible = true
		guiElementInfoWrap_K.itemBeltBarWrap.visible = true
		guiElementInfoWrap_K.itemBeltBarWrap.itemIPSWrap.visible = true
		guiElementInfoWrap_K.itemBeltBarWrap.itemIPSWrap.item_sprite.visible = true
		guiElementInfoWrap_K.itemBeltBarWrap.itemIPSWrap.item_sprite.sprite = spriteCheck(player, v.name) --additions/changes
		
		guiElementInfoWrap_K.itemBeltBarWrap.itemIPSWrap.item_sprite.tooltip = v.localised_name or v.name
		guiElementInfoWrap_K.itemBeltBarWrap.itemIPSWrap.IPSLabel.caption = truncateNumber(v.ips * global.ACT_slider[player.name][recipe.name].value, 2).."/s"

		if v.type ~= "fluid" then
			guiElementInfoWrap_K.itemBeltBarWrap.item_Bar.visible = true
			guiElementInfoWrap_K.itemBeltBarWrap.item_Bar.tooltip = v.pbar.tool
			guiElementInfoWrap_K.itemBeltBarWrap.item_Bar.style.color = v.pbar.color
			guiElementInfoWrap_K.itemBeltBarWrap.item_Bar.value = v.pbar.value
		end
		guiElementInfoWrap_K.itemBeltBarWrap.itemIPSWrap.IPSLabel.visible = true		
	end
end

local function updateMachine(currentGuiSection, sliderValue, entity)
	guiVisibleAttrDescend(currentGuiSection, true)
	currentGuiSection.sliderSection.sliderLabel.caption = {'', sliderValue, " ", entity.localised_name}
	currentGuiSection.sliderSection[currentGuiSection.player_index.."_slider"].slider_value = sliderValue
end

local function desiredGuiTypeEntity(event)
	if event.gui_type == defines.gui_type.entity then
		return true
	else 
		return false
	end
end

local function desiredGuiNameSlider(event)
	if event.element.name == event.player_index.."_slider" then
		return true
	else 
		return false
	end
end

local function desiredEntity(entity)
 if entity and (--add in reactor?
		entity.type:find("assembling%-machine") or
		entity.type:find("furnace") and not entity.name:find("reverse") or
		entity.type:find("rocket%-silo") or 
		entity.type:find("lab") or 
		entity.type:find("mining%-drill")) then
		return true
	else
		return false
	end
end

local function setupGui(player, playersGui)
-- outside container
	playersGui.add{type = "frame", name = "ACT_frame_"..playersGui.player_index, direction = "vertical", visible = true --[[**--]]}
	
	--add assemblerGroup
	playersGui["ACT_frame_"..playersGui.player_index].add{type = "flow"--[[X--]], name = "assemblerGroup", direction = "horizontal", visible = false --[[*--]]}
	local assembler_group = playersGui["ACT_frame_"..playersGui.player_index].assemblerGroup
	
	--"main" recipe section
	assembler_group.add{type = "flow"--[[X--]], name = "recipeSection", direction = "vertical",  visible = false --[[*--]]}
	local recipe_section = assembler_group.recipeSection
	
	recipe_section.add{type = "label", name = "recipeLabel", caption = "Recipe", visible = false --[[*--]]}
	recipe_section.add{type = "flow"--[[X--]], name ="recipe", direction = "horizontal", visible = false --[[*--]]}
	recipe_section.recipe.add{type = "sprite-button", name = "recipeSprite", tooltip = "", sprite = "", visible = false --[[*--]]}
	recipe_section.recipe.add{type = "label", name = "recipeCraftTime", caption = 'craft time', visible = false --[[*--]]}
	
	-- if no recipe, all below is not visible ***
	
	--add ingredients
	assembler_group.add{type = "flow"--[[X--]], name = "ingredientsSection", direction = "vertical", visible = false --[[*--]]}
	local ingredients_section = assembler_group.ingredientsSection
	
	ingredients_section.add{type = "label", name = "sectionLabel", caption = "Ingredients", visible = false --[[*--]]}

--add products
	assembler_group.add{type = "flow"--[[X--]], name ="productsSection", direction = "vertical", visible = false --[[*--]]}
	local products_section = assembler_group.productsSection
	
	products_section.add{type = "label", name = "sectionLabel", caption = "Products", visible = false --[[*--]]}
 
	--add machineGroup
	playersGui["ACT_frame_"..playersGui.player_index].add{type = "flow"--[[X--]], name = "machineGroup", direction = "vertical", visible = false --[[*--]]}
	local machine_group = playersGui["ACT_frame_"..playersGui.player_index].machineGroup
	
	machine_group.add{type = "label", name = "machineLabel", caption = "Adjust number of machines",tooltip = {'tooltips.scroll-wheel'}, visible = false --[[*--]]}
	machine_group.add{type = "flow"--[[X--]], name = "sliderSection", direction = "horizontal", tooltip = {'tooltips.scroll-wheel'}, visible = false --[[*--]]}
	
	machine_group.sliderSection.add{type = "sprite-button", name = "Sub5-ACT-sliderButton", tooltip = {'tooltips.add-sub', "-5", "1", "-31", "-25"}, sprite = spriteCheck(player, "editor_speed_down"), style = "ACT_buttons", visible = false --[[*--]]}
	machine_group.sliderSection.add{type = "sprite-button", name = "Sub1-ACT-sliderButton", tooltip = {'tooltips.add-sub', "-1", {'', {'tooltips.dn'}, ' ', global.settings[player.name]["max-slider-value"] / 2}, "-7", "-10"}, sprite = spriteCheck(player, "left_arrow"), style = "ACT_buttons", visible = false --[[*--]]}
	
	machine_group.sliderSection.add{type = "slider", name = playersGui.player_index.."_slider", minimum_value = 1, maximum_value = global.settings[player.name]["max-slider-value"], value = truncateNumber(0--[[sliderValue--]], 0), tooltip = {'tooltips.scroll-wheel'}, style = "slider", visible = false --[[*--]]}
	
	machine_group.sliderSection.add{type = "sprite-button", name = "Add1-ACT-sliderButton", tooltip = {'tooltips.add-sub', "+1", {'', {'tooltips.up'}, ' ', global.settings[player.name]["max-slider-value"] / 2}, "+7", "+10"}, sprite = spriteCheck(player, "right_arrow"), style = "ACT_buttons", visible = false --[[*--]]}
	machine_group.sliderSection.add{type = "sprite-button", name = "Add5-ACT-sliderButton", tooltip = {'tooltips.add-sub', "+5", global.settings[player.name]["max-slider-value"], "+31", "+25"}, sprite = spriteCheck(player, "editor_speed_up"), style = "ACT_buttons", visible = false --[[*--]]}
	
	machine_group.sliderSection.add{type = "label", name = "sliderLabel", caption =  "", visible = false --[[*--]]}
end

local function run(event)
	if not desiredGuiTypeEntity(event) then --event.gui_type == defines.gui_type.entity
		return
	end
	
	local entity = event.entity
	
	if not desiredEntity(entity) then 
		return
	end
	
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player then return end
	settings(player)
	local guiLocation = global.settings[player.name]["gui-location"]
	local playersGui = player.gui[guiLocation] --top or left	
	
	if not playersGui["ACT_frame_"..playerIndex] then
		setupGui(player, playersGui)
	end
	
	guiVisibleAttrDescend(playersGui["ACT_frame_"..playersGui.player_index], false)
	
	findPrototypeData(player.name)
	
	local recipe = getRecipe(entity, player.name)
	local assembler_group = playersGui["ACT_frame_"..playersGui.player_index].assemblerGroup
	if not recipe then	--update gui and return
		updateRecipe(assembler_group.recipeSection, {'tooltips.reset', entity.localised_name}, {'captions.no-recipe'}, spriteCheck(player, entity.name))
		return
	end
	
	globalSliderStorage(player.name, recipe.name)

	updateRecipe(assembler_group.recipeSection, {'tooltips.reset', recipe.localised_name}, {'captions.seconds', truncateNumber(recipe.seconds, 2)}, spriteCheck(player, recipe.name))
	
	updateItem(recipe, recipe.ingredients, assembler_group.ingredientsSection)

	updateItem(recipe, recipe.products, assembler_group.productsSection)

	local machine_group = playersGui["ACT_frame_"..playersGui.player_index].machineGroup
	updateMachine(machine_group, truncateNumber(global.ACT_slider[player.name][recipe.name].value, 0), entity)
end

local function resetACT(event)
	event.entity = game.players[event.player_index].opened
	event.gui_type = defines.gui_type.entity
	run(event)
end

local function changeGuiSliderButtons(event)
	local shi = event.shift
	local alt = event.alt
	local con = event.control
	
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player then return end
	local elementName = event.element.name
	
	local guiLocation = global.settings[player.name]["gui-location"]
	local playersGui = player.gui[guiLocation] --top or left
	local entity = player.opened
	if not entity then return end
	local recipe = getRecipe(entity, player.name)
	if not recipe then return end
	if 	shi and not alt and not con then			--click with keyboard
		if elementName:find("Sub5") then 	 	 -- -25
			global.ACT_slider[player.name][recipe.name].value = global.ACT_slider[player.name][recipe.name].value + -25
		elseif elementName:find("Sub1") then -- -10
			global.ACT_slider[player.name][recipe.name].value = global.ACT_slider[player.name][recipe.name].value + -10
		elseif elementName:find("Add1") then -- +10
			global.ACT_slider[player.name][recipe.name].value = global.ACT_slider[player.name][recipe.name].value + 10
		elseif elementName:find("Add5") then -- +25
			global.ACT_slider[player.name][recipe.name].value = global.ACT_slider[player.name][recipe.name].value + 25
		end
	elseif shi and con and not alt then				--click with keyboard
		if elementName:find("Sub5") then		 -- -31
			global.ACT_slider[player.name][recipe.name].value = global.ACT_slider[player.name][recipe.name].value + -31
		elseif elementName:find("Sub1") then -- -7
			global.ACT_slider[player.name][recipe.name].value = global.ACT_slider[player.name][recipe.name].value + -7
		elseif elementName:find("Add1") then -- +7
			global.ACT_slider[player.name][recipe.name].value = global.ACT_slider[player.name][recipe.name].value + 7
		elseif elementName:find("Add5") then -- +31
			global.ACT_slider[player.name][recipe.name].value = global.ACT_slider[player.name][recipe.name].value + 31
		end
	elseif con and not shi and not alt then				--click with keyboard
		local settingMaxSliderValue = global.settings[player.name]["max-slider-value"]
		if elementName:find("Sub5") then		 -- down to 1
			global.ACT_slider[player.name][recipe.name].value = 1
		elseif elementName:find("Sub1") then -- down to 50%
			if global.ACT_slider[player.name][recipe.name].value >= settingMaxSliderValue / 2 then 
				global.ACT_slider[player.name][recipe.name].value = settingMaxSliderValue / 2
			end
		elseif elementName:find("Add1") then -- up   to 50%
			if global.ACT_slider[player.name][recipe.name].value <= settingMaxSliderValue / 2 then
				global.ACT_slider[player.name][recipe.name].value = settingMaxSliderValue / 2
			end
		elseif elementName:find("Add5") then -- up   to max
			global.ACT_slider[player.name][recipe.name].value  = settingMaxSliderValue
		end
	elseif not shi and not alt and not con then			--normal click
		if elementName:find("Sub5") then			-- -5
			global.ACT_slider[player.name][recipe.name].value = global.ACT_slider[player.name][recipe.name].value + -5
		elseif elementName:find("Sub1") then -- -1
			global.ACT_slider[player.name][recipe.name].value = global.ACT_slider[player.name][recipe.name].value + -1
		elseif elementName:find("Add1") then -- +1
			global.ACT_slider[player.name][recipe.name].value = global.ACT_slider[player.name][recipe.name].value + 1
		elseif elementName:find("Add5") then -- +5
			global.ACT_slider[player.name][recipe.name].value = global.ACT_slider[player.name][recipe.name].value + 5
		end
	end
	if global.ACT_slider[player.name][recipe.name].value < 1 then
		global.ACT_slider[player.name][recipe.name].value = 1
	elseif global.ACT_slider[player.name][recipe.name].value > global.settings[player.name]["max-slider-value"] then
		global.ACT_slider[player.name][recipe.name].value = global.settings[player.name]["max-slider-value"]
	end
	event.gui_type = defines.gui_type.entity
	event.entity = entity
	run(event)
end

local function playerSlid(event)
	if not desiredGuiNameSlider(event) then return end
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player then return end
	local entity = player.opened
	if not entity then return end
	
	local recipe = getRecipe(entity, player.name)
	if not recipe then return end
	if global.ACT_slider[player.name][recipe.name] then
		if not (math.abs(global.ACT_slider[player.name][recipe.name].value - event.element.slider_value) >= global.settings[player.name]["sensitivity-value"] / 10) then return end
		global.ACT_slider[player.name][recipe.name].value = event.element.slider_value

		event.entity = player.opened
		event.gui_type = defines.gui_type.entity

		run(event)
	end
end

local function playerClickedGui(event)
	if not (event.element.type == "sprite-button") then return end
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player then return end
	local elementName = event.element.name
	if elementName == "recipeSprite" then
		resetACT(event)
		return
	end
	if elementName:find("ACT%-sliderButton") then
	changeGuiSliderButtons(event)
	return
	end
end

script.on_event(defines.events.on_gui_opened, run)

script.on_event(defines.events.on_gui_closed, closeGui)

script.on_event(defines.events.on_gui_click, playerClickedGui)

script.on_event(defines.events.on_gui_value_changed, playerSlid)