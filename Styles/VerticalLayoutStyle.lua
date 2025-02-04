local Style, Version = "vertical-layout", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetStyleVersion(Style) >= Version then return end

--[[ Example:
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
}]]

local function Transformer(template)
    local topLevelName = template[1].name

    local dest = {
        name = topLevelName,
        type = "vertical-layout",
        props = {}
    }

    for i = 2, #template do
        local field = template[i]
        table.insert(dest.props, {
            name = field.name,
            type = "vertical-layout",
            props = field.layout
        })
    end

    return dest
end

lib:RegisterStyle(Style, Version, Transformer)