if exists("did_load_filetypes")
  finish
endif

augroup filetypedetect
  au BufNewFile,BufRead *.nlogo,*.nlogo~,*.nls setf nlogo
augroup END

