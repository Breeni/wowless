local function loadToc(toc)
  local result = {}
  for line in io.lines(toc) do
    line = line:match('^%s*(.-)%s*$'):gsub('\\', '/')
    if line ~= '' and line:sub(1, 1) ~= '#' then
      local f = assert(io.open(line, 'rb'))
      local content = f:read('*all')
      f:close()
      if content:sub(1, 3) == '\239\187\191' then
        content = content:sub(4)
      end
      if line:sub(-4) == '.lua' then
        table.insert(result, {
          filename = line,
          lua = assert(loadstring(content)),
        })
      elseif line:sub(-4) == '.xml' then
        -- TODO support xml
      else
        error('unknown file type ' .. line)
      end
    end
  end
  return result
end

local bitlib = require('bit')

local UNIMPLEMENTED = function() end

local env = setmetatable({
  CreateFrame = function()
    return {
      RegisterEvent = UNIMPLEMENTED,
      SetForbidden = UNIMPLEMENTED,
      SetScript = UNIMPLEMENTED,
    }
  end,
  bit = {
    bor = bitlib.bor,
  },
  C_ScriptedAnimations = {
    GetAllScriptedAnimationEffects = function()
      return {}  -- UNIMPLEMENTED
    end,
  },
  C_Timer = {
    After = UNIMPLEMENTED,
  },
  C_VoiceChat = {},
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
  getfenv = getfenv,
  ipairs = ipairs,
  IsGMClient = UNIMPLEMENTED,
  math = {},
  pairs = pairs,
  rawget = rawget,
  RegisterStaticConstants = UNIMPLEMENTED,
  select = select,
  setmetatable = setmetatable,
  string = {},
  table = {
    insert = table.insert,
  },
  type = type,
}, {
  __index = function(t, k)
    if k == '_G' then
      return t
    elseif k:sub(1, 3) == 'LE_' then
      return 'AUTOGENERATED:' .. k
    end
  end
})

require('lfs').chdir('wowui/classic/FrameXML')
for _, code in ipairs(loadToc('FrameXML.toc')) do
  local success, err = pcall(setfenv(code.lua, env))
  if not success then
    error('failure loading ' .. code.filename .. ': ' .. err)
  end
end
for k in pairs(env) do
  print(k)
end
