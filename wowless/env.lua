local bitlib = require('bit')
local util = require('wowless.util')
local Mixin = util.mixin

local UNIMPLEMENTED = function() end
local STUB_NUMBER = function() return 1 end
local STUB_TABLE = function() return {} end

local function toTexture(parent, tex)
  if type(tex) == 'string' then
    local t = parent:CreateTexture()
    t:SetTexture(tex)
    return t
  else
    return tex
  end
end

local function mkBaseUIObjectTypes(api)
  local function u(x)
    return api.UserData(x)
  end

  local function m(obj, f, ...)
    return getmetatable(obj).__index[f](obj, ...)
  end

  local function UpdateVisible(obj)
    local ud = u(obj)
    local pv = not ud.parent or u(ud.parent).visible
    local nv = pv and ud.shown
    if ud.visible ~= nv then
      ud.visible = nv
      api.RunScript(obj, nv and 'OnShow' or 'OnHide')
      for k in pairs(ud.children or {}) do
        UpdateVisible(k)
      end
    end
  end

  local function flatten(types)
    local result = {}
    local function flattenOne(k)
      local lk = string.lower(k)
      if not result[lk] then
        local ty = types[k]
        local inherits = {}
        local metaindex = Mixin({}, ty.mixin)
        for _, inh in ipairs(ty.inherits) do
          flattenOne(inh)
          table.insert(inherits, string.lower(inh))
          Mixin(metaindex, result[string.lower(inh)].metatable.__index)
        end
        result[lk] = {
          constructor = function(self)
            for _, inh in ipairs(inherits) do
              result[inh].constructor(self)
            end
            if ty.constructor then
              ty.constructor(self)
            end
          end,
          inherits = inherits,
          metatable = { __index = metaindex },
          name = k,
        }
      end
    end
    for k in pairs(types) do
      flattenOne(k)
    end
    return result
  end

  return flatten({
    Actor = {
      inherits = {'ParentedObject', 'ScriptObject'},
    },
    AnimationGroup = {
      inherits = {'ParentedObject', 'ScriptObject'},
      mixin = {
        IsPlaying = UNIMPLEMENTED,
        Play = UNIMPLEMENTED,
        Stop = UNIMPLEMENTED,
      },
    },
    Browser = {
      inherits = {'Frame'},
      mixin = {
        NavigateHome = UNIMPLEMENTED,
      },
    },
    Button = {
      constructor = function(self)
        u(self).beingClicked = false
        u(self).buttonLocked = false
        u(self).buttonState = 'NORMAL'
        u(self).enabled = true
        u(self).fontstring = m(self, 'CreateFontString')
        u(self).pushedTextOffsetX = 0
        u(self).pushedTextOffsetY = 0
        u(self).registeredClicks = { LeftButtonUp = true }
      end,
      inherits = {'Frame'},
      mixin = {
        Click = function(self, button, down)
          local ud = u(self)
          if ud.enabled and not ud.beingClicked then
            ud.beingClicked = true
            local b = button or 'LeftButton'
            api.RunScript(self, 'PreClick', b, down)
            api.RunScript(self, 'OnClick', b, down)
            api.RunScript(self, 'PostClick', b, down)
            ud.beingClicked = false
          end
        end,
        Disable = function(self)
          u(self).enabled = false
        end,
        Enable = function(self)
          u(self).enabled = true
        end,
        GetButtonState = function(self)
          return u(self).buttonState
        end,
        GetDisabledTexture = function(self)
          return u(self).disabledTexture
        end,
        GetFontString = function(self)
          return u(self).fontstring
        end,
        GetHighlightTexture = function(self)
          return u(self).highlightTexture
        end,
        GetNormalTexture = function(self)
          return u(self).normalTexture
        end,
        GetPushedTextOffset = function(self)
          return u(self).pushedTextOffsetX, u(self).pushedTextOffsetY
        end,
        GetPushedTexture = function(self)
          return u(self).pushedTexture
        end,
        GetText = UNIMPLEMENTED,
        GetTextHeight = STUB_NUMBER,
        GetTextWidth = STUB_NUMBER,
        IsEnabled = function(self)
          return u(self).enabled
        end,
        LockHighlight = UNIMPLEMENTED,
        RegisterForClicks = function(self, ...)
          local ud = u(self)
          util.twipe(ud.registeredClicks)
          for _, type in ipairs({...}) do
            ud.registeredClicks[type] = true
          end
        end,
        SetButtonState = function(self, state, locked)
          u(self).buttonLocked = not not locked
          u(self).buttonState = state
        end,
        SetDisabledAtlas = function(self, atlas)
          u(self).disabledTexture = toTexture(self, atlas)
        end,
        SetDisabledFontObject = UNIMPLEMENTED,
        SetDisabledTexture = function(self, tex)
          u(self).disabledTexture = toTexture(self, tex)
        end,
        SetEnabled = function(self, value)
          u(self).enabled = not not value
        end,
        SetFormattedText = UNIMPLEMENTED,
        SetHighlightAtlas = function(self, atlas)
          u(self).highlightTexture = toTexture(self, atlas)
        end,
        SetHighlightFontObject = UNIMPLEMENTED,
        SetHighlightTexture = function(self, tex)
          u(self).highlightTexture = toTexture(self, tex)
        end,
        SetNormalAtlas = function(self, atlas)
          u(self).normalTexture = toTexture(self, atlas)
        end,
        SetNormalFontObject = UNIMPLEMENTED,
        SetNormalTexture = function(self, tex)
          u(self).normalTexture = toTexture(self, tex)
        end,
        SetPushedAtlas = function(self, atlas)
          u(self).pushedTexture = toTexture(self, atlas)
        end,
        SetPushedTextOffset = function(self, x, y)
          u(self).pushedTextOffsetX = x
          u(self).pushedTextOffsetY = y
        end,
        SetPushedTexture = function(self, tex)
          u(self).pushedTexture = toTexture(self, tex)
        end,
        SetText = UNIMPLEMENTED,
        UnlockHighlight = UNIMPLEMENTED,
      },
    },
    CheckButton = {
      constructor = function(self)
        u(self).checked = false
      end,
      inherits = {'Button'},
      mixin = {
        GetChecked = function(self)
          return u(self).checked
        end,
        GetCheckedTexture = function(self)
          return u(self).checkedTexture
        end,
        GetDisabledCheckedTexture = function(self)
          return u(self).disabledCheckedTexture
        end,
        SetChecked = function(self, checked)
          u(self).checked = not not checked
        end,
        SetCheckedTexture = function(self, tex)
          u(self).checkedTexture = toTexture(self, tex)
        end,
        SetDisabledCheckedTexture = function(self, tex)
          u(self).disabledCheckedTexture = toTexture(self, tex)
        end,
      },
    },
    CinematicModel = {
      inherits = {'PlayerModel'},
    },
    Cooldown = {
      inherits = {'Frame'},
      mixin = {
        Clear = UNIMPLEMENTED,
        SetBlingTexture = function(self, tex)
          u(self).blingTexture = toTexture(self, tex)
        end,
        SetEdgeTexture = function(self, tex)
          u(self).edgeTexture = toTexture(self, tex)
        end,
        SetHideCountdownNumbers = UNIMPLEMENTED,
        SetSwipeColor = UNIMPLEMENTED,
        SetSwipeTexture = function(self, tex)
          u(self).swipeTexture = toTexture(self, tex)
        end,
      },
    },
    DressUpModel = {
      inherits = {'PlayerModel'},
    },
    EditBox = {
      constructor = function(self)
        u(self).editboxText = ''
        u(self).enabled = true
        u(self).isAutoFocus = true
        u(self).isCountInvisibleLetters = false
        u(self).isMultiLine = false
        u(self).maxLetters = 64  -- TODO validate this default
      end,
      inherits = {'FontInstance', 'Frame'},
      mixin = {
        ClearFocus = UNIMPLEMENTED,
        Disable = function(self)
          u(self).enabled = false
        end,
        Enable = function(self)
          u(self).enabled = true
        end,
        GetInputLanguage = function()
          return 'ROMAN'  -- UNIMPLEMENTED
        end,
        GetMaxLetters = function(self)
          return u(self).maxLetters
        end,
        GetNumber = STUB_NUMBER,
        GetText = function(self)
          return u(self).editboxText
        end,
        IsAutoFocus = function(self)
          return u(self).isAutoFocus
        end,
        IsCountInvisibleLetters = function(self)
          return u(self).isCountInvisibleLetters
        end,
        IsEnabled = function(self)
          return u(self).enabled
        end,
        IsMultiLine = function(self)
          return u(self).isMultiLine
        end,
        SetAutoFocus = function(self, value)
          u(self).isAutoFocus = not not value
        end,
        SetCountInvisibleLetters = function(self, value)
          u(self).isCountInvisibleLetters = not not value
        end,
        SetFocus = UNIMPLEMENTED,
        SetMaxLetters = function(self, value)
          u(self).maxLetters = value
        end,
        SetMultiLine = function(self, value)
          u(self).isMultiLine = not not value
        end,
        SetNumber = UNIMPLEMENTED,
        SetNumeric = UNIMPLEMENTED,
        SetSecureText = function(self, text)
          u(self).editboxText = text
        end,
        SetSecurityDisablePaste = UNIMPLEMENTED,
        SetSecurityDisableSetText = UNIMPLEMENTED,
        SetText = function(self, text)
          u(self).editboxText = text
        end,
        SetTextInsets = UNIMPLEMENTED,
      },
    },
    FogOfWarFrame = {
      inherits = {'Frame'},
    },
    Font = {
      inherits = {'FontInstance'},
    },
    FontInstance = {
      inherits = {'UIObject'},
      mixin = {
        GetFont = function()
          return nil, 12  -- UNIMPLEMENTED
        end,
        GetShadowOffset = STUB_NUMBER,
        GetSpacing = STUB_NUMBER,
        GetTextColor = function()
          return 1, 1, 1  -- UNIMPLEMENTED
        end,
        SetFont = UNIMPLEMENTED,
        SetFontObject = UNIMPLEMENTED,
        SetIndentedWordWrap = UNIMPLEMENTED,
        SetJustifyH = UNIMPLEMENTED,
        SetJustifyV = UNIMPLEMENTED,
        SetShadowColor = UNIMPLEMENTED,
        SetShadowOffset = UNIMPLEMENTED,
        SetSpacing = UNIMPLEMENTED,
        SetTextColor = UNIMPLEMENTED,
      },
    },
    FontString = {
      inherits = {'FontInstance', 'LayeredRegion'},
      mixin = {
        GetLineHeight = STUB_NUMBER,
        GetStringWidth = STUB_NUMBER,
        GetText = UNIMPLEMENTED,
        IsTruncated = UNIMPLEMENTED,
        SetFormattedText = UNIMPLEMENTED,
        SetMaxLines = UNIMPLEMENTED,
        SetNonSpaceWrap = UNIMPLEMENTED,
        SetText = UNIMPLEMENTED,
        SetTextHeight = UNIMPLEMENTED,
      },
    },
    Frame = {
      constructor = function(self)
        table.insert(api.frames, self)
        u(self).attributes = {}
        u(self).frameLevel = 1
        u(self).frameStrata = 'MEDIUM'
        u(self).hyperlinksEnabled = false
        u(self).id = 0
        u(self).isClampedToScreen = false
        u(self).isUserPlaced = false
        u(self).mouseClickEnabled = true
        u(self).mouseMotionEnabled = true
        u(self).mouseWheelEnabled = false
        u(self).movable = false
        u(self).registeredAllEvents = false
        u(self).registeredEvents = {}
        u(self).resizable = false
      end,
      inherits = {'ParentedObject', 'Region', 'ScriptObject'},
      mixin = {
        CreateFontString = function(self, name)
          return api.CreateUIObject('fontstring', name, self)
        end,
        CreateTexture = function(self, name)
          return api.CreateUIObject('texture', name, self)
        end,
        EnableMouse = function(self, value)
          local ud = u(self)
          ud.mouseClickEnabled = not not value
          ud.mouseMotionEnabled = not not value
        end,
        EnableMouseWheel = function(self, value)
          u(self).mouseWheelEnabled = not not value
        end,
        GetAttribute = function(self, name)
          return u(self).attributes[name]
        end,
        GetChildren = function(self)
          local ret = {}
          for kid in pairs(u(self).children) do
            if api.InheritsFrom(u(kid).type, 'frame') then
              table.insert(ret, kid)
            end
          end
          return unpack(ret)
        end,
        GetFrameLevel = function(self)
          return u(self).frameLevel
        end,
        GetFrameStrata = function(self)
          return u(self).frameStrata
        end,
        GetHyperlinksEnabled = function(self)
          return u(self).hyperlinksEnabled
        end,
        GetID = function(self)
          return u(self).id
        end,
        GetMaxResize = function(self)
          return u(self).maxResizeWidth, u(self).maxResizeHeight
        end,
        GetMinResize = function(self)
          return u(self).minResizeWidth, u(self).minResizeHeight
        end,
        GetRegions = UNIMPLEMENTED,
        IgnoreDepth = UNIMPLEMENTED,
        IsClampedToScreen = function(self)
          return u(self).isClampedToScreen
        end,
        IsEventRegistered = function(self, event)
          local ud = u(self)
          return ud.registeredAllEvents or not not ud.registeredEvents[string.lower(event)]
        end,
        IsMouseClickEnabled = function(self)
          return u(self).mouseClickEnabled
        end,
        IsMouseEnabled = function(self)
          local ud = u(self)
          return ud.mouseClickEnabled and ud.mouseMotionEnabled
        end,
        IsMouseMotionEnabled = function(self)
          return u(self).mouseMotionEnabled
        end,
        IsMouseWheelEnabled = function(self)
          return u(self).mouseWheelEnabled
        end,
        IsMovable = function(self)
          return u(self).movable
        end,
        IsResizable = function(self)
          return u(self).resizable
        end,
        IsUserPlaced = function(self)
          return u(self).isUserPlaced
        end,
        Raise = UNIMPLEMENTED,
        RegisterAllEvents = function(self)
          u(self).registeredAllEvents = true
        end,
        RegisterEvent = function(self, event)
          u(self).registeredEvents[string.lower(event)] = true
        end,
        RegisterForDrag = UNIMPLEMENTED,
        RegisterForMouse = UNIMPLEMENTED,
        RegisterUnitEvent = function(self, event)  -- unit1, unit2
          -- TODO actually do unit filtering
          u(self).registeredEvents[string.lower(event)] = true
        end,
        SetAttribute = function(self, name, value)
          api.log(4, 'setting attribute %s on %s to %s', name, tostring(self:GetName()), tostring(value))
          u(self).attributes[name] = value
          api.RunScript(self, 'OnAttributeChanged', name, value)
        end,
        SetBackdrop = UNIMPLEMENTED,  -- TODO classic era only
        SetBackdropBorderColor = UNIMPLEMENTED,  -- TODO classic era only
        SetBackdropColor = UNIMPLEMENTED,  -- TODO classic era only
        SetClampedToScreen = function(self, value)
          u(self).isClampedToScreen = not not value
        end,
        SetClampRectInsets = UNIMPLEMENTED,
        SetFrameLevel = function(self, frameLevel)
          u(self).frameLevel = frameLevel
        end,
        SetFrameStrata = function(self, frameStrata)
          u(self).frameStrata = frameStrata
        end,
        SetHitRectInsets = UNIMPLEMENTED,
        SetHyperlinksEnabled = function(self, value)
          u(self).hyperlinksEnabled = not not value
        end,
        SetID = function(self, id)
          assert(type(id) == 'number', 'invalid ID ' .. tostring(id))
          u(self).id = id
        end,
        SetMaxResize = function(self, maxWidth, maxHeight)
          u(self).maxResizeWidth = maxWidth
          u(self).maxResizeHeight = maxHeight
        end,
        SetMinResize = function(self, minWidth, minHeight)
          u(self).minResizeWidth = minWidth
          u(self).minResizeHeight = minHeight
        end,
        SetMouseClickEnabled = function(self, value)
          u(self).mouseClickEnabled = not not value
        end,
        SetMouseMotionEnabled = function(self, value)
          u(self).mouseMotionEnabled = not not value
        end,
        SetMovable = function(self, value)
          u(self).movable = not not value
        end,
        SetResizable = function(self, value)
          u(self).resizable = not not value
        end,
        SetUserPlaced = function(self, value)
          u(self).isUserPlaced = not not value
        end,
        UnregisterAllEvents = function(self)
          u(self).registeredAllEvents = false
          util.twipe(u(self).registeredEvents)
        end,
        UnregisterEvent = function(self, event)
          u(self).registeredEvents[string.lower(event)] = nil
        end,
      },
    },
    GameTooltip = {
      inherits = {'Frame'},
      mixin = {
        AddLine = UNIMPLEMENTED,
        FadeOut = UNIMPLEMENTED,
        GetOwner = function(self)
          return u(self).tooltipOwner
        end,
        IsOwned = function(self)
          return u(self).tooltipOwner ~= nil
        end,
        SetBagItem = UNIMPLEMENTED,
        SetInventoryItem = UNIMPLEMENTED,
        SetMinimumWidth = UNIMPLEMENTED,
        SetOwner = function(self, owner)
          u(self).tooltipOwner = owner
        end,
        SetPadding = UNIMPLEMENTED,
        SetShapeshift = UNIMPLEMENTED,
        SetText = UNIMPLEMENTED,
        SetUnit = UNIMPLEMENTED,
      },
    },
    LayeredRegion = {
      inherits = {'Region'},
      mixin = {
        SetDrawLayer = UNIMPLEMENTED,
        SetVertexColor = UNIMPLEMENTED,
      },
    },
    MessageFrame = {
      inherits = {'Frame'},
    },
    Minimap = {
      inherits = {'Frame'},
    },
    Model = {
      inherits = {'Frame'},
      mixin = {
        SetRotation = UNIMPLEMENTED,
      },
    },
    ModelScene = {
      inherits = {'Frame'},
      mixin = {
        GetLightDirection = function()
          return 1, 1, 1  -- UNIMPLEMENTED
        end,
        GetLightPosition = function()
          return 1, 1, 1  -- UNIMPLEMENTED
        end,
        GetViewInsets = function()
          return 1, 1, 1, 1  -- UNIMPLEMENTED
        end,
        SetLightDirection = UNIMPLEMENTED,
        SetLightPosition = UNIMPLEMENTED,
        SetViewInsets = UNIMPLEMENTED,
      },
    },
    OffScreenFrame = {
      inherits = {'Frame'},
    },
    ParentedObject = {
      constructor = function(self)
        u(self).children = {}
      end,
      inherits = {'UIObject'},
      mixin = {
        GetParent = function(self)
          return u(self).parent
        end,
        SetForbidden = UNIMPLEMENTED,
      },
    },
    PlayerModel = {
      inherits = {'Model'},
      mixin = {
        RefreshCamera = UNIMPLEMENTED,
        RefreshUnit = UNIMPLEMENTED,
        SetAnimation = UNIMPLEMENTED,
        SetCamDistanceScale = UNIMPLEMENTED,
        SetDisplayInfo = UNIMPLEMENTED,
        SetDoBlend = UNIMPLEMENTED,
        SetPortraitZoom = UNIMPLEMENTED,
        SetUnit = UNIMPLEMENTED,
      },
    },
    POIFrame = {
      inherits = {'Frame'},
      mixin = {
        SetBorderAlpha = UNIMPLEMENTED,
        SetBorderScalar = UNIMPLEMENTED,
        SetBorderTexture = UNIMPLEMENTED,
        SetFillAlpha = UNIMPLEMENTED,
        SetFillTexture = UNIMPLEMENTED,
      },
    },
    QuestPOIFrame = {
      inherits = {'POIFrame'},
    },
    Region = {
      constructor = function(self)
        local ud = u(self)
        ud.alpha = 1
        ud.bottom = 0
        ud.height = 0
        ud.isIgnoringParentAlpha = false
        ud.isIgnoringParentScale = false
        ud.left = 0
        ud.points = {}
        ud.scale = 1
        ud.shown = true
        ud.visible = not ud.parent or u(ud.parent).visible
        ud.width = 0
      end,
      inherits = {'ParentedObject'},
      mixin = {
        ClearAllPoints = function(self)
          util.twipe(u(self).points)
        end,
        GetAlpha = function(self)
          return u(self).alpha
        end,
        GetBottom = function(self)
          return u(self).bottom
        end,
        GetCenter = function()
          return 1, 1  -- UNIMPLEMENTED
        end,
        GetEffectiveAlpha = function(self)
          local ud = u(self)
          if not ud.parent or ud.isIgnoringParentAlpha then
            return ud.alpha
          else
            return m(ud.parent, 'GetEffectiveAlpha') * ud.alpha
          end
        end,
        GetEffectiveScale = function(self)
          local ud = u(self)
          if not ud.parent or ud.isIgnoringParentScale then
            return ud.scale
          else
            return m(ud.parent, 'GetEffectiveScale') * ud.scale
          end
        end,
        GetHeight = function(self)
          return u(self).height
        end,
        GetLeft = function(self)
          return u(self).left
        end,
        GetNumPoints = function(self)
          return #u(self).points
        end,
        GetPoint = function(self, index)
          local idx
          if type(index) == 'string' then
            local i = 1
            while not idx and i <= #u(self).points do
              if u(self).points[i][1] == index then
                idx = i
              end
              i = i + 1
            end
          else
            idx = index or 1
          end
          if u(self).points[idx] then
            return unpack(u(self).points[idx])
          else
            api.log(1, 'returning fake point')
            return 'CENTER', api.env.UIParent, 'CENTER', 0, 0
          end
        end,
        GetRect = function(self)
          local ud = u(self)
          return ud.bottom, ud.left, ud.width, ud.height
        end,
        GetRight = function(self)
          return u(self).left + u(self).width
        end,
        GetScale = function(self)
          return u(self).scale
        end,
        GetSize = function(self)
          return m(self, 'GetWidth'), m(self, 'GetHeight')
        end,
        GetTop = function(self)
          return u(self).bottom + u(self).height
        end,
        GetWidth = function(self)
          return u(self).width
        end,
        Hide = function(self)
          m(self, 'SetShown', false)
        end,
        IsIgnoringParentAlpha = function(self)
          return u(self).isIgnoringParentAlpha
        end,
        IsIgnoringParentScale = function(self)
          return u(self).isIgnoringParentScale
        end,
        IsMouseOver = UNIMPLEMENTED,
        IsShown = function(self)
          return u(self).shown
        end,
        IsVisible = function(self)
          return u(self).visible
        end,
        SetAllPoints = UNIMPLEMENTED,
        SetAlpha = function(self, alpha)
          u(self).alpha = alpha < 0 and 0 or alpha > 1 and 1 or alpha
        end,
        SetHeight = function(self, height)
          u(self).height = height
        end,
        SetIgnoreParentAlpha = function(self, ignore)
          u(self).isIgnoringParentAlpha = not not ignore
        end,
        SetParent = function(self, parent)
          if type(parent) == 'string' then
            parent = api.env[parent]
          end
          api.SetParent(self, parent)
          UpdateVisible(self)
        end,
        SetPoint = function(self, point, arg1, arg2, arg3, arg4)
          -- TODO handle resetting points
          local p
          if type(arg2) == 'string' then
            p = { point, type(arg1) == 'string' and api.env[arg1] or arg1, arg2, arg3, arg4 }
          else
            p = { point, u(self).parent, point, arg1, arg2 }
          end
          table.insert(u(self).points, p)
        end,
        SetScale = function(self, scale)
          if scale > 0 then
            u(self).scale = scale
          end
        end,
        SetShown = function(self, shown)
          u(self).shown = shown
          UpdateVisible(self)
        end,
        SetSize = UNIMPLEMENTED,
        SetWidth = function(self, width)
          u(self).width = width
        end,
        Show = function(self)
          m(self, 'SetShown', true)
        end,
      },
    },
    ScriptObject = {
      constructor = function(self)
        u(self).scripts = {
          [0] = {},
          [1] = {},
          [2] = {},
        }
      end,
      inherits = {},
      mixin = {
        GetScript = function(self, name, bindingType)
          return u(self).scripts[bindingType or 1][string.lower(name)]
        end,
        HookScript = function(self, name, script, bindingType)
          local btype = bindingType or 1
          local lname = string.lower(name)
          local scripts = u(self).scripts[btype]
          local old = scripts[lname]
          if not old and btype ~= 1 then
            api.log(1, 'cannot hook nonexistent intrinsic precall/postcall')
            return false
          end
          scripts[lname] = function(...)
            if old then
              old(...)
            end
            script(...)
          end
          return true
        end,
        SetScript = function(self, name, script)
          api.SetScript(self, name, 1, script)
        end,
      },
    },
    ScenarioPOIFrame = {
      inherits = {'POIFrame'},
    },
    ScrollFrame = {
      inherits = {'Frame'},
      mixin = {
        GetHorizontalScroll = STUB_NUMBER,
        GetVerticalScrollRange = STUB_NUMBER,
        GetScrollChild = function(self)
          return u(self).scrollChild
        end,
        SetHorizontalScroll = UNIMPLEMENTED,
        SetScrollChild = function(self, scrollChild)
          u(self).scrollChild = scrollChild
        end,
        SetVerticalScroll = UNIMPLEMENTED,
        UpdateScrollChildRect = UNIMPLEMENTED,
      },
    },
    SimpleHTML = {
      inherits = {'FontInstance', 'Frame'},
      mixin = {
        SetText = UNIMPLEMENTED,
      },
    },
    Slider = {
      constructor = function(self)
        local ud = u(self)
        ud.enabled = true
        ud.max = 0
        ud.min = 0
        ud.value = 0
      end,
      inherits = {'Frame'},
      mixin = {
        Disable = function(self)
          u(self).enabled = false
        end,
        Enable = function(self)
          u(self).enabled = true
        end,
        GetMinMaxValues = function(self)
          local ud = u(self)
          return ud.min, ud.max
        end,
        GetThumbTexture = function(self)
          return u(self).thumbTexture
        end,
        GetValue = function(self)
          return u(self).value
        end,
        SetMinMaxValues = function(self, min, max)
          local ud = u(self)
          ud.min = min
          ud.max = max
        end,
        SetStepsPerPage = UNIMPLEMENTED,
        SetThumbTexture = function(self, tex)
          u(self).thumbTexture = toTexture(self, tex)
        end,
        SetValue = function(self, value)
          u(self).value = value
        end,
        SetValueStep = UNIMPLEMENTED,
      },
    },
    StatusBar = {
      constructor = function(self)
        local ud = u(self)
        ud.max = 0
        ud.min = 0
        ud.value = 0
      end,
      inherits = {'Frame'},
      mixin = {
        GetMinMaxValues = function(self)
          local ud = u(self)
          return ud.min, ud.max
        end,
        GetStatusBarTexture = function(self)
          return u(self).statusBarTexture
        end,
        GetValue = function(self)
          return u(self).value
        end,
        SetMinMaxValues = function(self, min, max)
          local ud = u(self)
          ud.min = min
          ud.max = max
        end,
        SetStatusBarColor = UNIMPLEMENTED,
        SetStatusBarTexture = function(self, tex)
          if type(tex) == 'number' then
            api.log(1, 'unimplemented call to SetStatusBarTexture')
            u(self).statusBarTexture = m(self, 'CreateTexture')
          else
            u(self).statusBarTexture = toTexture(self, tex)
          end
        end,
        SetValue = function(self, value)
          u(self).value = value
        end,
      },
    },
    Texture = {
      inherits = {'LayeredRegion', 'ParentedObject'},
      mixin = {
        GetTexCoord = UNIMPLEMENTED,
        GetTexture = UNIMPLEMENTED,
        SetAtlas = UNIMPLEMENTED,
        SetBlendMode = UNIMPLEMENTED,
        SetColorTexture = UNIMPLEMENTED,
        SetDesaturated = UNIMPLEMENTED,
        SetGradient = UNIMPLEMENTED,
        SetHorizTile = UNIMPLEMENTED,
        SetSnapToPixelGrid = UNIMPLEMENTED,
        SetTexCoord = UNIMPLEMENTED,
        SetTexelSnappingBias = UNIMPLEMENTED,
        SetTexture = UNIMPLEMENTED,
        SetVertTile = UNIMPLEMENTED,
      },
    },
    UIObject = {
      inherits = {},
      mixin = {
        GetName = function(self)
          return u(self).name
        end,
        GetObjectType = function(self)
          return api.uiobjectTypes[u(self).type].name
        end,
        IsObjectType = UNIMPLEMENTED,
      },
    },
    UnitPositionFrame = {
      inherits = {'Frame'},
      mixin = {
        AddUnit = UNIMPLEMENTED,
        ClearUnits = UNIMPLEMENTED,
        FinalizeUnits = UNIMPLEMENTED,
        GetMouseOverUnits = UNIMPLEMENTED,
        SetPlayerPingScale = UNIMPLEMENTED,
        SetPlayerPingTexture = UNIMPLEMENTED,
        SetUiMapID = UNIMPLEMENTED,
        StartPlayerPing = UNIMPLEMENTED,
        StopPlayerPing = UNIMPLEMENTED,
      },
    },
    WorldFrame = {
      inherits = {'Frame'},
    },
  })
