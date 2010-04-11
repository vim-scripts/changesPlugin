" Changes.vim - Using Signs for indicating changed lines
" ---------------------------------------------------------------
" Version:  0.2
" Authors:  Christian Brabandt <cb@256bit.org>
" Last Change: 2010/04/11
" Script:  <not yet available>
" License: VIM License
" GetLatestVimScripts: <not yet available>

" Documentation:"{{{1
" To see differences with your file, exexute:
" :EnableChanges
"
" The following variables will be accepted:
"
" g:changes_hl_lines
" If set, all lines will be highlighted, else
" only an indication will be displayed on the first column
" (default: 0)
"
" g:changes_autocmd
" Updates the indication for changed lines automatically,
" if the user does not press a key for 'updatetime' seconds when
" Vim is not in insert mode. See :h 'updatetime'
" (default: 0)
"
" g:changes_verbose
" Output a short description, what these colors mean
" (default: 1)
"
" Colors for indicating the changes
" By default changes.vim displays deleted lines using the hilighting
" DiffDelete, added lines using DiffAdd and modified lines using
" DiffChange.
" You can see how these are defined, by issuing 
" :hi DiffAdd
" :hi DiffDelete
" :hi DiffChange
" See also the help :h hl-DiffAdd :h hl-DiffChange and :h hl-DiffDelete
"
" If you'd like to change these colors, simply change these hilighting items
" see :h :hi

" Check preconditions"{{{1
fu changes#Check()
    if !has("diff") 
	call changes#WarningMsg("Diff support not available in your Vim version.")
	call changes#WarningMsg("changes plugin will not be working!")
	finish
    endif

    if  !has("signs")
	call changes#WarningMsg("Sign Support support not available in your Vim version.")
	call changes#WarningMsg("changes plugin will not be working!")
	finish
    endif

    if !executable("diff") || executable("diff") == -1
	call changes#WarningMsg("No diff executable found")
	call changes#WarningMsg("changes plugin will not be working!")
	finish
    endif
endfu

fu! changes#WarningMsg(msg)"{{{1
    echohl WarningMsg
    echo a:msg
    echohl Normal
endfu

fu! changes#Output()"{{{1
    if s:verbose
	echohl Title
	echo "Differences will be highlighted like this:"
	echohl Normal
	echo "========================================="
	echohl DiffAdd
	echo "+ Added Lines"
	echohl DiffDelete
	echo "- Deleted Lines"
	echohl DiffChange
	echo "* Changed Lines"
	echohl Normal
    endif
endfu

fu! changes#Init()"{{{1
    let s:hl_lines = (exists("g:changes_hl_lines") ? g:changes_hl_lines : 0)
    let s:autocmd  = (exists("g:changes_autocmd")  ? g:changes_autocmd  : 0)
    let s:verbose  = (exists("g:changes_verbose")  ? g:changes_verbose  : 1)

    let s:signs={}
    let s:ids={}
    let s:signs["add"] = "texthl=DiffAdd text=+ texthl=DiffAdd " . ( (s:hl_lines) ? " linehl=DiffAdd" : "")
    let s:signs["del"] = "texthl=DiffDelete text=- texthl=DiffDelete " . ( (s:hl_lines) ? " linehl=DiffDelete" : "")
    let s:signs["chg"] = "texthl=DiffChange text=* texthl=DiffChange " . ( (s:hl_lines) ? " linehl=DiffDelete" : "")

    let s:ids["add"]   = hlID("DiffAdd")
    let s:ids["del"]   = hlID("DiffDelete")
    let s:ids["ch"]    = hlID("DiffChange")
    call changes#DefineSigns()
    call changes#AuCmd(s:autocmd)
    call changes#Check()
endfu

fu! changes#AuCmd(arg)"{{{1
    if s:autocmd && a:arg
	augroup Changes
		autocmd!
		au CursorHold * :call changes#GetDiff()
	augroup END
    else
	augroup Changes
		autocmd!
	augroup END
    endif
endfu

fu! changes#DefineSigns()"{{{1
    exe "sign define add" s:signs["add"]
    exe "sign define del" s:signs["del"]
    exe "sign define ch"  s:signs["chg"]
endfu

fu! changes#GetDiff()"{{{1
    call changes#Init()
    let o_lz=&lz
    let o_fdm=&fdm
    setl lz
    sign unplace *
    call changes#MakeDiff()
    let b:diffhl={'add': [], 'del': [], 'ch': []}
    let line=1
    while line <= line('$')
	let id=diff_hlID(line,1)
	if  (id == 0)
	    let line+=1
	    continue
	elseif (id == s:ids["add"])
	    let b:diffhl['add'] = b:diffhl['add'] + [ line ]
	else
	    let b:diffhl['ch']  = b:diffhl['ch'] + [ line ]
	endif
	let line+=1
    endw
    " Switch to other buffer and check for deleted lines
    wincmd p
    " For some reason, getbufvar setbufvar do not work, so 
    " we use a temporary script variable here
    let s:temp={'del': []}
    let line=1
    while line <= line('$')
	let id=diff_hlID(line,1)
	if (id == s:ids["add"])
	    let s:temp['del'] = s:temp['del'] + [ line ]
	endif
	let line+=1
    endw
    wincmd p
    let b:diffhl['del'] = s:temp['del']
    call changes#PlaceSigns(b:diffhl)
    call changes#DiffOff()
    let &lz=o_lz
    let &fdm=o_fdm
endfu

fu! changes#PlaceSigns(dict)"{{{1
    for [ id, lines ] in items(a:dict)
	for item in lines
	    exe "sign place " . item . " line=" . item . " name=" . id . " buffer=" . bufnr('')
	endfor
    endfor
endfu
	    
fu! changes#MakeDiff()"{{{1
    " Get diff for current buffer with original
    vert new
    set bt=nofile
    r #
    0d_
    diffthis
    wincmd p
    diffthis
endfu

fu! changes#DiffOff()"{{{1
    " Turn off Diff Mode and close buffer
    wincmd p
    diffoff!
    q
endfu

fu! changes#CleanUp()"{{{1
    sign unplace *
    for key in s:keys
	exe "sign undefine " key
    endfor
"    sign undefine del
"    sign undefine ch
    call changes#AuCmd(0)
endfu


" Modeline "{{{1
" vi:fdm=marker fdl=0
