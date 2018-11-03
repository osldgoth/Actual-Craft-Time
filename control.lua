local function localizeString(st)
	return string.sub(st, 1, 1):upper()..string.sub(st, 2):gsub("-", " ")
end

local function truncateNumber(nu, digit)
	local k = 1
	while nu > k do
		k = k * 10
		digit = digit + 1
	end
	nu = string.format("%."..digit.."f", nu / k) * k
	return nu
end

local function getRecipeFromOutput(entity)
	for item,_ in pairs(entity.get_output_inventory().get_contents()) do --can get several *oil*?
		return game.recipe_prototypes[item]
	end
	return nil
end

local function getRecipeFromFurnace(entity)
	if entity.type == "furnace" then
		return entity.previous_recipe
	else
		return nil
	end
end

local function getRecipe(entity)
	return entity.get_recipe() or getRecipeFromOutput(entity) or getRecipeFromFurnace(entity)
end

local function spriteCheck(player, spritePath)
	if player.gui.is_valid_sprite_path(spritePath) then
		return spritePath
	else
		return "utility/questionmark"
	end
end

local function pbarTraits(IPS)
	IPS = tonumber(IPS)
	local belt = ""
	local color = {}
	local value = 0
	local tool = ""
	if IPS <= 13.33 then
		belt = 1
		color = {r = 0.98, g = 0.73, b = 0.0} -- 250, 186, 0
		value = IPS / 13.33
		tool = truncateNumber(IPS / 13.33 * 100, 2).."% of a Yellow Belt"
	elseif IPS <= 26.66 then
		belt = 2
		color = {r = 0.98, g = 0.27, b = 0.06} -- 250, 69, 15
		value = IPS / 26.66
		tool = truncateNumber(IPS / 26.66 * 100, 2).."% of a Red Belt"
	elseif IPS <= 40 then
		belt = 3
		color = {r = 0.15, g = 0.67, b = 0.71} -- 38, 171, 181
		value = IPS / 40
		tool = truncateNumber(IPS / 40 * 100, 2).."% of a Blue Belt"
	else
		belt = 3
		color = {r = 1, g = 1, b = 1} --white
		value = IPS / 40
		tool = truncateNumber(IPS / 40 * 100, 2).." Blue Belts"
	end
	return {belt = belt, color = color, value = value, tool = tool}
end

local function checkStackBonus(tech)
	local stackBonus = {stack = 1, nonStack = 1}
	local capTechs = {"stack-inserter", "inserter-capacity-bonus-1", "inserter-capacity-bonus-2", "inserter-capacity-bonus-3", "inserter-capacity-bonus-4", "inserter-capacity-bonus-5", "inserter-capacity-bonus-6", "inserter-capacity-bonus-7"}
	
	for i = 1, #capTechs do
		if tech[capTechs[i]].researched then
			for j = 1, #tech[capTechs[i]].effects do
				local tMod = tech[capTechs[i]].effects[j].modifier
				local tType = tech[capTechs[i]].effects[j].type
				if tMod then
					if tType == "inserter-stack-size-bonus" then
						stackBonus.nonStack = stackBonus.nonStack + tMod
					elseif tType == "stack-inserter-capacity-bonus" then
						stackBonus.stack = stackBonus.stack + tMod
					end
				end
			end
		end
	end
	return stackBonus
end

