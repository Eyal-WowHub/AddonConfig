local Name, Version = "spacer", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Name) >= Version then return end

local function Constructor(template)
    local initializer = Settings.CreateElementInitializer('SettingsCategoryListSpacerTemplate', template)

    template.__layout:AddInitializer(initializer)
end

lib:RegisterControl(Name, Version, Constructor)