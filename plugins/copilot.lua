return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "User AstroFile",
    opts = { suggestion = { enabled = false }, panel = { enabled = false } },
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = {
      "zbirenbaum/copilot.lua",
    },
    config = function()
      require("copilot_cmp").setup()
    end
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    opts = function(_, opts)
      local cmp = require "cmp"

      local has_words_before = function()
        if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
      end

      return require("astronvim.utils").extend_tbl(opts, {
        sources = cmp.config.sources {
          { name = "copilot",  priority = 1000 },
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          { name = "buffer",   priority = 500 },
          { name = "path",     priority = 250 },
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            require("copilot_cmp.comparators").prioritize,

            -- Below is the default comparitor list and order for nvim-cmp
            cmp.config.compare.offset,
            -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
          mapping = {
            -- tab complete
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() and has_words_before() then
                cmp.confirm { select = true }
              else
                fallback()
              end
            end, { "i", "s" }),
          }
        }
      })
    end
  },
  {
    "onsails/lspkind.nvim",
    opts = function(_, opts)
      opts.symbol_map = {
        Copilot = "",
      }

      vim.api.nvim_set_hl(0, "CmpItemKindCopilot", {fg ="#6CC644"})

      return opts
    end
  }
}
