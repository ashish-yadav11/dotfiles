set guifont=Monospace:h12


" fzf
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --color=always --column --hidden --line-number --no-heading --smart-case --max-depth 4 '.shellescape(<q-args>).' || exit 0', 1,
  \   fzf#vim#with_preview({'options': ['--prompt', 'Rg>', '--unicode']}), <bang>0)
