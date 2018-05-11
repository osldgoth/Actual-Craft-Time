local function localizeString(st)
	return string.sub(st, 1, 1):upper()..string.sub(st, 2):gsub("-", " ")
end

local function truncateNumber(nu)
	return string.format("%.2f", nu)
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

local function setupGui(event)
	if event.gui_type == defines.gui_type.entity then
		local entity = event.entity
		if	entity and (
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
			local playersGui = player.gui[guiLocation] --top or left
			local seconds
			
			playersGui.add{type = "frame", name = "ACT-frame_"..playerIndex}
			local ACTFrame = playersGui["ACT-frame_"..playerIndex]
			ACTFrame.add{type = "flow", name = "recipe", direction = "vertical"}
			local recipeFlow = ACTFrame["recipe"]
			recipeFlow.add{type = "label", name = "recipe_label", caption = "Recipe"}
			
			recipeFlow.add{type = "flow", name = "recipe info"}
			local recipeInfoFlow = recipeFlow["recipe info"]
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
				seconds = truncateNumber(base/(craftSpeed+percent))				
				local lRName = localizeString(recipe.name)
				spritePath = spriteCheck(player, "recipe/"..recipe.name)
				
				if simple then
					message = ""
				else
					message = lRName.." crafts in: "
				end
				message = message..seconds.." seconds"
				if recipeInfoFlow[playerIndex.."_sprite-button"] then
					recipeInfoFlow[playerIndex.."_sprite-button"].destroy()
					recipeInfoFlow.add{type = "sprite-button", name = playerIndex.."_sprite-button", sprite = spritePath, tooltip = lRName.." - set/reset recipe, or add/remove modules, then click here to refresh"}
				end
				
				if recipeInfoFlow[lName.."_"..playerIndex.."_label"] then
					recipeInfoFlow[lName.."_"..playerIndex.."_label"].destroy()
					recipeInfoFlow.add{type = "label", name = lRName.."_"..playerIndex.."_label", caption = message}
				end
				
				ACTFrame.add{type = "flow", name = "ingredients", direction = "vertical"}
				ACTFrame["ingredients"].add{type = "label", name = "ingredients_label", caption = "Ingredients"}

				ACTFrame.add{type = "flow", name = "products", direction = "vertical"}
				ACTFrame["products"].add{type = "label", name = "products_label", caption = "Products"}
						
				for i = 1, #recipe.ingredients do
					addItemFrame(player, ACTFrame, playerIndex, i, recipe.ingredients[i], seconds, "ingredients", effects)
				end
				
				for i = 1, #recipe.products do
					addItemFrame(player, ACTFrame, playerIndex, i, recipe.products[i], seconds, "products", effects)
				end
			end
		end
	end
end

function addItemFrame(player, ACTFrame, playerIndex, itemIndex, product, seconds, outerFrameName, effects)
	ACTFrame[outerFrameName].add{type = "flow", name = product.name}
	ACTFrame[outerFrameName][product.name].add{type = "sprite", name = outerFrameName..itemIndex, sprite = spriteCheck(player, product.type.."/"..product.name), tooltip = localizeString(product.name)}
	if outerFrameName == "ingredients" then
		ACTFrame[outerFrameName][product.name].add{type = "label", name = "IPS"..itemIndex, caption = truncateNumber((product.amount or product.amount_max) / seconds).."/s", tooltip = "Items per second"}
	else
		ACTFrame[outerFrameName][product.name].add{type = "label", name = "IPS"..itemIndex, caption = truncateNumber(((product.amount or product.amount_max) + ((product.amount or product.amount_max) * effects.productivity.bonus)) / seconds).."/s", tooltip = "Items per second"}
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
		event.element.parent.parent.parent.destroy()
		setupGui(event)
	end
end

script.on_event(defines.events.on_gui_opened, setupGui)

script.on_event(defines.events.on_gui_closed, closeGui)

script.on_event(defines.events.on_gui_click, playerClickedGui)
