" Vim syntax file
" Language:	grep

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn match grpLine1      "\d\+:"
syn match grpLine2      "^[0-9]\+\d"
syn match grpLine3      "^\[\+\s\+\d\+]"
syn match grpFile1	"^File.*"
syn match grpFile2      "^----------\s.*"

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_grp_syntax_inits")
  if version < 508
    let did_grp_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif
  
  HiLink grpLine1	Number
  HiLink grpLine2	Number
  HiLink grpLine3       Number                                   
  HiLink grpFile1	Statement
  HiLink grpFile2       Statement                     

  delcommand HiLink
endif

let b:current_syntax = "grp"

" vim: ts=8 sw=2
