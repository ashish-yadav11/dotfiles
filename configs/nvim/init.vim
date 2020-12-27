" keybindings

map                             <Space>                 \
nnoremap        <silent>        gf                      :e <cfile><cr>
nnoremap        <silent>        [f                      :e <cfile><cr>
nnoremap        <silent>        <C-w>gf                 :tabnew <cfile><cr>
nnoremap        <silent>        yd                      :let @+=expand("%:p:h")<CR>
nnoremap        <silent>        yp                      :let @+=expand("%:p")<CR>
nnoremap        <silent>        <Leader><Esc>           :nohlsearch<CR>
nnoremap                        <Leader>b               :buffers<CR>:buffer<Space>
nnoremap        <silent>        <Leader>p               :lcd %:p:h<CR>
nnoremap        <silent>        <Leader>r               :silent !/home/ashish/.scripts/ranger_file.sh "%:p"<CR>
nnoremap        <silent>        <Leader>R               :silent !/home/ashish/.scripts/ranger_dir.sh "%:p:h"<CR>
nnoremap        <silent>        <Leader><C-r>           :silent !/home/ashish/.scripts/ranger_dir.sh <C-r>=getcwd()<CR><CR>
inoremap                        <S-Tab>                 <C-v><Tab>


" general

filetype plugin on
syntax on

autocmd FileType c,cpp setlocal shiftwidth=8
autocmd FileType go setlocal noexpandtab smarttab shiftwidth=0 tabstop=8

set clipboard+=unnamedplus
set expandtab smarttab shiftwidth=4 tabstop=8
set mouse=a
set number relativenumber
set splitbelow
set splitright
set termguicolors
set title
set titlelen=0

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


" vimplug

call plug#begin(stdpath('data').'/plugged')

Plug 'junegunn/fzf.vim'
Plug 'morhetz/gruvbox'
Plug 'neomutt/neomutt.vim'
Plug 'lervag/vimtex'

call plug#end()


" colorschemes

" let g:gruvbox_bold = '1'
" let g:gruvbox_italic = '1'
" let g:gruvbox_underline = '1'
" let g:gruvbox_undercurl = '1'
let g:gruvbox_contrast_dark = 'hard'
" let g:gruvbox_hls_cursor = 'orange'
" let g:gruvbox_number_column = 'color'
" let g:gruvbox_color_column = 'bg1'
" let g:gruvbox_vert_split = 'bg0'
let g:gruvbox_invert_selection = '0'
" let g:gruvbox_invert_signs = '0'
" let g:gruvbox_invert_indent_guides = '0'
" let g:gruvbox_invert_tabline = '0'
" let g:gruvbox_improved_strings = '0'
" let g:gruvbox_improved_warnings = '1'

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


" vimtex

let g:tex_flavor = 'latex'
let g:vimtex_view_method = 'zathura'
