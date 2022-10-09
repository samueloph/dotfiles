" Specify a directory for plugins
call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'vim-syntastic/syntastic'
Plug 'Yggdroot/indentLine'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'preservim/nerdtree'
Plug 'wellle/context.vim'

" Initialize plugin system
call plug#end()

" [dracula] use theme
color dracula

" [airline] use powerline fonts
let g:airline_powerline_fonts = 1

" [airline] hide filetype when it's utf-8[unix]
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'

" [identline] use gray color
let g:indentLine_color_term = 239
let g:indentLine_setConceal = 0

" [syntastic] use recommended setings
" https://github.com/vim-syntastic/syntastic#settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" [syntastic] toggle with f8
map <F8> <ESC>:call SyntasticToggle()<CR>
let g:syntastic_is_open = 1
function! SyntasticToggle()
if g:syntastic_is_open == 1
    lclose
    let g:syntastic_is_open = 0
else
    Errors
    let g:syntastic_is_open = 1
endif
endfunction

" [syntastic] make error windows smaller if it has less than 10 items
" see :h syntastic-loclist-callback
function! SyntasticCheckHook(errors)
    if !empty(a:errors)
        let g:syntastic_loc_list_height = min([len(a:errors), 10])
    endif
endfunction

" [syntastic] use flake8 for python
let g:syntastic_python_checkers=['flake8']

" [syntastic] use custom symbols for error and warnings
let g:syntastic_error_symbol = "✗"
let g:syntastic_warning_symbol = "⚠"

" don't enter visual mode when using mouse
se mouse-=a

" enable syntax highlighting
syntax on

" toggle line counter with ctrl+n, enabled by default
se number
nmap <C-N> :set invnumber<CR>

" highlight trailing whitespaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" toggle spellcheck with f5
map <F5> :setlocal spell! spelllang=en_us<CR>

" insert newline without entering insert mode with Enter
" https://vim.fandom.com/wiki/Insert_newline_without_entering_insert_mode
nmap <S-Enter> O<Esc>
nmap <CR> o<Esc>

" open file on last place visited
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" display tabs as >-...
set list
set listchars=tab:>-

" use spaces instead of tabs
" https://vim.fandom.com/wiki/Converting_tabs_to_spaces
set tabstop=4 shiftwidth=4 expandtab

" Make backspace remove 4 spaces
set softtabstop=4

" insert real tabs with shitt+tab
inoremap <S-Tab> <C-V><Tab>

" incremental search
set incsearch

" highlight all search matches
set hlsearch

" press return to temporarily get out of the highlighted search
" https://vim.fandom.com/wiki/Highlight_all_search_pattern_matches
nnoremap <CR> :nohlsearch<CR><CR>

" blink on search results iteration
" https://youtu.be/aHm36-na4-4#t=4m59s
" Damian Conway's Die Blinkënmatchen: highlight matches
" extra: https://github.com/qxxxb/vim-searchhi
nnoremap <silent> n n:call HLNext(0.1)<cr>
nnoremap <silent> N N:call HLNext(0.1)<cr>

function! HLNext (blinktime)
  let target_pat = '\c\%#'.@/
  let ring = matchadd('ErrorMsg', target_pat, 101)
  redraw
  exec 'sleep ' . float2nr(a:blinktime * 1000) . 'm'
  call matchdelete(ring)
  redraw
endfunction

nmap <F6> :NERDTreeToggle<CR>
