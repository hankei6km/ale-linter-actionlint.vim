function! ale_linters#yaml#actionlint#GetCommand(buffer) abort
    " Only execute actionlint on YAML files in /.github/ paths.
    if expand('#' . a:buffer . ':p') !~# '\v[/\\]\.github[/\\]'
        return ''
    endif

    let l:options = ale#Var(a:buffer, 'yaml_actionlint_options')

    " The --stdin-filename option is necessary to read the .github/actionlint.yaml file.
    return 'actionlint -stdin-filename %s -format "{{json .}}"' . ale#Pad(l:options) . ' - '
endfunction

function! ale_linters#yaml#actionlint#Handle(buffer, lines) abort
    let l:output = []

    for l:err in ale#util#FuzzyJSONDecode(a:lines, [])
        call add(l:output, {
        \   'text': l:err['message'],
        \   'type': 'E',
        \   'code': l:err['kind'],
        \   'lnum': l:err['line'],
        \   'col' : l:err['column']
        \})
    endfor

    return l:output"
endfunction

call ale#linter#Define('yaml', {
\   'name': 'actionlint',
\   'executable': {b -> expand('#' . b . ':p:h') =~? '\.github/workflows$' ? 'actionlint' : ''},
\   'command': function('ale_linters#yaml#actionlint#GetCommand'),
\   'callback': 'ale_linters#yaml#actionlint#Handle',
\   'output_stream': 'stdout',
\})
