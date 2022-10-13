if exists("did_load_filetypes")
  finish
endif

augroup filetypedetect
  au BufNewFile,BufRead *.nlogo,*.nlogo~,*.nls setf nlogo
  au BufNewFile,BufRead *.esp setf cpp
augroup END

