describe('runner', function()
  local runner = require('wowless.runner')
  it('loads', function()
    local api = runner.run(0)
    assert.same(107, api.GetErrorCount())
  end)
end)
