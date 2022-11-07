local present, decay = pcall(require, 'decay')

if not present then
	return
end

decay.setup {
	style = 'decayce',
	nvim_tree = {
		contrast = true,
	},
	cmp = {
		block_kind = true,
	},
	italics = {
		comments = true,
		code = true,
	}
}
