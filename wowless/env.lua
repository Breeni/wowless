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

  return {
    actor = {
      inherits = {'parentedobject', 'scriptobject'},
      intrinsic = true,
      name = 'Actor',
    },
    animationgroup = {
      inherits = {'parentedobject', 'scriptobject'},
      intrinsic = true,
      mixin = {
        IsPlaying = UNIMPLEMENTED,
        Play = UNIMPLEMENTED,
        Stop = UNIMPLEMENTED,
      },
      name = 'AnimationGroup',
    },
    browser = {
      inherits = {'frame'},
      intrinsic = true,
      mixin = {
        NavigateHome = UNIMPLEMENTED,
      },
      name = 'Browser',
    },
    button = {
      constructor = function(self)
        u(self).beingClicked = false
        u(self).buttonLocked = false
        u(self).buttonState = 'NORMAL'
        u(self).enabled = true
        u(self).fontstring = m(self, 'CreateFontString')
      end,
      inherits = {'frame'},
      intrinsic = true,
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
        GetPushedTexture = function(self)
          return u(self).pushedTexture
        end,
        GetText = UNIMPLEMENTED,
        GetTextWidth = STUB_NUMBER,
        IsEnabled = function(self)
          return u(self).enabled
        end,
        LockHighlight = UNIMPLEMENTED,
        RegisterForClicks = UNIMPLEMENTED,
        SetButtonState = function(self, state, locked)
          u(self).buttonLocked = not not locked
          u(self).buttonState = state
        end,
        SetDisabledFontObject = UNIMPLEMENTED,
        SetDisabledTexture = function(self, tex)
          u(self).disabledTexture = toTexture(self, tex)
        end,
        SetEnabled = function(self, value)
          u(self).enabled = not not value
        end,
        SetFormattedText = UNIMPLEMENTED,
        SetHighlightAtlas = UNIMPLEMENTED,
        SetHighlightFontObject = UNIMPLEMENTED,
        SetHighlightTexture = function(self, tex)
          u(self).highlightTexture = toTexture(self, tex)
        end,
        SetNormalAtlas = UNIMPLEMENTED,
        SetNormalFontObject = UNIMPLEMENTED,
        SetNormalTexture = function(self, tex)
          u(self).normalTexture = toTexture(self, tex)
        end,
        SetPushedAtlas = UNIMPLEMENTED,
        SetPushedTexture = function(self, tex)
          u(self).pushedTexture = toTexture(self, tex)
        end,
        SetText = UNIMPLEMENTED,
        UnlockHighlight = UNIMPLEMENTED,
      },
      name = 'Button',
    },
    checkbutton = {
      constructor = function(self)
        u(self).checked = false
      end,
      inherits = {'button'},
      intrinsic = true,
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
      name = 'CheckButton',
    },
    cooldown = {
      inherits = {'frame'},
      intrinsic = true,
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
      name = 'Cooldown',
    },
    dressupmodel = {
      inherits = {'playermodel'},
      intrinsic = true,
      name = 'DressUpModel',
    },
    editbox = {
      constructor = function(self)
        u(self).editboxText = ''
      end,
      inherits = {'fontinstance', 'frame'},
      intrinsic = true,
      mixin = {
        ClearFocus = UNIMPLEMENTED,
        GetInputLanguage = function()
          return 'ROMAN'  -- UNIMPLEMENTED
        end,
        GetNumber = STUB_NUMBER,
        GetText = function(self)
          return u(self).editboxText
        end,
        SetFocus = UNIMPLEMENTED,
        SetNumber = UNIMPLEMENTED,
        SetSecureText = function(self, text)
          u(self).editboxText = text
        end,
        SetText = function(self, text)
          u(self).editboxText = text
        end,
        SetTextInsets = UNIMPLEMENTED,
      },
      name = 'EditBox',
    },
    font = {
      inherits = {'fontinstance'},
      intrinsic = true,
      name = 'Font',
    },
    fontinstance = {
      inherits = {'uiobject'},
      intrinsic = true,
      mixin = {
        GetFont = UNIMPLEMENTED,
        GetShadowOffset = STUB_NUMBER,
        GetSpacing = STUB_NUMBER,
        GetTextColor = function()
          return 1, 1, 1  -- UNIMPLEMENTED
        end,
        SetFontObject = UNIMPLEMENTED,
        SetIndentedWordWrap = UNIMPLEMENTED,
        SetJustifyH = UNIMPLEMENTED,
        SetSpacing = UNIMPLEMENTED,
        SetTextColor = UNIMPLEMENTED,
      },
      name = 'FontInstance',
    },
    fontstring = {
      inherits = {'fontinstance', 'layeredregion'},
      intrinsic = true,
      mixin = {
        GetLineHeight = STUB_NUMBER,
        GetStringWidth = STUB_NUMBER,
        GetText = UNIMPLEMENTED,
        IsTruncated = UNIMPLEMENTED,
        SetFormattedText = UNIMPLEMENTED,
        SetMaxLines = UNIMPLEMENTED,
        SetText = UNIMPLEMENTED,
      },
      name = 'FontString',
    },
    frame = {
      constructor = function(self, xmlattr)
        table.insert(api.frames, self)
        u(self).attributes = {}
        u(self).registeredEvents = {}
        if xmlattr.id then
          m(self, 'SetID', xmlattr.id)
        end
      end,
      inherits = {'parentedobject', 'region', 'scriptobject'},
      intrinsic = true,
      mixin = {
        CreateFontString = function(self, name)
          return api.CreateUIObject('fontstring', name, self)
        end,
        CreateTexture = function(self, name)
          return api.CreateUIObject('texture', name, self)
        end,
        EnableMouse = UNIMPLEMENTED,
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
        GetFrameLevel = STUB_NUMBER,
        GetID = function(self)
          return u(self).id or 0
        end,
        IgnoreDepth = UNIMPLEMENTED,
        IsEventRegistered = UNIMPLEMENTED,
        IsUserPlaced = UNIMPLEMENTED,
        Raise = UNIMPLEMENTED,
        RegisterEvent = function(self, event)
          u(self).registeredEvents[string.lower(event)] = true
        end,
        RegisterForDrag = UNIMPLEMENTED,
        RegisterUnitEvent = UNIMPLEMENTED,
        SetAttribute = function(self, name, value)
          api.log(4, 'setting attribute %s on %s to %s', name, tostring(self:GetName()), tostring(value))
          u(self).attributes[name] = value
          api.RunScript(self, 'OnAttributeChanged', name, value)
        end,
        SetClampRectInsets = UNIMPLEMENTED,
        SetFrameLevel = UNIMPLEMENTED,
        SetFrameStrata = UNIMPLEMENTED,
        SetHitRectInsets = UNIMPLEMENTED,
        SetID = function(self, id)
          u(self).id = id
        end,
        SetMouseClickEnabled = UNIMPLEMENTED,
        SetUserPlaced = UNIMPLEMENTED,
        UnregisterEvent = function(self, event)
          u(self).registeredEvents[string.lower(event)] = nil
        end,
      },
      name = 'Frame',
    },
    gametooltip = {
      inherits = {'frame'},
      intrinsic = true,
      mixin = {
        GetOwner = UNIMPLEMENTED,
        IsOwned = UNIMPLEMENTED,
        SetPadding = UNIMPLEMENTED,
      },
      name = 'GameTooltip',
    },
    layeredregion = {
      inherits = {'region'},
      intrinsic = true,
      mixin = {
        SetDrawLayer = UNIMPLEMENTED,
        SetVertexColor = UNIMPLEMENTED,
      },
      name = 'LayeredRegion',
    },
    messageframe = {
      inherits = {'frame'},
      intrinsic = true,
      name = 'MessageFrame',
    },
    minimap = {
      inherits = {'frame'},
      intrinsic = true,
      name = 'Minimap',
    },
    model = {
      inherits = {'frame'},
      intrinsic = true,
      mixin = {
        SetRotation = UNIMPLEMENTED,
      },
      name = 'Model',
    },
    modelscene = {
      inherits = {'frame'},
      intrinsic = true,
      mixin = {
        GetLightDirection = function()
          return 1, 1, 1  -- UNIMPLEMENTED
        end,
        GetLightPosition = function()
          return 1, 1, 1  -- UNIMPLEMENTED
        end,
        SetLightDirection = UNIMPLEMENTED,
        SetLightPosition = UNIMPLEMENTED,
      },
      name = 'ModelScene',
    },
    parentedobject = {
      constructor = function(self)
        u(self).children = {}
      end,
      inherits = {'uiobject'},
      intrinsic = true,
      mixin = {
        GetParent = function(self)
          return u(self).parent
        end,
        SetForbidden = UNIMPLEMENTED,
      },
      name = 'ParentedObject',
    },
    playermodel = {
      inherits = {'model'},
      intrinsic = true,
      mixin = {
        RefreshCamera = UNIMPLEMENTED,
        RefreshUnit = UNIMPLEMENTED,
        SetPortraitZoom = UNIMPLEMENTED,
        SetUnit = UNIMPLEMENTED,
      },
      name = 'PlayerModel',
    },
    region = {
      constructor = function(self)
        local ud = u(self)
        ud.alpha = 1
        ud.height = 0
        ud.isIgnoringParentAlpha = false
        ud.isIgnoringParentScale = false
        ud.points = {}
        ud.scale = 1
        ud.shown = true
        ud.visible = not ud.parent or u(ud.parent).visible
        ud.width = 0
      end,
      inherits = {'parentedobject'},
      intrinsic = true,
      mixin = {
        ClearAllPoints = function(self)
          util.twipe(u(self).points)
        end,
        GetAlpha = function(self)
          return u(self).alpha
        end,
        GetBottom = STUB_NUMBER,
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
        GetLeft = STUB_NUMBER,
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
          return unpack(u(self).points[idx])
        end,
        GetRight = STUB_NUMBER,
        GetScale = function(self)
          return u(self).scale
        end,
        GetSize = function(self)
          return m(self, 'GetWidth'), m(self, 'GetHeight')
        end,
        GetTop = STUB_NUMBER,
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
          api.SetParent(self, parent)
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
      name = 'Region',
    },
    scriptobject = {
      constructor = function(self)
        u(self).scripts = {
          [0] = {},
          [1] = {},
          [2] = {},
        }
      end,
      inherits = {},
      intrinsic = true,
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
      name = 'ScriptObject',
    },
    scrollframe = {
      inherits = {'frame'},
      intrinsic = true,
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
      name = 'ScrollFrame',
    },
    slider = {
      inherits = {'frame'},
      intrinsic = true,
      mixin = {
        Disable = UNIMPLEMENTED,
        Enable = UNIMPLEMENTED,
        GetMinMaxValues = UNIMPLEMENTED,
        GetThumbTexture = function(self)
          return u(self).thumbTexture
        end,
        GetValue = STUB_NUMBER,
        SetMinMaxValues = UNIMPLEMENTED,
        SetStepsPerPage = UNIMPLEMENTED,
        SetThumbTexture = function(self, tex)
          u(self).thumbTexture = toTexture(self, tex)
        end,
        SetValue = UNIMPLEMENTED,
        SetValueStep = UNIMPLEMENTED,
      },
      name = 'Slider',
    },
    statusbar = {
      inherits = {'frame'},
      intrinsic = true,
      mixin = {
        GetMinMaxValues = function()
          return 0, 0  -- UNIMPLEMENTED
        end,
        GetStatusBarTexture = function(self)
          return u(self).statusBarTexture
        end,
        GetValue = function()
          return 0  -- UNIMPLEMENTED
        end,
        SetMinMaxValues = UNIMPLEMENTED,
        SetStatusBarColor = UNIMPLEMENTED,
        SetStatusBarTexture = function(self, tex)
          if type(tex) == 'number' then
            api.log(1, 'unimplemented call to SetStatusBarTexture')
            u(self).statusBarTexture = m(self, 'CreateTexture')
          else
            u(self).statusBarTexture = toTexture(self, tex)
          end
        end,
        SetValue = UNIMPLEMENTED,
      },
      name = 'StatusBar',
    },
    texture = {
      inherits = {'layeredregion', 'parentedobject'},
      intrinsic = true,
      mixin = {
        GetTexCoord = UNIMPLEMENTED,
        GetTexture = UNIMPLEMENTED,
        SetAtlas = UNIMPLEMENTED,
        SetColorTexture = UNIMPLEMENTED,
        SetDesaturated = UNIMPLEMENTED,
        SetGradient = UNIMPLEMENTED,
        SetHorizTile = UNIMPLEMENTED,
        SetTexCoord = UNIMPLEMENTED,
        SetTexture = UNIMPLEMENTED,
        SetVertTile = UNIMPLEMENTED,
      },
      name = 'Texture',
    },
    uiobject = {
      inherits = {},
      intrinsic = true,
      mixin = {
        GetName = function(self)
          return u(self).name
        end,
        GetObjectType = function(self)
          return api.uiobjectTypes[u(self).type].name
        end,
        IsObjectType = UNIMPLEMENTED,
      },
      name = 'UIObject',
    },
    worldframe = {
      inherits = {'frame'},
      intrinsic = true,
      name = 'WorldFrame',
    },
  }
