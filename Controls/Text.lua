local Type, Version = "text", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Type) >= Version then return end

local function Constructor(template, parent)
end

lib:RegisterType(Type, Version, Constructor)