end

local function stringFormat(fmt, ...)
  local args = {...}
  for i, arg in ipairs(args) do
    fmt = fmt:gsub('%%' .. i .. '%$', arg)
  end
  return string.format(fmt, ...)
end

local function mkBaseEnv()
  return {
    abs = math.abs,
    assert = assert,
    bit = {
      band = bitlib.band,
      bor = bitlib.bor,
    },
    ceil = math.ceil,
    error = error,
    floor = math.floor,
    format = stringFormat,
    getmetatable = getmetatable,
    getn = table.getn,
    gsub = string.gsub,
    ipairs = ipairs,
    math = {
      abs = math.abs,
      ceil = math.ceil,
      floor = math.floor,
      max = math.max,
      min = math.min,
      pi = math.pi,
      sqrt = math.sqrt,
    },
    max = math.max,
    min = math.min,
    mod = math.fmod,
    newproxy = newproxy,
    next = next,
    pairs = pairs,
    pcall = pcall,
    PI = math.pi,
    print = print,
    rawget = rawget,
    rawset = rawset,
    select = select,
    setfenv = setfenv,
    setmetatable = setmetatable,
    sort = table.sort,
    string = {
      byte = string.byte,
      find = string.find,
      format = stringFormat,
      gmatch = string.gmatch,
      gsub = string.gsub,
      len = string.len,
      lower = string.lower,
      match = string.match,
      rep = string.rep,
      sub = string.sub,
      upper = string.upper,
    },
    strlower = string.lower,
    strsub = string.sub,
    strupper = string.upper,
    table = {
      concat = table.concat,
      insert = table.insert,
      sort = table.sort,
      wipe = util.twipe,
    },
    tinsert = table.insert,
    tonumber = tonumber,
    tostring = tostring,
    tremove = table.remove,
    type = type,
    unpack = unpack,
  }
