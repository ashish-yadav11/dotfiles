" keybindings

map                             <Space>                 \
nnoremap        <silent>        gf                      :edit <cfile><CR>
nnoremap        <silent>        [f                      :edit <cfile><CR>
nnoremap        <silent>        <C-w>gf                 :tabnew <cfile><CR>
nnoremap        <silent>        yd                      :let @+=expand("%:p:h")<CR>
nnoremap        <silent>        yp                      :let @+=expand("%:p")<CR>
nnoremap        <silent>        <Leader><Esc>           :nohlsearch<CR>
nnoremap                        <Leader>b               :buffers<CR>:buffer<Space>
nnoremap        <silent>        <Leader>p               :lcd %:p:h<CR>
nnoremap        <silent>        <Leader>t               :execute ':silent !setsid -f termite -d '.shellescape(expand("%:p:h"), 1)<CR>
nnoremap        <silent>        <Leader><C-t>           :execute ':silent !setsid -f termite -d '.shellescape(expand(getcwd()), 1)<CR>
nnoremap        <silent>        <Leader>r               :execute ':silent !RANGER_LEVEL=0 setsid -f termite -e '.shellescape('ranger --selectfile='.shellescape(expand("%:p")), 1)<CR>
nnoremap        <silent>        <Leader>R               :execute ':silent !RANGER_LEVEL=0 setsid -f termite -e '.shellescape('ranger '.shellescape(expand("%:p:h")), 1)<CR>
nnoremap        <silent>        <Leader><C-r>           :execute ':silent !RANGER_LEVEL=0 setsid -f termite -e '.shellescape('ranger '.shellescape(expand(getcwd())), 1)<CR>
inoremap                        <S-Tab>                 <C-v><Tab>


" general

filetype plugin on
syntax on

autocmd FileType c,cpp setlocal cindent shiftwidth=8
autocmd FileType go setlocal noexpandtab smarttab shiftwidth=0 tabstop=8

set clipboard+=unnamedplus
set expandtab smarttab shiftwidth=4 tabstop=8
set mouse=a
set number relativenumber
set splitbelow splitright
set termguicolors
set title titlelen=0

let g:clipboard = {
  \     'name': 'xsel',
  \     'copy': {
  \         '+': 'xsel -nib',
  \         '*': 'xsel -nip',
  \     },
  \     'paste': {
  \         '+': 'xsel -ob',
  \         '*': 'xsel -op',
  \     },
  \     'cache_enabled': 1,
  \ }
let g:netrw_browsex_viewer = 'xdg-open'


" vim-plug

call plug#begin(stdpath('data').'/plugged')

Plug 'junegunn/fzf.vim'
Plug 'morhetz/gruvbox'
Plug 'JuliaEditorSupport/julia-vim'
Plug 'neomutt/neomutt.vim'
Plug 'lervag/vimtex'

call plug#end()

delcommand PlugUpgrade


" gruvbox

let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_invert_selection = '0'

colorscheme gruvbox


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
  \     fzf#vim#with_preview(),
  \     <bang>0
  \ )


" julia

let g:latex_to_unicode_eager = 0
let g:latex_to_unicode_file_types = '.*'


" vimtex

let g:tex_flavor = 'latex'
let g:vimtex_view_method = 'zathura'
