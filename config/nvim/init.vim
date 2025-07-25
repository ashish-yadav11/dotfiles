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
nnoremap        <silent>        yx                      :call UrlCopy()<CR>
" switching between splits
nnoremap        <silent>        <C-j>                   <C-w>j
nnoremap        <silent>        <C-k>                   <C-w>k
nnoremap        <silent>        <C-l>                   <C-w>l
nnoremap        <silent>        <C-h>                   <C-w>h
" switching between tabs
noremap         <silent>        <Leader>1               1gt
noremap         <silent>        <Leader>2               2gt
noremap         <silent>        <Leader>3               3gt
noremap         <silent>        <Leader>4               4gt
noremap         <silent>        <Leader>5               5gt
noremap         <silent>        <Leader>aa              1gt
noremap         <silent>        <Leader>as              2gt
noremap         <silent>        <Leader>ad              3gt
noremap         <silent>        <Leader>af              4gt
noremap         <silent>        <Leader>6               :tablast<CR>4gT
noremap         <silent>        <Leader>7               :tablast<CR>3gT
noremap         <silent>        <Leader>8               :tablast<CR>2gT
noremap         <silent>        <Leader>9               :tablast<CR>1gT
noremap         <silent>        <Leader>0               :tablast<CR>
noremap         <silent>        <Leader>aj              :tablast<CR>3gT
noremap         <silent>        <Leader>ak              :tablast<CR>2gT
noremap         <silent>        <Leader>al              :tablast<CR>1gT
noremap         <silent>        <Leader>a;              :tablast<CR>
noremap         <silent>        <Leader>j               gt
noremap         <silent>        <Leader>k               gT
noremap         <silent>        <Leader>J               :tabmove +1<CR>
noremap         <silent>        <Leader>K               :tabmove -1<CR>

" yank path and directory of the current file
nnoremap        <silent>        yn                      :let @+=expand("%")<CR>
nnoremap        <silent>        yp                      :let @+=expand("%:p")<CR>
nnoremap        <silent>        yd                      :let @+=expand("%:p:h")<CR>
" undo search highlighting
nnoremap        <silent>        <Leader><Esc>           :nohlsearch<CR>
" refresh syntax highlighting
nnoremap        <silent>        <Leader>s               :syntax sync fromstart<CR>
" switch buffers
nnoremap        <silent>        <Leader>b               :Buffers<CR>
nnoremap                        <Leader>B               :buffers<CR>:buffer<Space>
" marks
nnoremap        <silent>        <Leader>m               :Marks<CR>
" edit files
nnoremap        <silent>        <Leader>f               :Files<CR>
nnoremap                        <Leader>F               :Files<Space>
" cd to the directory of the current file
nnoremap        <silent>        <Leader>p               :lcd %:p:h<CR>
" spawn terminal and ranger 'around' the current file
nnoremap        <silent>        <Leader>t               :call SpawnTerm("tc")<CR>
nnoremap        <silent>        <Leader>T               :call SpawnTerm("td")<CR>
nnoremap        <silent>        <Leader><C-t>           :call SpawnTerm("td")<CR>
nnoremap        <silent>        <Leader>r               :call SpawnTerm("rp")<CR>
nnoremap        <silent>        <Leader>R               :call SpawnTerm("rc")<CR>
nnoremap        <silent>        <Leader><C-r>           :call SpawnTerm("rd")<CR>
" logs
nnoremap                        <Leader>w               :w <C-r>=strftime("%y%m%d")<CR>.txt<Left><Left><Left><Left>
nnoremap                        <Leader>e               :call RenameFile()<CR>
nnoremap        <silent>        <Leader>n               :enew<Bar>bdelete #<CR>
nnoremap        <silent>        <Leader>d               :call DeleteBuffers(0)<CR>
nnoremap        <silent>        <Leader>D               :call DeleteBuffers(1)<CR>
" undotree toggle
nnoremap        <silent>        <Leader>u               :UndotreeToggle<CR>
" vimtex
nnoremap        <silent>        <Leader>lt              :call vimtex#fzf#run('ctli',
                                                          \ {'window': { 'width': 0.6, 'height': 0.6 }})<CR>
" literal tab character on shift-tab
inoremap                        <S-Tab>                 <C-v><Tab>
" ctrl+space to insert date
inoremap                        <C-Space>               <C-r>=strftime("%y%m%d")<CR>
cnoremap                        <C-Space>               <C-r>=strftime("%y%m%d")<CR>


" general

filetype plugin on
syntax on