end

local baseEnv = {
  abs = math.abs,
  assert = assert,
  bit = {
    bor = bitlib.bor,
  },
  ceil = math.ceil,
  floor = math.floor,
  format = string.format,
  getfenv = getfenv,
  getmetatable = getmetatable,
  getn = table.getn,
  gsub = string.gsub,
  ipairs = ipairs,
  math = {
    ceil = math.ceil,
    floor = math.floor,
    max = math.max,
    min = math.min,
  },
  max = math.max,
  min = math.min,
  mod = math.fmod,
  next = next,
  pairs = pairs,
  pcall = pcall,
  print = print,
  rawget = rawget,
  select = select,
  setmetatable = setmetatable,
  sort = table.sort,
  string = {
    byte = string.byte,
    find = string.find,
    format = string.format,
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
    insert = table.insert,
    wipe = util.twipe,
  },
  tinsert = table.insert,
  tonumber = tonumber,
  tostring = tostring,
  tremove = table.remove,
  type = type,
  unpack = unpack,
}

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
  return {
    AntiAliasingSupported = UNIMPLEMENTED,
    BNFeaturesEnabled = UNIMPLEMENTED,
    BNFeaturesEnabledAndConnected = UNIMPLEMENTED,
    BNGetInfo = UNIMPLEMENTED,
    BNGetNumFriendInvites = function()
      return 0  -- UNIMPLEMENTED
    end,
    BNGetNumFriends = function()
      return 0, 0  -- UNIMPLEMENTED
    end,
    CanAutoSetGamePadCursorControl = UNIMPLEMENTED,
    CanReplaceGuildMaster = UNIMPLEMENTED,
    CastShapeshiftForm = UNIMPLEMENTED,
    ChangeActionBarPage = UNIMPLEMENTED,
    Constants = {
      CurrencyConsts = {},
    },
    ContainerIDToInventoryID = UNIMPLEMENTED,
    CreateFont = function(name)
      return api.CreateUIObject('font', name)
    end,
    CreateFrame = function(type, name, parent, templates)
      local ltype = string.lower(type)
      assert(api.InheritsFrom(ltype, 'frame'), type .. ' does not inherit from frame')
      local inherits = {}
      for template in string.gmatch(templates or '', '[^, ]+') do
        table.insert(inherits, string.lower(template))
      end
      local obj = api.CreateUIObject(ltype, name, parent, inherits)
      api.RunScript(obj, 'OnLoad')
      return obj
    end,
    CursorHasItem = UNIMPLEMENTED,
    C_ChatInfo = {
      IsValidChatLine = UNIMPLEMENTED,
    },
    C_Club = {
      GetInvitationsForSelf = STUB_TABLE,
      GetSubscribedClubs = STUB_TABLE,
      IsEnabled = UNIMPLEMENTED,
    },
    C_Commentator = {
      IsSpectating = UNIMPLEMENTED,
    },
    C_CurrencyInfo = {
      GetCurrencyInfo = STUB_TABLE,
    },
    C_CVar = {
      GetCVar = function(var)
        return api.env.C_CVar.GetCVarDefault(var)  -- UNIMPLEMENTED
      end,
      GetCVarBool = UNIMPLEMENTED,
      GetCVarDefault = function(var)  -- UNIMPLEMENTED
        local defaults = {
          cameraSmoothStyle = '0',
          cameraSmoothTrackingStyle = '0',
          nameplateMotion = '0',
        }
        return defaults[var]
      end,
      SetCVar = UNIMPLEMENTED,
    },
    C_DeathInfo = {
      GetSelfResurrectOptions = UNIMPLEMENTED,
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
    C_GuildInfo = {
      GuildControlGetRankFlags = STUB_TABLE,
      GuildRoster = UNIMPLEMENTED,
    },
    C_LootHistory = {
      GetItem = UNIMPLEMENTED,
      GetNumItems = STUB_NUMBER,
    },
    C_NamePlate = {
      GetNumNamePlateMotionTypes = STUB_NUMBER,
    },
    C_PaperDollInfo = {
      OffhandHasWeapon = UNIMPLEMENTED,
    },
    C_ProductChoice = {
      GetChoices = STUB_TABLE,
    },
    C_ScriptedAnimations = {
      GetAllScriptedAnimationEffects = STUB_TABLE,
    },
    C_Social = {
      RegisterSocialBrowser = UNIMPLEMENTED,
      TwitterCheckStatus = UNIMPLEMENTED,
    },
    C_StorePublic = {
      IsDisabledByParentalControls = UNIMPLEMENTED,
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
    C_VoiceChat = {
      CanPlayerUseVoiceChat = UNIMPLEMENTED,
      GetActiveChannelID = UNIMPLEMENTED,
      GetAvailableInputDevices = UNIMPLEMENTED,
      GetAvailableOutputDevices = UNIMPLEMENTED,
      GetCommunicationMode = UNIMPLEMENTED,
      GetInputVolume = UNIMPLEMENTED,
      GetMasterVolumeScale = UNIMPLEMENTED,
      GetOutputVolume = UNIMPLEMENTED,
      GetVADSensitivity = UNIMPLEMENTED,
    },
    C_Widget = {},
    DropCursorMoney = UNIMPLEMENTED,
    Enum = setmetatable({}, {
      __index = function(_, k)
        return setmetatable({}, {
          __index = function(_, k2)
            return 'AUTOGENERATED:Enum:' .. k .. ':' .. k2
          end,
        })
      end,
    }),
    FillLocalizedClassList = UNIMPLEMENTED,
    GetActionBarPage = STUB_NUMBER,
    GetActionBarToggles = UNIMPLEMENTED,
    GetActionCount = STUB_NUMBER,
    GetActionInfo = UNIMPLEMENTED,
    GetActionTexture = UNIMPLEMENTED,
    GetActiveLootRollIDs = STUB_TABLE,
    GetAddOnEnableState = UNIMPLEMENTED,
    GetAlternativeDefaultLanguage = UNIMPLEMENTED,
    GetArenaTeam = UNIMPLEMENTED,
    GetAvailableLocales = UNIMPLEMENTED,
    GetBattlefieldStatus = UNIMPLEMENTED,
    GetBindingKey = UNIMPLEMENTED,
    GetBindingText = UNIMPLEMENTED,
    GetChatTypeIndex = STUB_NUMBER,
    GetChatWindowInfo = UNIMPLEMENTED,
    GetChatWindowSavedDimensions = UNIMPLEMENTED,
    GetChatWindowSavedPosition = UNIMPLEMENTED,
    GetClassicExpansionLevel = STUB_NUMBER,
    GetComboPoints = STUB_NUMBER,
    GetContainerItemInfo = UNIMPLEMENTED,
    GetContainerNumFreeSlots = STUB_NUMBER,
    GetContainerNumSlots = STUB_NUMBER,
    GetCurrentScaledResolution = function()
      return 1024, 768  -- UNIMPLEMENTED
    end,
    GetCurrentTitle = UNIMPLEMENTED,
    GetCursorInfo = UNIMPLEMENTED,
    GetCursorMoney = STUB_NUMBER,
    GetCursorPosition = function()
      return 0, 0  -- UNIMPLEMENTED
    end,
    GetCVarInfo = UNIMPLEMENTED,
    GetCVarSettingValidity = UNIMPLEMENTED,
    GetDailyQuestsCompleted = STUB_NUMBER,
    GetDefaultLanguage = function()
      return 'Common', 7  -- UNIMPLEMENTED
    end,
    GetDefaultVideoOptions = UNIMPLEMENTED,
    GetFileStreamingStatus = UNIMPLEMENTED,
    GetGameTime = function()
      return 1, 1  -- UNIMPLEMENTED
    end,
    GetGMStatus = UNIMPLEMENTED,
    GetGuildRosterShowOffline = UNIMPLEMENTED,
    GetInventoryAlertStatus = UNIMPLEMENTED,
    GetInventoryItemID = UNIMPLEMENTED,
    GetInventorySlotInfo = function()
      return 'UNIMPLEMENTED'
    end,
    GetItemQualityColor = function()
      return 0, 0, 0  -- UNIMPLEMENTED
    end,
    GetLanguageByIndex = UNIMPLEMENTED,
    GetLootMethod = function()
      return 'freeforall'  -- UNIMPLEMENTED
    end,
    GetLootThreshold = STUB_NUMBER,
    GetMaxDailyQuests = STUB_NUMBER,
    GetMaxPlayerLevel = STUB_NUMBER,
    GetMaxRenderScale = UNIMPLEMENTED,
    GetMinimapZoneText = UNIMPLEMENTED,
    GetMinRenderScale = UNIMPLEMENTED,
    GetMirrorTimerInfo = function()
      return 'UNKNOWN'  -- UNIMPLEMENTED
    end,
    GetModifiedClick = UNIMPLEMENTED,
    GetMoney = STUB_NUMBER,
    GetMouseFocus = UNIMPLEMENTED,
    GetNetStats = function()
      return 1, 1, 1, 1  -- UNIMPLEMENTED
    end,
    GetNumAddOns = function()
      return 0  -- UNIMPLEMENTED
    end,
    GetNumLanguages = STUB_NUMBER,
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
    GetNumShapeshiftForms = STUB_NUMBER,
    GetNumSkillLines = STUB_NUMBER,
    GetNumSpellTabs = STUB_NUMBER,
    GetNumSubgroupMembers = STUB_NUMBER,
    GetNumTitles = STUB_NUMBER,
    GetNumTrackingTypes = STUB_NUMBER,
    GetOptOutOfLoot = UNIMPLEMENTED,
    GetPetActionCooldown = UNIMPLEMENTED,
    GetPetActionInfo = UNIMPLEMENTED,
    GetPetExperience = STUB_NUMBER,
    GetPlayerTradeMoney = STUB_NUMBER,
    GetPVPLifetimeStats = UNIMPLEMENTED,
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
    GetSpellConfirmationPromptsInfo = STUB_TABLE,
    GetSpellTabInfo = function()
      return 'moo', 0, 0, 0  -- UNIMPLEMENTED
    end,
    GetSubZoneText = UNIMPLEMENTED,
    GetSummonFriendCooldown = function()
      return 0, 0  -- UNIMPLEMENTED
    end,
    GetTabardCreationCost = STUB_NUMBER,
    GetText = UNIMPLEMENTED,
    GetTime = UNIMPLEMENTED,
    GetTotemInfo = UNIMPLEMENTED,
    GetTrackingInfo = UNIMPLEMENTED,
    GetWeaponEnchantInfo = UNIMPLEMENTED,
    GetWebTicket = UNIMPLEMENTED,
    GetXPExhaustion = UNIMPLEMENTED,
    GetZonePVPInfo = UNIMPLEMENTED,
    GetZoneText = UNIMPLEMENTED,
    GuildControlGetNumRanks = STUB_NUMBER,
    GuildControlGetRankName = UNIMPLEMENTED,
    HasAction = UNIMPLEMENTED,
    HasBonusActionBar = UNIMPLEMENTED,
    HasKey = UNIMPLEMENTED,
    HasPetSpells = UNIMPLEMENTED,
    HasPetUI = UNIMPLEMENTED,
    HasTempShapeshiftActionBar = UNIMPLEMENTED,
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
    InCinematic = UNIMPLEMENTED,
    InCombatLockdown = UNIMPLEMENTED,
    IsAccountSecured = UNIMPLEMENTED,
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
    IsInRaid = UNIMPLEMENTED,
    IsItemAction = UNIMPLEMENTED,
    IsMacClient = UNIMPLEMENTED,
    IsModifiedClick = UNIMPLEMENTED,
    IsOnGlueScreen = UNIMPLEMENTED,
    IsQuestWatched = UNIMPLEMENTED,
    IsResting = UNIMPLEMENTED,
    IsRestrictedAccount = UNIMPLEMENTED,
    issecure = UNIMPLEMENTED,
    IsShiftKeyDown = UNIMPLEMENTED,
    IsStackableAction = UNIMPLEMENTED,
    IsTitleKnown = UNIMPLEMENTED,
    IsTrialAccount = UNIMPLEMENTED,
    IsTutorialFlagged = UNIMPLEMENTED,
    IsUnitOnQuest = UNIMPLEMENTED,
    IsVeteranTrialAccount = UNIMPLEMENTED,
    IsWindowsClient = UNIMPLEMENTED,
    LE_EXPANSION_BURNING_CRUSADE = 2,  -- UNIMPLEMENTED
    LoadAddOn = function(name)
      api.log(1, 'failing to load addon ' .. name)
      return false, 'LOAD_FAILED'  -- UNIMPLEMENTED
    end,
    Kiosk = {
      IsEnabled = UNIMPLEMENTED,
    },
    MultiSampleAntiAliasingSupported = UNIMPLEMENTED,
    newproxy = function()
      return setmetatable({}, {})
    end,
    NUM_LE_ITEM_QUALITYS = 10,  -- UNIMPLEMENTED
    PetHasActionBar = UNIMPLEMENTED,
    PickupContainerItem = UNIMPLEMENTED,
    PickupInventoryItem = UNIMPLEMENTED,
    PlaySound = UNIMPLEMENTED,
    PutItemInBackpack = UNIMPLEMENTED,
    QuestHonorFrame_Update = UNIMPLEMENTED,
    RegisterStaticConstants = UNIMPLEMENTED,
    RequestRaidInfo = UNIMPLEMENTED,
    ResurrectGetOfferer = UNIMPLEMENTED,
    RollOnLoot = UNIMPLEMENTED,
    securecall = function(func, ...)
      assert(func, 'securecall of nil function')
      if type(func) == 'string' then
        assert(api.env[func], 'securecall of unknown function ' .. func)
        func = api.env[func]
      end
      return func(...)
    end,
    SelectQuestLogEntry = UNIMPLEMENTED,
    SetActionBarToggles = UNIMPLEMENTED,
    SetActionUIButton = UNIMPLEMENTED,
    SetBagPortraitTexture = UNIMPLEMENTED,
    SetChatWindowName = UNIMPLEMENTED,
    SetChatWindowShown = UNIMPLEMENTED,
    seterrorhandler = UNIMPLEMENTED,
    SetPortraitTexture = UNIMPLEMENTED,
    SetPortraitToTexture = UNIMPLEMENTED,
    SetSelectedSkill = UNIMPLEMENTED,
    ShouldKnowUnitHealth = UNIMPLEMENTED,
    ShowBossFrameWhenUninteractable = UNIMPLEMENTED,
    Sound_GameSystem_GetNumOutputDrivers = STUB_NUMBER,
    Sound_GameSystem_GetOutputDriverNameByIndex = UNIMPLEMENTED,
    SpellCanTargetItem = UNIMPLEMENTED,
    SpellCanTargetItemID = UNIMPLEMENTED,
    ToggleWorldMap = UNIMPLEMENTED,
    TriggerTutorial = UNIMPLEMENTED,
    UnitAura = UNIMPLEMENTED,
    UnitCanCooperate = UNIMPLEMENTED,
    UnitCastingInfo = UNIMPLEMENTED,
    UnitChannelInfo = UNIMPLEMENTED,
    UnitClass = UNIMPLEMENTED,
    UnitExists = UNIMPLEMENTED,
    UnitFactionGroup = UNIMPLEMENTED,
    UnitGUID = UNIMPLEMENTED,
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
    UnitOnTaxi = UNIMPLEMENTED,
    UnitPower = STUB_NUMBER,
    UnitPowerMax = STUB_NUMBER,
    UnitPowerType = function()
      return 0, 'MANA'  -- UNIMPLEMENTED
    end,
    UnitRace = function()
      return 'Human', 'Human', 1  -- UNIMPLEMENTED
    end,
    UnitRealmRelationship = UNIMPLEMENTED,
    UnitSex = function()
      return 2  -- UNIMPLEMENTED
    end,
    UnitXP = STUB_NUMBER,
    UnitXPMax = STUB_NUMBER,
    UseInventoryItem = UNIMPLEMENTED,
  }
end

local fakeConstants = (function()
  local names = {
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
  Mixin(api.env, baseEnv, fakeConstants, mkWowEnv(api), require('wowless.globalstrings'))
  Mixin(api.uiobjectTypes, mkBaseUIObjectTypes(api))
end

return {
  init = init,
}
