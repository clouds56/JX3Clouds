--注意这个插件默认不加载要手动点加载
--修改function Clouds_Test.test()的内容
--然后新建宏 /Clouds_Test
--保存文件后记得使用宏 /ReloadUI （或快捷键）重载
--使用宏 /SwitchDebug 打开关闭调试信息
--如果闪退或者无响应请关闭其他插件试试（尤其是盒子）
--仔细阅读注释，完成任务（这算半个插件）

Clouds_Test = {
	version = "0.1",
	DebugOn = false,--当为true时开启lua错误报警，会在聊天栏警报lua错误慎重使用
}
--一般都会把插件所有除了本地(local)的变量、函数以外所有东西都放在一个table里方便管理
--这个table的名字最好独一无二

function Clouds_Test.Msg(szMsg)
	OutputMessage("MSG_SYS","[Test]"..szMsg:gsub("\n","").."\n")
end
--e.g. Clouds_Test.Msg("这里是调试信息 version:"..Clouds_Test.version)

function Clouds_Test.Msgs(szMsg)
	OutputMessage("MSG_SYS","[Test]"..szMsg.."\n")
end

function Clouds_Test.test()
	local me = GetClientPlayer()
	Clouds_Test.Msg("欢迎["..me.szName.."]使用流云调试器")

	--TODO: your code added here
	--任务: 运行这个函数：
	--1.若自己的目标的职业是【少林】时密聊对方【大师需要[从来不用]么~】
	--2.否则在队伍里说【这年头卖把梳子都这么累可怜的[（我）]啊】
	--这里【从来不用】是荻花宫掉落的一件武器，最好做成可以点开查看属性的样式
	--【我】替换成我的名字，最好做成右击可以组队的样式

end

function Clouds_Test.timer()
	--Clouds_Test.Msg("timer @ "..GetLogicFrameCount())
	--这个函数每秒被调用一次，不信你可以把上面一行注释掉（刷屏后果自负随时准备CSA~）
end

function Clouds_Test.Reload()
	Clouds_Test.Msg("Reloading@"..GetLogicFrameCount())
	ReloadUIAddon()
end

Hotkey.AddBinding("Test_Reload", "重启界面","测试调试器",function()
	Clouds_Test.Reload()
end,nil)
Hotkey.Set("Test_Reload",1,458944,true,true,true)
--这两个函数是热键绑定用的，具体参数看xlsx的UI接口一栏（注意有多个表格）
--默认热键是Ctrl+Shift+Alt+Oem3，就是1旁边那个键
--尽量使用这个热键，或者使用宏 /script Clouds_Test.Reload() 或 /ReloadUI
--有提示可以看到是重载前/后出的问题
--如果热键不能用说明加载失败（语法错误而不是运行时错误）

local tErr={}
--这就是本地变量，我用了保存各个错误出现次数，看下面的算法，有一定的防刷屏机制
function Clouds_Test.ShowError(szErr)
	if not Clouds_Test.DebugOn then
		return
	end
	szErr = szErr or arg0
	local count=tErr[szErr] or 0
	tErr[szErr]=count+1
	if count<10 or (count<1000 and count%100==0) or count%1000==0 then
		Clouds_Test.Msgs(szErr)
	end
end

function Clouds_Test.ChangeDebug()
	Clouds_Test.DebugOn =  not Clouds_Test.DebugOn
	--not nil == true
	--not Clouds_Test == false
	Clouds_Test.Msg(("调试已 [%s]"):format(Clouds_Test.DebugOn and "开" or "关"))
	--或者完整的写成 string.format("调试已 [%s] @ %d","开",GetLogicFrameCount())
	--和printf语法相似
end

AppendCommand("Clouds_Test", Clouds_Test.test)
AppendCommand("ReloadUI", Clouds_Test.Reload)
AppendCommand("SwitchDebug", Clouds_Test.ChangeDebug)
--这两个是新增宏的语句
--在聊天栏输入 /Clouds_Test 即运行 Clouds_Test.test()
--另外两个同理(类似于 /roll)
--函数参数可在xlsx的全局接口找到
--宏命令可以自行修改（注意别和其他插件冲突）

--下面三个函数一个语句是窗口相关的
--等看玩了小雪的（一）差不多能理解了
function Clouds_Test.OnFrameCreate()
	this:RegisterEvent("CALL_LUA_ERROR")
end

function Clouds_Test.OnFrameBreathe()
	if GetLogicFrameCount()%16==0 then
		Clouds_Test.timer()
	end
end

function Clouds_Test.OnEvent(event)
	if event=="CALL_LUA_ERROR" then
		Clouds_Test.ShowError(arg0)
	end
end

Wnd.OpenWindow("interface\\Clouds_Test\\Clouds_Test.ini","Clouds_Test")

Clouds_Test.Msg("加载完成")
--看到聊天栏有加载完成才算加载完成
--不然就有语法错误
--语法错误可以通过SciTe的运行按钮检查出来
