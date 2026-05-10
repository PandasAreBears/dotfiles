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

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})
vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { silent = true, noremap = true })
vim.diagnostic.enable(false)

vim.keymap.set("n", "<leader>w", vim.cmd.w, { noremap = true, silent = true, desc = "Save" })
vim.keymap.set("n", "<leader>q", vim.cmd.q, { noremap = true, silent = true, desc = "Quit" })
vim.keymap.set("n", "<leader>c", "<cmd>bdelete<CR>", { noremap = true, silent = true, desc = "Close buffer" })
vim.keymap.set("n", "<leader>ta", ":$tabnew<CR>", { noremap = true, silent = true, desc = "New tab" })
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { noremap = true, silent = true, desc = "Close tab" })
vim.keymap.set("n", "<leader>tn", ":tabn<CR>", { noremap = true, silent = true, desc = "Next tab" })
vim.keymap.set("n", "<leader>tp", ":tabp<CR>", { noremap = true, silent = true, desc = "Prev tab" })
vim.keymap.set("n", "<leader>gec", ":e ~/.config/nvim/init.lua<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { silent = true, desc = "Copy to clipboard" })

vim.pack.add({
	{ src = "https://github.com/folke/tokyonight.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/mason-org/mason.nvim.git" },
	{ src = "https://github.com/neovim/nvim-lspconfig.git" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/windwp/nvim-autopairs" },
	{ src = "https://github.com/Saghen/blink.cmp", version = "v1.6.0" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim" },
})

vim.cmd.colorscheme("tokyonight")

require("nvim-treesitter").setup({
	ensure_installed = { "all" },
})
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		pcall(vim.treesitter.start)
	end,
})

require("mason").setup()

vim.filetype.add({
	extension = {
		m = "objc",
		mm = "objcpp",
	},
})

vim.lsp.config("ruff", {})
vim.lsp.enable("lua_la")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("clangd")
vim.lsp.enable("gopls")
vim.lsp.enable("ruff")
vim.lsp.enable("ty")
vim.lsp.log.set_level("off")

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

require("oil").setup({
	view_options = {
		show_hidden = true,
	},
})
vim.keymap.set("n", "<leader>i", "<CMD>Oil<CR>", { noremap = true, silent = true, desc = "Open parent directory" })

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
		["<C-p>"] = { "select_prev", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },
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
vim.keymap.set("n", "<leader>o", builtin.lsp_document_symbols, {})
vim.keymap.set("n", "<leader>sg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>sh", builtin.help_tags, {})

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		json = { "jq" },
		rust = { "rustfmt" },
		python = { "ruff" },
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

require("nvim-autopairs").setup({})

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
			prompt_title = "Home Directories (depth ≤ 3)",
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
