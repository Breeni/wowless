local function loader(api, skipscripts, log, sink)

  local path = require('path')
  local xml = require('wowless.xml')
  local util = require('wowless.util')
  local readFile, mixin = util.readfile, util.mixin

  local function loadLuaString(filename, str)
    sink(filename, assert(loadstring(str)))
  end

  local loadFile

  local function loadXml(filename)
    local dir = path.dirname(filename)

    local loadElement

    local function loadKids(e, parent)
      for _, v in ipairs(e.kids) do
        loadElement(v, parent)
      end
    end

    local xmllang = {
      frames = function(e, parent)
        loadKids(e, parent)
      end,
      include = function(e)
        assert(e.attr.file and #e.kids == 0)
        loadFile(path.join(dir, e.attr.file))
      end,
      scopedmodifier = function(e, parent)
        loadKids(e, parent)
      end,
      script = function(e)
        if not skipscripts then
          if e.attr.file then
            assert(#e.kids == 0)
            loadFile(path.join(dir, e.attr.file))
          else
            for _, s in ipairs(e.kids) do
              loadLuaString(filename, s)
            end
          end
        end
      end,
    }

    function loadElement(e, parent)
      if api:IsIntrinsicType(e.name) then
        local inherits = {e.name}
        for _, inh in ipairs(e.attr.inherits or {}) do
          table.insert(inherits, string.lower(inh))
        end
        local mix = {}
        for _, m in ipairs(e.attr.mixin or {}) do
          mixin(mix, api.env[m])
        end
        local virtual = e.attr.virtual
        if e.attr.intrinsic then
          assert(virtual ~= false, 'intrinsics cannot be explicitly non-virtual: ' .. e.name)
          virtual = true
        end
        if virtual then
          assert(e.attr.name, 'cannot create anonymous virtual uiobject')
          local name = string.lower(e.attr.name)
          if api.uiobjectTypes[name] then
            api.log(0, 'overwriting uiobject type ' .. e.attr.name)
          end
          api.uiobjectTypes[name] = {
            constructor = function(obj)
              loadKids(e, obj)
            end,
            inherits = inherits,
            intrinsic = e.attr.intrinsic,
            mixin = mix,
            name = e.attr.name,
          }
        else
          local name = e.attr.name
          if name and string.match(name, '$parent') then
            local p = parent
            while p ~= nil and not p:GetName() do
              p = p:GetParent()
            end
            assert(p, '$parent substitution requires a parent name: ' .. name)
            name = string.gsub(name, '$parent', p:GetName())
          end
          local obj = api:CreateUIObject(e.name, name, parent, inherits)
          mixin(obj, mix)
          loadKids(e, obj)
        end
      else
        local fn = xmllang[e.name]
        if fn then
          fn(e, parent)
        else
          log(1, 'skipping ' .. filename .. ' ' .. e.name)
        end
      end
    end

    local root = xml.validate(filename)
    assert(root.name == 'ui')
    loadKids(root)
  end

  function loadFile(filename)
    log(2, 'loading file %s', filename)
    if filename:sub(-4) == '.lua' then
      loadLuaString(filename, readFile(filename))
    elseif filename:sub(-4) == '.xml' then
      return loadXml(filename)
    else
      error('unknown file type ' .. filename)
    end
  end

  local function loadToc(toc)
    local dir = path.dirname(toc)
    for line in io.lines(toc) do
      line = line:match('^%s*(.-)%s*$')
      if line ~= '' and line:sub(1, 1) ~= '#' then
        loadFile(path.join(dir, line))
      end
    end
  end

  return loadToc
end

local function run(loglevel, skipscripts)
  local function log(level, fmt, ...)
    if level <= loglevel then
      print(string.format(fmt, ...))
    end
  end
  local env, api = require('wowless.env').new(log)
  local sink = function(filename, lua)
    local success, err = pcall(setfenv(lua, env))
    assert(success, 'failure in ' .. filename .. ': ' .. tostring(err))
  end
  local toc = require('datafile').path('wowui/classic/FrameXML/FrameXML.toc')
  loader(api, skipscripts, log, sink)(toc)
  return env
end

return {
  run = run,
}
