" File: vgrep.vim
" Author: Lechee.Lai 
" Version: 1.1
" 
" Goal:
"   Easy look for complex directory search without long filename fill 
" context line
" 
" Another grep output in wide format like semware grep / oakgrep / TurboGrep
" and GNU grep 2.0d with patch http://www.interlog.com/~tcharron/grep.html
" it also work for Win32 only I think it's easy port from current GNU grep
"
" ============ Wide Output Format =================
" File: C:\vim\vim62\plugin\vgrep.vim             
"     1: File: vgrep.vim                          
"    17: let loaded_vgrep = 1                     
" File: C:\vim\vim62\plugin\testtttt1\testtttt2\testtttt3\whereis.vim           
"     1: File: whereis.vim                        
" =================================================
"
" Wide vs Unix
" 
" ============ Unix Output ========================
" plugin\vgrep.vim:1: file...
" plugin\testtttt1\testtttt2\testtttt2\whereis.vim:1: file ...
" =================================================
" 
" Change Vgrep_Path locate for grep.exe
" Change Vgrep_Output locate for grep result store
" Make sure your are using semware grep or GNU grep 2.0f
" only this two grep are support now default in GNU grep 2.0f
"
" "=== S e t   Y o u r  G r e p   F i r s t  ==="
"
"
" Command :Vgrep for grep under cursor
"         :Vlist for lister and select by ENTER
"
" History
"    1.0 Initial Revision
"        Only GnuGrep 2.0f and semware Support
"
"    1.1 Add Start Directory for search
"        Add Turbo Grep 5.5 Support 
"        Add OakGrep 5.1+ Support
"        Add Error handle for unknow format prevent 100% CPU Usage
"        Add grp.vim for syntax color
"    


if exists("loaded_vgrep") || &cp
    finish
endif
let loaded_vgrep = 1

" ======= "? Which grep you have ?" ======= 
let TurboGrep = 0
let semwareGrep = 0   
let GnuGrep = 1
let OakGrep = 0
" =======================================

if TurboGrep == 1 
    let semwareGrep = 0     
    let GnuGrep = 0
    let OakGrep = 0
elseif semwareGrep == 1
    let TurboGrep = 0
    let GnuGrep = 0
    let OakGrep = 0    
elseif GnuGrep == 1
    let TurboGrep = 0
    let semwareGrep = 0
    let OakGrep = 0
elseif OakGrep == 1
	let semwareGrep = 0
	let GnuGrep = 0
	let	TurboGrep = 0
endif

" Location of the grep utility
if !exists("Vgrep_Path")
  if semwareGrep == 1
    let Vgrep_Path = 'c:\usr32\grep.exe'
  elseif GnuGrep == 1
    let Vgrep_Path = 'c:\usr32\gnugrep.exe'
  elseif TurboGrep == 1
    let Vgrep_Path = 'c:\usr32\tgrep.exe'
  elseif OakGrep == 1
	let Vgrep_Path = 'c:\usr32\grep32.exe'  
  endif  
endif

" you can use "CTRL-V" for mapping real key in Quote
if !exists("Vlist_Key")
    let Vlist_Key = 'Îo' " Alt-F8
endif

" you can use "CTRL-V" for mapping real key in Quote
if !exists("Vgrep_Key")
    let Vgrep_Key = '§'   " Alt-'
endif

let g:Vgrep_Shell_Quote_Char = '"'


"============ different grep option =========================
" make default grep -option- as "ignore case / Subdirectory / line number"

" semware grep 2.0
if semwareGrep == 1
    let g:Vgrep_Default_Options = '-isn'
endif

" GNU grep 2.0f option z for wide output
if GnuGrep == 1
    let g:Vgrep_Default_Options = '-iSzn'
endif

" Turbo Grep 5.5 from Borloand C++ 5.5 free compiled kit
if TurboGrep == 1
    let g:Vgrep_Default_Options = '-idn'
endif

