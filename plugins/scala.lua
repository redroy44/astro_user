return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astronvim.utils").list_insert_unique(opts.ensure_installed, "scala")
      end
    end,
  },
  { "derekwyatt/vim-scala" },
  {
    "scalameta/nvim-metals",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap"
    },
    ft = { "scala", "sbt", "java" },
    init = function() astronvim.lsp.skip_setup = require("astronvim.utils").list_insert_unique(astronvim.lsp.skip_setup, { "scala", "sbt", "java" }) end,
    -- init = function()
    --   vim.api.nvim_create_autocmd("FileType", {
    --     pattern = { "scala", "sbt", "java" },
    --     callback = function() require("metals").initialize_or_attach(require("astronvim.utils.lsp").config "metals") end,
    --     group = vim.api.nvim_create_augroup("nvim-metals", { clear = true }),
    --   })
    -- end,
    opts = {
    },
    config = function(_, opts)
      local metals = require "metals"
      local metals_config = metals.bare_config()

      metals_config.settings = {
        showImplicitArguments = true,
        showInferredType = true,
        testUserInterface = "Test Explorer",
        excludedPackages = {
          'akka.actor.typed.javadsl',
          'com.github.swagger.akka.javadsl'
        }
      }
      metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()
      metals_config.init_options.statusBarProvider = "on"

      local dap = require('dap')
      dap.defaults.fallback.force_external_terminal = true
    
      dap.configurations.scala = {
        {
          type = "scala",
          request = "launch",
          name = "Run or Test Target",
          metals = {
            runType = "runOrTestFile",
          },
        },
        {
          type = "scala",
          request = "launch",
          name = "Test Target",
          metals = {
            runType = "testTarget",
          },
        },
      }

      metals_config.on_attach = function(client, bufnr) 
          require("astronvim.utils.lsp").on_attach(client, bufnr) 
          require('metals').setup_dap()
        end,

      vim.api.nvim_create_autocmd("Filetype", {
        pattern = { "scala", "sbt", "java" }, -- autocmd to start metals
        callback = function() require("metals").initialize_or_attach(metals_config) end,
      })
    end,
  },
}