" Author: w0rp <devw0rp@gmail.com>
" Description: This module runs Jasmine tests via ts-node in a split window.

function! s:RunCommand(command) abort
    let l:command = a:command

    if has('win32')
        let l:command = 'cmd /c ' . l:command
    else
        let l:command = split(&shell) + split(&shellcmdflag) + [l:command]
    endif

    :new +set\ filetype=jasmine_test_results
    let l:buffer = bufnr('%')

    let b:job = job_start(l:command, {
    \   'out_io': 'buffer',
    \   'out_buf': l:buffer,
    \   'err_io': 'buffer',
    \   'err_buf': l:buffer,
    \})

    " vint: -ProhibitAutocmdWithNoGroup
    autocmd BufUnload <buffer> call job_stop(b:job)
endfunction

function! jasmine_test_runner#Run() abort
    let l:node_modules_dir = finddir('node_modules', ',;')

    if empty(l:node_modules_dir)
        echom 'No node_modules directory found'
        return
    endif

    let l:project_dir = fnamemodify(l:node_modules_dir, ':h')
    let l:filename = expand('%:p')

    " Find the test filename for the file.
    if l:filename =~# '\.spec\.ts$'
        " The current file is the test file.
        let l:test_filename = l:filename
    else
        " The test file is next to the file.
        let l:test_filename = substitute(l:filename, '\.ts$', '.unit.spec.ts', '')
    endif

    if !filereadable(l:test_filename)
        echom 'Could not read the test file'
        return
    endif

    " Make the path relative, if we can.
    let l:relative_test_filename = l:test_filename[:len(l:project_dir) - 1] is# l:project_dir
    \   ? '.' . l:test_filename[len(l:project_dir): ]
    \   : l:test_filename

    let l:command = 'cd ' . shellescape(l:project_dir) . ' &&'
    \   . ' node_modules/.bin/ts-node'
    \   . ' -r tsconfig-paths/register'
    \   . ' node_modules/.bin/jasmine'
    \   . ' ' . shellescape(l:relative_test_filename)

    call s:RunCommand(l:command)
endfunction
