local indir, outdir = unpack(arg)
local lfs = require('lfs')
local tags = {
  'wow',
  'wowt',
  'wow_classic',
  'wow_classic_era',
  'wow_classic_era_ptr',
  'wow_classic_ptr',
}
local docs = {}
local enum = {}
for _, tag in ipairs(tags) do
  local tagdir = indir .. '/' .. tag
  local docdir = tagdir .. '/Interface/AddOns/Blizzard_APIDocumentation'
  for f in lfs.dir(docdir) do
    if f:sub(-4) == '.lua' then
      pcall(setfenv(loadfile(docdir .. '/' .. f), {
        APIDocumentation = {
          AddDocumentationTable = function(_, t)
            docs[f] = docs[f] or {}
            docs[f][tag] = t
          end,
        }
      }))
    end
  end
  local env = {}
  setfenv(loadfile(tagdir .. '/Interface/GlobalEnvironment.lua'), env)()
  for en in pairs(env.Enum) do
    enum[en] = true
  end
end
lfs.mkdir(outdir)
local types = {
  bool = 'b',
  number = 'n',
  string = 's',
  table = 't',
}
local tables = {
  Constants = 'n',
  Enumeration = 'n',
  Structure = 't',
}
local tys = {}
-- First pass for types.
for _, envt in pairs(docs) do
  for _, t in pairs(envt) do
    for _, ty in ipairs(t.Tables or {}) do
      local name = (t.Namespace and (t.Namespace .. '.') or '') .. ty.Name
      local c = assert(tables[ty.Type])
      local old = tys[name]
      if old then
        assert(old == c)
      else
        tys[name] = c
      end
    end
  end
end
local function insig(fn, ns)
  local inputs = ''
  local firstDefault = nil
  for i, a in ipairs(fn.Arguments or {}) do
    local c = types[a.Type] or (ns and tys[ns .. '.' .. a.Type]) or tys[a.Type] or (enum[a.Type] and 'n')
    if not c then
      print('unknown type ' .. a.Type)
      c = '?'
    end
    firstDefault = firstDefault or ((a.Default or a.Nilable) and i)
    inputs = inputs .. c
  end
  local t = {}
  if firstDefault then
    for i = firstDefault, inputs:len() do
      table.insert(t, inputs:sub(1, i-1))
    end
  end
  table.insert(t, inputs)
  return t
end
local omap = {
  b = 'bool',
  n = 'number',
  s = 'string',
  t = 'table',
}
local knownMixinStructs = {
  ColorMixin = 'Color',
  Vector2DMixin = 'Vector2D',
}
local function ret2ty(r, ns)
  local t = r.Type
  if r.Nilable then
    return 'nil'
  elseif enum[t] then
    return 'number'
  end
  local oty = omap[types[t] or (ns and tys[ns .. '.' .. t]) or tys[t]]
  if not oty then
    print('unknown type ' .. r.Type)
    return 'unknown'
  elseif oty == 'table' and r.Mixin then
    return knownMixinStructs[r.Mixin] or oty
  else
    return oty
  end
end
local expectedReturnKeys = {
  Default = true,
  Documentation = true,
  InnerType = true,
  Mixin = true,
  Name = true,
  Nilable = true,
  StrideIndex = true,
  Type = true,
}
local function outsig(fn, ns)
  local outputs = {}
  for _, r in ipairs(fn.Returns or {}) do
    for k in pairs(r) do
      assert(expectedReturnKeys[k], ('unexpected key %q'):format(k))
    end
    table.insert(outputs, {
      default = r.Default,
      innerType = r.InnerType,
      mixin = r.Mixin,
      name = r.Name,
      nilable = r.Nilable,
      type = ret2ty(r, ns),
    })
  end
  return outputs
end
local functions = {}
for f, envt in pairs(docs) do
  for env, t in pairs(envt) do
    if t.Name then
      assert(t.Type == 'System', f)
      for _, fn in ipairs(t.Functions or {}) do
        assert(fn.Type == 'Function', f)
        local name = (t.Namespace and (t.Namespace .. '.') or '') .. fn.Name
        functions[name] = functions[name] or {}
        functions[name][env] = fn
      end
    end
  end
end
require('tools.rewrite').yaml(function(api)
  if api.status ~= 'autogenerated' then
    return
  end
  local name = api.name
  local dotpos = name:find('%.')
  local ns = dotpos and name:sub(1, dotpos-1)
  local envfn = functions[name]
  if not envfn then
    return
  end
  local inputs = {}
  local outputs = nil
  for _, fn in pairs(envfn) do
    for _, input in ipairs(insig(fn, ns)) do
      inputs[input] = true
    end
    outputs = outputs or outsig(fn, ns)
  end
  local inlist = {}
  for input in pairs(inputs) do
    table.insert(inlist, input)
  end
  table.sort(inlist)
  return {
    name = name,
    status = 'autogenerated',
    inputs = #inlist == 1 and inlist[1] or inlist,
    outputs = outputs,
  }
end)
local expectedStructureKeys = {
  Name = true,
  Type = true,
  Fields = true,
  Documentation = true,
}
local expectedStructureFieldKeys = {
  Name = true,
  Nilable = true,
  Type = true,
  InnerType = true,
  Mixin = true,
  Documentation = true,
  Default = true,
}
local structures = {}
for f, envt in pairs(docs) do
  for _, t in pairs(envt) do
    for _, st in ipairs(t.Tables or {}) do
      if st.Type == 'Structure' then
        local name = (t.Namespace and (t.Namespace .. '.') or '') .. st.Name
        for k in pairs(st) do
          assert(expectedStructureKeys[k], ('unexpected structure key %q in %q'):format(k, f))
        end
        structures[name] = structures[name] or {
          name = name,
          status = 'autogenerated',
          fields = (function()
            local ret = {}
            for _, field in ipairs(st.Fields) do
              for k in pairs(field) do
                assert(expectedStructureFieldKeys[k], ('unexpected field key %q in %q'):format(k, f))
              end
              local ty = field.Type
              if ty == 'table' and field.Mixin then
                ty = knownMixinStructs[field.Mixin] or ty
              end
              table.insert(ret, {
                name = field.Name,
                nilable = field.Nilable,
                type = ty,
                innerType = field.InnerType,
                mixin = field.Mixin,
                default = field.Default,
              })
            end
            return ret
          end)(),
        }
      end
    end
  end
end
local writeFile = require('pl.file').write
local pprintYaml = require('wowapi.yaml').pprint
for k, v in pairs(structures) do
  writeFile('data/structures/' .. k .. '.yaml', pprintYaml(v))
end
