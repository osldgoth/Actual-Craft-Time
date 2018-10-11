local function localizeString(st)
	return string.sub(st, 1, 1):upper()..string.sub(st, 2):gsub("-", " ")
end

local function truncateNumber(nu, digit)
	if nu <= 1 then
		nu = string.format("%."..digit.."f", nu)
	elseif nu <= 10 then
		digit = digit + 1
		nu = string.format("%."..digit.."f", nu / 10) * 10
	elseif nu <=100 then
		digit = digit + 2
		nu = string.format("%."..digit.."f", nu / 100) * 100
	elseif nu <=1000 then
		digit = digit + 3
		nu = string.format("%."..digit.."f", nu / 1000) * 1000
	end
	return nu
end

local function TN(nu, digit)
	game.print("tR nu "..nu)
	if nu <= 1 then
		nu = string.format("%."..digit.."f", nu)
	elseif nu <= 10 then
		game.print("<=10 di: "..digit.." and num: "..nu)        
		digit = digit + 1         
		nu = string.format("%."..digit.."f", nu / 10) * 10 
		game.print("aft fmt di: "..digit.." and num: "..nu)
	
	elseif nu <=100 then
		digit = digit + 2
		nu = string.format("%."..digit.."f", nu / 100) * 100
	elseif nu <=1000 then
		digit = digit + 3
		nu = string.format("%."..digit.."f", nu / 1000) * 1000
	end
	game.print("result "..nu)
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
	local color = {}
	local value = 0
	local tool = ""
	if IPS <= 13.33 then
		color = {r = 0.98, g = 0.73, b = 0.0} -- 250, 186, 0
		value = IPS / 13.33
		tool = truncateNumber(IPS / 13.33 * 100, 2).."%"
	elseif IPS <= 26.66 then
		color = {r = 0.98, g = 0.27, b = 0.06} -- 250, 69, 15
		value = IPS / 26.66
		tool = truncateNumber(IPS / 26.66 * 100, 2).."%"
	elseif IPS <= 40 then
		color = {r = 0.15, g = 0.67, b = 0.71} -- 38, 171, 181
		value = IPS / 40
		tool = truncateNumber(IPS / 40 * 100, 2).."%"
	else
		color = {r = 1, g = 1, b = 1} --white
		value = IPS / 40
		tool = TN(IPS / 40, 2).."%"
	end
	return {color = color, value = value, tool = tool}
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
			local seconds
			
			if playersGui["ACT-frame_"..playerIndex] then
				playersGui["ACT-frame_"..playerIndex].destroy()
			end
			playersGui.add{type = "frame", name = "ACT-frame_"..playerIndex, direction = "vertical"}
			playersGui["ACT-frame_"..playerIndex].add{type = "flow" --[[--]], name = "assemblerFlow", direction = "horizontal"}
			playersGui["ACT-frame_"..playerIndex].add{type = "flow" --[[--]], name = "machineFlow", direction = "vertical"}
			
			local ACTAssemplerFlow = playersGui["ACT-frame_"..playerIndex]["assemblerFlow"]
			local ACTMachineFlow = playersGui["ACT-frame_"..playerIndex]["machineFlow"]
			
			-- START OF ASSEMBLER_FLOW DATA
			ACTAssemplerFlow.add{type = "flow" --[[--]], name = "recipe", direction = "vertical"}
			local recipeFlow = ACTAssemplerFlow["recipe"]
			recipeFlow.add{type = "label", name = "recipe_label", caption = "Recipe"}
			
			recipeFlow.add{type = "flow" --[[--]], name = "recipeInfo", direction = "horizontal"}
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
				message = message..truncateNumber(seconds,2).." seconds"
				if recipeInfoFlow[playerIndex.."_sprite-button"] then
					recipeInfoFlow[playerIndex.."_sprite-button"].destroy()
					recipeInfoFlow.add{type = "sprite-button", name = playerIndex.."_sprite-button", sprite = spritePath, tooltip = lRName.." - set/reset recipe, or add/remove modules, then click here to refresh"}
				end
				
				if recipeInfoFlow[lName.."_"..playerIndex.."_label"] then
					recipeInfoFlow[lName.."_"..playerIndex.."_label"].destroy()
					recipeInfoFlow.add{type = "label", name = lRName.."_"..playerIndex.."_label", caption = message}
				end
				
				ACTAssemplerFlow.add{type = "flow" --[[--]], name = "ingredients", direction = "vertical"}
				ACTAssemplerFlow["ingredients"].add{type = "label", name = "ingredients_label", caption = "Ingredients"}

				ACTAssemplerFlow.add{type = "flow" --[[--]], name = "products", direction = "vertical"}
				ACTAssemplerFlow["products"].add{type = "label", name = "products_label", caption = "Products"}
				
				IngerdientIPS = {}
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
				ACTMachineFlow.add{type = "label", name = "slider_label", caption = "Adjust number of machines"}
				ACTMachineFlow.add{type = "flow" --[[--]], name = "slider_flow", direction = "horizontal"}
				if event.slider_value then
					ACTMachineFlow["slider_flow"].add{type = "slider", name = playerIndex.."_slider", minimum_value = 1, maximum_value = playerSliderSetting, value = event.slider_value}
				else
					ACTMachineFlow["slider_flow"].add{type = "slider", name = playerIndex.."_slider", minimum_value = 1, maximum_value = playerSliderSetting, value = 1}
				end
				ACTMachineFlow["slider_flow"].add{type = "label", name = "slider_label", caption = truncateNumber(ACTMachineFlow["slider_flow"][playerIndex.."_slider"].slider_value,0).." "..localizeString(entity.name)}
			
			end
		end
	end
