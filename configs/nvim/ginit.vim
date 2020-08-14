set guifont=Monospace:h12


" fzf
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --hidden --line-number --no-heading --color=always --smart-case --max-depth 4 '.shellescape(<q-args>).' || exit 0', 1,
  \   fzf#vim#with_preview({'options': ['--prompt', 'Rg>', '--unicode']}), <bang>0)
