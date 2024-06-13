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

nvim_lsp.pyright.setup {
    handlers = {
        ["textDocument/publishDiagnostics"] = function() end,
    },
    file_types = {"python"},
    init_options = {
        highlight = {
            lsRanges = false,
        }
    },
}
