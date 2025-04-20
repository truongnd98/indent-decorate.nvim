local id_indent = require("indent-decorate.indent")
local id_scope = require("indent-decorate.scope")
local id_animate = require("indent-decorate.animate")

local M = {}

---@param conf? { indent?: indent.Config, scope?: scope.Config, animate?: animate.Config }
function M.setup(conf)
  local opts = conf or {}

  id_animate.setup(opts.animate)
  id_scope.setup(opts.scope)
  id_indent.setup(opts.indent)
  id_indent.enable()
end

return M