local function inserterSpriteParams(sourceType, stackBonus, IPS)
	local params = {["inserter"] = {count = 0, stack = 0},
									["fast-inserter"] = {count = 0, stack = 0}, 
									["stack-inserter"] = {count = 0, stack = 0}
								}
	local throughputFromSource = {
		{
			{0.83, 1.57, 2.00, name = "inserter", stack = stackBonus.nonStack},
			{2.22, 4.17, 5.71, name = "fast-inserter", stack = stackBonus.nonStack},
			{2.308, 3.636, 4.185, 4.706, 4.999, 5.251, 0, 5.580, 0, 5.714, 0, 5.901, name = "stack-inserter", stack = stackBonus.stack},
			name = "transport-belt",
		},
		{
			{0.74, 1.48, 2.11, name = "inserter", stack = stackBonus.nonStack},
			{2.22, 3.81, 5.45, name = "fast-inserter", stack = stackBonus.nonStack},
			{2.308, 4.000, 5.175, 6.154, 6.886, 7.500, 0, 8.421, 0, 9.091, 0, 9.600, name = "stack-inserter", stack = stackBonus.stack}, 
			name = "fast-transport-belt",
		},
		{
			{0.77, 1.45, 2.07, name = "inserter", stack = stackBonus.nonStack},
			{2.14, 4.00, 5.46, name = "fast-inserter", stack = stackBonus.nonStack},
			{2.308, 4.138, 5.637, 6.857, 7.924, 9.000, 0, 10.213, 0, 11.321, 0, 12.203, name = "stack-inserter", stack = stackBonus.stack},
			name = "express-transport-belt",
		},
		{
			{.83, 1.66, 2.49, name = "inserter", stack = stackBonus.nonStack},
			{2.31, 4.62, 6.93, name = "fast-inserter", stack = stackBonus.nonStack},
			{0, 4.62, 6.93 , 9.24, 11.55, 13.86, 0, 18.48, 0, 23.1, 0, 27.72, name = "stack-inserter", stack = stackBonus.stack},
			name = "chest",
		}
	}
	
	local stop = 0
	while IPS > 0 do		--sourceType is 1 through 4
		stop = stop + 1
		for i = 1, #throughputFromSource[sourceType] do --each inserter 1,2, and 3-basic, fast, stack
			local stack = throughputFromSource[sourceType][i].stack
			local name = throughputFromSource[sourceType][i].name
			if IPS - throughputFromSource[sourceType][i][stack] <=0 then
				IPS = IPS - throughputFromSource[sourceType][i][stack]
				params[name].count = params[name].count + 1
				params[name].stack = throughputFromSource[sourceType][i][stack]
				break
			elseif i == 3 then
				IPS = IPS - throughputFromSource[sourceType][i][stack]
				params[name].count = params[name].count + 1
				params[name].stack = throughputFromSource[sourceType][i][stack]
			end
		end
		if stop >=12 then
			--game.print("while-loop force stopped. This should not be - something may have gone wrong! Notify ACT Mod Author") --add log info here?
			break
		end
	end
	return params
end

local function addInserterSprites(ACTAssemplerFlowI_PWrap, productName, belt, techs, IPS, toFrom)
	-- START of Product Inserter sprites
		-- START of Belt limited
	local beltSpriteParams = inserterSpriteParams(belt, checkStackBonus(techs), IPS)
	local i = 0
	for k,v in pairs(beltSpriteParams) do --IPS inserter sprites
		if v.count ~= 0 then
			ACTAssemplerFlowI_PWrap[productName.."-ingredientWrap"][productName.."-inserter-sprite-wrap"]["belt"].add{type = "sprite-button", name = productName.."-inserter-sprite-"..i, sprite = "entity/"..k, style = "ACT_inserter", number = v.count, tooltip = localizeString(k).." moves upto "..v.stack.." Items Per Second "..toFrom.." a belt"}
		end
		i = i + 1
	end
		-- END of belt limited
		-- START of chest limited		
	
	local chestSpriteParams = inserterSpriteParams(4, checkStackBonus(techs), IPS)
	--game.print("chestSpriteParams "..serpent.block(chestSpriteParams))
	local i = 0
	for k,v in pairs(chestSpriteParams) do 
		if v.count ~=0 then
			ACTAssemplerFlowI_PWrap[productName.."-ingredientWrap"][productName.."-inserter-sprite-wrap"]["chest"].add{type = "sprite-button", name = productName.."-inserter-sprite-"..i, sprite = "entity/"..k, style = "ACT_inserter", number = v.count, tooltip = localizeString(k).. " moves upto "..v.stack.." Items Per Second "..toFrom.." a chest"}
		end
		i = i + 1
	end
		-- END of chest limited
	-- END of Product Inserter sprites
end

local function addItemFrame(player, ACTAssemplerFlowI_PWrap, product, seconds, effects)
	ACTAssemplerFlowI_PWrap.add{type = "flow" --[[--]], name = product.name.."-ingredientWrap", direction = "horizontal"}
---[[tooltip--]]ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"].tooltip = product.name.."-ingredientWrap"

	ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"].add{type = "flow" --[[--]], name = product.name.."-PbarFlowWrap", direction = "vertical"}
