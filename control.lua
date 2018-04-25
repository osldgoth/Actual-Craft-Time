local function localizeString(st)
	return string.sub(st, 1, 1):upper()..string.sub(st, 2):gsub("-", " ")
end

local function truncateNumber(nu)
	return string.format("%.2f", nu)
end

local function showActualCraftTime(gui, spritePath, recipeName, message)
	if gui["ACT-frame"] then
		gui["ACT-frame"].destroy()
	end
	if spritePath then
		gui.add{type = "frame", name = "ACT-frame"}.add{type = "sprite", name = recipeName..gui.player_index, sprite = spritePath}
		gui["ACT-frame"].add{type = "label", name = recipeName.."_"..gui.player_index, caption = message}
	else
		gui.add{type = "frame", name = "ACT-frame"}.add{type = "label", name = recipeName..gui.player_index, caption = message}
	end
end

function spriteCheck(player, spritePath)
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
				entity.type == "rocket-silo")	then
			local craftSpeed = entity.prototype.crafting_speed
			local recipe = entity.get_recipe()
			if not recipe and entity.type == "furnace" then
				if not entity.get_output_inventory().is_empty() then 
					for item,_ in pairs(entity.get_output_inventory().get_contents()) do
						recipe = game.recipe_prototypes[item]
					end
				end
				if not recipe  then
					recipe = entity.previous_recipe
				end
			end
			
			
			local effects = 0
			if entity.effects and entity.effects.speed then
				effects = entity.effects.speed.bonus
			end
			local percent = craftSpeed*effects
			local player = game.players[event.player_index]
			local guiLocation = player.mod_settings["ACT-Gui-Location"].value
			local playersGui = player.gui[guiLocation] --top or left
			local spritePath
			if recipe then
				local simple = player.mod_settings["ACT-simple-text"].value --t or f
				local message = ""
				local base = recipe.energy
				local seconds = truncateNumber(base/(craftSpeed+percent))
				local ips = truncateNumber(1/seconds)
				
				local lName = localizeString(recipe.name)				
				if simple then
					spritePath = spriteCheck(player, "recipe/"..recipe.name)
				else
					message = lName.." crafts in: "
				end
				message = message..seconds.."s.   Items/s: "..ips
				showActualCraftTime(playersGui, spritePath, lName, message)
			else
				spritePath = spriteCheck(player, "entity/"..entity.name)
				local lName = ""
				local message = "No recipe information"
				showActualCraftTime(playersGui, spritePath, lName, message)
			end
		end
	end
end

local function closeGui(event)
local player = game.players[event.player_index]
local guiLocation = player.mod_settings["ACT-Gui-Location"].value
	if player.gui[guiLocation]["ACT-frame"] then
		player.gui[guiLocation]["ACT-frame"].destroy()
	end
end

-- local function modifyRecipe(event)
	-- game.print("on_gui_click confirmed")
-- end

script.on_event(defines.events.on_gui_opened, setupGui)

script.on_event(defines.events.on_gui_closed, closeGui)

--script.on_event(defines.events.on_gui_click, modifyRecipe)

