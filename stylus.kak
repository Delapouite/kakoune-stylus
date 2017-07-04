# http://stylus-lang.com
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*[.](styl) %{
    set buffer filetype stylus
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter -group / regions -default code stylus \
    string  '"' (?<!\\)(\\\\)*"        '' \
    string  "'" "'"                    '' \
    comment //  '$'                    '' \
    comment /\* \*/                    ''

add-highlighter -group /stylus/string  fill string
add-highlighter -group /stylus/comment fill comment

add-highlighter -group /stylus/code regex [*]|[#.][A-Za-z][A-Za-z0-9_-]* 0:variable
add-highlighter -group /stylus/code regex &|@[A-Za-z][A-Za-z0-9_-]* 0:meta
add-highlighter -group /stylus/code regex (#[0-9A-Fa-f]+)|((\d*\.)?\d+(em|px)) 0:value
add-highlighter -group /stylus/code regex ([A-Za-z][A-Za-z0-9_-]*)\h*: 1:keyword
add-highlighter -group /stylus/code regex :(before|after) 0:attribute
add-highlighter -group /stylus/code regex !important 0:keyword

# Commands
# ‾‾‾‾‾‾‾‾

def -hidden stylus-filter-around-selections %{
    # remove trailing white spaces
    try %{ exec -draft -itersel <a-x> s \h+$ <ret> d }
}

def -hidden stylus-indent-on-new-line %{
    eval -draft -itersel %{
        # copy '/' comment prefix and following white spaces
        try %{ exec -draft k <a-x> s ^\h*\K/\h* <ret> y gh j P }
        # preserve previous line indent
        try %{ exec -draft \; K <a-&> }
        # filter previous line
        try %{ exec -draft k : stylus-filter-around-selections <ret> }
        # avoid indent after properties and comments
        try %{ exec -draft k <a-x> <a-K> [:/] <ret> j <a-gt> }
    }
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook -group stylus-highlight global WinSetOption filetype=stylus %{ add-highlighter ref stylus }

hook global WinSetOption filetype=stylus %{
    hook window InsertEnd  .* -group stylus-hooks  stylus-filter-around-selections
    hook window InsertChar \n -group stylus-indent stylus-indent-on-new-line
}

hook -group stylus-highlight global WinSetOption filetype=(?!stylus).* %{ remove-highlighter stylus }

hook global WinSetOption filetype=(?!stylus).* %{
    remove-hooks window stylus-indent
    remove-hooks window stylus-hooks
}
