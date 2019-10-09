data:extend({
	{
		type = "string-setting",
		name = "ACT-Gui-Location",
		setting_type = "runtime-per-user",
		default_value = "top",
		allowed_values = {"top", "left"}
	},
	{
		type = "bool-setting",
		name = "ACT-simple-text",
		setting_type = "runtime-per-user",
		default_value = false
	},
	{
		type = "int-setting",
		name = "ACT-max-slider-value",
		setting_type = "runtime-per-user",
		minimum_value = 25,
		default_value = 200
	},
	{
		type = "int-setting",
		name = "ACT-slider-sensitivity",
		setting_type = "runtime-per-user",
		minimum_value = 1,
		default_value = 5,
		maximum_value = 10
	}
})