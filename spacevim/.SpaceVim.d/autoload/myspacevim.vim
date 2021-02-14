function! myspacevim#before() abort
  " Create Writegood bindings.
  call SpaceVim#custom#SPCGroupName(["a", "w"], "writegood")
  call SpaceVim#custom#SPC("nore", ["a", "w", "d"], ":WritegoodDisable", "disable", 1)
  call SpaceVim#custom#SPC("nore", ["a", "w", "e"], ":WritegoodEnable", "enable", 1)
  call SpaceVim#custom#SPC("nore", ["a", "w", "t"], ":WritegoodToggle", "toggle", 1)
endfunction

function! myspacevim#after() abort
  let g:deoplete#sources#go#gocode_binary = '/home/aray/go/bin/gocode'
endfunction
