UIEditor
========
插件界面编辑器 By **Danexx** [24713503]

教程参见 http://bbs.178.com/thread-6943318-1-1.html 

修改 By **Clouds**

* 添加保存功能，自动保存到`examples`文件夹
     * 会根据ini名称`filename`在`examples\filename\`目录下生成`project`,`filename.inic`,`filename.tmp`,`filename.end`文件

*  游戏内添加文件切换`UIEditor`左上角`文件`下拉菜单
     * `打开`命令可以打开/新建文件
     * `保存`可以强制保存当前文件
     * `压缩`会放弃撤销记录只保存最后更改（当前所在状态）

*  自动从`workspace`读取`project`列表并获取上次打开的文件，
     * 依次读取`.tmp`,`.end`或`.inic`文件试图还原工程

*  工具`examples\chop.lua`,`examples\chopd.lua`分别提供`.inic`和`.ini`文件之间的转换
     * 文件名默认从`workspace`的`lastopen`读取
     * 生成的`.ini`文件可直接使用`Wnd.OpenWindow`打开
     * 生成的`.inic`文件可以用游戏中`UIEditor`的`打开`操作打开

*  新增`tmp`工作区
     * 该工作区下的文件如果不修改不会新建目录
     * `UIEditor`使用`打开`命令`tmp:filename`则会打开
     * `chop`与`chopd`会处理`workspace.lastopen`中的`tmp:`标签

*  手动修改`workspace`文件
     * `projects`：`#table`，按自然序号保存`filename`
     * `tmp`：`#table`，按自然序号保存`filename`
     * `lastopen`：`#string`，`[tmp:]filename`
     * 第一行修改为`data = {`


附注
----
* 可能有数据损失（极罕见情况会损失非空字串建议[联系我们](mailto:ztq56@126.com)）
* 可能会有数据顺序改变（一般无影响）
