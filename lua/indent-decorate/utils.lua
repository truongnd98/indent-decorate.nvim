local M = {}

---@param group string|string[] hl group to get color from
---@param prop? string property to get. Defaults to "fg"
function M.color(group, prop)
  prop = prop or "fg"
  group = type(group) == "table" and group or { group }
  ---@cast group string[]
  for _, g in ipairs(group) do
    local hl = vim.api.nvim_get_hl(0, { name = g, link = false })
    if hl[prop] then
      return string.format("#%06x", hl[prop])
    end
  end
end

--- Redraw the range of lines in the window.
--- Optimized for Neovim >= 0.10
---@param win number
---@param from number -- 1-indexed, inclusive
---@param to number -- 1-indexed, inclusive
function M.redraw_range(win, from, to)
  if vim.api.nvim__redraw then
    vim.api.nvim__redraw({ win = win, range = { math.floor(from - 1), math.floor(to) }, valid = true, flush = false })
  else
    vim.cmd([[redraw!]])
  end
end

--- Parse async when available.
---@param parser vim.treesitter.LanguageTree
---@param range boolean|Range|nil: Parse this range in the parser's source.
---@param on_parse fun(err?: string, trees?: table<integer, TSTree>) Function invoked when parsing completes.
function M.parse(parser, range, on_parse)
  ---@diagnostic disable-next-line: invisible
  local have_async = (vim.treesitter.languagetree or {})._async_parse ~= nil
  if have_async then
    parser:parse(range, on_parse)
  else
    parser:parse(range)
    on_parse(nil, parser:trees())
  end
end

--- Get a buffer or global variable.
---@generic T
---@param buf? number
---@param name string
---@param default? T
---@return T
function M.var(buf, name, default)
  local ok, ret = pcall(function()
    return vim.b[buf or 0][name]
  end)
  if ok and ret ~= nil then
    return ret
  end
  ret = vim.g[name]
  if ret ~= nil then
    return ret
  end
  return default
end

local langs = {} ---@type table<string, boolean>

---@param lang string|number|nil
---@overload fun(buf:number):string?
---@overload fun(ft:string):string?
---@return string?
function M.get_lang(lang)
  lang = type(lang) == "number" and vim.bo[lang].filetype or lang --[[@as string?]]
  lang = lang and vim.treesitter.language.get_lang(lang) or lang
  if lang and lang ~= "" and langs[lang] == nil then
    local ok, ret = pcall(vim.treesitter.language.add, lang)
    langs[lang] = (ok and ret) or (ok and vim.fn.has("nvim-0.11") == 0)
  end
  return langs[lang] and lang or nil
end

return M