end

local function mkMetaEnv(api)
  local __dump = (function()
    local block = require('serpent').block
    local config = { nocode = true }
    local function dump(x)
      print(block(x, config))
    end
    return function(...)
      for _, x in ipairs({...}) do
        dump(x)
        if api.UserData(x) then
          print('===[begin userdata]===')
          dump(api.UserData(x))
          print('===[ end userdata ]===')
        end
      end
    end
  end)()
  return {
    __index = {
      _G = api.env,
      __dump = __dump,
    },
  }
end

local function mkWowEnv(api)
  local function CreateFrame(type, name, parent, templateNames)
    local ltype = string.lower(type)
    assert(api.IsIntrinsicType(ltype), type .. ' is not intrinsic')
    assert(api.InheritsFrom(ltype, 'frame'), type .. ' does not inherit from frame')
    local templates = {}
    for templateName in string.gmatch(templateNames or '', '[^, ]+') do
      local template = api.templates[string.lower(templateName)]
      assert(template, 'unknown template ' .. templateName)
      table.insert(templates, template)
    end
    return api.CreateUIObject(ltype, name, parent, nil, unpack(templates))
  end
  return {
    AntiAliasingSupported = UNIMPLEMENTED,
    BankButtonIDToInvSlotID = STUB_NUMBER,
    BNFeaturesEnabled = UNIMPLEMENTED,
    BNFeaturesEnabledAndConnected = UNIMPLEMENTED,
    BNGetInfo = UNIMPLEMENTED,
    BNGetNumFriendInvites = function()
      return 0  -- UNIMPLEMENTED
    end,
    BNGetNumFriends = function()
      return 0, 0  -- UNIMPLEMENTED
    end,
    BreakUpLargeNumbers = tostring,  -- UNIMPLEMENTED,
    CanAutoSetGamePadCursorControl = UNIMPLEMENTED,
    CanBeRaidTarget = UNIMPLEMENTED,
    CanHearthAndResurrectFromArea = UNIMPLEMENTED,
    CanReplaceGuildMaster = UNIMPLEMENTED,
    CanSendSoRByText = UNIMPLEMENTED,
    CastingInfo = UNIMPLEMENTED,  -- TODO classic era only
    CastShapeshiftForm = UNIMPLEMENTED,
    ChangeActionBarPage = UNIMPLEMENTED,
    ChannelInfo = UNIMPLEMENTED,  -- TODO classic era only
    CollapseSkillHeader = UNIMPLEMENTED,
    CombatLogAddFilter = UNIMPLEMENTED,
    CombatLogGetCurrentEntry = UNIMPLEMENTED,
    CombatLogGetNumEntries = STUB_NUMBER,
    CombatLogResetFilter = UNIMPLEMENTED,
    CombatLogSetCurrentEntry = UNIMPLEMENTED,
    CombatLog_Object_IsA = UNIMPLEMENTED,
    CombatTextSetActiveUnit = UNIMPLEMENTED,
    Constants = setmetatable({}, {
      __index = function(_, k)
        return setmetatable({}, {
          __index = function(_, k2)
            return 'AUTOGENERATED:Enum:' .. k .. ':' .. k2
          end,
        })
      end,
    }),
    ContainerIDToInventoryID = UNIMPLEMENTED,
    CreateFont = function(name)
      return api.CreateUIObject('font', name)
    end,
    CreateForbiddenFrame = CreateFrame,
    CreateFrame = CreateFrame,
    CursorHasItem = UNIMPLEMENTED,
    C_AdventureJournal = {
      CanBeShown = UNIMPLEMENTED,
    },
    C_AdventureMap = {},
    C_AreaPoiInfo = {
      GetAreaPOIForMap = STUB_TABLE,
    },
    C_ArtifactUI = {},
    C_AuthChallenge = {
      SetFrame = UNIMPLEMENTED,
    },
    C_ChatInfo = {
      GetNumReservedChatWindows = STUB_NUMBER,
      IsValidChatLine = UNIMPLEMENTED,
    },
    C_ClassColor = {
      GetClassColor = function()  -- UNIMPLEMENTED
        return Mixin({r=0, g=0, b=0}, api.env.ColorMixin)
      end,
    },
    C_Club = {
      ClearClubPresenceSubscription = UNIMPLEMENTED,
      GetInvitationsForSelf = STUB_TABLE,
      GetSubscribedClubs = STUB_TABLE,
      IsEnabled = UNIMPLEMENTED,
    },
    C_Commentator = {
      GetMaxNumPlayersPerTeam = STUB_NUMBER,
      GetMaxNumTeams = STUB_NUMBER,
      IsSpectating = UNIMPLEMENTED,
      SetFollowCameraSpeeds = UNIMPLEMENTED,
      SetMouseDisabled = UNIMPLEMENTED,
    },
    C_Console = {
      SetFontHeight = UNIMPLEMENTED,
    },
    C_CurrencyInfo = {
      GetCurrencyInfo = STUB_TABLE,
    },
    C_CVar = (function()
      local cvarDefaults = {
        cameraSmoothStyle = '0',
        cameraSmoothTrackingStyle = '0',
        NamePlateHorizontalScale = '1',
        nameplateMotion = '0',
        NamePlateVerticalScale = '1',
        timeMgrAlarmTime = '0',
      }
      local cvars = {}
      local function GetCVar(var)
        return cvars[var] or cvarDefaults[var]
      end
      return {
        GetCVar = GetCVar,
        GetCVarBool = function(var)
          return GetCVar(var) == "1"
        end,
        GetCVarDefault = function(var)
          return cvarDefaults[var]
        end,
        RegisterCVar = function(var, value)
          cvars[var] = value
        end,
        SetCVar = function(var, value)
          cvars[var] = value
        end,
      }
    end)(),
    C_DateAndTime = {
      GetCurrentCalendarTime = function()
        return {
          hour = 3,
          minute = 26,
          month = 7,
          monthDay = 15,
          weekday = 5,
          year = 2021,
        }
      end,
    },
    C_DeathInfo = {
      GetCorpseMapPosition = UNIMPLEMENTED,
      GetSelfResurrectOptions = UNIMPLEMENTED,
    },
    C_FrameManager = {
      GetFrameVisibilityState = UNIMPLEMENTED,
    },
    C_FriendList = {
      GetFriendInfoByIndex = STUB_TABLE,
      GetNumFriends = STUB_NUMBER,
      GetNumOnlineFriends = STUB_NUMBER,
      SetSelectedFriend = UNIMPLEMENTED,
      SetWhoToUi = UNIMPLEMENTED,
      ShowFriends = UNIMPLEMENTED,
    },
    C_GamePad = {},
    C_Garrison = {
      GetAllEncounterThreats = STUB_TABLE,
      IsUsingPartyGarrison = UNIMPLEMENTED,
    },
    C_GossipInfo = {
      GetGossipPoiForUiMapID = UNIMPLEMENTED,
      GetPoiForUiMapID = UNIMPLEMENTED,
    },
    C_GuildInfo = {
      GuildControlGetRankFlags = STUB_TABLE,
      GuildRoster = UNIMPLEMENTED,
    },
    C_Item = {},
    C_LFGInfo = {
      CanPlayerUseGroupFinder = UNIMPLEMENTED,
      CanPlayerUseLFD = UNIMPLEMENTED,
      CanPlayerUseLFR = UNIMPLEMENTED,
      CanPlayerUsePremadeGroup = UNIMPLEMENTED,
    },
    C_LFGList = {
      GetApplications = STUB_TABLE,
      GetAvailableCategories = STUB_TABLE,
      GetAvailableLanguageSearchFilter = STUB_TABLE,
      GetAvailableRoles = UNIMPLEMENTED,
      GetDefaultLanguageSearchFilter = STUB_NUMBER,
      GetLanguageSearchFilter = STUB_NUMBER,
      GetNumApplications = function()
        return 0, 0  -- UNIMPLEMENTED
      end,
      HasActiveEntryInfo = UNIMPLEMENTED,
    },
    C_LootHistory = {
      GetItem = UNIMPLEMENTED,
      GetNumItems = STUB_NUMBER,
      GetPlayerInfo = function()
        return 'moo', 'WARRIOR'  -- UNIMPLEMENTED
      end,
    },
    C_Map = {
      GetBestMapForUnit = UNIMPLEMENTED,
      GetFallbackWorldMapID = function()
        return 0
      end,
      GetMapArtBackgroundAtlas = UNIMPLEMENTED,
      GetMapArtID = STUB_NUMBER,
      GetMapArtLayers = function()
        local layer = {
          additionalZoomSteps = 0,
          layerHeight = 1,
          layerWidth = 1,
          maxScale = 1,
          minScale = 1,
          tileHeight = 1,
          tileWidth = 1,
        }
        return { layer }
      end,
      GetMapArtLayerTextures = STUB_TABLE,
      GetMapChildrenInfo = STUB_TABLE,
      GetMapDisplayInfo = UNIMPLEMENTED,
      GetMapHighlightInfoAtPosition = UNIMPLEMENTED,
      GetMapInfo = function(uiMapID)
        return {
          flags = 0,
          mapID = uiMapID,
          mapType = api.env.Enum.UIMapType.World,
          name = 'TheMap',
          parentMapID = 0,
        }
      end,
    },
    C_MapExplorationInfo = {
      GetExploredMapTextures = STUB_TABLE,
    },
    C_ModelInfo = {
      GetModelSceneInfoByID = UNIMPLEMENTED,
    },
    C_NamePlate = {
      GetNamePlateForUnit = UNIMPLEMENTED,
      GetNamePlates = STUB_TABLE,
      GetNumNamePlateMotionTypes = STUB_NUMBER,
      SetNamePlateEnemySize = UNIMPLEMENTED,
      SetNamePlateFriendlySize = UNIMPLEMENTED,
      SetNamePlateSelfClickThrough = UNIMPLEMENTED,
      SetNamePlateSelfSize = UNIMPLEMENTED,
      SetTargetClampingInsets = UNIMPLEMENTED,
    },
    C_NewItems = {
      RemoveNewItem = UNIMPLEMENTED,
    },
    C_PaperDollInfo = {
      OffhandHasWeapon = UNIMPLEMENTED,
    },
    C_PartyInfo = {
      AllowedToDoPartyConversion = UNIMPLEMENTED,
    },
    C_PetBattles = {
      CanPetSwapIn = UNIMPLEMENTED,
      GetAllEffectNames = UNIMPLEMENTED,
      GetAllStates = UNIMPLEMENTED,
      GetBattleState = UNIMPLEMENTED,
      GetDisplayID = STUB_NUMBER,
      GetHealth = STUB_NUMBER,
      GetIcon = STUB_NUMBER,
      GetLevel = STUB_NUMBER,
      GetMaxHealth = STUB_NUMBER,
      GetName = function()
        return 'PetName'
      end,
      GetNumPets = STUB_NUMBER,
      GetPVPMatchmakingInfo = UNIMPLEMENTED,
      GetSelectedAction = UNIMPLEMENTED,
      IsSkipAvailable = UNIMPLEMENTED,
      IsTrapAvailable = UNIMPLEMENTED,
      ShouldShowPetSelect = UNIMPLEMENTED,
    },
    C_PlayerInfo = {
      UnitIsSameServer = UNIMPLEMENTED,
    },
    C_PlayerMentorship = {},
    C_ProductChoice = {
      GetChoices = STUB_TABLE,
      GetNumSuppressed = STUB_NUMBER,
    },
    C_PvP = {
      GetArenaCrowdControlInfo = UNIMPLEMENTED,
      IsInBrawl = UNIMPLEMENTED,
    },
    C_QuestLog = {
      GetMaxNumQuests = STUB_NUMBER,
    },
    C_QuestSession = {
      GetSessionBeginDetails = UNIMPLEMENTED,
    },
    C_RecruitAFriend = {
      GetRAFInfo = UNIMPLEMENTED,
      GetRAFSystemInfo = UNIMPLEMENTED,
      IsEnabled = UNIMPLEMENTED,
      IsRecruitingEnabled = UNIMPLEMENTED,
      IsSendingEnabled = UNIMPLEMENTED,
    },
    C_Scenario = {
      ShouldShowCriteria = UNIMPLEMENTED,
    },
    C_ScriptedAnimations = {
      GetAllScriptedAnimationEffects = STUB_TABLE,
    },
    C_Social = {
      RegisterSocialBrowser = UNIMPLEMENTED,
      TwitterCheckStatus = UNIMPLEMENTED,
    },
    C_SocialQueue = {
      GetAllGroups = STUB_TABLE,
      GetConfig = UNIMPLEMENTED,
    },
    C_SocialRestrictions = {
      IsSilenced = UNIMPLEMENTED,
      IsSquelched = UNIMPLEMENTED,
    },
    C_SpecializationInfo = {
      CanPlayerUseTalentSpecUI = UNIMPLEMENTED,
    },
    C_Spell = {},
    C_StorePublic = {
      IsDisabledByParentalControls = UNIMPLEMENTED,
      IsEnabled = UNIMPLEMENTED,
    },
    C_StoreSecure = {
      GetCurrencyID = UNIMPLEMENTED,
      GetFailureInfo = UNIMPLEMENTED,
      GetPurchaseList = UNIMPLEMENTED,
      HasPurchaseInProgress = UNIMPLEMENTED,
      IsAvailable = UNIMPLEMENTED,
    },
    C_SummonInfo = {
      CancelSummon = UNIMPLEMENTED,
      ConfirmSummon = UNIMPLEMENTED,
      GetSummonConfirmTimeLeft = STUB_NUMBER,
      GetSummonReason = UNIMPLEMENTED,
      IsSummonSkippingStartExperience = UNIMPLEMENTED,
    },
    C_Texture = {
      GetAtlasInfo = UNIMPLEMENTED,
    },
    C_Timer = {
      After = UNIMPLEMENTED,
    },
    C_UIWidgetManager = {
      GetAllWidgetsBySetID = STUB_TABLE,
      GetBelowMinimapWidgetSetID = function()
        return 2
      end,
      GetObjectiveTrackerWidgetSetID = STUB_NUMBER,
      GetPowerBarWidgetSetID = STUB_NUMBER,
      GetTopCenterWidgetSetID = function()
        return 1
      end,
      GetWidgetSetInfo = function()
        return {
          layoutDirection = 0,
          verticalPadding = 0,
        }
      end,
    },
    C_VoiceChat = {
      CanPlayerUseVoiceChat = UNIMPLEMENTED,
      GetActiveChannelID = UNIMPLEMENTED,
      GetActiveChannelType = UNIMPLEMENTED,
      GetAvailableInputDevices = UNIMPLEMENTED,
      GetAvailableOutputDevices = UNIMPLEMENTED,
      GetCommunicationMode = UNIMPLEMENTED,
      GetInputVolume = UNIMPLEMENTED,
      GetMasterVolumeScale = UNIMPLEMENTED,
      GetOutputVolume = UNIMPLEMENTED,
      GetVADSensitivity = UNIMPLEMENTED,
      IsLoggedIn = UNIMPLEMENTED,
      IsMuted = UNIMPLEMENTED,
      IsSpeakForMeActive = UNIMPLEMENTED,
      IsTranscriptionAllowed = UNIMPLEMENTED,
    },
    C_Widget = {},
    C_WowTokenPublic = {
      GetCommerceSystemStatus = UNIMPLEMENTED,
    },
    C_WowTokenSecure = {
      CancelRedeem = UNIMPLEMENTED,
    },
    C_ZoneAbility = {
      GetActiveAbilities = STUB_TABLE,
    },
    DropCursorMoney = UNIMPLEMENTED,
    Enum = setmetatable({
      ItemQualityMeta = {
        NumValues = 1,
      },
      StoreError = {
        InvalidPaymentMethod = 1,
        PaymentFailed = 2,
        WrongCurrency = 3,
        BattlepayDisabled = 4,
        InsufficientBalance = 5,
        Other = 6,
        AlreadyOwned = 7,
        ParentalControlsNoPurchase = 8,
        PurchaseDenied = 9,
        ConsumableTokenOwned = 10,
        TooManyTokens = 11,
        ItemUnavailable = 12,
        ClientRestricted = 13,
      },
      TransmogCollectionTypeMeta = {
        NumValues = 1,
      },
      UIMapType = {
        Continent = 0,
        Cosmic = 0,
        World = 0,
      },
      VasError = {
        AllianceNotEligible = 1,
        BattlepayDeliveryPending = 2,
        BoostedTooRecently = 3,
        CannotMoveGuildMaster = 4,
        CharacterTransferTooSoon = 5,
        CharLocked = 6,
        CustomizeAlreadyRequested = 7,
        DisallowedDestinationAccount = 8,
        DisallowedSourceAccount = 9,
        DuplicateCharacterName = 10,
        FactionChangeTooSoon = 11,
        HasAuctions = 12,
        HasCagedBattlePet = 13,
        HasHeirloom = 14,
        HasMail = 15,
        HasWoWToken = 16,
        IneligibleMapID = 17,
        IneligibleTargetRealm = 18,
        InvalidDestinationAccount = 19,
        InvalidSourceAccount = 20,
        LastCustomizeTooRecent = 21,
        LastRenameTooRecent = 22,
        LastSaveTooDistant = 23,
        LastSaveTooRecent = 24,
        LowerBoxLevel = 25,
        MaxCharactersOnServer = 26,
        NameNotAvailable = 27,
        NeedsEraChoice = 28,
        NoMixedAlliance = 29,
        PendingItemAudit = 30,
        PvEToPvPTransferNotAllowed = 31,
        PveToPvpTransferNotAllowed = 31,  -- case insensitive?
        RaceClassComboIneligible = 32,
        RealmNotEligible = 33,
        TooMuchMoneyForLevel = 34,
        UnderMinLevelReq = 35,
        CharacterHasVasPending = 36,
        OperationAlreadyInProgress = 37,
        LockedForVas = 38,
        MoveInProgress = 39,
        AlreadyRenameFlagged = 40,
        GuildRankInsufficient = 41,
        CharacterWithoutGuild = 42,
        GmSeniorityInsufficient = 43,
        AuthenticatorInsufficient = 44,
        NewLeaderInvalid = 45,
        NeedsLevelSquish = 46,
      },
      VasServiceType = {
        FactionChange = 1,
        RaceChange = 2,
        AppearanceChange = 3,
        NameChange = 4,
        CharacterTransfer = 5,
        GuildNameChange = 6,
        GuildFactionChange = 7,
      },
    }, {
      __index = function(t, k)
        local next = 1
        local v = setmetatable({}, {
          __index = function(t2, k2)
            t2[k2] = next
            next = next + 1
            return t2[k2]
          end,
        })
        t[k] = v
        return v
      end,
    }),
    FillLocalizedClassList = UNIMPLEMENTED,
    FlashClientIcon = UNIMPLEMENTED,
    GetActionBarPage = STUB_NUMBER,
    GetActionBarToggles = UNIMPLEMENTED,
    GetActionCount = STUB_NUMBER,
    GetActionInfo = UNIMPLEMENTED,
    GetActionTexture = UNIMPLEMENTED,
    GetActiveLootRollIDs = STUB_TABLE,
    GetAddOnEnableState = UNIMPLEMENTED,
    GetAlternativeDefaultLanguage = UNIMPLEMENTED,
    GetArchaeologyInfo = UNIMPLEMENTED,
    GetArchaeologyRaceInfo = function()
      return 'Name', nil, nil, 0, 0  -- UNIMPLEMENTED
    end,
    GetArenaOpponentSpec = function()
      return 0, 0  -- UNIMPLEMENTED
    end,
    GetArenaTeam = UNIMPLEMENTED,
    GetAuctionDeposit = STUB_NUMBER,
    GetAuctionItemSubClasses = UNIMPLEMENTED,
    GetAvailableLocales = UNIMPLEMENTED,
    GetBagSlotFlag = UNIMPLEMENTED,
    GetBankBagSlotFlag = UNIMPLEMENTED,
    GetBattlefieldFlagPosition = UNIMPLEMENTED,
    GetBattlefieldStatus = UNIMPLEMENTED,
    GetBidderAuctionItems = UNIMPLEMENTED,
    GetBinding = UNIMPLEMENTED,
    GetBindingKey = UNIMPLEMENTED,
    GetBindingText = UNIMPLEMENTED,
    GetCategoryList = STUB_TABLE,
    GetChatTypeIndex = STUB_NUMBER,
    GetChatWindowChannels = UNIMPLEMENTED,
    GetChatWindowInfo = function(idx)
      return '', 10, 1, 1, 1, 1, 1, 1, idx  -- UNIMPLEMENTED
    end,
    GetChatWindowMessages = UNIMPLEMENTED,
    GetChatWindowSavedDimensions = UNIMPLEMENTED,
    GetChatWindowSavedPosition = UNIMPLEMENTED,
    GetClassicExpansionLevel = STUB_NUMBER,
    GetComboPoints = STUB_NUMBER,
    GetContainerItemInfo = UNIMPLEMENTED,
    GetContainerNumFreeSlots = STUB_NUMBER,
    GetContainerNumSlots = STUB_NUMBER,
    GetCurrentRegionName = function()
      return 'RegionName'  -- UNIMPLEMENTED
    end,
    GetCurrentScaledResolution = function()
      return 1024, 768  -- UNIMPLEMENTED
    end,
    GetCurrentTitle = UNIMPLEMENTED,
    GetCursorInfo = UNIMPLEMENTED,
    GetCursorMoney = STUB_NUMBER,
    GetCursorPosition = function()
      return 0, 0  -- UNIMPLEMENTED
    end,
    GetCVar = function(name)
      return api.env.C_CVar.GetCVar(name)
    end,
    GetCVarBool = function(name)
      return api.env.C_CVar.GetCVarBool(name)
    end,
    GetCVarDefault = function(name)
      return api.env.C_CVar.GetCVarDefault(name)
    end,
    GetCVarInfo = UNIMPLEMENTED,
    GetCVarSettingValidity = UNIMPLEMENTED,
    GetDailyQuestsCompleted = STUB_NUMBER,
    GetDefaultLanguage = function()
      return 'Common', 7  -- UNIMPLEMENTED
    end,
    GetDefaultScale = STUB_NUMBER,
    GetDefaultVideoOptions = UNIMPLEMENTED,
    GetExpansionLevel = UNIMPLEMENTED,
    GetExtraBarIndex = STUB_NUMBER,
    getfenv = function(arg)
      if arg == 0 then
        return api.env
      else
        return getfenv(arg)
      end
    end,
    GetFileStreamingStatus = UNIMPLEMENTED,
    GetGameTime = function()
      return 1, 1  -- UNIMPLEMENTED
    end,
    GetGMStatus = UNIMPLEMENTED,
    GetGMTicket = UNIMPLEMENTED,
    GetGroupMemberCounts = function()
      return {
        DAMAGER = 3,
        HEALER = 1,
        NOROLE = 0,
        TANK = 1,
      }
    end,
    GetGuildLogoInfo = UNIMPLEMENTED,
    GetGuildRosterShowOffline = UNIMPLEMENTED,
    GetInstanceInfo = UNIMPLEMENTED,
    GetInventoryAlertStatus = UNIMPLEMENTED,
    GetInventoryItemID = UNIMPLEMENTED,
    GetInventoryItemLink = UNIMPLEMENTED,
    GetInventoryItemQuality = UNIMPLEMENTED,
    GetInventoryItemTexture = UNIMPLEMENTED,
    GetInventorySlotInfo = (function()
      local t = {
        ammoslot = 0,
        headslot = 1,
        neckslot = 2,
        shoulderslot = 3,
        shirtslot = 4,
        chestslot = 5,
        waistslot = 6,
        legsslot = 7,
        feetslot = 8,
        wristslot = 9,
        handsslot = 10,
        finger0slot = 11,
        finger1slot = 12,
        trinket0slot = 13,
        trinket1slot = 14,
        backslot = 15,
        mainhandslot = 16,
        secondaryhandslot = 17,
        rangedslot = 18,
        tabardslot = 19,
        bag0slot = 20,
        bag1slot = 21,
        bag2slot = 22,
        bag3slot = 23,
      }
      return function(slotName)
        return assert(t[string.lower(slotName)], 'unknown slot name ' .. slotName)
      end
    end)(),
    GetItemClassInfo = function(classID)
      return string.format('ItemClass%d', classID)
    end,
    GetItemInfo = UNIMPLEMENTED,
    GetItemInventorySlotInfo = function(inventorySlot)
      return string.format('ItemInventorySlot%d', inventorySlot)
    end,
    GetItemQualityColor = function()
      return 0, 0, 0  -- UNIMPLEMENTED
    end,
    GetItemSubClassInfo = function(classID, subClassID)
      return string.format('ItemClass%dSubClass%d', classID, subClassID)
    end,
    GetLanguageByIndex = UNIMPLEMENTED,
    GetLFGCategoryForID = UNIMPLEMENTED,
    GetLFGDeserterExpiration = STUB_NUMBER,
    GetLFGRoleUpdate = UNIMPLEMENTED,
    GetLootMethod = function()
      return 'freeforall'  -- UNIMPLEMENTED
    end,
    GetLootThreshold = STUB_NUMBER,
    GetMaxBattlefieldID = STUB_NUMBER,
    GetMaxDailyQuests = STUB_NUMBER,
    GetMaxLevelForPlayerExpansion = STUB_NUMBER,
    GetMaxPlayerLevel = STUB_NUMBER,
    GetMaxRenderScale = UNIMPLEMENTED,
    GetMerchantFilter = UNIMPLEMENTED,
    GetMinimapZoneText = UNIMPLEMENTED,
    GetMinRenderScale = UNIMPLEMENTED,
    GetMirrorTimerInfo = function()
      return 'UNKNOWN'  -- UNIMPLEMENTED
    end,
    GetModifiedClick = UNIMPLEMENTED,
    GetMoney = STUB_NUMBER,
    GetMouseFocus = UNIMPLEMENTED,
    GetMultiCastBarIndex = STUB_NUMBER,
    GetNetStats = function()
      return 1, 1, 1, 1  -- UNIMPLEMENTED
    end,
    GetNumAddOns = function()
      return 0  -- UNIMPLEMENTED
    end,
    GetNumArchaeologyRaces = STUB_NUMBER,
    GetNumArenaOpponents = STUB_NUMBER,
    GetNumArenaOpponentSpecs = STUB_NUMBER,
    GetNumArtifactsByRace = STUB_NUMBER,
    GetNumBattlefieldFlagPositions = STUB_NUMBER,
    GetNumBindings = STUB_NUMBER,
    GetNumCompletedAchievements = function()
      return 1, 1  -- UNIMPLEMENTED
    end,
    GetNumLanguages = STUB_NUMBER,
    GetNumMacros = STUB_NUMBER,
    GetNumQuestLeaderBoards = function()
      return 0  -- UNIMPLEMENTED
    end,
    GetNumQuestLogChoices = STUB_NUMBER,
    GetNumQuestLogEntries = function()
      return 1, 1  -- UNIMPLEMENTED
    end,
    GetNumQuestLogRewards = STUB_NUMBER,
    GetNumQuestLogRewardSpells = STUB_NUMBER,
    GetNumQuestWatches = function()
      return 0  -- UNIMPLEMENTED
    end,
    GetNumSavedInstances = STUB_NUMBER,
    GetNumShapeshiftForms = STUB_NUMBER,
    GetNumSkillLines = STUB_NUMBER,
    GetNumSpecializations = STUB_NUMBER,
    GetNumSpellTabs = STUB_NUMBER,
    GetNumSubgroupMembers = STUB_NUMBER,
    GetNumTitles = STUB_NUMBER,
    GetNumTrackingTypes = STUB_NUMBER,
    GetOptOutOfLoot = UNIMPLEMENTED,
    GetOwnerAuctionItems = UNIMPLEMENTED,
    GetPartyLFGID = STUB_NUMBER,
    GetPetActionCooldown = UNIMPLEMENTED,
    GetPetActionInfo = UNIMPLEMENTED,
    GetPetExperience = STUB_NUMBER,
    GetPhysicalScreenSize = function()
      return 1024, 768
    end,
    GetPlayerTradeMoney = STUB_NUMBER,
    GetPVPLastWeekStats = UNIMPLEMENTED,
    GetPVPLifetimeStats = UNIMPLEMENTED,
    GetPVPRankInfo = function()
      return 'Pariah', 0  -- UNIMPLEMENTED
    end,
    GetPVPRankProgress = UNIMPLEMENTED,
    GetPVPThisWeekStats = UNIMPLEMENTED,
    GetPVPSessionStats = UNIMPLEMENTED,
    GetPVPYesterdayStats = UNIMPLEMENTED,
    GetQuestBackgroundMaterial = UNIMPLEMENTED,
    GetQuestLogChoiceInfo = function()
      return 'moo', 1, 1, 1, false  -- UNIMPLEMENTED
    end,
    GetQuestLogGroupNum = STUB_NUMBER,
    GetQuestLogPushable = UNIMPLEMENTED,
    GetQuestLogQuestText = UNIMPLEMENTED,
    GetQuestLogRequiredMoney = STUB_NUMBER,
    GetQuestLogRewardHonor = STUB_NUMBER,
    GetQuestLogRewardInfo = function()
      return 'moo', 1, 1, 1, false, 1, 1  -- UNIMPLEMENTED
    end,
    GetQuestLogRewardMoney = STUB_NUMBER,
    GetQuestLogRewardSpell = UNIMPLEMENTED,
    GetQuestLogRewardTitle = UNIMPLEMENTED,
    GetQuestLogSelection = STUB_NUMBER,
    GetQuestLogTimeLeft = STUB_NUMBER,
    GetQuestLogTitle = function()
      return 'moo', 1  -- UNIMPLEMENTED
    end,
    GetQuestTimers = UNIMPLEMENTED,
    GetRaidTargetIndex = UNIMPLEMENTED,
    GetRealmID = STUB_NUMBER,
    GetRealmName = function()
      return 'Realm'  -- UNIMPLEMENTED
    end,
    GetRealZoneText = function()
      return 'RealZoneText'  -- UNIMPLEMENTED
    end,
    GetReleaseTimeRemaining = function()
      return 0  -- UNIMPLEMENTED
    end,
    GetRepairAllCost = STUB_NUMBER,
    GetRestrictedAccountData = function()
      local rLevel = 20
      local rMoney = 10000000
      local profCap = 0
      return rLevel, rMoney, profCap
    end,
    GetRestState = function()
      return 2, 'Normal', 1  -- UNIMPLEMENTED
    end,
    GetScreenHeight = STUB_NUMBER,
    GetScreenWidth = STUB_NUMBER,
    GetSelectedSkill = STUB_NUMBER,
    GetSendMailPrice = STUB_NUMBER,
    GetShapeshiftFormCooldown = UNIMPLEMENTED,
    GetShapeshiftFormInfo = UNIMPLEMENTED,
    GetSkillLineInfo = function()
      return nil, nil, nil, 0, 0, 0, 1  -- UNIMPLEMENTED
    end,
    GetSpecialization = STUB_NUMBER,
    GetSpecializationInfo = UNIMPLEMENTED,
    GetSpellConfirmationPromptsInfo = STUB_TABLE,
    GetSpellTabInfo = function()
      return 'moo', 0, 0, 0  -- UNIMPLEMENTED
    end,
    GetSpellTexture = UNIMPLEMENTED,
    GetSubZoneText = UNIMPLEMENTED,
    GetSummonFriendCooldown = function()
      return 0, 0  -- UNIMPLEMENTED
    end,
    GetTabardCreationCost = STUB_NUMBER,
    GetText = function(token)
      return 'GetText(' .. token .. ')'  -- UNIMPLEMENTED
    end,
    GetTime = STUB_NUMBER,
    GetTitleName = UNIMPLEMENTED,
    GetTotemInfo = UNIMPLEMENTED,
    GetTrackedAchievements = UNIMPLEMENTED,
    GetTrackingInfo = UNIMPLEMENTED,
    GetTradeSkillInvSlotFilter = UNIMPLEMENTED,
    GetTradeSkillInvSlots = UNIMPLEMENTED,
    GetTradeSkillSubClasses = UNIMPLEMENTED,
    GetTradeSkillSubClassFilter = UNIMPLEMENTED,
    GetTrainerServiceTypeFilter = UNIMPLEMENTED,
    GetUnitPowerBarInfo = UNIMPLEMENTED,
    GetWeaponEnchantInfo = UNIMPLEMENTED,
    GetWebTicket = UNIMPLEMENTED,
    GetWorldPVPQueueStatus = UNIMPLEMENTED,
    GetXPExhaustion = UNIMPLEMENTED,
    GetZonePVPInfo = UNIMPLEMENTED,
    GetZoneText = UNIMPLEMENTED,
    GMEuropaBugsEnabled = UNIMPLEMENTED,
    GMEuropaComplaintsEnabled = UNIMPLEMENTED,
    GMEuropaSuggestionsEnabled = UNIMPLEMENTED,
    GMEuropaTicketsEnabled = UNIMPLEMENTED,
    GuildControlGetNumRanks = STUB_NUMBER,
    GuildControlGetRankName = UNIMPLEMENTED,
    GuildRoster = function()
      return api.env.C_GuildInfo.GuildRoster()
    end,
    HasAction = UNIMPLEMENTED,
    HasBonusActionBar = UNIMPLEMENTED,
    HasCompletedAnyAchievement = UNIMPLEMENTED,
    HasKey = UNIMPLEMENTED,
    HasPetSpells = UNIMPLEMENTED,
    HasPetUI = UNIMPLEMENTED,
    HasTempShapeshiftActionBar = UNIMPLEMENTED,
    HonorSystemEnabled = UNIMPLEMENTED,
    hooksecurefunc = function(arg1, arg2, arg3)
      local tbl, name, fn
      if arg3 ~= nil then
        tbl, name, fn = arg1, arg2, arg3
      else
        tbl, name, fn = api.env, arg1, arg2
      end
      local oldfn = tbl[name]
      tbl[name] = function(...) oldfn(...) fn(...) end
    end,
    InActiveBattlefield = UNIMPLEMENTED,
    InCinematic = UNIMPLEMENTED,
    InCombatLockdown = UNIMPLEMENTED,
    IsAccountSecured = UNIMPLEMENTED,
    IsActiveBattlefieldArena = UNIMPLEMENTED,
    IsAddOnLoaded = UNIMPLEMENTED,
    IsAddonVersionCheckEnabled = UNIMPLEMENTED,
    IsAltKeyDown = UNIMPLEMENTED,
    IsBattlefieldArena = UNIMPLEMENTED,
    IsConsumableAction = UNIMPLEMENTED,
    IsControlKeyDown = UNIMPLEMENTED,
    IsCurrentQuestFailed = UNIMPLEMENTED,
    IsEquippedAction = UNIMPLEMENTED,
    IsEveryoneAssistant = UNIMPLEMENTED,
    IsGMClient = UNIMPLEMENTED,
    IsInGroup = UNIMPLEMENTED,
    IsInGuild = UNIMPLEMENTED,
    IsInInstance = UNIMPLEMENTED,
    IsInJailersTower = UNIMPLEMENTED,
    IsInRaid = UNIMPLEMENTED,
    IsInventoryItemLocked = UNIMPLEMENTED,
    IsInventoryItemProfessionBag = UNIMPLEMENTED,
    IsItemAction = UNIMPLEMENTED,
    IsMacClient = UNIMPLEMENTED,
    IsModifiedClick = UNIMPLEMENTED,
    IsOnGlueScreen = UNIMPLEMENTED,
    IsPlayerInWorld = UNIMPLEMENTED,
    IsPublicBuild = UNIMPLEMENTED,
    IsQuestWatched = UNIMPLEMENTED,
    IsRaidMarkerActive = UNIMPLEMENTED,
    InRepairMode = UNIMPLEMENTED,
    IsResting = UNIMPLEMENTED,
    IsRestrictedAccount = UNIMPLEMENTED,
    issecure = function()
      -- use tainted-lua if available
      return issecure and issecure() or true
    end,
    IsShiftKeyDown = UNIMPLEMENTED,
    IsStackableAction = UNIMPLEMENTED,
    IsTestBuild = UNIMPLEMENTED,
    IsThreatWarningEnabled = UNIMPLEMENTED,
    IsTitleKnown = UNIMPLEMENTED,
    IsTrialAccount = UNIMPLEMENTED,
    IsTutorialFlagged = UNIMPLEMENTED,
    IsUnitOnQuest = UNIMPLEMENTED,
    IsVeteranTrialAccount = UNIMPLEMENTED,
    IsWindowsClient = UNIMPLEMENTED,
    LE_BAG_FILTER_FLAG_CONSUMABLES = 1,
    LE_BAG_FILTER_FLAG_EQUIPMENT = 2,
    LE_BAG_FILTER_FLAG_IGNORE_CLEANUP = 3,
    LE_BAG_FILTER_FLAG_JUNK = 4,
    LE_BAG_FILTER_FLAG_TRADE_GOODS = 5,
    LE_GAME_ERR_ABILITY_COOLDOWN = 1,
    LE_GAME_ERR_OUT_OF_ARCANE_CHARGES = 5,
    LE_GAME_ERR_OUT_OF_CHI = 6,
    LE_GAME_ERR_OUT_OF_COMBO_POINTS = 7,
    LE_GAME_ERR_OUT_OF_ENERGY = 8,
    LE_GAME_ERR_OUT_OF_FOCUS = 9,
    LE_GAME_ERR_OUT_OF_FURY = 10,
    LE_GAME_ERR_OUT_OF_HEALTH = 11,
    LE_GAME_ERR_OUT_OF_HOLY_POWER = 12,
    LE_GAME_ERR_OUT_OF_INSANITY = 13,
    LE_GAME_ERR_OUT_OF_LUNAR_POWER = 14,
    LE_GAME_ERR_OUT_OF_MAELSTROM = 15,
    LE_GAME_ERR_OUT_OF_MANA = 16,
    LE_GAME_ERR_OUT_OF_PAIN = 17,
    LE_GAME_ERR_OUT_OF_POWER_DISPLAY = 18,
    LE_GAME_ERR_OUT_OF_RAGE = 19,
    LE_GAME_ERR_OUT_OF_RANGE = 20,
    LE_GAME_ERR_OUT_OF_RUNES = 21,
    LE_GAME_ERR_OUT_OF_RUNIC_POWER = 22,
    LE_GAME_ERR_OUT_OF_SOUL_SHARDS = 23,
    LE_GAME_ERR_SPELL_COOLDOWN = 24,
    LE_GAME_ERR_SPELL_FAILED_ANOTHER_IN_PROGRESS = 25,
    LE_EXPANSION_BURNING_CRUSADE = 2,  -- UNIMPLEMENTED
    LE_INVENTORY_TYPE_BODY_TYPE = 1,
    LE_INVENTORY_TYPE_CHEST_TYPE = 2,
    LE_INVENTORY_TYPE_CLOAK_TYPE = 3,
    LE_INVENTORY_TYPE_FEET_TYPE = 4,
    LE_INVENTORY_TYPE_FINGER_TYPE = 5,
    LE_INVENTORY_TYPE_HAND_TYPE = 6,
    LE_INVENTORY_TYPE_HEAD_TYPE = 7,
    LE_INVENTORY_TYPE_HOLDABLE_TYPE = 8,
    LE_INVENTORY_TYPE_LEGS_TYPE = 9,
    LE_INVENTORY_TYPE_NECK_TYPE = 10,
    LE_INVENTORY_TYPE_ROBE_TYPE = 11,
    LE_INVENTORY_TYPE_SHOULDER_TYPE = 12,
    LE_INVENTORY_TYPE_TRINKET_TYPE = 13,
    LE_INVENTORY_TYPE_WAIST_TYPE = 14,
    LE_INVENTORY_TYPE_WRIST_TYPE = 15,
    LE_ITEM_CLASS_ARMOR = 2,
    LE_ITEM_CLASS_MISCELLANEOUS = 3,
    LE_ITEM_CLASS_WEAPON = 1,
    LE_ITEM_MISCELLANEOUS_COMPANION_PET = 1,
    LE_ITEM_MISCELLANEOUS_HOLIDAY = 2,
    LE_ITEM_MISCELLANEOUS_JUNK = 3,
    LE_ITEM_MISCELLANEOUS_MOUNT = 4,
    LE_ITEM_MISCELLANEOUS_OTHER = 5,
    LE_ITEM_MISCELLANEOUS_REAGENT = 6,
    LE_ITEM_WEAPON_AXE1H = 1,
    LE_ITEM_WEAPON_AXE2H = 2,
    LE_ITEM_WEAPON_BOWS = 3,
    LE_ITEM_WEAPON_CROSSBOW = 4,
    LE_ITEM_WEAPON_DAGGER = 5,
    LE_ITEM_WEAPON_FISHINGPOLE = 6,
    LE_ITEM_WEAPON_GENERIC = 7,
    LE_ITEM_WEAPON_GUNS = 8,
    LE_ITEM_WEAPON_MACE1H = 9,
    LE_ITEM_WEAPON_MACE2H = 10,
    LE_ITEM_WEAPON_POLEARM = 11,
    LE_ITEM_WEAPON_STAFF = 12,
    LE_ITEM_WEAPON_SWORD1H = 13,
    LE_ITEM_WEAPON_SWORD2H = 14,
    LE_ITEM_WEAPON_THROWN = 15,
    LE_ITEM_WEAPON_UNARMED = 16,
    LE_ITEM_WEAPON_WAND = 17,
    LE_LOOT_FILTER_SPEC1 = 0,
    LE_PARTY_CATEGORY_HOME = 1,
    LE_PARTY_CATEGORY_INSTANCE = 2,
    LE_TRANSMOG_COLLECTION_TYPE_FEET = 1,  -- UNIMPLEMENTED
    LoadAddOn = function(name)
      api.log(1, 'failing to load addon ' .. name)
      return false, 'LOAD_FAILED'  -- UNIMPLEMENTED
    end,
    Kiosk = {
      IsEnabled = UNIMPLEMENTED,
    },
    MoveBackwardStop = UNIMPLEMENTED,
    MoveForwardStop = UNIMPLEMENTED,
    MultiSampleAntiAliasingSupported = UNIMPLEMENTED,
    NUM_LE_BAG_FILTER_FLAGS = 5,
    NUM_LE_ITEM_QUALITYS = 10,  -- UNIMPLEMENTED
    NUM_LE_LFG_CATEGORYS = 0,  -- UNIMPLEMENTED
    NUM_LE_TRANSMOG_COLLECTION_TYPES = 0,  -- UNIMPLEMENTED
    PetHasActionBar = UNIMPLEMENTED,
    PickupContainerItem = UNIMPLEMENTED,
    PickupInventoryItem = UNIMPLEMENTED,
    PlaySound = UNIMPLEMENTED,
    PutItemInBackpack = UNIMPLEMENTED,
    PutItemInBag = UNIMPLEMENTED,
    QuestHonorFrame_Update = UNIMPLEMENTED,
    RegisterStaticConstants = UNIMPLEMENTED,
    RequestRaidInfo = UNIMPLEMENTED,
    ResetCursor = UNIMPLEMENTED,
    ResurrectGetOfferer = UNIMPLEMENTED,
    RollOnLoot = UNIMPLEMENTED,
    securecall = function(func, ...)
      assert(func, 'securecall of nil function')
      if type(func) == 'string' then
        assert(api.env[func], 'securecall of unknown function ' .. func)
        func = api.env[func]
      end
      -- use tainted-lua if available
      if securecall then
        return securecall(func, ...)
      else
        return func(...)
      end
    end,
    SelectGossipOption = UNIMPLEMENTED,
    SelectQuestLogEntry = UNIMPLEMENTED,
    SetActionBarToggles = UNIMPLEMENTED,
    SetActionUIButton = UNIMPLEMENTED,
    SetBagPortraitTexture = UNIMPLEMENTED,
    SetBinding = UNIMPLEMENTED,
    SetChatWindowDocked = UNIMPLEMENTED,
    SetChatWindowLocked = UNIMPLEMENTED,
    SetChatWindowName = UNIMPLEMENTED,
    SetChatWindowShown = UNIMPLEMENTED,
    SetChatWindowUninteractable = UNIMPLEMENTED,
    SetCursor = UNIMPLEMENTED,
    seterrorhandler = UNIMPLEMENTED,
    SetPortraitTexture = UNIMPLEMENTED,
    SetPortraitToTexture = UNIMPLEMENTED,
    SetSelectedSkill = UNIMPLEMENTED,
    SetUIVisibility = UNIMPLEMENTED,
    ShouldKnowUnitHealth = UNIMPLEMENTED,
    ShowBossFrameWhenUninteractable = UNIMPLEMENTED,
    SortAuctionClearSort = UNIMPLEMENTED,
    SortAuctionSetSort = UNIMPLEMENTED,
    Sound_GameSystem_GetNumOutputDrivers = STUB_NUMBER,
    Sound_GameSystem_GetOutputDriverNameByIndex = UNIMPLEMENTED,
    SpellCanTargetItem = UNIMPLEMENTED,
    SpellCanTargetItemID = UNIMPLEMENTED,
    StoreSecureReference = UNIMPLEMENTED,
    StrafeLeftStop = UNIMPLEMENTED,
    StrafeRightStop = UNIMPLEMENTED,
    SupportsClipCursor = UNIMPLEMENTED,
    TargetSpellReplacesBonusTree = UNIMPLEMENTED,
    ToggleWorldMap = UNIMPLEMENTED,
    TriggerTutorial = UNIMPLEMENTED,
    TurnLeftStop = UNIMPLEMENTED,
    TurnRightStop = UNIMPLEMENTED,
    UnitAffectingCombat = UNIMPLEMENTED,
    UnitAura = UNIMPLEMENTED,
    UnitCanCooperate = UNIMPLEMENTED,
    UnitCastingInfo = UNIMPLEMENTED,
    UnitChannelInfo = UNIMPLEMENTED,
    UnitClass = function()
      return 'Warrior', 'WARRIOR', 1
    end,
    UnitExists = UNIMPLEMENTED,
    UnitFactionGroup = function()
      return 'Horde', 'Horde'
    end,
    UnitGetAvailableRoles = UNIMPLEMENTED,
    UnitGetIncomingHeals = UNIMPLEMENTED,
    UnitGetTotalAbsorbs = UNIMPLEMENTED,
    UnitGetTotalHealAbsorbs = UNIMPLEMENTED,
    UnitGUID = UNIMPLEMENTED,
    UnitHasLFGDeserter = UNIMPLEMENTED,
    UnitHasRelicSlot = UNIMPLEMENTED,
    UnitHasVehicleUI = UNIMPLEMENTED,
    UnitHealth = STUB_NUMBER,
    UnitHealthMax = STUB_NUMBER,
    UnitInBattleground = UNIMPLEMENTED,
    UnitIsConnected = UNIMPLEMENTED,
    UnitIsDead = UNIMPLEMENTED,
    UnitIsDeadOrGhost = UNIMPLEMENTED,
    UnitIsGhost = UNIMPLEMENTED,
    UnitIsGroupAssistant = UNIMPLEMENTED,
    UnitIsGroupLeader = UNIMPLEMENTED,
    UnitIsOtherPlayersPet = UNIMPLEMENTED,
    UnitIsPlayer = UNIMPLEMENTED,
    UnitIsPossessed = UNIMPLEMENTED,
    UnitIsUnit = UNIMPLEMENTED,
    UnitIsVisible = UNIMPLEMENTED,
    UnitLevel = STUB_NUMBER,
    UnitName = function()
      return 'Unitname'  -- UNIMPLEMENTED
    end,
    UnitNameUnmodified = UNIMPLEMENTED,
    UnitOnTaxi = UNIMPLEMENTED,
    UnitPlayerControlled = UNIMPLEMENTED,
    UnitPosition = UNIMPLEMENTED,
    UnitPower = STUB_NUMBER,
    UnitPowerMax = STUB_NUMBER,
    UnitPowerType = function()
      return 0, 'MANA'  -- UNIMPLEMENTED
    end,
    UnitPVPRank = STUB_NUMBER,
    UnitRace = function()
      return 'Human', 'Human', 1  -- UNIMPLEMENTED
    end,
    UnitReaction = UNIMPLEMENTED,
    UnitRealmRelationship = UNIMPLEMENTED,
    UnitResistance = function()
      return 0, 0, 0, 0
    end,
    UnitSex = function()
      return 2  -- UNIMPLEMENTED
    end,
    UnitThreatSituation = UNIMPLEMENTED,
    UnitXP = STUB_NUMBER,
    UnitXPMax = STUB_NUMBER,
    UseInventoryItem = UNIMPLEMENTED,
  }