if OakGrep == 1
	let g:Vgrep_Default_Options = '-isnQ'
endif

"============================================================

if !exists("Vgrep_Default_Filelist")
     if $bmask == ""   
         let g:Vgrep_Default_Filelist = '*'   
     else 
	 let g:Vgrep_Default_Filelist = $bmask
     endif
endif	
	
let Vgrep_Output = 'c:\fte.grp'

if !exists("Vgrep_dirs")
    if $bhome == ""    
       let g:Vgrep_dirs=getcwd()
    else
       let g:Vgrep_dirs=$bhome     
    endif
endif

if !exists("Vgrep_Null_Device")
    if has("win32") || has("win16") || has("win95")
        let Vgrep_Null_Device = 'NUL'
    else
        let Vgrep_Null_Device = '/dev/null'
    endif
endif
 

" Map a key to invoke grep on a word under cursor.
exe "nnoremap <unique> <silent> " . Vgrep_Key . " :call <SID>RunVgrep()<CR>"
exe "inoremap <unique> <silent> " . Vgrep_Key . " <C-O>:call <SID>RunVgrep()<CR>"
exe "nnoremap <unique> <silent> " . Vlist_Key . " :call <SID>RunVlist()<CR>"
exe "inoremap <unique> <silent> " . Vlist_Key . " <C-O>:call <SID>RunVlist()<CR>"

" DelVgrepClrDat()
"
function! s:RunVgrepClrDat()
    let tmpfile = g:Vgrep_Output
    if filereadable(tmpfile)
      let del_str = 'del ' . tmpfile
      let cmd_del = system(del_str)
      exe "redir! > " . g:Vgrep_Null_Device
      silent echon cmd_del
    redir END
    endif

    
endfunction

" RunVgrepCmd()
" Run the specified grep command using the supplied pattern
function! s:RunVgrepCmd(cmd, pattern)

    let tmpfile = g:Vgrep_Output
    let cmd_output = system(a:cmd)
    
    if cmd_output == ""
        echohl WarningMsg | 
        \ echomsg "Error: Pattern " . a:pattern . " not found" | 
        \ echohl None
        return
    endif

    exe "redir! > " . tmpfile
    silent echon cmd_output
    redir END

endfunction

