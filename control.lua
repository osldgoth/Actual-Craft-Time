local function localizestring(st)
	return string.sub(st, 1, 1):upper()..string.sub(st, 2):gsub("-", " ")
end

local function truncateNumber(nu)
	return string.format("%.2f", nu)
end

local function showActualCraftTime(gui, recipeName, seconds)
	local simple = game.players[gui.player_index].mod_settings["__-simple-text"].value
	local message = ""
	if simple then
		--add icon of recipe
	else
		message = recipeName.." crafts in"
	end
	message = message..": " ..seconds.."s"
	--add flow around it? --change text color?
	gui.add{type = "frame", name = "ACT-frame"}.add{type = "label", name = gui.player_index..recipeName, caption = message}
end

--add on gui closed, on recipe set?
script.on_event(defines.events.on_gui_opened, function(event)
	if event.gui_type == defines.gui_type.entity then
		local entity = event.entity
		if	entity and (
				entity.type == "assembling-machine" or
				entity.type == "furnace" or
				entity.type == "rocket-silo")	then
			
			local craftSpeed = entity.prototype.crafting_speed
			local recipe = entity.get_recipe()
			local effects = 0
			local base = 0
			if entity.effects and entity.effects.speed then
				effects = entity.effects.speed.bonus
			end
			local percent = craftSpeed*effects
			if recipe then
				local player = game.players[event.player_index]
				local guiLocation = player.mod_settings["__-Gui-Location"].value
				local playersGui = player.gui[guiLocation] --top or left
				base = recipe.energy
				showActualCraftTime(playersGui, localizestring(recipe.name), truncateNumber(base/(craftSpeed+percent)))
				
			end
		end
	end
end
)