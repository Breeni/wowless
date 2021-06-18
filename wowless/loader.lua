local function loader(api, skipscripts, log, sink)

  local path = require('path')
  local xml = require('wowless.xml')
  local readFile = require('wowless.util').readfile

  local function loadLuaString(filename, str)
    sink(filename, assert(loadstring(str)))
  end

  local loadFile

  local function loadXml(filename)
    local dir = path.dirname(filename)

    local function loadKids(e, parent)
      for _, v in ipairs(e.kids) do
        if v.name == 'include' then
          assert(v.attr.file and #v.kids == 0)
          loadFile(path.join(dir, v.attr.file))
        elseif v.name == 'scopedmodifier' then
          -- TODO support ScopedModifier attributes
          loadKids(v, parent)
        elseif v.name == 'frames' then
          loadKids(v, parent)
        elseif api.IsIntrinsicType(v.name) then
          local obj = api:CreateUIObject({
            inherits = v.attr.inherits or {},
            intrinsic = v.attr.intrinsic,
            name = v.attr.name,
            parent = parent,
            type = v.name,
            virtual = v.attr.virtual,
          })
          loadKids(v, obj)
        elseif not skipscripts and v.name == 'script' then
          if v.attr.file then
            assert(#v.kids == 0)
            loadFile(path.join(dir, v.attr.file))
          else
            for _, x in ipairs(v.kids) do
              loadLuaString(filename, x)
            end
          end
        else
          log(1, 'skipping ' .. filename .. ' ' .. v.name)
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
