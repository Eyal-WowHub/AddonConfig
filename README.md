# SettingsGenerator

A library that generates addon settings from a template.

#### Dependencies: [LibStub](https://www.curseforge.com/wow/addons/libstub), [Contracts](https://github.com/Eyal-WowHub/Contracts)

### Examples:

```lua
local SG = LibStub("SettingsGenerator-1.0")
```

#### Traditional Template

The following example demonstrates the traditional template structure for creating the settings:

```lua
local settings = {
    name = "AddonName",
    type = "vertical-layout",
    props = {
        {
            name = "Category 1",
            type = "vertical-layout",
            props = {
                {
                    name = "Click Me!",
                    type = "button",
                    click = ClickHandler
                }
            }
        },
        {
            name = "Category 2",
            type = "vertical-layout",
            props = {}
        },
        {
            name = "Category 3",
            type = "vertical-layout",
            props = {}
        }
    }
}

local optionsID = SG:Generate(settings)
```

#### Simplified Template

For a more concise approach, you can use the following simplified template structure, which produces the same results as the above:

```lua
local settings = {
    {
        name = "AddonName"
    },
    {
        name = "Category 1",
        layout = {
            {
                name = "Click Me!",
                type = "button",
                click = ClickHandler
            }
        }
    },
    {
        name = "Category 2",
        layout = {}
    },
    {
        name = "Category 3",
        layout = {}
    }
}

local optionsID = SG:FromVerticalLayoutStyle(settings)
```







