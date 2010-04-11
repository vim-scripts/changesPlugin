" ChangesPlugin.vim - Using Signs for indicating changed lines
" ---------------------------------------------------------------
" Version:  0.3
" Authors:  Christian Brabandt <cb@256bit.org>
" Last Change: 2010/04/11
" Script:  http://www.vim.org/scripts/script.php?script_id=3052
" License: VIM License
" Documentation: see :help changesPlugin.txt
" GetLatestVimScripts: 3052 2 :AutoInstall: ChangesPlugin.vim


" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_changes")
 finish
endif
let g:loaded_changes       = 1
let s:keepcpo              = &cpo
set cpo&vim

let s:autocmd  = (exists("g:changes_autocmd")  ? g:changes_autocmd  : 0)
" ------------------------------------------------------------------------------
" Public Interface: {{{1
com! EnableChanges  call changes#GetDiff()|:call changes#Output()
com! DisableChanges call changes#CleanUp()

if s:autocmd
    call changes#Init()
endif
" =====================================================================
" Restoration And Modelines: {{{1
" vim: fdm=marker
let &cpo= s:keepcpo
unlet s:keepcpo

" Modeline
" vi:fdm=marker fdl=0
