describe('loader', function()
  local loader = require('wowless.loader')
  it('loads', function()
    local api = loader.run(0)
    assert.same(106, api.GetErrorCount())
  end)
end)
