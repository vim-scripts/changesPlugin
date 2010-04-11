" ChangesPlugin.vim - Using Signs for indicating changed lines
" ---------------------------------------------------------------
" Version:  0.2
" Authors:  Christian Brabandt <cb@256bit.org>
" Last Change: 2010/04/11
" Script:  <not yet available>
" License: VIM License
" GetLatestVimScripts: <not yet available>
" TODO: enable GLVS


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