---[[tooltip--]]ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-PbarFlowWrap"].tooltip = product.name.."-PbarFlowWrap"
	ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"].add{type = "flow" --[[--]], name = product.name.."-inserter-sprite-wrap", direction = "vertical"}
---[[tooltip--]]ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-inserter-sprite-wrap"].tooltip = product.name.."-inserter-sprite-wrap"

	ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-inserter-sprite-wrap"].add{type = "flow" --[[--]], name = "belt", direction = "horizontal"}
---[[tooltip--]]ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-inserter-sprite-wrap"]["belt"].tooltip = "belt"
	
	ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-inserter-sprite-wrap"].add{type = "flow" --[[--]], name = "chest", direction = "horizontal"}
---[[tooltip--]]ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-inserter-sprite-wrap"]["chest"].tooltip = "chest"


	ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-PbarFlowWrap"].add{type = "flow" --[[--]], name = product.name.."IPS"}
---[[tooltip--]]ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-PbarFlowWrap"][product.name.."IPS"].tooltip = product.name.."IPS"

	ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-PbarFlowWrap"][product.name.."IPS"].add{type = "sprite", name = product.name.."Sprite", sprite = spriteCheck(player, product.type.."/"..product.name), tooltip = localizeString(product.name)} 
	
	if product.type ~= "fluid" then
		ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-inserter-sprite-wrap"]["belt"].add{type = "label", name = "belt-label", caption = "Belt"}
		ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-inserter-sprite-wrap"]["chest"].add{type = "label", name = "chest-label", caption = "Chest"}
		ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-PbarFlowWrap"].add{type = "progressbar", name = product.name.."pbar"}
		ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-PbarFlowWrap"][product.name.."pbar"].style.maximal_width = 95
	end
	
	if ACTAssemplerFlowI_PWrap.name == "ingredients" then 
		local IPS = (product.amount or product.amount_max) / seconds --figure out if this does or does not need productivity bonus
		
		IngredientIPS[product.name.."-ingredientWrap"] = IPS
		ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-PbarFlowWrap"][product.name.."IPS"].add{type = "label", name = product.name.."Label", caption = truncateNumber(IPS, 2).."/s", tooltip = "Items per second"} 
		
		local pbarInitial = pbarTraits(IPS)

		if product.type ~= "fluid" then
			addInserterSprites(ACTAssemplerFlowI_PWrap, product.name, pbarInitial.belt, player.force.technologies, truncateNumber(IPS, 2), "from")
			
			-- Progressbar
			ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-PbarFlowWrap"][product.name.."pbar"].style.color = pbarInitial.color
			ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-PbarFlowWrap"][product.name.."pbar"].value = pbarInitial.value
			ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-PbarFlowWrap"][product.name.."pbar"].tooltip = pbarInitial.tool
		end
	else -- "products"
		local IPS = ((product.amount or product.amount_max) + ((product.amount or product.amount_max) * effects.productivity.bonus)) / seconds
		productIPS[product.name.."-ingredientWrap"] = IPS
		ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-PbarFlowWrap"][product.name.."IPS"].add{type = "label", name = product.name.."Label", caption = truncateNumber(IPS, 2).."/s", tooltip = "Items per second"} 
		
		local pbarInitial = pbarTraits(IPS)
		
		if product.type ~= "fluid" then
			addInserterSprites(ACTAssemplerFlowI_PWrap, product.name, pbarInitial.belt, player.force.technologies, truncateNumber(IPS, 2), "to")
			
			-- Progressbar
			ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-PbarFlowWrap"][product.name.."pbar"].style.color = pbarInitial.color
			ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-PbarFlowWrap"][product.name.."pbar"].value = pbarInitial.value
			ACTAssemplerFlowI_PWrap[product.name.."-ingredientWrap"][product.name.."-PbarFlowWrap"][product.name.."pbar"].tooltip = pbarInitial.tool
		end
	end
end

local function setupGui(event)
	if event.gui_type == defines.gui_type.entity then
		local entity = event.entity
		
		if	entity and (--add in mining drills/reactor/
		--/c game.print(serpent.block(game.player.selected.prototype.mineable_properties))
				entity.type == "assembling-machine" or
				entity.type == "furnace" or
				entity.type == "rocket-silo")  then
				
			local recipe = getRecipe(entity)
			local playerIndex = event.player_index
			local player = game.players[playerIndex]
			local spritePath = spriteCheck(player, "entity/"..entity.name)
			local lName = localizeString(entity.name)
			local message = "No recipe information"
			
			local guiLocation = player.mod_settings["ACT-Gui-Location"].value
			local playerSliderSetting = player.mod_settings["ACT-max-slider-value"].value
			
			local playersGui = player.gui[guiLocation] --top or left
			local seconds = 1
			
			if playersGui["ACT-frame_"..playerIndex] then
				playersGui["ACT-frame_"..playerIndex].destroy()
			end
			playersGui.add{type = "frame", name = "ACT-frame_"..playerIndex, direction = "vertical"}