end

function addItemFrame(player, ACTAssemplerFlowI_P, product, seconds, effects)
	ACTAssemplerFlowI_P.add{type = "flow" --[[--]], name = product.name.."PbarFlowWrap", direction = "vertical"}
	ACTAssemplerFlowI_P[product.name.."PbarFlowWrap"].add{type = "flow" --[[--]], name = product.name.."IPS"}
	ACTAssemplerFlowI_P[product.name.."PbarFlowWrap"][product.name.."IPS"].add{type = "sprite", name = product.name.."Sprite", sprite = spriteCheck(player, product.type.."/"..product.name), tooltip = localizeString(product.name)}
	
	if product.type ~= "fluid" then
		ACTAssemplerFlowI_P[product.name.."PbarFlowWrap"].add{type = "progressbar", name = product.name.."pbar"}
		ACTAssemplerFlowI_P[product.name.."PbarFlowWrap"][product.name.."pbar"].style.maximal_width = 93
	end
	
	if ACTAssemplerFlowI_P.name == "ingredients" then
		local IPS = truncateNumber((product.amount or product.amount_max) / seconds, 2)
		IngerdientIPS[product.name.."PbarFlowWrap"] = IPS
		ACTAssemplerFlowI_P[product.name.."PbarFlowWrap"][product.name.."IPS"].add{type = "label", name = product.name.."Label", caption = IPS.."/s", tooltip = "Items per second"}
		
		local pbarInitial = pbarTraits(IPS)

		if product.type ~= "fluid" then
			ACTAssemplerFlowI_P[product.name.."PbarFlowWrap"][product.name.."pbar"].style.color = pbarInitial.color
			ACTAssemplerFlowI_P[product.name.."PbarFlowWrap"][product.name.."pbar"].value = pbarInitial.value
			ACTAssemplerFlowI_P[product.name.."PbarFlowWrap"][product.name.."pbar"].tooltip = pbarInitial.tool
		end
	else
		local IPS = truncateNumber(((product.amount or product.amount_max) + ((product.amount or product.amount_max) * effects.productivity.bonus)) / seconds,2)
		productIPS[product.name.."PbarFlowWrap"] = IPS
		ACTAssemplerFlowI_P[product.name.."PbarFlowWrap"][product.name.."IPS"].add{type = "label", name = product.name.."Label", caption = IPS.."/s", tooltip = "Items per second"}
		
		local pbarInitial = pbarTraits(IPS)
		
		if product.type ~= "fluid" then
			ACTAssemplerFlowI_P[product.name.."PbarFlowWrap"][product.name.."pbar"].style.color = pbarInitial.color
			ACTAssemplerFlowI_P[product.name.."PbarFlowWrap"][product.name.."pbar"].value = pbarInitial.value
			ACTAssemplerFlowI_P[product.name.."PbarFlowWrap"][product.name.."pbar"].tooltip = pbarInitial.tool
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
	local player = game.players[event.player_index]
	if event.element.type == "sprite-button" and event.element.name == playerIndex.."_sprite-button"  then 

		event.entity = player.opened
		event.gui_type = defines.gui_type.entity
		setupGui(event)
	end
