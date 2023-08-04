" markdown settings --------------------------------------------------------------------------------

" snippets
" See https://hcy-asleep.github.io/Redis-%E5%9F%BA%E7%A1%80-%E9%97%B2%E8%81%8A/ for more infos

function! INSERT_A_PICTURE()
  call feedkeys("\<BS>\<img src\=\"\"\/\>\<LEFT>\<LEFT>\<LEFT>",'n')  
endfunction

function! LEFT_TEXT_DIALOUGE()
  call feedkeys("\<BS>\<ENTER><div align=\"left\"><div style=\"width: 60%; border-style: solid; border-width: 1px; border-radius: 16px; position: relative; padding:30px; text-align:center\"\><span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent black transparent transparent; border-width: 10px; position: absolute; top: 10px; left: -20px;\"\>\</span><span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent white transparent transparent; border-width: 10px; position: absolute; top: 10px; left: -19px;\"\>\</span\>\<ENTER>\<ENTER></div></div><br/>\<UP>",'n')
endfunction

function! RIGHT_TEXT_DIALOUGE()
  call feedkeys("\<BS>\<ENTER><div align=\"right\"\>\<div style=\"width: 60%; border-style: solid; border-width: 1px; border-radius: 16px; position: relative; padding:30px; text-align:center\"\>\<span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent transparent transparent black; border-width: 10px; position: absolute; top: 10px; right: -20px;\"></span><span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent transparent transparent white; border-width: 10px; position: absolute; top: 10px; right: -19px\"></span>\<ENTER>\<ENTER></div></div><br/>\<UP>",'n')
endfunction

function! LEFT_PICTURE_DIALOUGE()
  call feedkeys("\<BS>\<ENTER><div align=\"left\"><div style=\"width: 80%; border-style: solid; border-width: 1px; border-radius: 16px; position: relative; padding:30px; text-align:center\"><span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent transparent transparent black; border-width: 10px; position: absolute; top: 10px; right: -20px;\"></span><span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent transparent transparent white; border-width: 10px; position: absolute; top: 10px; right: -19px\"></span>\<ENTER>\<ENTER></div></div><br/>\<UP>\<img src\=\"\"\/\>\<LEFT>\<LEFT>\<LEFT>",'n')
endfunction

function! RIGHT_PICTURE_DIALOUGE()
  call feedkeys("\<BS>\<ENTER><div align=\"right\"><div style=\"width: 80%; border-style: solid; border-width: 1px; border-radius: 16px; position: relative; padding:30px; text-align:center\"><span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent transparent transparent black; border-width: 10px; position: absolute; top: 10px; right: -20px;\"></span><span style=\"width: 0px; height: 0px; border-style: solid; border-color: transparent transparent transparent white; border-width: 10px; position: absolute; top: 10px; right: -19px\"></span>\<ENTER>\<ENTER></div></div><br/>\<UP>\<img src\=\"\"\/\>\<LEFT>\<LEFT>\<LEFT>",'n')
endfunction



inoremap <expr> <c-j> LEFT_TEXT_DIALOUGE()
inoremap <expr> <c-k> RIGHT_TEXT_DIALOUGE()
inoremap <expr> <c-h> LEFT_PICTURE_DIALOUGE()
inoremap <expr> <c-l> RIGHT_PICTURE_DIALOUGE()
inoremap <expr> <c-p> INSERT_A_PICTURE()



"-------------------------------------------------------------------------------------------------------------
"-----------------------------------------markdown-dialogue-end-----------------------------------------------
"-------------------------------------------------------------------------------------------------------------
