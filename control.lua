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
			playersGui["ACT-frame_"..playerIndex].add{type = "sprite-button", name = lName.."_"..playerIndex.."_sprite", sprite = spritePath, tooltip = lName.." - set/reset recipe, or add/remove modules, then click here to refresh"}
			playersGui["ACT-frame_"..playerIndex].add{type = "label", name = lName.."_"..playerIndex.."_label", caption = message}
			
			if recipe then
				local craftSpeed = entity.prototype.crafting_speed
				local effects = 0
				if entity.effects and entity.effects.speed then
					effects = entity.effects.speed.bonus
				end
				local percent = craftSpeed*effects

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
				message = message..seconds.." seconds."
				if playersGui["ACT-frame_"..playerIndex][lName.."_"..playerIndex.."_sprite"] then
					playersGui["ACT-frame_"..playerIndex][lName.."_"..playerIndex.."_sprite"].destroy()
					playersGui["ACT-frame_"..playerIndex].add{type = "sprite-button", name = lRName.."_"..playerIndex.."_sprite", sprite = spritePath, tooltip = lRName.." - set/reset recipe, or add/remove modules, then click here to refresh"}
				end
				
				if playersGui["ACT-frame_"..playerIndex][lName.."_"..playerIndex.."_label"] then
					playersGui["ACT-frame_"..playerIndex][lName.."_"..playerIndex.."_label"].destroy()
					playersGui["ACT-frame_"..playerIndex].add{type = "label", name = lRName.."_"..playerIndex.."_label", caption = message}
				end
				
				-- playersGui["ACT-frame_"..playerIndex].add{type = "frame", name = "ingredients", caption = "Ingredient Items Per Second"}
				-- playersGui["ACT-frame_"..playerIndex].add{type = "frame", name = "products", caption = "Product Items Per Second"}
								
				for i = 1, #recipe.products do
					local product = recipe.products[i]
					playersGui["ACT-frame_"..playerIndex].add{type = "frame", name = product.name}
					playersGui["ACT-frame_"..playerIndex][product.name].add{type = "sprite", name = "product"..i, sprite = spriteCheck(player, product.type.."/"..product.name), tooltip = localizeString(product.name)}
					playersGui["ACT-frame_"..playerIndex][product.name].add{type = "label", name = "IPS"..i, caption = truncateNumber((product.amount or product.amount_max) / seconds).."/s", tooltip = "Items per second"}
				end
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
	local player = game.players[event.player_index]
	if event.element.type == "sprite-button"  then 

		event.entity = player.opened
		event.gui_type = defines.gui_type.entity
		event.element.parent.destroy()
		setupGui(event)
	end
end

script.on_event(defines.events.on_gui_opened, setupGui)

script.on_event(defines.events.on_gui_closed, closeGui)

script.on_event(defines.events.on_gui_click, playerClickedGui)