set expandtab smarttab shiftwidth=4 tabstop=8
set ignorecase smartcase
set isfname-==
set nojoinspaces
set mouse=a
set mousemodel=extend
set number relativenumber
set splitbelow splitright
set termguicolors
set title titlelen=0
set titlestring=nvim\ '%t'%(\ %M%)%(\ \(%{expand(\"%:~:h\")}\)%)%a

autocmd TabLeave * let g:lasttab = tabpagenr()
autocmd FileType go setlocal noexpandtab shiftwidth=0
autocmd FileType tex setlocal textwidth=80 indentexpr=""
autocmd BufNewFile,BufRead *.[ch] setlocal cindent shiftwidth=8
autocmd BufNewFile,BufRead */st/*.[ch] setlocal noexpandtab shiftwidth=0
autocmd BufNewFile,BufRead neomutt-*-\w\+,neomutt[[:alnum:]_-]\\\{6\} setfiletype mail

let g:netrw_browsex_viewer = 'setsid -f xdg-open'
let g:netrw_nogx = 1

if $TERM !=# 'linux'
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
    set clipboard+=unnamedplus
endif


" vim-plug

call plug#begin(stdpath('data')..'/plugged')

Plug 'junegunn/fzf.vim'
Plug 'morhetz/gruvbox'
Plug 'JuliaEditorSupport/julia-vim'
Plug 'neomutt/neomutt.vim'
Plug 'mbbill/undotree'
Plug 'lervag/vimtex'
Plug 'ziglang/zig.vim'

call plug#end()

delcommand PlugUpgrade

if $USER ==# 'root'
    delcommand Plug
    delcommand PlugClean
    delcommand PlugDiff
    delcommand PlugInstall
    delcommand PlugSnapshot
    delcommand PlugStatus
    delcommand PlugUpdate
endif


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
          \ --no-ignore
          \ -- '..shellescape(<q-args>)..'; exit 0',
  \     1,
  \     fzf#vim#with_preview(),
  \     <bang>0
  \ )


" julia

let g:latex_to_unicode_eager = 0
let g:latex_to_unicode_file_types = '.*'


" undotree
let g:undotree_WindowLayout = 3
let g:undotree_ShortIndicators = 1
let g:undotree_SetFocusWhenToggle = 1
let g:undotree_RelativeTimestamp = 0


" vimtex

let g:tex_flavor = 'latex'
"let g:vimtex_view_automatic = 0
"let g:vimtex_view_forward_search_on_start = 0
let g:vimtex_view_method = 'zathura'
let g:vimtex_view_use_temp_files = 1
let g:vimtex_view_zathura_check_libsynctex = 0


" zig

let g:zig_fmt_autosave = 0


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
            let l:arg = expand(expand("<cfile>")) " 2 expands not a typo
        endif
        if l:arg !=# ""
            if filereadable(l:arg) || isdirectory(l:arg)
                let l:arg = shellescape(l:arg, 1)
            else
                echohl ErrorMsg
                redraw
                echomsg '"'..l:arg..'" is not a valid url or file!'
                echohl None
                return
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

function UrlCopy()
    " https://github.com/itchyny/vim-highlighturl/blob/master/autoload/highlighturl.vim#L18
    let l:urlrgx = '\v\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%('
                 \.'[&:#*@~%_\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\-=?!+/0-9a-z]+|:\d+|'
                 \.',%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|'
                 \.'\([&:#*@~%_\-=?!+;/.0-9a-z]*\)|\[[&:#*@~%_\-=?!+;/.0-9a-z]*\]|'
                 \.'\{%([&:#*@~%_\-=?!+;/.0-9a-z]*|\{[&:#*@~%_\-=?!+;/.0-9a-z]*\})\})+'


    let l:arg = expand("<cWORD>")
    let l:url = matchstr(l:arg, l:urlrgx)
    if l:url !=# ""
        let @+=l:url
    else
        let @+=l:arg
    endif
endfunction

function RenameFile()
    let l:oldname = expand("%")
    let l:newname = input("New file name: ", l:oldname.."\<Left>\<Left>\<Left>\<Left>", "file")
    if l:newname != '' && l:newname != l:oldname
        execute 'saveas ' l:newname
        execute 'silent !rm ' l:oldname
        redraw!
    endif
endfunction

function DeleteBuffers(allhidden = 0)
    let [i, n; empty] = [1, bufnr("$")]
    while i <= n
        if bufexists(i) && getbufinfo(i)[0].hidden && (a:allhidden == 1 || bufname(i) == "")
            call add(empty, i)
        endif
        let i += 1
    endwhile
    if len(empty) > 0
        execute 'bdelete' join(empty)
    endif
endfunction
