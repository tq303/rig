-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Prevent <Space> from acting as a motion in visual mode so leader sequences work
vim.keymap.set("x", "<Space>", "<Nop>")

-- buffers
--
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bD", ":bdelete!<CR>", { desc = "Force delete buffer" })
vim.keymap.set("n", "<leader>bl", ":FzfLua buffers<CR>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>bn", ":enew<CR>", { desc = "New buffer" })
vim.keymap.set("n", "<leader>bs", function()
	local name = vim.fn.input("Save as: ")
	if name ~= "" then
		vim.cmd("w " .. name)
	end
end, { desc = "Save buffer" })

-- files
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>ff", ":FzfLua files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fs", ":FzfLua live_grep<CR>", { desc = "Search (ripgrep)" })
vim.keymap.set("x", "<leader>fs", function()
  local from = vim.fn.getpos("'<")
  local to = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_text(0, from[2] - 1, from[3] - 1, to[2] - 1, to[3], {})
  require("fzf-lua").live_grep({ search = table.concat(lines, "\n") })
end, { desc = "Search selection (ripgrep)" })
vim.keymap.set("n", "<leader>fr", ":FzfLua oldfiles<CR>", { desc = "Recent files" })
vim.keymap.set("n", "<leader>fg", ":GrugFar<CR>", { desc = "Find and replace" })
vim.keymap.set("x", "<leader>fg", function()
  require("grug-far").with_visual_selection()
end, { desc = "Find and replace selection" })

-- misc
vim.keymap.set("n", "<leader>l", ":Lazy<CR>", { desc = "Lazy" })
vim.keymap.set("n", "<leader>m", ":Mason<CR>", { desc = "Mason" })
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save" })

-- code
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gw", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      vim.api.nvim_win_close(win, false)
      return
    end
  end
  vim.diagnostic.open_float()