---[[tooltip--]]playersGui["ACT-frame_"..playerIndex].tooltip = "ACT-frame_"..playerIndex
			playersGui["ACT-frame_"..playerIndex].add{type = "flow" --[[--]], name = "assemblerFlow", direction = "horizontal"}
---[[tooltip--]]playersGui["ACT-frame_"..playerIndex]["assemblerFlow"].tooltip = "assemblerFlow" 
			playersGui["ACT-frame_"..playerIndex].add{type = "flow" --[[--]], name = "machineFlow", direction = "vertical"}
---[[tooltip--]]playersGui["ACT-frame_"..playerIndex]["machineFlow"].tooltip = "machineFlow" 
			
			local ACTAssemplerFlow = playersGui["ACT-frame_"..playerIndex]["assemblerFlow"]
			local ACTMachineFlow = playersGui["ACT-frame_"..playerIndex]["machineFlow"]
			
			-- START OF ASSEMBLER_FLOW DATA
			ACTAssemplerFlow.add{type = "flow" --[[--]], name = "recipe", direction = "vertical"}
---[[tooltip--]]ACTAssemplerFlow["recipe"].tooltip = "recipe"
			local recipeFlow = ACTAssemplerFlow["recipe"]
			
			recipeFlow.add{type = "label", name = "recipe_label", caption = "Recipe"}
			
			recipeFlow.add{type = "flow" --[[--]], name = "recipeInfo", direction = "horizontal"}
---[[tooltip--]]recipeFlow["recipeInfo"].tooltip = "recipeInfo"
			local recipeInfoFlow = recipeFlow["recipeInfo"]
			recipeInfoFlow.add{type = "sprite-button", name = playerIndex.."_sprite-button", sprite = spritePath, tooltip = lName.." - set/reset recipe, or add/remove modules, then click here to refresh"}
			recipeInfoFlow.add{type = "label", name = lName.."_"..playerIndex.."_label", caption = message}
			
			if recipe then
				local craftSpeed = entity.prototype.crafting_speed
				local effects = {
					consumption={bonus=0.0},
					speed={bonus=0.0},
					productivity={bonus=0.0},
					pollution={bonus=0.0}
				}
				if entity.effects then
					if entity.effects.speed	then
						effects.speed.bonus = entity.effects.speed.bonus
					end
					if entity.effects.productivity then
						effects.productivity.bonus = entity.effects.productivity.bonus
					end
				end
				
				local percent = craftSpeed*effects.speed.bonus

				local simple = player.mod_settings["ACT-simple-text"].value --t or f
				local base = recipe.energy
				seconds = base/(craftSpeed+percent)
				local lRName = localizeString(recipe.name)
				spritePath = spriteCheck(player, "recipe/"..recipe.name)
				
				if simple then
					message = ""
				else
					message = lRName.." crafts in: "
				end
				message = message..truncateNumber(seconds, 2).." seconds"
				if recipeInfoFlow[playerIndex.."_sprite-button"] then
					recipeInfoFlow[playerIndex.."_sprite-button"].destroy()
					recipeInfoFlow.add{type = "sprite-button", name = playerIndex.."_sprite-button", sprite = spritePath, tooltip = lRName.." - set/reset recipe, or add/remove modules, then click here to refresh"}
				end
				
				if recipeInfoFlow[lName.."_"..playerIndex.."_label"] then
					recipeInfoFlow[lName.."_"..playerIndex.."_label"].destroy()
					recipeInfoFlow.add{type = "label", name = lRName.."_"..playerIndex.."_label", caption = message}
				end
				
				ACTAssemplerFlow.add{type = "flow" --[[--]], name = "ingredients", direction = "vertical"}
