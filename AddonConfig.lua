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
    props = "table?",
    init = "function?"
}

--[[ Localization ]]

local L = {
    ["ALREADY_REGISTERED"] = "the %s '%s version %d' already registered.",
    ["STYLE_IS_UNKNOWN"] = "the style '%s' is unknown.",
    ["CONTROL_IS_UNKNOWN"] = "the template field '[\"%s\"].type' is assigned with an unknown control '%s'.",
    ["SCHEMA_TYPE_IS_NOT_SUPPORTED"] = "the schema type '%s' is not supported. Supported types: 'boolean', 'number', 'string', 'table' and 'function'.",
    ["TEMPLATE_FIELD_IS_MISSING_OR_NIL"] = "the template field '[#%s].%s' is either missing or has a nil value. Expected type(s) '%s'.",
    ["TEMPLATE_FIELD_IS_INVALID"] = "the field '%s' of '%s' is invalid.",
}

--[[ Template API ]]

local Template = {}

function Template:Validate(schema)
    C:IsTable(schema, 2)

    lib:Validate(self, schema)
end

function Template:SetCategory(category, layout)
    C:IsTable(category, 2)

    self.__category = category
    self.__layout = layout
end

do
    local varIndex = 1

    local function GenerateVariableName(name)
        return (name:gsub("([A-Za-z0-9])([A-Za-z0-9]*)", function(first, rest)
            return first:upper() .. rest:lower()
        end):gsub("%W", ""))
    end

    function Template:SetParentInfo()
        varIndex = varIndex + 1

        self.__index = self.__index or "1"
        self.__varName = self.__varName or GenerateVariableName(self.name) .. varIndex
        self.__handler = self.__handler or self.handler
    end

    function Template:SetChildInfo(index, child)
        C:IsNumber(index, 2)
        C:IsTable(child, 3)

        varIndex = varIndex + 1

        child.__parent = self
        child.__category = self.__category
        child.__layout = self.__layout
        child.__index = self.__index .. ":" .. index
        child.__varName = self.__varName .. "_" .. GenerateVariableName(child.name) .. varIndex
        child.__handler = self.__handler
    end
end

function Template:GetCurrentIndex()
    return self.__index:match(".*:(%d+)") or self.__index
end

function Template:SetVariableTypeByValue(value)
    C:Requires(value, 2, "string", "number", "boolean")

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
    if not self:HasVariableType() then
        self:SetVariableTypeByValue(self.default)
    end

    local function get()
        local value = self.get(self.__handler)

        return value ~= nil and value or self.default
    end

    local function set(...)
        self.set(self.__handler, ...)
    end

    local hasOptions = self.options and type(self.options) == "table"

    if hasOptions then
        local hasDisabledFunc = self.disabled and type(self.disabled) == "function"

        if hasDisabledFunc then
            self.options.disabled = function()
                return self.disabled(self.__handler)
            end
        end
    end

    C:Ensures(type(self.__category) == "table", L["TEMPLATE_FIELD_IS_INVALID"], "__category", self.name)

    local setting = Settings.RegisterProxySetting(self.__category, self.__varName, self.__varType, self.name, self.default, get, set)

    Settings.SetOnValueChangedCallback(setting.variable, function(_, setting, value)
        -- NOTE: This event notifies controls when a setting's value changes.  
        --       Any control listening to this event can respond accordingly.  
        --       For example, a textbox may enable or disable itself based on the state of a checkbox. 
        EventRegistry:TriggerEvent("AddonConfig.ValueChanged", setting, value)
	end)

    return setting
end

function Template:InitializeControl(controlTemplate)
    C:IsString(controlTemplate, 2)

    local setting = self:RegisterControlSetting()
    local initializer = Settings.CreateControlInitializer(controlTemplate, setting, self.options, self.tooltip)

    C:Ensures(type(self.__layout) == "table", L["TEMPLATE_FIELD_IS_INVALID"], "__layout", self.name)

    self.__layout:AddInitializer(initializer)
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

            C:Ensures(IsValueMatchTypes(propValue, propType), L["TEMPLATE_FIELD_IS_MISSING_OR_NIL"], template.__index, propName, propType)
        end
    end
end

do
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
        ConstructControl(template)

        template:SetParentInfo()

        local props = template.props or {}

        if type(template.init) == "function" then
            template.init(props)
        end

        for index, t in ipairs(props) do
            template:SetChildInfo(index, t)

            ConstructControls(t)
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