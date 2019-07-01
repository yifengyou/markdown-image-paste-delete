{CompositeDisposable} = require 'atom'
{dirname, join} = require 'path'
clipboard = require 'clipboard'
fs = require 'fs'


module.exports =
    subscriptions : null

    activate : ->
      @subscriptions = new CompositeDisposable
      @subscriptions.add atom.commands.add 'atom-workspace',
            'markdown-image-paste-delete:paste' : => @paste()
      @subscriptions.add atom.commands.add 'atom-workspace',
            'markdown-image-paste-delete:namedpaste' : => @namedpaste()
      @subscriptions.add atom.commands.add 'atom-workspace',
            'markdown-image-paste-delete:delImage' : => @delImage()

    deactivate : ->
        @subscriptions.dispose()

    paste : ->
        try
          if !cursor = atom.workspace.getActiveTextEditor() then return
          text = clipboard.readText()
          # 保证文本黏贴正常使用
          if(text)
            editor = atom.workspace.getActiveTextEditor()
            editor.insertText(text)
            return

          # 文件类型检测，根据扩展名
          fileFormat = ""
          if !grammar = cursor.getGrammar() then return
          if cursor.getPath()
              # We are in a markdown file
              if  cursor.getPath().substr(-3) == '.md' or
                  cursor.getPath().substr(-9) == '.markdown' and
                  grammar.scopeName != 'source.gfm'
                      fileFormat = "md"
              # We are in a RST file
              else if cursor.getPath().substr(-4) == '.rst' and
                  grammar.scopeName != 'source.gfm'
                      fileFormat = "rst"
          else
              if grammar.scopeName != 'source.gfm' then return

          # clipboard扩展读取粘贴板图片内容
          img = clipboard.readImage()
          # 空内容处理
          if img.isEmpty()
            if atom.config.get 'markdown-image-paste-delete.infoalertenable'
              atom.notifications.addError(message = '快速贴图失败', {detail:'粘贴板为空'})
            return

          editor = atom.workspace.getActiveTextEditor()
          position = cursor.getCursorBufferPosition()

          filenamecandidate = atom.workspace.getActiveTextEditor().getSelectedText()
          # 检测选中区域是否可以构成文件名
          filenamePattern = /// ^[0-9a-zA-Z-_]+$ ///
          if filenamecandidate.match filenamePattern
            messagecontent = "命名贴图成功"
            filename = filenamecandidate
          else
            messagecontent = "快速贴图成功"
            filename = new Date().format()

          filenameNosuffix = filename
          # 添加文件名后缀
          filename += ".png"

          # 如果当前行就是空白行，直接插入，否则删除行内容插入
          if !cursor.getBuffer().isRowBlank(position.row)
              # 修改光标在删除行上一行尾部，从尾部插入图片链接代码
              position.column = 0
              cursor.setCursorBufferPosition position
              # 删除光标之后行的内容
              editor.deleteToEndOfLine(true)
          # 设定文件存放子目录
          curDirectory = dirname(cursor.getPath())
          # Join adds a platform independent directory separator
          fullname = join(curDirectory, filename)

          subFolderToUse = ""
          if atom.config.get 'markdown-image-paste-delete.use_subfolder'
            # 根据设置获取子目录文件名
            subFolderToUse = atom.config.get 'markdown-image-paste-delete.subfolder'
            if subFolderToUse != ""
              assetsDirectory = join(curDirectory, subFolderToUse)
              # 如果子目录不存在则创建之
              if !fs.existsSync assetsDirectory
                fs.mkdirSync assetsDirectory
              # 文件完整路径名
              fullname = join(assetsDirectory, filename)

          # 如果下一行不为空，则添加一个空行分割开来
          textd = ""
          if !cursor.getBuffer().isRowBlank(parseInt(position.row + 1))
            textd += "\r\n"

          # 插入图片代码，如果上一行不为空，则添加一个空行分割开来
          textb = ""
          if !cursor.getBuffer().isRowBlank(parseInt(position.row - 1))
            textb += "\r\n"
            position.row = parseInt(position.row + 1)

          # markdown图片文件链接代码生成
          if(fileFormat == "md")
            text += '![' + filenameNosuffix + ']('
            text += join(subFolderToUse, filename) + ') '
          # rst图片文件链接代码生成
          else if (fileFormat == "rst")
            text += ".. figure:: "
            text += join(subFolderToUse, filename) + '\r\n'
            text += "\t :alt: " + filename

          # 将反斜杠改成斜杠，这样在github和gitbook上都可以正常显示
          text = text.replace(/\\/g, "/");
          position.column = text.length
          text = textb + text + textd

          # 写图片到文件系统 img.toPng() 这个地方会造成错误，版本问题
          # 如果不灵光，就要 ctrl+shift+i 查看日志
          fs.writeFileSync fullname, img.toPNG()
          # 写代码到光标行
          cursor.insertText text
          cursor.setCursorBufferPosition position
          if atom.config.get 'markdown-image-paste-delete.infoalertenable'
            if atom.config.get 'markdown-image-paste-delete.infoalertenable'
              atom.notifications.addSuccess(message = messagecontent, {detail:'文件促存放路径:' + fullname})
        # 捕获错误异常
        catch error
            if atom.config.get 'markdown-image-paste-delete.infoalertenable'
              atom.notifications.addError(message = '贴图失败', {detail:'错误原因:' + error})

    delImage : ->
        try
          if !cursor = atom.workspace.getActiveTextEditor() then return

          # 检测当前文件是否为md文件，否则执行原有快捷键方式
          fileFormat = ""
          if !grammar = cursor.getGrammar() then return
          if cursor.getPath() and
             cursor.getPath().substr(-3) == '.md' or
                  cursor.getPath().substr(-9) == '.markdown' and
                    grammar.scopeName != 'source.gfm'
                      fileFormat = "md"
          else
              # 当前不在markdown文件中,执行原有操作
              cursor.deleteToEndOfWord()
              return


          # 选中图片代码区域，按快捷键ctrl-delete
          selectedToDelImg = cursor.lineTextForBufferRow(cursor.getCursorBufferPosition().row)
          # 删掉当前行的空白字符
          selectedToDelImg = selectedToDelImg.replace(/\s/g, "");
          # 检测当前行是否为图片md链接
          markdownImageLinkPattern = /// ^!\[[0-9a-zA-Z-_]+\]\([0-9a-zA-Z-_/]+\.png\)$ ///
          if !selectedToDelImg.match markdownImageLinkPattern
            # 当前在markdown文件中，但是光标所在行不是md链接
            cursor.deleteToEndOfWord()
            return
          # 提取文件名

          filename = selectedToDelImg.substring( selectedToDelImg.indexOf('(') + 1 , selectedToDelImg.indexOf(')') )
          curDirectory = dirname(cursor.getPath())
          fullname = join(curDirectory, filename)

          # 检验文件存在与否
          if !fs.existsSync fullname
            if atom.config.get 'markdown-image-paste-delete.infoalertenable'
              atom.notifications.addError(message = '删除失败', {detail:'文件不存在，其完整路径名:' + fullname })
            return

          # 删除文件，删除当前行内容
          fs.unlink fullname, (error) ->
            if error
              if atom.config.get 'markdown-image-paste-delete.infoalertenable'
                atom.notifications.addError(message = '删除失败', {detail:'原因:' + error})
              return
            else
              if atom.config.get 'markdown-image-paste-delete.infoalertenable'
                atom.notifications.addSuccess(message = '删除成功', {detail:'[' + fullname + ']已被删除'})
              cursor.deleteLine()
          # 删除多余空白行
          position = cursor.getCursorBufferPosition()
          if cursor.getBuffer().isRowBlank(position.row + 1 ) &&
            cursor.getBuffer().isRowBlank(position.row - 1)
              cursor.deleteLine()
        # 捕获错误异常
        catch error
          if atom.config.get 'markdown-image-paste-delete.infoalertenable'
              atom.notifications.addError(message = '删除失败', {detail:'错误原因:' + error})

# 光标所在处插入text，光标移动到文本末尾
paste_text = (cursor, text) ->
    cursor.insertText text
    position = cursor.getCursorBufferPosition()
    #position.row = position.row - 1 就在光标所在行操作，无需上一行
    position.column = position.column + text.length + 1
    cursor.setCursorBufferPosition position


# 时间格式化
Date.prototype.format = ->
    # 保证两位数字显示，小于10前加'0'，大于100除10取整
    shift2digits = (val) ->
        if val < 10
            return "0#{val}"
        else if val > 99
            return parseInt(val/10)
        return val

    year = @getFullYear()
    month = shift2digits @getMonth()+1
    day = shift2digits @getDate()
    hour = shift2digits @getHours()
    minute = shift2digits @getMinutes()
    second = shift2digits @getSeconds()
    ms = shift2digits @getMilliseconds()

    return "#{year}#{month}#{day}_#{hour}#{minute}#{second}_#{ms}"