---[[tooltip--]]ACTAssemplerFlow["ingredients"].tooltip = "ingredients"
				ACTAssemplerFlow["ingredients"].add{type = "label", name = "ingredients_label", caption = "Ingredients"}

				ACTAssemplerFlow.add{type = "flow" --[[--]], name = "products", direction = "vertical"}
---[[tooltip--]]ACTAssemplerFlow["products"].tooltip = "products"
				ACTAssemplerFlow["products"].add{type = "label", name = "products_label", caption = "Products"}
				
				IngredientIPS = {}
				productIPS = {}

				for i = 1, #recipe.ingredients do
					addItemFrame(player, ACTAssemplerFlow["ingredients"], recipe.ingredients[i], seconds, effects)
				end
				
				for i = 1, #recipe.products do
					addItemFrame(player, ACTAssemplerFlow["products"], recipe.products[i], seconds, effects)
				end
				
				if recipe.name == "rocket-part" then
					addItemFrame(player, ACTAssemplerFlow["products"], {amount = 10, name = "space-science-pack", type = "item"}, seconds, effects)					
				end
				
				-- START OF MACHINE_FLOW DATA
				ACTMachineFlow.add{type = "label", name = "sliderLabel", caption = "Adjust number of machines"}
				ACTMachineFlow.add{type = "flow" --[[--]], name = "sliderFlow", direction = "horizontal"}
---[[tooltip--]]ACTMachineFlow["sliderFlow"].tooltip = "sliderFlow"
				if event.slider_value then
					ACTMachineFlow["sliderFlow"].add{type = "slider", name = playerIndex.."_slider", minimum_value = 1, maximum_value = playerSliderSetting, value = event.slider_value}
				else
					ACTMachineFlow["sliderFlow"].add{type = "slider", name = playerIndex.."_slider", minimum_value = 1, maximum_value = playerSliderSetting, value = 1}
				end
				ACTMachineFlow["sliderFlow"].add{type = "label", name = "sliderLabel", caption = truncateNumber(ACTMachineFlow["sliderFlow"][playerIndex.."_slider"].slider_value, 0).." "..localizeString(entity.name)}
			
			end
		end
	end
end

local function closeGui(event)
	local player = game.players[event.player_index]
	local guiLocation = player.mod_settings["ACT-Gui-Location"].value
	if player.gui[guiLocation]["ACT-frame_"..event.player_index] then
		player.gui[guiLocation]["ACT-frame_"..event.player_index].destroy()
	end
end

local function playerClickedGui(event)
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if event.element.type == "sprite-button" and event.element.name == playerIndex.."_sprite-button"  then 

		event.entity = player.opened
		event.gui_type = defines.gui_type.entity
		setupGui(event)
	end
end