" EditFile()
"
function! s:EditFile()
    let Done = 0    

    " memory the last location 
    exe 'normal ' . 'mZ'    
                         
    if g:GnuGrep == 1 || g:semwareGrep == 1
    
        let chkline = getline('.')
        let foundln = stridx(chkline,':')
        let chk = strpart(chkline,0,foundln)
        if chk == "File"
    	    let fname = strpart(chkline, foundln+2)
    	    let fline = ""
        else
           let fline = chk
           let fname = ""
           while Done == 0
            	execute "normal " . "k"
    	    	let chkline = getline('.')
    	    	let foundln = stridx(chkline,':')
    	    	let chk = strpart(chkline,0,foundln)
    	    	if chk == "File"
    		 		let fname = strpart(chkline, foundln+2)
    		 		let Done = 1
    	    	endif        
    			let chkerror = line(".")
    			if chkerror == 1 && fname == ""
    				break
    			else	
    				let chkerror = 0
    			endif
           endwhile
        endif   
    endif
    
    if g:TurboGrep == 1
        let chkline = getline('.')
		let foundln = stridx(chkline, ' ')
		let chk = strpart(chkline,0,foundln)
		if chk == "File"
        	let fname = strpart(chkline, foundln+1)
			let flen = strlen(fname)
			let fname = strpart(fname, 0, flen-1)
			if fname[1] != ':'
				let fname = g:Vgrep_dirs . '\' . fname
			endif
	     	let fline = ""
		else
	     	let fline = chk
			let fname = ""
	     	while Done == 0
				exe "normal " . "k" 	
				let chkline = getline('.')
				let foundln = stridx(chkline, ' ')
				let chk = strpart(chkline,0,foundln)
				if chk == "File"
					let fname = strpart(chkline, foundln+1)
					let flen = strlen(fname)
					let fname = strpart(fname, 0, flen-1)
					if fname[1] != ':'
						let fname = g:Vgrep_dirs . '\' . fname
					endif
					let Done = 1
				endif
    			let chkerror = line(".")
    			if chkerror == 1 && fname == ""
    				break
    			else	
    				let chkerror = 0
    			endif
	     	endwhile
		endif

    endif

	if g:OakGrep == 1
		let chkerror = 0
        let chkline = getline('.')
		if chkline != ""	
 		let foundln = stridx(chkline, ']')
    		if foundln == -1 || foundln > 11
    			let foundln = stridx(chkline, '----------')
    			let chk = strpart(chkline, 0, 10)
    		else
    			let chk = strpart(chkline,1,foundln-1)
    		endif	
    		if chk == "----------"
            	let fname = strpart(chkline, 11)
    			if fname[1] != ':'
    				let fname = g:Vgrep_dirs . '\' . fname
    			endif
    	     	let fline = ""
    		else
    	     	let fline = chk
    			let fname = ""
            	while Done == 0
        			exe "normal " . "k" 	
        			let chkline = getline('.')
        			let foundln = stridx(chkline, ']')
        	        if foundln == -1 || foundln > 11
        				let foundln = stridx(chkline, '----------')
        				let chk = strpart(chkline,0,10)
        			else
        			    let chk = strpart(chkline,1,foundln-1)
        			endif	
        			if chk == "----------"
        				let fname = strpart(chkline, 11)
        				if fname[1] != ':'
        					let fname = g:Vgrep_dirs . '\' . fname
        				endif
        				let Done = 1
        			endif
    				let chkerror = line(".")
    				if chkerror == 1 && fname == ""
    					break
    				else	
    					let chkerror = 0
    				endif
				endwhile
    		endif
    	else
    	  let chkerror = 1	
    	endif   
   		
	endif
    exe 'normal ' . '`Z'

    if chkerror == 1
		echo "Invaild Grep Format / NULL Line " 
 	else	
    	" Make suit for you
    	" silent! bdelete
    	exe 'edit ' . fname
    	if strlen(fline)
      		exe 'normal ' . fline . 'gg'
    	endif  
	endif
endfunction	


" RunVgrep()
" Run the specified grep command
function! s:RunVgrep(...)
"    if a:0 == 0 || a:1 == ''
    let vgrep_opt = g:Vgrep_Default_Options
    let vgrep_path = g:Vgrep_Path
    
    " No argument supplied. Get the identifier and file list from user
    let pattern = input("Grep for pattern: ", expand("<cword>"))
    if pattern == ""
	echo "Cancelled."    
        return
    endif
    let pattern = g:Vgrep_Shell_Quote_Char . pattern . g:Vgrep_Shell_Quote_Char

    let filenames = input("Grep in files: ", g:Vgrep_Default_Filelist)
    if filenames == ""
	echo "Cancelled."    
        return
    endif

    let cmd = vgrep_path . " " . vgrep_opt . " "
    let cmd = cmd . " " . pattern
    let cmd = cmd . " " . filenames
    let vgrepdir = input("vgrep dir: ", g:Vgrep_dirs)
    if vgrepdir == ""
	    echo "Cancelled."    
	    return
    endif 
	let g:Vgrep_dirs = vgrepdir

    let last_cd = getcwd()
    exe 'cd ' . vgrepdir
    call s:RunVgrepClrDat()
    call s:RunVgrepCmd(cmd, pattern)
    exe 'cd ' . last_cd
   
    if filereadable(g:Vgrep_Output)
       setlocal modifiable 
       exe 'edit ' . g:Vgrep_Output
       setlocal nomodifiable
    endif       

    nnoremap <buffer> <silent> <CR> :call <SID>EditFile()<CR>
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

" vim:tabstop=4:sw=4
