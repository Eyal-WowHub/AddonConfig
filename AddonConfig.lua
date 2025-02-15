---@diagnostic disable: undefined-field
assert(LibStub, "AddonConfig-1.0 requires LibStub")

local C = LibStub("Contracts-1.0")
assert(C, "AddonConfig-1.0 requires Contracts-1.0")

local lib = LibStub:NewLibrary("AddonConfig-1.0", 0)
if not lib then return end

lib.Styles = lib.Styles or {}
lib.Controls = lib.Controls or {}
lib.Schema = lib.Schema or {
    name = "string",
    type = "string",
    handler = "table?",
    props = {"table?", "function?"},
}

--[[ Localization ]]

local L = {
    ["ALREADY_REGISTERED"] = "the %s '%s version %d' already registered.",
    ["STYLE_IS_UNKNOWN"] = "the style '%s' is unknown.",
    ["CONTROL_IS_UNKNOWN"] = "the template field '[\"%s\"].type' is assigned with an unknown control '%s'.",
    ["SCHEMA_TYPE_IS_NOT_SUPPORTED"] = "the schema type '%s' is not supported. Supported types: 'boolean', 'number', 'string', 'table' and 'function'.",
    ["TEMPLATE_FIELD_IS_MISSING_OR_NIL"] = "the template field '[#%s].%s' is either missing or has a nil value. Expected type(s) '%s'."
}

--[[ Template API ]]

local Template = {}

function Template:Validate(schema)
    lib:Validate(self, schema)
end

function Template:SetCategory(category, layout)
    self.__category = category
    self.__layout = layout
end

do
    local ParentInfo = {}

    -- NOTE: If you call `GetParentInfo` outside a closure and need to use its properties inside the closure, 
    --       store a reference to them beforehand. Otherwise, the closure may execute later, and the original 
    --       values might no longer be accessible.
    
    function Template:GetParentInfo()
        local parent = self.__parent

        if parent then
            ParentInfo.template = parent
            ParentInfo.category = parent.__category
            ParentInfo.layout = parent.__layout
            ParentInfo.handler = parent.handler
            return ParentInfo
        end

        return nil
    end
end

function Template:GetIndex()
    return self.__index
end

function Template:GetCurrentIndex()
    return self:GetIndex():match(".*:(%d+)") or self:GetIndex()
end

function Template:SetVariableTypeByValue(value)
    local valueType = type(value)

    if valueType == "string" then
        self.__varType = Settings.VarType.String
    elseif valueType == "number" then
        self.__varType = Settings.VarType.Number
    elseif valueType == "boolean" then
        self.__varType = Settings.VarType.Boolean
    end
end

function Template:HasVariableType()
    return self.__varType ~= nil
end

function Template:RegisterControlSetting()
    local parent = self:GetParentInfo()
    local handler = parent.handler

    if not self:HasVariableType() then
        self:SetVariableTypeByValue(self.default)
    end

    local function get()
        local value = self.get(handler)

        return value ~= nil and value or self.default
    end

    local function set(...)
        self.set(handler, ...)
    end

    local hasOptions = self.options and type(self.options) == "table"
    
    if hasOptions then
        local hasDisabledFunc = self.disabled and type(self.disabled) == "function"

        if hasDisabledFunc then
            self.options.disabled = function()
                return self.disabled(handler)
            end
        end
    end

    local setting = Settings.RegisterProxySetting(parent.category, self.__varName, self.__varType, self.name, self.default, get, set)

    Settings.SetOnValueChangedCallback(setting.variable, function(_, setting, value)
        -- NOTE: This event notifies controls when a setting's value changes.  
        --       Any control listening to this event can respond accordingly.  
        --       For example, a textbox may enable or disable itself based on the state of a checkbox. 
        EventRegistry:TriggerEvent("AddonConfig.ValueChanged", setting, value)
	end)

    return setting
end

function Template:InitializeControl(controlTemplate)
    local parent = self:GetParentInfo()
    local setting = self:RegisterControlSetting()
    local initializer = Settings.CreateControlInitializer(controlTemplate, setting, self.options, self.tooltip)

    parent.layout:AddInitializer(initializer)
end

-- [[ Library API ]]

