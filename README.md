JX3Clouds
=========

Clouds JX3 Interface
剑网三流云插件集

UIEditor
--------
插件界面编辑器 By Danexx [24713503]
教程参见 http://bbs.178.com/thread-6943318-1-1.html 

修改 By Clouds
1. 添加保存功能，自动保存到"examples"文件夹
   生成"LastOpen","%f.tmp","%f.end","%f.inic"四个文件（其中%f为Frame名称）
2. 自动从LastOpen获取上次打开的文件
   依次读取".tmp",".end",".inic"文件试图还原工程
3. 工具"chop.lua","chopd.lua"分别提供".inic"至".ini"文件的转换及其逆操作
   文件名默认从"LastOpen"读取
   生成的".ini"文件可直接使用"Wnd.OpenWindow"打开
4. 可将任意".ini"文件通过"chopd.lua"生成".inic"文件
   手动设置"LastOpen"，输入`data="%f"`
   加载UIEditor进入游戏即可观察该".ini"文件的结构并修改
   注：可能有数据损失
