---@diagnostic disable: undefined-global
local imports = function ()
	local plugins = {
		'mason', 'mason-lspconfig', 'lspconfig',
		'cmp', 'cmp_nvim_lsp', 'luasnip',
		'cmp_luasnip', 'lspkind', 'lspsaga'
	}

  local ret = true

	for _, plug in ipairs(plugins) do
    local is_installed, _ = pcall(require, plug)
		if not is_installed then
			ret = false
		end
	end

	return ret
end

local ok = imports()

if not ok then
	return
end

local mason = require 'mason'
local mason_lspconfig = require 'mason-lspconfig'
local lspconfig = require 'lspconfig'

mason.setup()
mason_lspconfig.setup()

local map = require 'keymaps'

local lsp_keybinds = function ()
	map.make('n', '<space>e', map.cmd 'Lspsaga show_cursor_diagnostics')
	map.make('n', '[d', map.cmd 'Lspsaga diagnostic_jump_next')
	map.make('n', ']d', map.cmd 'Lspsaga diagnostic_jump_prev')
end

lsp_keybinds()

local on_attach = function (_, bufnr)
	map.for_lsp(bufnr, 'n', '<space>df', map.cmd 'Lspsaga lsp_finder')
	map.for_lsp(bufnr, 'n', 'gD', vim.lsp.buf.declaration)
  map.for_lsp(bufnr, 'n', 'gd', map.cmd 'Lspsaga peek_definition')
  map.for_lsp(bufnr, 'n', 'K', map.cmd 'Lspsaga hover_doc')
  map.for_lsp(bufnr, 'n', 'gi', vim.lsp.buf.implementation)
  map.for_lsp(bufnr, 'n', '<space>D', vim.lsp.buf.type_definition)
  map.for_lsp(bufnr, 'n', '<space>rn', map.cmd 'Lspsaga rename')
  map.for_lsp(bufnr, 'n', '<space>ca', map.cmd 'Lspsaga code_action')
  map.for_lsp(bufnr, 'n', 'gr', vim.lsp.buf.references)
end

-- define servers to load
local servers = {
	-- 'tsserver',
	'pyright',
	-- 'sumneko_lua'
}

-- configure cmp.nvim
local cmp = require 'cmp'
local cmp_nvim_lsp = require 'cmp_nvim_lsp'
local lspkind = require 'lspkind'
local luasnip = require 'luasnip'

cmp.setup {
	window = {
		completion = {
			winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
			col_offset = - 3,
			side_padding = 0,
		},
	},
	formatting = {
		fields = { 'kind', 'abbr', 'menu' },
	  format = function (entry, vim_item)
			local kind_generator = lspkind.cmp_format {
				mode = 'symbol_text',
				max_width = 50
			}

			local kind = kind_generator(entry, vim_item)
			local strings = vim.split(kind.kind, '%s', { trimempty = true })

			local mappings = {
			  TypeParameter = '',
			}

			-- apply mappings to strings[1]
			for name, icon in pairs(mappings) do
				if name == strings[1] then
					strings[1] = icon
				end
			end

			kind.kind = ' ' .. strings[1] .. ' '

			if #strings > 1 then
			  kind.menu = '    (' .. strings[2] .. ')'
			end

			return kind
	  end
	},
	snippet = {
		expand = function (args)
			luasnip.lsp_expand(args.body)
		end
	},
	mapping = cmp.mapping.preset.insert {
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<CR>'] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		},
		['<Tab>'] = cmp.mapping(function (fallback)
			if cmp.visible () then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, {'i', 's'}),
		['<S-Tab>'] = cmp.mapping(function (fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, {'i', 's'}),
	},
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	}
}

local capabilities = cmp_nvim_lsp.default_capabilities()

-- enable `servers`
for _, server in ipairs(servers) do
	lspconfig[server].setup {
		on_attach = on_attach,
		capabilities = capabilities,
	}
end
