" general

set guifont=Monospace:h12


" fzf

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \     'rg
          \ --color=always
          \ --column
          \ --line-number
          \ --no-heading
          \ --max-depth 4
          \ --hidden
          \ --smart-case
          \ -- '.shellescape(<q-args>).'; exit 0',
  \     1,
  \     fzf#vim#with_preview({'options': ['--unicode']}),
  \     <bang>0
  \ )
