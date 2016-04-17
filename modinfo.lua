name = "Craft Pot"
author = "IvanX"
version = "0.31"
description = "Don't you think cooking and crafting are lot alike?"

priority = -1337

forumthread = ""
api_version = 6

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options =
{
  {
    name = "lock_uncooked",
    label = "Lock uncooked",
    options =
    {
        {description = "On", data = true},
        {description = "Off", data = false},
    },
    default = "on"
  }
}