end, { desc = "Show line diagnostics" })
vim.keymap.set("n", "gh", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      vim.api.nvim_win_close(win, false)
      return
    end
  end
  vim.lsp.buf.hover()
end, { desc = "Hover (type info)" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>cf", function()
	require("conform").format({ async = true })
end, { desc = "Format" })

-- quit
vim.keymap.set("n", "<leader>qq", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>qa", ":qa<CR>", { desc = "Quit all" })

-- save
vim.keymap.set({ "n", "i" }, "<C-s>", function()
	vim.cmd("w")
	vim.notify("saved", vim.log.levels.INFO, { title = "file" })
end, { desc = "Save" })

-- move lines
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Indentation (global)
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 2 -- Indent width (used by >>, <<, etc.)
vim.opt.tabstop = 2 -- How many spaces a <Tab> counts for
vim.opt.softtabstop = 2 -- How many spaces <Tab>/<BS> use in Insert mode
vim.opt.smartindent = true -- Auto-indent new lines intelligently
vim.opt.autoindent = true -- Copy indent from current line when starting a new one
vim.opt.autoread = true -- Reload files changed outside nvim
vim.opt.updatetime = 300 -- Faster CursorHold → checktime
vim.schedule(function()
	if os.getenv("SSH_TTY") then
		vim.g.clipboard = {
			name = "OSC 52",
			copy = {
				["+"] = require("vim.ui.clipboard.osc52").copy("+"),
				["*"] = require("vim.ui.clipboard.osc52").copy("*"),
			},
			paste = {
				["+"] = require("vim.ui.clipboard.osc52").paste("+"),
				["*"] = require("vim.ui.clipboard.osc52").paste("*"),
			},
		}
	else
		vim.opt.clipboard = "unnamedplus"
	end
end)
vim.opt.number = true
vim.opt.relativenumber = true

vim.api.nvim_set_hl(0, "MsgArea", { fg = "#7aa2f7" })
vim.api.nvim_create_autocmd("CmdlineEnter", {
	callback = function()
		vim.api.nvim_set_hl(0, "MsgArea", { fg = "#c0caf5", bg = "#3b3f4c", bold = true })
	end,
})
vim.api.nvim_create_autocmd("CmdlineLeave", {
	callback = function()
		vim.api.nvim_set_hl(0, "MsgArea", { fg = "#7aa2f7" })
	end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { link = "@markup.heading.2.markdown" })
		vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", { link = "@markup.heading.2.markdown" })
		vim.api.nvim_set_hl(0, "@markup.heading.5.markdown", { link = "@markup.heading.2.markdown" })
		vim.api.nvim_set_hl(0, "@markup.heading.6.markdown", { link = "@markup.heading.2.markdown" })
	end,
})

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{ "echasnovski/mini.icons", opts = {} },
		{
			"akinsho/bufferline.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			opts = {
				options = {
					separator_style = "slant",
					show_buffer_close_icons = true,
					show_close_icon = false,
					diagnostics = "nvim_lsp",
				},
			},
		},
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {
				preset = "helix",
				spec = {
					{ "<leader>b", group = "buffer" },
					{ "<leader>f", group = "file", mode = { "n", "x" } },
					{ "<leader>w", group = "window" },
					{ "<leader>q", group = "quit/session" },
					{ "<leader>c", group = "code" },
					{ "g", group = "goto/surround" },
					{ "gd", desc = "definition" },
					{ "gh", desc = "hover" },
					{ "gw", desc = "diagnostics" },
					{ "gs", desc = "surround" },
				},
			},
		},
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			main = "nvim-treesitter.config",
			opts = {
				ensure_installed = {
					"bash",
					"go",
					"gomod",
					"gowork",
					"html",
					"javascript",
					"typescript",
					"tsx",
					"json",
					"lua",
					"markdown",
					"markdown_inline",
					"yaml",
				},
				highlight = { enable = true },
				indent = { enable = true },
			},
		},
		{
			"nvim-tree/nvim-tree.lua",
			cmd = "NvimTreeToggle",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			config = function()
				require("nvim-tree").setup({
					filters = {
						dotfiles = false,
					git_ignored = false,
					},
				})
			end,
		},
		-- dashboard (via snacks.nvim, configured below)

		{
			"ibhagwan/fzf-lua",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			opts = {
				grep = {
					rg_opts = "--hidden --glob '!.git' --column --line-number --no-heading --color=always",
				},
			},
		},
		{
			"saghen/blink.cmp",
			version = "1.*",
			opts = {
				keymap = {
					preset = "default",
					["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
					["<CR>"] = { "accept", "fallback" },
					["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
				},
				completion = {
					list = { selection = { preselect = true, auto_insert = false } },
				},
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
				},
			},
		},
		{
			"williamboman/mason.nvim",
			config = function()
				require("mason").setup()
				local registry = require("mason-registry")
				for _, tool in ipairs({ "shfmt", "yamlfmt", "stylua", "clang-format" }) do
					if not registry.is_installed(tool) then
						registry.get_package(tool):install()
					end
				end
			end,
		},
		{
			"williamboman/mason-lspconfig.nvim",
			dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig", "saghen/blink.cmp" },
			config = function()
				local capabilities = require("blink.cmp").get_lsp_capabilities()
				require("mason-lspconfig").setup({
					ensure_installed = { "gopls", "ts_ls", "lua_ls" },
					handlers = {
						function(server)
							require("lspconfig")[server].setup({ capabilities = capabilities })
						end,
					},
				})
			end,
		},
		{
			"mg979/vim-visual-multi",
			init = function()
				vim.g.VM_maps = {
					["Append"] = "a",
					["I Append"] = "A",
					["I Insert"] = "I",
				}
			end,
		},
		{ "MagicDuck/grug-far.nvim", opts = {} },
		{
			"stevearc/conform.nvim",
			opts = {
				formatters_by_ft = {
					javascript = { "oxfmt" },
					typescript = { "oxfmt" },
					javascriptreact = { "oxfmt" },
					typescriptreact = { "oxfmt" },
					json = { "oxfmt" },
					markdown = { "oxfmt" },
					go = { "goimports", "gofmt" },
					sh = { "shfmt" },
					bash = { "shfmt" },
					yaml = { "yamlfmt" },
					lua = { "stylua" },
				},
				format_on_save = { timeout_ms = 500 },
			},
		},
		{
			"folke/snacks.nvim",
			opts = {
				notifier = {
					position = "top-right",
				},
				dashboard = {
					preset = {
						header = [[
⠀⠀⠀⠀⠀⠀⠀⠄⣀⠢⢀⣤⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⡔⢀⠂⡜⢭⢻⣍⢯⡻⣝⣿⣿⡿⣟⠂
⠀⠀⠀⠀⠀⠀⠀⠄⠀⣦⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡔⡀⢂⠜⣪⢗⡾⣶⡽⣾⣟⣯⠛⠀⠀
⠀⠀⠀⠀⠀⠄⠀⠠⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣔⠨⡸⡝⣯⣳⢏⣿⠳⠉⠀⢠⣬⡶
⠠⣓⢤⣂⣄⣀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠁⣞⡱⣝⠎⠀⢀⠠⣥⠳⡞⡹
⠀⡄⢉⠲⢿⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡔⣧⡽⠋⠀⣰⣶⣻⣶⣿⢾⣷
⢤⡈⠉⠲⢤⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⢀⡴⢏⡳⢮⡿⣽⣞⠻⡜
⠒⣭⠳⢶⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⡙⠮⣜⣯⡽⣳⢌⡓⠈
⡸⣰⢋⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣻⢿⣻⣿⡽⣗⠋⠄⠀
⠣⢇⢟⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⢟⡿⢣⣟⡻⠘⠀⠀⠀
⠱⡊⠤⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠨⠗⠋⣁⣤⠖⠊⢁⣀
⠀⠁⠂⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⠀⠀⣿⡂⠹⣿⣿⣿⣿⣿⠙⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠄⠒⢋⣉⡤⣔⣮⣽⣾
⢢⠣⣌⢼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⢰⣿⡅⠀⣿⣿⣿⣿⣿⠀⠸⢿⣹⣿⣿⣿⣿⣿⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣻⣿⣿⣿⣿⣿⣿⣿
⢃⡉⠠⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣼⢹⠀⠀⠀⠀⣾⠿⡇⠀⣿⣿⣿⣿⡏⠀⠀⣞⣧⣻⠟⢿⣿⣿⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣧⠱⣌⣳⣽⣻⣿⣿⣻
⠀⢒⡕⣺⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⡇⠈⣇⠀⠀⠀⠈⡆⢳⠀⠇⡟⠋⠉⠀⠀⠀⠃⢙⣠⣤⣤⣼⣯⣚⣟⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠌⠑⠌⢳⠛⡛⠏⠛⠉
⡘⢷⣌⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠉⢻⣀⣧⣤⣽⣦⣤⣄⠀⠰⡀⠃⠀⠀⠀⠀⠀⠀⡴⠟⠛⣉⣉⡉⠉⠈⠉⠉⠉⠋⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⢈⠈⠈⠁⠛⠀⠀⠀⣒
⠉⢣⡛⣿⣿⣿⣿⣿⣿⣿⣿⣿⡧⠖⠛⠉⠉⠉⠀⠀⠐⠒⢢⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡾⣠⣲⣾⣿⢿⣷⢶⡄⠀⠀⣽⣿⣿⣿⣿⡿⠟⣿⣿⣿⣿⣿⠛⢁⣤⡶⠿⠛⠋
⠀⠀⠌⢽⣿⣿⣿⣿⣿⣿⣿⣿⡷⠀⠀⠀⣠⣶⣶⣿⣟⣿⣶⡅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠃⢿⣿⣿⣿⣿⠀⣿⡀⠀⢻⣬⣙⡻⡿⣡⣾⣿⣿⡍⠈⣀⣤⣬⣤⣶⣲⣶⣿
⠀⢈⠐⡀⢻⣫⢿⣿⣿⣿⣿⠘⢧⠁⠀⣻⡏⠸⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⢄⣉⣛⣋⣡⡴⠃⠀⠀⣿⣿⣿⠟⣠⡛⢿⣿⣿⣷⣲⣽⣿⣿⣷⣾⣷⣿⣿
⠀⠀⢀⠐⡀⢃⡈⣿⢿⣿⣿⣟⡆⠀⠀⠉⠿⣦⣈⣉⣉⠤⠚⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡟⣡⣶⣿⣿⣾⣿⣿⣿⢿⡿⣿⣿⡿⠿⠛⣋⣡
⠠⠐⡀⢢⣶⣿⢧⠻⣯⣿⣯⡛⢿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⠘⠐⠂⡁⠤⠔⢂⣉⣤⡴
⣀⠥⠌⣳⢯⣟⣮⣗⣾⣟⣿⣿⣦⣭⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⠂⣈⠥⡔⡤⣍⠣⣝⢾⡹
⠀⠀⠀⠠⠈⠉⠈⠉⠉⠉⣨⣿⣿⣿⣯⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⡟⠻⢞⣿⣝⣳⢎⢳⢻⡮⣕
⠀⠀⢀⠀⡀⠀⠀⣀⣴⣾⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⡗⢠⠘⡼⣽⣛⡞⠦⣧⢻⣽
⠀⢈⠀⡀⡀⢤⠞⡉⢭⣹⣿⣿⣿⣿⣿⣿⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣟⣿⣍⣣⢾⣵⣯⣷⣽⣦⣑⣯⢿
⠀⠂⣴⣾⡟⣧⠊⡔⢢⠛⣿⣿⣿⣿⣿⣿⣿⣿⣷⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠒⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⠉⣯⢹⣽⢻⣿⣿⣿⣿⣿⣿⣿⣿
⣶⣟⠳⣏⡿⣎⠳⣈⡜⣺⣿⠿⢿⣝⡿⣫⢟⣽⣿⣿⠻⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠛⣿⠿⣟⢩⢾⣿⣿⣿⣿⣇⠾⣜⡧⣯⣟⣿⣿⣿⣿⣿⣿⣿⣿
⠋⢀⢱⣫⣟⢾⡹⢴⡸⣵⡏⣂⢾⡿⣽⣹⣟⣾⣿⡟⢠⡇⠀⣹⠂⠄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣷⣣⢟⡿⣾⣿⣿⣿⣿⢌⠫⢝⡻⣵⢻⡟⣿⢿⣿⢿⡿⣿⠿
⠀⢢⠞⣴⢯⢯⣝⣦⢳⡝⡶⣭⣿⣽⣳⣟⡾⣽⡟⢀⡟⠀⢀⡿⠀⠀⠀⠁⠠⠤⠀⠀⠀⠤⠐⠀⠀⠀⠀⠀⠀⠀⢸⡗⠈⠭⣿⣿⣿⣿⡿⢌⠣⡀⡐⢈⠃⠚⠦⣉⠂⠣⠜⡄⢋
⣜⣷⢻⡜⣯⣾⡞⣥⣓⢾⡽⢎⡷⢯⡷⣯⢟⣽⠃⣸⠁⠀⡼⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡄⢹⣿⣿⣿⣿⢃⡮⡑⢰⢠⣂⡜⣦⡴⣱⣎⣴⣩⡜⣦
⣿⣯⢷⡻⣏⣷⣟⠶⣙⠮⡙⢪⠜⣯⢽⣯⣿⠃⠄⢃⣠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣾⣿⣿⣿⡇⠢⢡⡙⢦⡓⡼⣽⣾⣿⣿⣿⣿⣷⣿⣿
⣿⡹⢇⡳⡹⣞⠘⡈⢅⠢⢁⠂⡘⠤⣋⣶⣡⠴⠚⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⠰⡁⢆⠘⣡⠻⣽⣳⣿⣿⣿⣿⢿⣿⣿⣿
⢣⠝⡢⢍⠱⢈⣂⣌⡤⠦⠶⠶⠞⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⠛⠷⣭⣂⠌⢠⠓⡴⣻⣿⣿⣿⣿⣿⣿⣯⣿
⣇⢾⡱⠞⠈⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⡇⠀⠀⠀⠉⠛⠳⠿⣶⣽⣿⣿⣿⣿⣿⣿⣿⣿
						]],
					},
					sections = {
						{ section = "header" },
						{ section = "keys", gap = 1 },
						{ section = "recent_files", limit = 5, title = "Recent Files", gap = 1 },
						{ section = "startup" },
					},
					keys = {
						{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
						{
							icon = " ",
							key = "g",
							desc = "Find Text",
							action = ":lua Snacks.dashboard.pick('live_grep')",
						},
						{
							icon = " ",
							key = "r",
							desc = "Recent Files",
							action = ":lua Snacks.dashboard.pick('oldfiles')",
						},
						{ icon = " ", key = "s", desc = "Restore Session", action = ":lua require('persistence').load()" },
						{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
						{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
					},
				},
			},
		},
		{
			"folke/tokyonight.nvim",
			priority = 1000,
			config = function()
				vim.cmd.colorscheme("tokyonight")
				vim.api.nvim_set_hl(0, "Visual", { bg = "#164a5c", fg = "#7dcfff" })
			end,
		},
		{
			"folke/persistence.nvim",
			event = "BufReadPre",
			opts = {},
		},
		{
			"kylechui/nvim-surround",
			event = "VeryLazy",
			config = function()
				require("nvim-surround").setup()
				vim.keymap.set({ "n", "x" }, "gs", "<Plug>(nvim-surround-normal)")
			end,
		},
	},
	install = { colorscheme = { "tokyonight", "habamax" } },
	checker = { enabled = true, notify = false },
})