end

local function playerSlid(event)
	game.print("break!!!")
	if event.element.name == event.player_index.."_slider" then
		local playerIndex = event.player_index
		local player = game.players[playerIndex]
		local guiLocation = player.mod_settings["ACT-Gui-Location"].value
		local playersGui = player.gui[guiLocation] --top or left
		local sliderLabelCaption = playersGui["ACT-frame_"..event.player_index]["machineFlow"]["slider_flow"]["slider_label"].caption
		local sliderNum = string.sub(sliderLabelCaption, string.find(sliderLabelCaption, "%d+"))
		
		if math.abs( sliderNum - event.element.slider_value) >= .5 then
			
			local ingredients = playersGui["ACT-frame_"..event.player_index]["assemblerFlow"]["ingredients"]
			local products = playersGui["ACT-frame_"..event.player_index]["assemblerFlow"]["products"]
			
			local iChildren = ingredients.children_names
			local pChildren = products.children_names
			
			local sliderValue = truncateNumber(event.element.slider_value, 0)
			
			playersGui["ACT-frame_"..event.player_index]["machineFlow"]["slider_flow"]["slider_label"].caption = sliderValue.." "..localizeString(player.opened.name)
			
			for i = 2, #iChildren do
				local iName = string.sub(iChildren[i], 1, string.find(iChildren[i], "PbarFlowWrap") - 1)
				ingredients[iChildren[i]][iName.."IPS"][iName.."Label"].caption = tostring(IngerdientIPS[iChildren[i]] * sliderValue).."/s"
				
				local pbarSlider = pbarTraits(IngerdientIPS[iChildren[i]] * sliderValue)

				if ingredients[iName.."PbarFlowWrap"][iName.."pbar"] then
					ingredients[iName.."PbarFlowWrap"][iName.."pbar"].style.color = pbarSlider.color
					ingredients[iName.."PbarFlowWrap"][iName.."pbar"].value = pbarSlider.value
					ingredients[iName.."PbarFlowWrap"][iName.."pbar"].tooltip = pbarSlider.tool
				end
			end
			for i = 2, #pChildren do
				local pName = string.sub(pChildren[i], 1, string.find(pChildren[i], "PbarFlowWrap") - 1)
				products[pChildren[i]][pName.."IPS"][pName.."Label"].caption = tostring(productIPS[pChildren[i]] * sliderValue).."/s"
				
				local pbarSlider = pbarTraits(productIPS[pChildren[i]] * sliderValue)
		
				if products[pName.."PbarFlowWrap"][pName.."pbar"] then
					products[pName.."PbarFlowWrap"][pName.."pbar"].style.color = pbarSlider.color
					products[pName.."PbarFlowWrap"][pName.."pbar"].value = pbarSlider.value
					products[pName.."PbarFlowWrap"][pName.."pbar"].tooltip = pbarSlider.tool
				end
			end
		end
	end
end

script.on_event(defines.events.on_gui_opened, setupGui)

script.on_event(defines.events.on_gui_closed, closeGui)

script.on_event(defines.events.on_gui_click, playerClickedGui)

script.on_event(defines.events.on_gui_value_changed, playerSlid)
