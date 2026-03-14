-- Options

vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.clipboard = "unnamedplus"
vim.opt.showmatch = true
vim.opt.matchtime = 0
vim.opt.cmdheight = 0
vim.opt.laststatus = 3
vim.opt.termguicolors = true
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"

-- Pre-plugin config

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

--- Simple editor binding
vim.keymap.set("n", "<leader>w", vim.cmd.w, { noremap = true, silent = true, desc = "Save" })
vim.keymap.set("n", "<leader>q", vim.cmd.q, { noremap = true, silent = true, desc = "Quit" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { silent = true, noremap = true })

--- Custom keybinds
vim.keymap.set("n", "<leader>c", "<cmd>bdelete<CR>", { noremap = true, silent = true, desc = "Close buffer" })
vim.keymap.set("n", "<leader>rp", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Find and Replace" })
vim.keymap.set("n", "<leader>ta", ":$tabnew<CR>", { noremap = true, silent = true, desc = "New tab" })
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { noremap = true, silent = true, desc = "Close tab" })
vim.keymap.set("n", "<leader>to", ":tabonly<CR>", { noremap = true, silent = true, desc = "Only tab" })
vim.keymap.set("n", "<leader>tn", ":tabn<CR>", { noremap = true, silent = true, desc = "Next tab" })
vim.keymap.set("n", "<leader>tp", ":tabp<CR>", { noremap = true, silent = true, desc = "Prev tab" })
vim.keymap.set("n", "<leader>gec", ":e ~/.config/nvim/init.lua<CR>", { noremap = true, silent = true })

-- QoL fixes
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { silent = true, desc = "Copy to clipboard" })

-- Plugins

vim.pack.add({
	{ src = "https://github.com/folke/tokyonight.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/SmiteshP/nvim-navic" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim.git" },
	{ src = "https://github.com/neovim/nvim-lspconfig.git" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/windwp/nvim-autopairs" },
	{ src = "https://github.com/nvim-mini/mini.nvim" },
	{ src = "https://github.com/ThePrimeagen/harpoon" },
	{ src = "https://github.com/Saghen/blink.cmp", version = "v1.6.0" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/tpope/vim-fugitive" },
	{ src = "https://github.com/malewicz1337/oil-git.nvim" },
	{ src = "https://github.com/chenasraf/text-transform.nvim" },
})

-- Post plugin config

vim.cmd.colorscheme("tokyonight")

require("nvim-treesitter").setup({
	ensure_installed = { "all" },
})
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		pcall(vim.treesitter.start)
	end,
})

--- So that the lualine color doesn't change during insert mode.
---
local theme = require("lualine.themes.auto")
local a_fixed = vim.deepcopy(theme.normal.a)
local navic = require("nvim-navic")
theme.insert.a = a_fixed
theme.visual.a = a_fixed
theme.replace.a = a_fixed
theme.command.a = a_fixed
theme.terminal.a = a_fixed
theme.inactive.a = a_fixed
require("lualine").setup({
	options = {
		theme = theme,
	},
	sections = {
		lualine_c = {
			{
				function()
					local ok, navic = pcall(require, "nvim-navic")
					if not ok then
						return ""
					end
					if not navic.is_available() then
						return ""
					end
					return navic.get_location()
				end,
			},
		},
	},
})

require("mason").setup()

vim.filetype.add({
	extension = {
		m = "objc",
		mm = "objcpp",
	},
})

vim.lsp.enable("basedpyright")
vim.lsp.enable("lua_la")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("clangd")

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		local opts = { noremap = true, silent = true }
		vim.keymap.set("n", "<leader>.", function()
			vim.lsp.buf.code_action({
				filter = function(action)
					return not action.disabled
				end,
			})
		end, opts)
		vim.keymap.set("n", "<leader>k", function()
			vim.lsp.buf.definition()
		end, opts)
		vim.keymap.set("n", "<leader>m", function()
			vim.diagnostic.goto_next()
		end, opts)
		vim.keymap.set("n", "<leader>l", function()
			vim.lsp.buf.hover()
		end, opts)
		client.server_capabilities.semanticTokensProvider = nil
	end,
})

require("oil").setup()
require("oil-git").setup()
vim.keymap.set("n", "<leader>i", "<CMD>Oil<CR>", { noremap = true, silent = true, desc = "Open parent directory" })

require("text-transform").setup({
	keymap = {
		telescope_popup = nil,
	},
})
vim.keymap.set({ "n", "v" }, "<leader>rs", ":TtSnake<CR>", { silent = true, desc = "To snake_case" })

require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<Tab>"] = {
			function(cmp)
				if cmp.snippet_active() then
					return cmp.accept()
				else
					return cmp.select_and_accept()
				end
			end,
			"snippet_forward",
			"fallback",
		},
		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
	},
	appearance = {
		nerd_font_variant = "mono",
	},
	sources = {
		default = { "lsp", "path", "buffer" },
	},
	fuzzy = { implementation = "prefer_rust_with_warning" },
})

