" Made from the example vimrc file.
" 
" Maintainer:	Gracekinglau@gmail.com
" 
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"     for Amiga:  s:.vimrc
"for MS-DOS and Win32:  $VIM\_vimrc
"     for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
        finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
        set nobackup		" do not keep a backup file, use versions instead
else
        set backup		" keep a backup file
endif
set history=1000		" keep 1000 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
        set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
        syntax on
        set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

        " Enable file type detection.
        " Use the default filetype settings, so that mail gets 'tw' set to 72,
        " 'cindent' is on in C files, etc.
        " Also load indent files, to automatically do language-dependent indenting.
        filetype plugin indent on

        " Put these in an autocmd group, so that we can delete them easily.
        augroup vimrcEx
                au!

                " For all text files set 'textwidth' to 78 characters.
                autocmd FileType text setlocal textwidth=78

                " When editing a file, always jump to the last known cursor position.
                " Don't do it when the position is invalid or when inside an event handler
                " (happens when dropping a file on gvim).
                " Also don't do it when the mark is in the first line, that is the default
                " position when opening a file.
                autocmd BufReadPost *
                                        \ if line("'\"") > 1 && line("'\"") <= line("$") |
                                        \   exe "normal! g`\"" |
                                        \ endif

        augroup END

else

        set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
        command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
                                \ | wincmd p | diffthis
endif

" auto close bracket
let PairClass = {'autoclose':'off'}
function! PairClass.ClosePair(char) dict
        if getline('.')[col('.') - 1] == a:char
                return "\<Right>"
        else
                return a:char
        endif
endfunction	
function! PairClass.TogglePair() dict
        if self.autoclose == 'on'
                let self.autoclose = 'off'
                inoremap ( (
                inoremap ) )
                inoremap { {
                inoremap } }
                inoremap [ [
                inoremap ] ]
                inoremap < <
                inoremap > >
                inoremap ' '
                inoremap " "
                return
        else
                let self.autoclose = 'on'
                inoremap ( ()<ESC>i
                inoremap ) <c-r>=self.ClosePair(')')<CR>
                inoremap { {}<ESC>i
                inoremap } <c-r>=self.ClosePair('}')<CR>
                inoremap [ []<ESC>i
                inoremap ] <c-r>=self.ClosePair(']')<CR>
                inoremap < <><ESC>i
                inoremap > <c-r>=self.ClosePair('>')<CR>
                inoremap ' ''<ESC>i
                inoremap " ""<ESC>i
        endif
endfunction
" call PairClass.TogglePair()
" use delimitMate.vim instead

" common config
nmap qw :q<CR>
nmap wa :wa<CR>
set foldenable
set foldmethod=manual
set tabstop=4
set shiftwidth=4
set expandtab
autocmd FileType python set tabstop=4
autocmd FileType python set shiftwidth=4
autocmd FileType java set tabstop=4
autocmd FileType java set shiftwidth=4
autocmd FileType js set tabstop=4
autocmd FileType js set shiftwidth=4
autocmd FileType html set tabstop=4
autocmd FileType html set shiftwidth=4
autocmd FileType bash set tabstop=8
autocmd FileType bash set shiftwidth=8
set nu
set nobackup
set listchars=tab:>-,trail:$                " list chars for 'set list' below.
" set list                                  " use this to display tab and space at the end of a line.
map <C-j> <C-W>j<C-W>_

map <C-k> <C-W>k<C-W>_
imap <C-S> <Esc>:w<CR>
nmap wa :wa<CR>
nmap qw :q<CR>
nmap qa :qa<CR>
"map <C-S-q> :qa<CR>
nmap to :TlistOpen<CR><C-W>l<C-W>l<C-W>l<C-W>l
nmap tc :TlistClose<CR>
nmap vs :vs<CR>
let Tlist_Auto_Open = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_File_Fold_Auto_Close = 1

nmap taf :silent !taggen && find . -name "*.h" -o -name "*.c" -o -name "*.cc" -o -name "*.cpp" > cscope.files && cscope -Rb -i cscope.files<CR>
nmap tap :silent !find . -name "*.py" > cscope.files && cscope -Rb -i cscope.files<CR><CR>

nmap px :exe ":!" . expand("%:p:r")<CR>
nmap ea :AV<CR>:vertical res 40<CR>
let g:SuperTabDefaultCompletionType='context'

"""""""""""""""""cscope"""""""""""""""""""""
"C symbol
nmap css :cs find s <C-R>=expand("<cword>")<CR><CR>
"definition
nmap csg :cs find g <C-R>=expand("<cword>")<CR><CR>
"calling functions
nmap csc :cs find c <C-R>=expand("<cword>")<CR><CR>
"text string
nmap cst :cs find t <C-R>=expand("<cword>")<CR><CR>
"egrep pattern
nmap cse :cs find e <C-R>=expand("<cword>")<CR><CR>
"file
nmap csf :cs find f <C-R>=expand("<cfile>")<CR><CR>
"find including files
nmap csi :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
"called functions
nmap csd :cs find d <C-R>=expand("<cword>")<CR><CR>
nmap <F3> csgzz
nmap csa :cs add ./cscope.out

"""""""""""""""save current project""""""""
nmap ps :mks!<CR>:wv viminfo<CR>
nmap pl :so Session.vim<CR>:rv viminfo<CR>


" for bashsupport
let g:BASH_AuthorName = "gmliao"
let g:BASH_Email="Gracekinglau@gmail.com"
let g:BASH_CodeSnippets=$HOME.'/.vim/bundle/bashsupport/bash-support/codesnippets'
let g:BASH_Dictionary_File=$HOME.'/.vim/bundle/bashsupport/bash-support/wordlists/bash.list'
let g:BASH_Template_Directory=$HOME.'/.vim/bundle/bashsupport/bash-support/templates/'

" config for vimrc operation
let mapleader=","
map ,ee :vs ~/.vimrc<CR>
map ,ss :source ~/.vimrc<CR>

" config for pydiction
let g:pydiction_location = '/home/baina/python/pydiction-1.2/complete-dict'
imap <buffer> <F2> <ESC>:execute "!pydoc " . expand("<cword>")<CR>i

" config for Tlist
let Tlist_Use_Right_Window = 1


" omni-completion
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType java set omnifunc=javacomplete#Complete


function! ModeChange()
        if getline(1) =~ '^#!'
                if getline(1) =~ "/bin/"
                        silent !chmod a+x <afile>
                endif
        endif
endfunction
au BufWritePost * call ModeChange()


" pathogen to manage plugins
call pathogen#infect()



hi chwm ctermbg=yellow
imap <F3> <ESC>:execute 'mat chwm /\<'.expand('<cword>').'\>/'<CR>li


let g:cursorholdWordMatch = "1"
function! CursorholdMat()
        echo "hello"
endfunction
if g:cursorholdWordMatch == "1"
        au CursorHoldI call CursorholdMat()
endif
"execute '<ESC>:mat chwm /\<'.expand('<cword>').'\>/<CR>li'


let Vimplate = "~/.vim/bundle/vimplate-0.2.3/vimplate" 
