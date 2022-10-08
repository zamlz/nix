-- Workspace Management

require("common.keybinder")

function window_move_on_create(key)
    if key == "j" or key == "k" then
        vim.cmd("wincmd s")
    else
        vim.cmd("wincmd v")
    end
    vim.cmd("wincmd "..key)
end

nmap("<leader><C-h>", ":lua window_move_on_create('h')<CR>")
nmap("<leader><C-j>", ":lua window_move_on_create('j')<CR>")
nmap("<leader><C-k>", ":lua window_move_on_create('k')<CR>")
nmap("<leader><C-l>", ":lua window_move_on_create('l')<CR>")