local builtin = require("telescope.builtin")
require("telescope").setup({
	pickers = {
		buffers = {
			initial_mode = "normal",
		},
		bookmarks = {
			initial_mode = "normal",
		},
	},
})

vim.keymap.set("n", "<leader>p", builtin.find_files, {})
vim.keymap.set("n", "<leader>sf", builtin.git_files, {})
vim.keymap.set("n", "<leader>ss", builtin.lsp_dynamic_workspace_symbols, {})
vim.keymap.set("n", "<leader>o", builtin.lsp_document_symbols, {})
vim.keymap.set("n", "<leader>sg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sb", builtin.buffers, {})
vim.keymap.set("n", "<leader>sh", builtin.help_tags, {})
vim.keymap.set("n", "<leader>sk", builtin.keymaps, {})

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		json = { "jq" },
		rust = { "rustfmt" },
		python = { "black" },
		html = { "djlint" },
		javascript = { "prettier" },
		zig = { "zigfmt" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		objc = { "clang-format" },
		objcpp = { "clang-format" },
	},
})

vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format()
end, { desc = "[F]ormat" })

require("telescope").load_extension("harpoon")

local harpoon_ui = require("harpoon.ui")
local harpoon_mark = require("harpoon.mark")
vim.keymap.set("n", "<leader>e", function()
	harpoon_ui.toggle_quick_menu()
end, { silent = true, noremap = true })
vim.keymap.set("n", "<leader>a", function()
	harpoon_mark.add_file()
end, { silent = true, noremap = true })

for i = 1, 9 do
	local idx = i
	vim.keymap.set("n", "<leader>" .. idx, function()
		harpoon_ui.nav_file(idx)
	end, { silent = true, noremap = true })
end

require("mini.icons").setup()
require("nvim-autopairs").setup({})

require("gitsigns").setup()

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

--- Telescope tab picker

local function tab_cwd_picker()
	local tabs = vim.api.nvim_list_tabpages()
	local results = {}

	for _, tab in ipairs(tabs) do
		local tabnr = vim.api.nvim_tabpage_get_number(tab)
		local cwd = vim.fn.getcwd(-1, tabnr)

		table.insert(results, {
			tabnr = tabnr,
			cwd = cwd,
			display = string.format("%d: %s", tabnr, cwd),
		})
	end

	pickers
		.new({}, {
			prompt_title = "Tabs",
			finder = finders.new_table({
				results = results,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.display,
						ordinal = entry.cwd,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					vim.cmd("tabnext " .. selection.value.tabnr)
				end)
				return true
			end,
		})
		:find()
end

vim.keymap.set("n", "<leader>st", function()
	tab_cwd_picker()
end, { silent = true, noremap = true, desc = "Search Tabs" })

--- File system tcd

local function home_dir_picker()
	local home = vim.loop.os_homedir()

	pickers
		.new({}, {
			prompt_title = "Home Directories (depth ≤ 10)",
			finder = finders.new_oneshot_job({
				"fd",
				"--type",
				"d",
				"--max-depth",
				"3",
				"--hidden",
				"--follow",
				"--exclude",
				".git",
				".",
				home,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					local dir = selection[1]

					vim.cmd("tcd " .. vim.fn.fnameescape(dir))
				end)
				return true
			end,
		})
		:find()
end

vim.keymap.set("n", "<leader>to", function()
	home_dir_picker()
end, { silent = true, noremap = true, desc = "Select working directory" })

vim.keymap.set("n", "<leader>tw", function()
	local tabnr = vim.api.nvim_tabpage_get_number(0)
	local cwd = vim.fn.getcwd(-1, tabnr)

	local escaped = vim.fn.shellescape(cwd)
	local cmd = "tmux new-window -c " .. escaped

	vim.fn.system(cmd)
end, { desc = "Open tmux window in tab cwd" })

local builtin = require("telescope.builtin")

local function get_visual_selection()
	vim.cmd('noau normal! "vy')
	local text = vim.fn.getreg("v")
	vim.fn.setreg("v", {})
	text = string.gsub(text, "\n", "")

	return text
end

local function get_visual_selection()
	vim.cmd('noau normal! "vy')
	local text = vim.fn.getreg("v")
	vim.fn.setreg("v", {})
	text = string.gsub(text, "\n", "")
	return text
end

vim.keymap.set("v", "<leader>sv", function()
	local text = get_visual_selection()
	builtin.live_grep({
		default_text = vim.fn.escape(text, [[\^$.*+?()[\]{}|]]),
	})
end, { noremap = true, silent = true })

vim.keymap.set("v", "<leader>/", function()
	local text = get_visual_selection()
	text = vim.fn.escape(text, [[\^$.*+?()[\]{}|]]), vim.fn.setreg("/", text)
end, { noremap = true, silent = true })
