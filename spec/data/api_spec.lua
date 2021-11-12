describe('api', function()
  local data = require('wowapi.data')
  local yaml = require('wowapi.yaml')
  for filename in require('lfs').dir('data/api') do
    if filename ~= '.' and filename ~= '..' then
      assert(filename:sub(-5) == '.yaml', 'invalid file ' .. filename)
      describe(filename, function()
        local str do
          local file = io.open('data/api/' .. filename, 'r')
          str = file:read('*all')
          file:close()
        end
        local t = yaml.parse(str)
        it('is formatted correctly', function()
          assert.same(str, yaml.pprint(t))
        end)
        it('has the right name', function()
          assert.same(filename:sub(1, -6), t.name)
        end)
        it('has a valid status', function()
          local valid = {
            autogenerated = true,
            implemented = true,
            stub = true,
            unimplemented = true,
          }
          assert.Not.Nil(t.status, 'missing status')
          assert.True(valid[t.status], ('invalid status %q'):format(t.status))
        end)
        it('has a valid version list', function()
          local valid = {
            Vanilla = true,
            TBC = true,
            Mainline = true,
          }
          if t.versions then
            assert.True(#t.versions > 0, 'empty version list')
            for _, v in ipairs(t.versions) do
              assert.True(valid[v], ('invalid version %q'):format(v))
            end
          end
        end)
        it('has a valid protection', function()
          local valid = {
            hardware = true,
            secure = true,
          }
          assert.True(t.protection == nil or valid[t.protection])
        end)
        it('has valid inputs', function()
          local ty = type(t.inputs)
          if ty == 'table' then
            for _, v in ipairs(t.inputs) do
              assert.True(type(v) == 'string')
            end
          else
            assert.True(ty == 'string' or ty == 'nil')
          end
        end)
        it('has valid outputs', function()
          local fields = {
            default = true,
            innerType = true,
            mixin = true,
            name = true,
            nilable = true,
            type = true,
          }
          local types = {
            bool = true,
            ['nil'] = true,
            number = true,
            oneornil = true,
            string = true,
            table = true,
            unknown = true,
          }
          local ty = type(t.outputs)
          if ty ~= 'nil' then
            assert.True(ty == 'table')
            for _, v in ipairs(t.outputs) do
              assert.True(type(v) == 'table')
              for k in pairs(v) do
                assert.True(fields[k])
              end
              local ot = assert(v.type)
              assert.True(type(ot) == 'string')
              assert.truthy(types[ot] or data.structures[ot], ('invalid type %q'):format(ot))
              assert.True(v.mixin == nil or type(v.mixin) == 'string')
            end
          end
        end)
        it('has no extraneous fields', function()
          local fields = {
            comment = true,
            inputs = true,
            name = true,
            outputs = true,
            protection = true,
            returns = true,
            states = true,
            status = true,
            versions = true,
          }
          for k in pairs(t) do
            assert.True(fields[k], ('unexpected field %q'):format(k))
          end
        end)
        it('has exactly one implementation', function()
          if t.status == 'autogenerated' or t.status == 'unimplemented' then
            assert.Nil(t.states, 'unimplemented apis cannot specify states')
            assert.Nil(t.returns, 'unimplemented apis cannot specify return values')
            assert.Nil(data.impl[t.name], 'unimplemented apis cannot have an implementation')
          elseif t.status == 'stub' then
            assert.Nil(t.states, 'stub apis cannot specify states')
            assert.same('table', type(t.returns), 'stub apis must specify return value table')
            assert.Nil(data.impl[t.name], 'stub apis cannot have an implementation')
          elseif t.status == 'implemented' then
            assert.Nil(t.returns, 'implemented apis cannot specify return values')
            assert.Not.Nil(data.impl[t.name], 'implemented apis must have an implementation')
            for _, st in ipairs(t.states or {}) do
              assert.truthy(data.state[st] or st == 'env', 'states must be valid')
            end
          else
            error('unsupported status')
          end
        end)
      end)
    end
  end
end)
