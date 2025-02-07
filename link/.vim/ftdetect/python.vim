fun! s:DetectPython()
    if getline(1) == '#!/usr/bin/env -S pipx run'
        set ft=python
    endif
endfun

autocmd BufNewFile,BufRead * call s:DetectPython()
