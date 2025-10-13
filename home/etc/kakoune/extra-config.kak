declare-option -docstring "name of the directory the file is in" \
    str buffile_directory_path

hook global WinCreate .* %{
    hook window NormalIdle .* %{ evaluate-commands %sh{
        bufdir=$(dirname "''${kak_buffile}" | sed "s|^$HOME|~|")
        printf 'set window buffile_directory_path %%{%s}' "''${bufdir}"
    } }
}

hook global WinCreate .* %{ evaluate-commands %sh{
    printf 'set-option window modelinefmt %%{%s}' "%opt{buffile_directory_path}/''${kak_opt_modelinefmt}"
}}