end

local fakeConstants = (function()
  local names = {
    'BINDING_HEADER_MOVEMENT',
    'LE_ACTIONBAR_STATE_MAIN',
    'LE_AUTOCOMPLETE_PRIORITY_ACCOUNT_CHARACTER',
    'LE_AUTOCOMPLETE_PRIORITY_ACCOUNT_CHARACTER_SAME_REALM',
    'LE_AUTOCOMPLETE_PRIORITY_FRIEND',
    'LE_AUTOCOMPLETE_PRIORITY_GUILD',
    'LE_AUTOCOMPLETE_PRIORITY_INTERACTED',
    'LE_AUTOCOMPLETE_PRIORITY_IN_GROUP',
    'LE_AUTOCOMPLETE_PRIORITY_OTHER',
    'LE_EXPANSION_CLASSIC',
    'LE_FRAME_TUTORIAL_ARTIFACT_RELIC_MATCH',
    'LE_FRAME_TUTORIAL_AZERITE_ITEM_IN_SLOT',
    'LE_GAME_ERR_CANT_USE_ITEM',
    'LE_GAME_ERR_GENERIC_NO_VALID_TARGETS',
    'LE_GAME_ERR_ITEM_COOLDOWN',
    'LE_GAME_ERR_OUT_OF_MANA',
    'LE_GAME_ERR_SPELL_ALREADY_KNOWN_S',
    'LE_GAME_ERR_SPELL_FAILED_ALREADY_AT_FULL_HEALTH',
    'LE_GAME_ERR_SPELL_FAILED_ALREADY_AT_FULL_MANA',
    'LE_GAME_ERR_SPELL_FAILED_ALREADY_AT_FULL_POWER_S',
    'LE_GAME_ERR_SPELL_FAILED_ANOTHER_IN_PROGRESS',
    'LE_GAME_ERR_SPELL_FAILED_EQUIPPED_ITEM',
    'LE_GAME_ERR_SPELL_FAILED_EQUIPPED_ITEM_CLASS_S',
    'LE_GAME_ERR_SPELL_FAILED_EQUIPPED_SPECIFIC_ITEM',
    'LE_GAME_ERR_SPELL_FAILED_NOTUNSHEATHED',
    'LE_GAME_ERR_SPELL_FAILED_REAGENTS',
    'LE_GAME_ERR_SPELL_FAILED_REAGENTS_GENERIC',
    'LE_GAME_ERR_SPELL_FAILED_S',
    'LE_GAME_ERR_SPELL_FAILED_SHAPESHIFT_FORM_S',
    'LE_GAME_ERR_SPELL_FAILED_TOTEMS',
    'LE_GAME_ERR_SPELL_OUT_OF_RANGE',
    'LE_GAME_ERR_SPELL_UNLEARNED_S',
    'LE_ITEM_QUALITY_ARTIFACT',
    'LE_ITEM_QUALITY_COMMON',
    'LE_ITEM_QUALITY_EPIC',
    'LE_ITEM_QUALITY_HEIRLOOM',
    'LE_ITEM_QUALITY_LEGENDARY',
    'LE_ITEM_QUALITY_POOR',
    'LE_ITEM_QUALITY_RARE',
    'LE_ITEM_QUALITY_UNCOMMON',
    'LE_ITEM_QUALITY_WOW_TOKEN',
    'LE_LFG_CATEGORY_BATTLEFIELD',
    'LE_LFG_CATEGORY_FLEXRAID',
    'LE_LFG_CATEGORY_LFD',
    'LE_LFG_CATEGORY_LFR',
    'LE_LFG_CATEGORY_RF',
    'LE_LFG_CATEGORY_SCENARIO',
    'LE_LFG_CATEGORY_WORLDPVP',
    'LE_MODEL_BLEND_OPERATION_NONE',
    'LE_QUEST_TAG_TYPE_DUNGEON',
    'LE_QUEST_TAG_TYPE_RAID',
    'LE_SUMMON_REASON_SCENARIO',
    'LE_TOKEN_REDEEM_TYPE_BALANCE',
    'LE_TOKEN_REDEEM_TYPE_GAME_TIME',
    'LE_TOKEN_RESULT_ERROR_BALANCE_NEAR_CAP',
    'LE_TOKEN_RESULT_ERROR_DISABLED',
    'LE_TOKEN_RESULT_ERROR_OTHER',
    'LE_TOKEN_RESULT_SUCCESS',
    'LE_WORLD_QUEST_QUALITY_COMMON',
    'LE_WORLD_QUEST_QUALITY_EPIC',
    'LE_WORLD_QUEST_QUALITY_RARE',
  }
  local t = {}
  for _, n in ipairs(names) do
    t[n] = 'AUTOGENERATED:' .. n
  end
  return t
end)()

local function init(api)
  setmetatable(api.env, mkMetaEnv(api))
  Mixin(api.env, mkBaseEnv(), fakeConstants, mkWowEnv(api))
  Mixin(api.uiobjectTypes, mkBaseUIObjectTypes(api))
end

return {
  init = init,
}
