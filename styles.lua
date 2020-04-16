local default_style = data.raw["gui-style"].default

default_style.ACT_buttons = {
  type = "button_style",
  --parent = "slot_button",

	scalable = false,

  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,

  height = 20,
  width = 20,
}

 default_style.ACT_vertical_flow = {
			type = "vertical_flow_style",
			vertical_spacing = 10,
			top_padding = 6,
		}
-- }