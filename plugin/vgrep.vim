" File: vgrep.vim
" Author: Lechee.Lai 
" Version: 1.0
" 
" Another grep output in wide format like semware grep / oakgrep / TurboGrep
" and GNU grep 2.0d with patch http://www.interlog.com/~tcharron/grep.html
" it also work for Win32 only I think it's easy port from current GNU grep
" ============ Output Format =====================
" File: C:\vim\vim62\plugin\vgrep.vim
"     1: " File: vgrep.vim
"    14: if exists("loaded_vgrep") || &cp
"    17: let loaded_vgrep = 1
"    20: if !exists("Vgrep_Path")
" ================================================
" 
if exists("loaded_vgrep") || &cp
    finish
endif
let loaded_vgrep = 1

" Location of the grep utility
if !exists("Vgrep_Path")
    let Vgrep_Path = 'c:\usr32\grep.exe'
endif

    let Vlist_Key = 'Îo' " Alt-F8'
if !exists("Vgrep_Key")
    let Vgrep_Key = '§'   " Alt-'
endif

let g:Vgrep_Shell_Quote_Char = '"'

" make default grep -option-
" semware grep
let g:Vgrep_Default_Options = '-is'

" GNU grep 2.0f
" let g:Vgrep_Default_Options = '-iSz'

let g:Vgrep_Default_Filelist = '*'

let g:Vgrep_Output = 'c:\fte.grp'

let g:Vgrep_dirs='c:\vim'

" Map a key to invoke grep on a word under cursor.
exe "nnoremap <unique> <silent> " . Vgrep_Key . " :call <SID>RunVgrep()<CR>"
exe "nnoremap <unique> <silent> " . Vlist_Key . " :call <SID>RunVlist()<CR>"

" RunVgrepCmd()
" Run the specified grep command using the supplied pattern
function! s:RunVgrepCmd(cmd, pattern)
    let cmd_output = system(a:cmd)

    if cmd_output == ""
        echohl WarningMsg | 
        \ echomsg "Error: Pattern " . a:pattern . " not found" | 
        \ echohl None
        return
    endif

    let tmpfile = g:Vgrep_Output

    exe "redir! > " . tmpfile
    silent echon cmd_output
    redir END

endfunction

" EditFile()
"
function! s:EditFile()
    let Done = 0    
    exe 'normal ' . 'mZ'
    let chkline = getline('.')
    let foundln = stridx(chkline,':')
    let chk = strpart(chkline,0,foundln)
    if chk == "File"
	    let fname = strpart(chkline, foundln+2)
	    let fline = ""
	    let Done = 1
    else
       let fline = chk
       
       while Done == 0
         execute "normal " . "k"
	 let chkline = getline('.')
	 let foundln = stridx(chkline,':')
	 let chk = strpart(chkline,0,foundln)
	 if chk == "File"
		 let fname = strpart(chkline, foundln+2)
		 let Done = 1
	 endif        
       endwhile
    endif   
    exe 'normal ' . '`Z'
    " Make suit for you
    "   silent! bdelete
    exe 'edit ' . fname
    if strlen(fline)
      exe 'normal ' . fline . 'gg'
    endif  
endfunction	


" RunVgrep()
" Run the specified grep command
function! s:RunVgrep(...)
"    if a:0 == 0 || a:1 == ''
    let vgrep_opt = g:Vgrep_Default_Options
    let vgrep_path = g:Vgrep_Path
    let clrfile = g:Vgrep_Output
    
    " No argument supplied. Get the identifier and file list from user
    let pattern = input("Grep for pattern: ", expand("<cword>"))
    if pattern == ""
	echo "Cancelled."    
        return
    endif
    "    delete (clrfile) " !!! but not work !!!
    let pattern = g:Vgrep_Shell_Quote_Char . pattern . g:Vgrep_Shell_Quote_Char

    let filenames = input("Grep in files: ", g:Vgrep_Default_Filelist)
    if filenames == ""
	echo "Cancelled."    
        return
    endif

    let cmd = vgrep_path . " " . vgrep_opt . "n "
    let cmd = cmd . " " . pattern
    let cmd = cmd . " " . filenames

" Tweak in next version    
"    let vgrepdir = input("vgrep dir: ", g:Vgrep_dirs)
"    if vgrepdir == ""
"	    echo "Cancelled."    
"	    return
"    endif        
    
"    let last_cd = getcwd()
"    exe 'cd ' . vgrepdir
    call s:RunVgrepCmd(cmd, pattern)
"    exe 'cd ' . last_cd

    setlocal modifiable 
    if filereadable(g:Vgrep_Output)
       exe 'edit ' . g:Vgrep_Output
    endif        
    nnoremap <buffer> <silent> <CR> :call <SID>EditFile()<CR>
    setlocal nomodifiable
endfunction

function! s:RunVlist()
    setlocal modifiable
    exe 'edit ' . g:Vgrep_Output
    nnoremap <buffer> <silent> <CR> :call <SID>EditFile()<CR>
    setlocal nomodifiable
endfunction

" Define the set of grep commands
command! -nargs=* Vgrep call s:RunVgrep(<q-args>)
command! Vlist call s:RunVlist()