do
    local function CreateTypeInfo(kind, registry, name, version)
        C:Ensures(not registry[name] or registry[name].version == version, L["ALREADY_REGISTERED"], kind, name, version)
    
        local typeInfo = {
            version = version
        }
    
        registry[name] = typeInfo
    
        return typeInfo
    end
    
    local function GetTypeVersion(registry, name)
        return registry[name] and registry[name].version or 0
    end
    
    function lib:RegisterControl(name, version, ctor)
        C:IsString(name, 2)
        C:IsNumber(version, 3)
        C:IsFunction(ctor, 4)
    
        local controlInfo = CreateTypeInfo("control", self.Controls, name, version)
        controlInfo.constructor = ctor
    end
    
    function lib:GetControlVersion(name)
        C:IsString(name, 2)
    
        return GetTypeVersion(self.Controls, name)
    end
    
    function lib:RegisterStyle(name, version, transformer)
        C:IsString(name, 2)
        C:IsNumber(version, 3)
        C:IsFunction(transformer, 4)
    
        local styleInfo = CreateTypeInfo("style", self.Styles, name, version)
        styleInfo.transformer = transformer
    end
    
    function lib:GetStyleVersion(name)
        C:IsString(name, 2)
    
        return GetTypeVersion(self.Styles, name)
    end
end

do
    local LuaType = {
        ["boolean"] = true,
        ["number"] = true,
        ["string"] = true,
        ["table"] = true,
        ["function"] = true
    }

    local function GetSchemaType(schemaType)
        local actualType, optional = string.match(schemaType, "^([a-z]+)([?]?)$")
        local isOptional = optional ~= ""

        actualType = LuaType[actualType] and actualType

        C:Ensures(actualType, L["SCHEMA_TYPE_IS_NOT_SUPPORTED"], schemaType)

        return actualType, isOptional
    end

    local function IsValueMatchType(propValue, schemaType)
        local actualType, isOptional = GetSchemaType(schemaType)

        return isOptional and propValue == nil or type(propValue) == actualType
    end

    local function IsValueMatchTypes(propValue, schemaType)
        if type(schemaType) == "table" then
            for _, schemaType in pairs(schemaType) do
                if IsValueMatchType(propValue, schemaType) then
                    return true
                end
            end
        elseif type(schemaType) == "string" then
            return IsValueMatchType(propValue, schemaType)
        end

        return false
    end

    function lib:Validate(template, schema)
        C:IsTable(template, 1)
        C:IsTable(schema, 2)

        for propName, propType in pairs(schema) do
            local propValue = template[propName]

            C:Ensures(IsValueMatchTypes(propValue, propType), L["TEMPLATE_FIELD_IS_MISSING_OR_NIL"], template:GetIndex(), propName, propType)
        end
    end
end

do
    local function GenerateVariableName(name)
        return (name:gsub("([A-Za-z0-9])([A-Za-z0-9]*)", function(first, rest)
            return first:upper() .. rest:lower()
        end):gsub("%W", ""))
    end

    local function ConstructControl(template)
        template = setmetatable(template, { __index = Template })

        if template.type ~= "spacer" then
            lib:Validate(template, lib.Schema)
        end
        
        local controlInfo = lib.Controls[template.type]

        C:Ensures(controlInfo, L["CONTROL_IS_UNKNOWN"], template.name, template.type)

        controlInfo.constructor(template)
    end

    local function ConstructControls(template)
        template.__index = template.__index or "1"
        template.__varName = template.__varName or GenerateVariableName(template.name)

        ConstructControl(template)

        local props = template.props

        if type(props) == "function" then
            props = props({})
        end

        if type(props) == "table" then
            for index, t in ipairs(props) do
                t.__parent = template
                t.__index = template.__index .. ":" .. index
                t.__varName = template.__varName .. "_" .. GenerateVariableName(t.name)
                ConstructControls(t)
            end
        end
    end

    function lib:Generate(template, style)
        C:IsTable(template, 2)

        if style then
            C:IsString(style, 3)

            local styleInfo = self.Styles[style]

            C:Ensures(styleInfo, L["STYLE_IS_UNKNOWN"], style)

            template = styleInfo.transformer(template)
        end

        ConstructControls(template)

        local root = template.__category

        return root:GetID()
    end
end