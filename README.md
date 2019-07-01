# markdown-image-paste-delete

## 本仓库说明

Atom贴图/删图工具

```
Something I hope you know before go into the coding~
* First, please watch or star this repo, I'll be more happy if you follow me.
* Bug report, questions and discussion are welcome, you can post an issue or pull a request.
```

## 使用方法

快捷键包括 **Ctrl+v** 和 **Ctrl+del**

* 截图工具截图，推荐 `Snipaste`
* Atom 打开markdown 文件，“**Ctrl+v**”粘贴
  - 方式一：**快速贴图**，**(不选中任何文字)直接**“**Ctrl+v**”粘贴
    - 优点：简单干脆，`大懒人模式`
    - 缺点：文件名根据时间戳生成，量多不好删改
  - 方式二：**命名贴图**，**选中文字区域作为图片文件名**，“**Ctrl+v**”粘贴
    - 优点：可以命名图片
    - 缺点：需要选中文字作为文件名
* 删除图片及Mardkwon图片链接，自动删除多余的空行
  - 光标移到Mardkwon图片链接所在行，“**Ctrl+del**”，删除当前行以及对应的图片

## 截图演示

![snapshot.gif](https://raw.githubusercontent.com/yifengyou/markdown-image-paste-delete/master/image/snapshot.gif)

![delimage.gif](https://raw.githubusercontent.com/yifengyou/markdown-image-paste-delete/master/image/delimage.gif)

![dellinesnapshot.gif](https://raw.githubusercontent.com/yifengyou/markdown-image-paste-delete/master/image/dellinesnapshot.gif)

## 注意

1. 方式一，删除光标所在行后粘贴，因此最好另起空白行粘贴，直接粘贴会删除当前行内容。
2. 方式一根据时间戳生成，海量图片每个粘贴都命名太麻烦了哟，这是个人习惯。
3. 方式二选中文字区域作为图片文件名，**必须要选中**再按快捷键，且选中文字符合命名规范。
4. 方式二中文件名规范，只包含字母数字下划线横杆。**托管仓库不支持中文路径和文件名**。
3. 默认存放在当前工作路径的`image`文件夹下，可在设置中修改存放路径，遵守命名规范。
4. 存放路径只限本地，再传 GitHub 之类仓库托管，没有传图床的习惯。
5. **不支持动图**，所有截图转成 PNG 格式。能搞动图岂不更好玩，想想办法后面改进~
6. **不支持 Win 本地图片复制粘贴 **，会报错误粘贴板为空，怎么破？
7. 支持 QQ 、微信聊天窗口图片复制粘贴

## 推荐 Snipaste 截图神器

![1561429590195.png](https://raw.githubusercontent.com/yifengyou/markdown-image-paste-delete/master/image/1561429590195.png)

![1561429523195.jpg](https://raw.githubusercontent.com/yifengyou/markdown-image-paste-delete/master/image/1561429523195.jpg)

`我懒懒的搞了别人动图过来~~`

- <https://zh.snipaste.com>
- <https://www.52pojie.cn/thread-690279-1-1.html>


## 改进

1. 动图，复制动图粘贴会转PNG格式且变成静图


## 参考

- <https://github.com/nmecad/markdown-img-paste>
- <https://github.com/cocoakekeyu/markdown-img-paste>

##
