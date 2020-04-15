" vim:fdm=marker

" leader keys {{{
let mapleader = ',' " semicolon is the leader key
let maplocalleader = '\\' " backslash is the localleader key
" }}}
" remaps {{{
" easier remappings of common commands {{{
inoremap uu <Esc>| " use "uu" to exit insert mode
inoremap hh <Esc>:w<CR>| " use "hh" to exit insert mode and save
nnoremap <space> :| " remap space to : in normal mode for ease of use
vnoremap <space> :| " remap space to : in visual mode for ease of use
nnoremap <space><space> :wq<CR>| " remap space twice to save and quit for ease of use
nnoremap <BS> :w<CR>| " remap backspace to save in normal mode
vnoremap <BS> :w<CR>| " remap backspace to save in visual mode
nnoremap <CR><CR> :q<CR>| " remap enter twice to quit
" }}}
" use H and L to go to beginning and end of lines {{{
" NOTE: nmap is used here rather than nnoremap in order for the .txt filetype
" configuration to be able to make use of these mappings. If a better way to
" deal with this is found, it will be changed.
noremap H ^| " H moves to first non-blank character of line
noremap L g_| " L moves to last non-blank character of line
" }}}
" easier scrolling/scrolling that doesn't conflict with existing mappings {{{
nnoremap <c-h> <c-e>| " scroll down
nnoremap <c-n> <c-y>| " scroll up
" }}}
" do case sensitive search with * and # {{{
noremap * /\<<C-R>=expand('<cword>')<CR>\><CR>
noremap # ?\<<C-R>=expand('<cword>')<CR>\><CR>
" }}}
" }}}
" autocmds {{{
" fixes the problem detailed at http://vim.wikia.com/wiki/Keep_folds_closed_while_inserting_text {{{
" Without this, folds open and close at will as you type code.
augroup fixfolds
    autocmd!
    autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
    autocmd InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif
augroup END
" }}}
" highlight word under cursor {{{
augroup highlight_word_under_cursor
    autocmd!
    autocmd CursorMoved * exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\'))
augroup END
" }}}
" }}}
" filetype configuration {{{
" .txt files {{{
augroup txt_files
    autocmd!
    autocmd FileType text setlocal wrap linebreak " set linewrapping
    autocmd FileType text setlocal spell spelllang=en_us " use the en_us dictionary

    " standard motion commands should move by wrapped lines
    autocmd FileType text noremap <buffer> <silent> k gk
    autocmd FileType text noremap <buffer> <silent> j gj
    autocmd FileType text noremap <buffer> <silent> 0 g0
    autocmd FileType text noremap <buffer> <silent> $ g$
    autocmd FileType text noremap <buffer> <silent> ^ g^
    autocmd FileType text noremap <buffer> <silent> H g^
    autocmd FileType text noremap <buffer> <silent> L g$| " TODO: this should be changed to gg_ or whatever the linewrapping version of g_ is
    "autocmd FileType text noremap <buffer> <silent> g_ gg_| " TODO: is there a linewrapping version of g_?
augroup END
" }}}
" gitcommit files {{{
augroup gitcommit_files
    autocmd!
    autocmd FileType gitcommit setlocal spell
augroup END
" }}}
" go files {{{
augroup go_files
    autocmd!
    autocmd FileType go setlocal rtp+=$GOPATH/src/github.com/golang/lint/misc/vim " add golint for vim to the runtime path
    autocmd BufWritePost,FileWritePost *.go execute 'mkview!' | execute 'Lint' | execute 'silent! loadview'| " execute the Lint command on write
augroup END
" }}}
" markdown files {{{
augroup markdown_files
    autocmd!
    autocmd FileType markdown setlocal spell " turn on spellcheck
augroup END
" }}}
" tex files {{{
augroup tex_files
    autocmd!
    autocmd FileType tex setlocal spell " turn on spellcheck
augroup END
" }}}
" }}}
" easy editing of vimrc file {{{
nnoremap <silent> <leader>ev :tabe $MYVIMRC<CR>| " open .vimrc in new tab
nnoremap <silent> <leader>sv :so $MYVIMRC<CR>| " resource .vimrc
" }}}
" search {{{
set ignorecase " make search case insensitive
set smartcase " ignore case if only lowercase characters used in search text
set incsearch " show search results incrementally as you type
set gdefault " always do global substitutions
" }}}
" tabs {{{
set expandtab " tabs are expanded to spaces
set tabstop=4 " tabs count as 4 spaces
set softtabstop=4 " tabs count as 4 spaces while performing editing operations (yeah, I don't really understand this either)
set shiftwidth=4 " number of spaces used for autoindent
set shiftround " should round indents to multiple of shiftwidth
set autoindent " automatically indent lines
set smarttab " be smart about how you use shiftwidth vs tabstop or softtabstop I think
" }}}
" show whitespace {{{
set list " display whitespace characters
set listchars=tab:>.,trail:.,extends:#,nbsp:. " specify which whitespace characters to display ('trail' is for trailing spaces, and 'extends' is for when the line extends beyond the right end of the screen)
" }}}
" misc. settings {{{
set number " show line numbers
set nowrap " don't wrap lines
set showmatch " show matching bracket when one is inserted
set backspace=indent,eol,start " be able to backspace beyond the point where insert mode was entered
set history=1000 " the length of the : command history
set undolevels=1000 " maximum number of changes that can be undone
set wildignore=*.swp,*.bak,*.pyc,*.class " file patterns to ignore when expanding wildcards
set title " title of window set to titlename/currently edited file
set visualbell " use visual bell instead of beeping
set noerrorbells " don't ring the bell for error messages
set foldmethod=syntax " fold based on the language syntax (e.g. #region tags)
set colorcolumn=80,120 " highlight the 80th and 120th columns for better line-length management
set wildmode=longest,full " in command line, first <tab> press complete to longest common string, next show full match
set wildmenu " visually cycle through command line completions
set cursorline " highlight the current line
set cursorcolumn " highlight the current column
set nojoinspaces " don't add an extra space after a period for J and gq
" }}}
" custom functions {{{
" toggle between number and relativenumber
function! ToggleNumber()
    if(&relativenumber == 1)
        set norelativenumber
        set number
    else
        set relativenumber
    endif
endfunc

" format json
function! FormatJson()
    %!python -m json.tool
endfunc
" }}}
