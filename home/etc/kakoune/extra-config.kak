require-module "byline"

declare-option -docstring "name of the directory the file is in" \
    str buffile_directory_path

hook global ModuleLoaded smarttab %{
    set-option global softtabstop 4
    hook global WinSetOption filetype=(rust|markdown|kak|lisp|scheme|sh|perl) expandtab
    hook global WinSetOption filetype=(makefile|gas) noexpandtab
    hook global WinSetOption filetype=(c|cpp) smarttab
    hook global WinSetOption filetype=(nix) softtabstop 2
}

hook global BufNewFile  .* expandtab
hook global BufOpenFile .* expandtab

hook global BufOpenFile .* %{
    modeline-parse
}

hook global WinCreate .* %{
    hook window NormalIdle .* %{ evaluate-commands %sh{
        bufdir=$(dirname "${kak_buffile}" | sed "s|^$HOME|~|")
        printf 'set window buffile_directory_path %%{%s}' "${bufdir}"
    } }
}

hook global WinCreate .* %{ evaluate-commands %sh{
    printf 'set-option window modelinefmt %%{%s}' "%opt{buffile_directory_path}/${kak_opt_modelinefmt}"
}}
