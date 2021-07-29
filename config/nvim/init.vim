" keybindings

" map space as leader
" don't remove \ as leader so that pressing space shows as \ in status
map                             <Space>                 \
" don't fail when the file doesn't exist
nnoremap        <silent>        gf                      :edit <cfile><CR>
nnoremap        <silent>        <C-w>gf                 :edit <cfile><CR>
xnoremap        <silent>        gf                      :<C-u>call EditVisualFile(0)<CR>
xnoremap        <silent>        <C-w>gf                 :<C-u>call EditVisualFile(1)<CR>
" fix broken netrw gx (https://github.com/vim/vim/issues?=1/4738)
nnoremap        <silent>        gx                      :call XdgOpen(1)<CR>
xnoremap        <silent>        gx                      :<C-u>call XdgOpen(0)<CR>
" yank path and directory of the current file
nnoremap        <silent>        yp                      :let @+=expand("%:p")<CR>
nnoremap        <silent>        yd                      :let @+=expand("%:p:h")<CR>
" undo search highlighting
nnoremap        <silent>        <Leader><Esc>           :nohlsearch<CR>
" switch buffers
nnoremap                        <Leader>b               :buffers<CR>:buffer<Space>
" cd to the directory of the current file
nnoremap        <silent>        <Leader>p               :lcd %:p:h<CR>
" spawn terminal and ranger 'around' the current file
nnoremap        <silent>        <Leader>t               :call SpawnTerm("tc")<CR>
nnoremap        <silent>        <Leader>T               :call SpawnTerm("td")<CR>
nnoremap        <silent>        <Leader><C-t>           :call SpawnTerm("td")<CR>
nnoremap        <silent>        <Leader>r               :call SpawnTerm("rc")<CR>
nnoremap        <silent>        <Leader>R               :call SpawnTerm("rd")<CR>
nnoremap        <silent>        <Leader><C-r>           :call SpawnTerm("rp")<CR>
" literal tab character on shift-tab
inoremap                        <S-Tab>                 <C-v><Tab>


" general

filetype plugin on
syntax on

autocmd FileType c,cpp setlocal cindent shiftwidth=8
autocmd FileType go setlocal noexpandtab smarttab shiftwidth=0 tabstop=8

set clipboard+=unnamedplus
set expandtab smarttab shiftwidth=4 tabstop=8
set nojoinspaces
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
let g:netrw_browsex_viewer = 'setsid -f xdg-open'
let g:netrw_nogx = 1


" vim-plug

call plug#begin(stdpath('data')..'/plugged')

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
          \ -- '..shellescape(<q-args>)..'; exit 0',
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


" custom functions

function EditVisualFile(newtab)
    let l:path = VisualSelectionWord()
    if l:path ==# ''
        normal gv
        return
    endif
    try
        execute (a:newtab ? 'tabnew' : 'edit') fnameescape(l:path)
    catch /^Vim\%((\a\+)\)\=:/
        echohl ErrorMsg
        redraw
        echomsg substitute(v:exception, '^\CVim\%((\a\+)\)\=:', '', '')
        echohl None
    endtry
endfunction

function SpawnTerm(arg = "tc")
    let l:shell = &shell
    set shell=/bin/sh

    let l:env = 'unset NVIM_LISTEN_ADDRESS; RANGER_LEVEL=0'
    let l:cmd = 'setsid -f st'

    if a:arg ==# "td"
        let l:dir = expand("%:p:h")
        if l:dir !=# ""
            let l:cmd = 'cd '..shellescape(l:dir, 1)..'; '..l:cmd
        endif
    elseif a:arg ==# "rc"
        let l:cmd = l:cmd..' -e ranger'
    elseif a:arg ==# "rd"
        let l:cmd = l:cmd..' -e ranger'
        let l:dir = expand("%:p:h")
        if l:dir !=# ""
            let l:cmd = l:cmd..' '..shellescape(l:dir, 1)
        endif
    elseif a:arg ==# "rp"
        let l:cmd = l:cmd..' -e ranger'
        let l:path = expand("%")
        if l:path !=# ""
            let l:cmd = l:cmd..' --selectfile='..shellescape(l:path, 1)
        endif
    endif

    silent execute '!' l:env l:cmd '>>"${XLOGFILE:-/dev/null}" 2>&1'

    let &shell = l:shell
endfunction

function VisualSelectionWord()
    " https://stackoverflow.com/questions/1533565
    let [l:ls, l:cs] = getpos("'<")[1:2]
    let [l:le, l:ce] = getpos("'>")[1:2]
    if l:le != l:ls
        return ''
    endif
    let l:word = getline(l:ls)[l:cs - 1 : l:ce - (&selection ==# "inclusive" ? 1 : 2)]
    return trim(l:word)
endfunction

function XdgOpen(normal = 1)
    let l:shell = &shell
    set shell=/bin/sh

    " https://github.com/itchyny/vim-highlighturl/blob/master/autoload/highlighturl.vim#L18
    let l:urlrgx = '\v\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%('
                 \.'[&:#*@~%_\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\-=?!+/0-9a-z]+|:\d+|'
                 \.',%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|'
                 \.'\([&:#*@~%_\-=?!+;/.0-9a-z]*\)|\[[&:#*@~%_\-=?!+;/.0-9a-z]*\]|'
                 \.'\{%([&:#*@~%_\-=?!+;/.0-9a-z]*|\{[&:#*@~%_\-=?!+;/.0-9a-z]*\})\})+'


    let l:arg = a:normal ? expand("<cWORD>") : VisualSelectionWord()
    let l:url = matchstr(l:arg, l:urlrgx)
    if l:url !=# ""
        let l:arg = shellescape(l:url, 1)
    else
        if a:normal
            let l:arg = expand(expand("<cfile>"))
        endif
        if l:arg !=# ""
            if filereadable(l:arg)
                let l:arg = shellescape(l:arg, 1)
            else
                echohl ErrorMsg
                redraw
                echomsg '"'..l:arg..'" is not a valid url or file!'
                echohl None
            endif
        else
            if ! a:normal
                normal gv
            endif
            return
        endif
    endif

    let l:env = 'unset NVIM_LISTEN_ADDRESS; RANGER_LEVEL=0'
    silent execute '!' l:env 'setsid -f xdg-open' l:arg '>>"${XLOGFILE:-/dev/null}" 2>&1'

    let &shell = l:shell
endfunction
