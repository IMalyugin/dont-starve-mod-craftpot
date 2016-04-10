name = "Craft Pot"
author = "IvanX"
version = "0.3"
description = "Don't you think cooking and crafting are lot alike?"

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
