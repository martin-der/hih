" ============================================================================
" File:        hih.vim
" Description: Provide helper for color highlight definition
" Author:      
" Licence:     Vim licence
" Website:    
" Version:     0.0.1    
" Note:        
"              
"
" ============================================================================

scriptencoding utf-8

if &cp || exists('g:loaded_highlight_helper')
    finish
endif

let g:loaded_highlight_helper = 1

if v:version < 700
    echohl WarningMsg
    echomsg 'HIH: Vim version is too old, HIH requires at least 7.0'
    echohl None
    finish
endif


let g:hih_term_has_italic = 0
if !has('gui_running')
	try
		silent! call system('/bin/sh -c "command -v tput && tput sitm"')
		let g:hih_term_has_italic = !v:shell_error
	catch
	endtry
endif


command! -nargs=* 
                \ HI call hih#doHighlight(<f-args>)

