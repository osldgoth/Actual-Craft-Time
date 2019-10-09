local default_style = data.raw["gui-style"].default

default_style.ACT_inserter = {
  type = "button_style",
  parent = "slot_button",

	scalable = false,

  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,

  height = 20,
  width = 20,

  default_graphical_set = {
        type = "composition",
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        load_in_minimal_mode = true,
        corner_size = {1, 1},
        position = {0, 17} --0,17
      },
  hovered_graphical_set = {
        type = "composition",
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        load_in_minimal_mode = true,
        corner_size = {1, 1},
        position = {0, 17}
      },
  clicked_graphical_set = {
        type = "composition",
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        load_in_minimal_mode = true,
        corner_size = {1, 1},
        position = {0, 17}
      }
}

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

  --[[default_graphical_set = {
        type = "composition",
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        load_in_minimal_mode = true,
        corner_size = {1, 1},
        position = {0, 0} --0,17
      },
  hovered_graphical_set = {
        type = "composition",
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        load_in_minimal_mode = true,
        corner_size = {1, 1},
        position = {0, 0}
      },
  clicked_graphical_set = {
        type = "composition",
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        load_in_minimal_mode = true,
        corner_size = {1, 1},
        position = {0, 0}
      }--]]
}