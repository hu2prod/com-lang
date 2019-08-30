module = @
require 'fy'
require 'fy/codegen'
@coffee_script_module = require 'iced-coffee-script'

# LATER
# {tag_hash} = require 'html-tag-collection'
# @tag_hash = tag_hash

# missed intentionally. Probably will add later
# @VERSION
# @FILE_EXTENSIONS
# @helpers
# withPrettyErrors ??

@_HACK_preprocess_arrow = (token_list, opt)->
  new_token_list = []
  for token in token_list
    if token.generated
      # fix if a then b else c case
      if token[0] == 'INDENT' and token.origin?[0] == 'THEN'
        new_token_list.push token.origin
      continue
    new_token_list.push token
  token_list = new_token_list
  
  new_token_list = []
  token_idx = 0
  parse_stream = (is_root = false, string_magic = true)->
    while token = token_list[token_idx++]
      if token[0] == 'TERMINATOR'
        new_token_list.push token
        continue
      if token[0] == 'IDENTIFIER' and string_magic
        new_token_list.push token
        parse_id_string()
        continue
      token_idx--
      while token = token_list[token_idx++]
        if token[0] == 'TERMINATOR' # can string_magic again
          new_token_list.push token
          break
        if token[0] in [ '->', '=>']
          string_magic = true
        if token[0] in [ '}', 'OUTDENT']
          new_token_list.push token
          # p "parse_stream > #{token[0]}"
          return
        if token[0] in ['{']
          new_token_list.push token
          parse_stream(false, false)
          continue
        if token[0] in ['INDENT']
          new_token_list.push token
          parse_stream(false, string_magic)
          continue
        new_token_list.push token
      if !token
        ### !pragma coverage-skip-block  ###
        throw new Error "unexpected token stream end"
    return
    
  parse_id_string = ()->
    # lone token policy
    token = token_list[token_idx]
    if token[0] in ['OUTDENT', 'TERMINATOR'] # HERE comes magic
      if opt.lone_tag_filter and !opt.tag_hash[new_token_list.last()[1].toUpperCase()]
        return
      if token[0] != 'OUTDENT'
        token_idx++
      new_token_list.last().newLine = false
      new_token_list.last().spaced = true
      new_token_list.push proxy = ['=>', '=>']
      proxy.newLine = true
      new_token_list.push token if token[0] == 'TERMINATOR'
      return
    if token[0] in ['{'] # HERE comes magic
      new_token_list.last().spaced = true
      
    string_magic =  true
    loc_idx = -1
    while token = token_list[token_idx++]
      loc_idx++
      if token[0] in ['=', ':', '->', '=>', '[', '('] # magic disablers
        new_token_list.push token
        string_magic = false
        continue
      
      if token[0] == 'INDENT' and string_magic # HERE comes magic
        new_token_list.last().newLine = false
        if loc_idx == 0
          new_token_list.last().spaced = true
          new_token_list.push proxy = ['=>', '=>']
          proxy.newLine = true
        else
          new_token_list.push [',', ',']
          new_token_list.push proxy = ['=>', '=>']
          proxy.newLine = true
        new_token_list.push token
        parse_stream()
        continue
      if token[0] in ['{']
        new_token_list.push token
        parse_stream(false, false)
        continue
      if token[0] in ['INDENT']
        new_token_list.push token
        parse_stream()
        continue
        
      if token[0] in [ '}', 'OUTDENT', 'TERMINATOR']
        token_idx--
        return
      new_token_list.push token
    ### !pragma coverage-skip-next  ###
    p new_token_list
    ### !pragma coverage-skip-next  ###
    throw new Error "unexpected token stream end"
  
  parse_stream(true)
  
  token_list = new_token_list
  code_chunk_list = []
  indent_list = []
  indent_get = ()->
    count = 0
    for val in indent_list
      count += val
    ' '.repeat count # NOTE thinks that indent is spaces. No code execution impact
  
  for token,idx in token_list
    if token[0] == 'INDENT'
      code_chunk_list.push ' '.repeat token[1]
      indent_list.push token[1]
      continue
    if token[0] == 'OUTDENT'
      ### !pragma coverage-skip-next  ###
      if indent_list.length == 0
        throw new Error "too much OUTDENT"
      indent_list.pop()
      continue
    if token[0] == 'HERECOMMENT'
      code_chunk_list.push make_tab "####{token[1]}###", indent_get()
      continue
    if token[0] == 'JS'
      code_chunk_list.push "`#{token[1]}`"
      continue
    if token[0] == 'TERMINATOR'
      code_chunk_list.push token[1]+indent_get()
      continue
    code_chunk_list.push token[1]
    if token.spaced # NOTE. shrink multiple spaces. No code execution impact
      code_chunk_list.push " "
    if token.newLine # it's very good putting out code 1-1, so need some workaround
      if next_token = token_list[idx+1]
        # LOOKUP OUTDENT
        loc_idx = idx+1
        loc_indent_list = indent_list.clone()
        while (next_token = token_list[loc_idx++]) and (next_token[0] == "OUTDENT")
          loc_indent_list.pop()
        if next_token?[0] != 'TERMINATOR'
          count = 0
          for val in loc_indent_list
            count += val
          indent = ' '.repeat count
          code_chunk_list.push "\n"+indent
  code_chunk_list.join ''

@compile = (code, options={})->
  token_list = @coffee_script_module.tokens code, options
  code = module._HACK_preprocess_arrow token_list, options
  @coffee_script_module.compile code, options
# @tokens
# @nodes
@run = (code, options={})->
  token_list = @coffee_script_module.tokens code, options
  code = module._HACK_preprocess_arrow token_list, options
  @coffee_script_module.run code, options

@eval = (code, options={})->
  token_list = @coffee_script_module.tokens code, options
  code = module._HACK_preprocess_arrow token_list, options
  @coffee_script_module.eval code, options

# @register
# @_compileFile
# @iced = iced_runtime
