local nvim_lsp = require('lspconfig')

nvim_lsp.clangd.setup {
    handlers = {
        ["textDocument/publishDiagnostics"] = function() end,
    },
    init_options = {
        highlight = {
            lsRanges = false,
        }
    },
}
