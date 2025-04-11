local Name, Version = "vertical-layout", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Name) >= Version then return end

local function Constructor(template)
    if not template.__parent then
        local category = Settings.RegisterVerticalLayoutCategory(template.name)

        template:SetCategory(category)

        Settings.RegisterAddOnCategory(category)
    else
        local subCategory, layout = Settings.RegisterVerticalLayoutSubcategory(template.__category, template.name)

        template:SetCategory(subCategory, layout)
    end
end

lib:RegisterControl(Name, Version, Constructor)