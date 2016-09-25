" Only do this when not done yet for this buffer
if exists("b:loaded_yapf_ftplugin")
    finish
endif
let b:loaded_yapf_ftplugin=1

if !exists("*Yapf(...)")
    function Yapf(...)

        let l:args = get(a:, 1, '')

        if exists("g:yapf_cmd")
            let yapf_cmd=g:yapf_cmd
        else
            let yapf_cmd="yapf"
        endif

        if exists("g:yapf_style")
            let yapf_style=" --style " . g:yapf_style
        else
            let yapf_style=""
        endif

        if !executable(yapf_cmd)
            echoerr "File " . yapf_cmd . " not found. Please install it first."
            return
        endif

        let execmdline=yapf_cmd . " " . yapf_style . " " . l:args

		" current cursor
		let current_cursor = getpos(".")
		" show diff if not explicitly disabled
		if !exists("g:yapf_disable_show_diff")
			let tmpfile = tempname()
			try
				" write buffer contents to tmpfile because yapf --diff
				" does not work with standard input
				silent execute "0,$w! " . tmpfile
				let diff_cmd = execmdline . " --diff \"" . tmpfile . "\""
				let diff_output = system(diff_cmd)
			finally
				" file close
				if filewritable(tmpfile)
					call delete(tmpfile)
				endif
			endtry
		endif
        " execute yapf passing buffer contents as standard input
		silent execute "0,$!" . execmdline
		" restore cursor
		call setpos('.', current_cursor)

		" show diff
		if !exists("g:yapf_disable_show_diff")
		  vertical new yapf
		  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
		  silent execute ':put =diff_output'
		  setlocal nomodifiable
		  setlocal nu
		  setlocal filetype=diff
		endif

		hi Green ctermfg=green
		echohl Green
		echon "Fixed with yapf this file."
		echohl

    endfunction
endif

" Add mappings, unless the user didn't want this.
" The default mapping is registered under to <F3> by default, unless the user
" remapped it already (or a mapping exists already for <F3>)
if !exists("no_plugin_maps") && !exists("no_yapf_maps")
    if !hasmapto('Yapf(')
        noremap <buffer> <F3> :call Yapf()<CR>
        command! -nargs=? -bar Yapf call Yapf(<f-args>)
    endif
endif
