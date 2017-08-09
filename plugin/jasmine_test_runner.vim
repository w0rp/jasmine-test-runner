if exists('g:loaded_jasmine_test_runner')
    finish
endif

let g:loaded_jasmine_test_runner = 1

" <Plug> mappings for functions
nnoremap <silent> <Plug>(run_jasmine_tests)
\   :call jasmine_test_runner#Run()<Return>