local function playerSlid(event)
	if event.element.name == event.player_index.."_slider" then
		local playerIndex = event.player_index
		local player = game.players[playerIndex]
		local guiLocation = player.mod_settings["ACT-Gui-Location"].value
		local playersGui = player.gui[guiLocation] --top or left
		local sliderLabelCaption = playersGui["ACT-frame_"..event.player_index]["machineFlow"]["sliderFlow"]["sliderLabel"].caption
		local sliderNum = string.sub(sliderLabelCaption, string.find(sliderLabelCaption, "%d+"))
		local entity = player.opened
		
		local recipe = getRecipe(entity)
		if recipe then
			if math.abs(sliderNum - event.element.slider_value) >= .5 then
				local ingredients = playersGui["ACT-frame_"..event.player_index]["assemblerFlow"]["ingredients"]
				local products = playersGui["ACT-frame_"..event.player_index]["assemblerFlow"]["products"]
				
				local iChildren = ingredients.children_names
				local pChildren = products.children_names
				
				local sliderValue = truncateNumber(event.element.slider_value, 0)
				
				playersGui["ACT-frame_"..event.player_index]["machineFlow"]["sliderFlow"]["sliderLabel"].caption = sliderValue.." "..localizeString(player.opened.name)
				
				for i = 1, #iChildren do
					if string.find(iChildren[i], "-ingredientWrap") then
						local iName = string.sub(iChildren[i], 1, string.find(iChildren[i], "-ingredientWrap") - 1)
						local productType
						for i = 1, #recipe.ingredients do
							if recipe.ingredients[i].name == iName then
								productType = recipe.ingredients[i].type
							end
						end
						local product = game.item_prototypes[iName] or game.recipe_prototypes[iName] or game.fluid_prototypes[iName]
						ingredients[iName.."-ingredientWrap"][iName.."-PbarFlowWrap"][iName.."IPS"][iName.."Label"].caption = tostring(truncateNumber(IngredientIPS[iChildren[i]] * sliderValue, 2)).."/s"
						local pbarSlider = pbarTraits(IngredientIPS[iChildren[i]] * sliderValue)
						ingredients[iName.."-ingredientWrap"][iName.."-inserter-sprite-wrap"]["belt"].clear()
						ingredients[iName.."-ingredientWrap"][iName.."-inserter-sprite-wrap"]["chest"].clear()
						if productType ~= "fluid" then
							ingredients[iName.."-ingredientWrap"][iName.."-inserter-sprite-wrap"]["belt"].add{type = "label", name = "belt-label", caption = "Belt"}
							ingredients[iName.."-ingredientWrap"][iName.."-inserter-sprite-wrap"]["chest"].add{type = "label", name = "chest-label", caption = "Chest"}
							addInserterSprites(ingredients, iName, pbarSlider.belt, player.force.technologies, truncateNumber(IngredientIPS[iChildren[i]], 2), "from")
						end
						if ingredients[iName.."-ingredientWrap"][iName.."-PbarFlowWrap"][iName.."pbar"] then
							ingredients[iName.."-ingredientWrap"][iName.."-PbarFlowWrap"][iName.."pbar"].style.color = pbarSlider.color
							ingredients[iName.."-ingredientWrap"][iName.."-PbarFlowWrap"][iName.."pbar"].value = pbarSlider.value
							ingredients[iName.."-ingredientWrap"][iName.."-PbarFlowWrap"][iName.."pbar"].tooltip = pbarSlider.tool
						end
					end
				end
				for i = 1, #pChildren do
					if string.find(pChildren[i], "-ingredientWrap") then
						local pName = string.sub(pChildren[i], 1, string.find(pChildren[i], "-ingredientWrap") - 1)
						local productType
						for i = 1, #recipe.products do
							if recipe.products[i].name == pName then
								productType = recipe.products[i].type
							end
						end
						local product = game.item_prototypes[pName] or game.recipe_prototypes[pName] or game.fluid_prototypes[pName]
						products[pName.."-ingredientWrap"][pName.."-PbarFlowWrap"][pName.."IPS"][pName.."Label"].caption = tostring(truncateNumber(productIPS[pChildren[i]] * sliderValue, 2)).."/s"
						local pbarSlider = pbarTraits(productIPS[pChildren[i]] * sliderValue)
						
						products[pName.."-ingredientWrap"][pName.."-inserter-sprite-wrap"]["belt"].clear()
						products[pName.."-ingredientWrap"][pName.."-inserter-sprite-wrap"]["chest"].clear()
						if productType ~= "fluid" then
						
							products[pName.."-ingredientWrap"][pName.."-inserter-sprite-wrap"]["belt"].add{type = "label", name = "belt-label", caption = "Belt"}
							products[pName.."-ingredientWrap"][pName.."-inserter-sprite-wrap"]["chest"].add{type = "label", name = "chest-label", caption = "Chest"}
							addInserterSprites(products, pName, pbarSlider.belt, player.force.technologies, truncateNumber(productIPS[pChildren[i]], 2), "to")
						end			
						if products[pName.."-ingredientWrap"][pName.."-PbarFlowWrap"][pName.."pbar"] then
							products[pName.."-ingredientWrap"][pName.."-PbarFlowWrap"][pName.."pbar"].style.color = pbarSlider.color
							products[pName.."-ingredientWrap"][pName.."-PbarFlowWrap"][pName.."pbar"].value = pbarSlider.value
							products[pName.."-ingredientWrap"][pName.."-PbarFlowWrap"][pName.."pbar"].tooltip = pbarSlider.tool
						end
					end
				end
			end
		else
			event.entity = player.opened
			event.gui_type = defines.gui_type.entity
			setupGui(event)
		end
	end
end

script.on_event(defines.events.on_gui_opened, setupGui)

script.on_event(defines.events.on_gui_closed, closeGui)

script.on_event(defines.events.on_gui_click, playerClickedGui)

script.on_event(defines.events.on_gui_value_changed, playerSlid)
