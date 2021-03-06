if runtime.DEBUG then
    args = {"qq"}
    smartOpen("酷安")
end

settings = {
    --指令设置
    dl_auto_use_net = {title = "自动使用数据网络下载", summary = "如果提示", t = "checkbox", default = false}
}
config = registerSettings("coolapk_auto_dl", settings, 1)
if (#args < 1) then
    speak("下载什么")
    return
end

require "accessibility"
ViewFinder().id("menu_badge").waitFor(5000).parent.parent.tryClick()
waitForId("search_text", 2000).setText(args[1])
waitForId("search_button").tryClick()

n = ViewFinder().id("title_view").waitFor(7000) --等待网络加载完成
if (not n) then
    speak("失败啦") -- 直..
end

s = ViewFinder().id("title_view").containsText(args[1]).waitFor(6000) --查找第一个
print(s)
if (s) then
    s.tryClick()
    action_button = waitForId("action_button")
    if (action_button.text == "打开") then
        speak("已经下载过啦") --
    else
        action_button.tryClick()
        hint_dialog = ViewFinder().containsText("手机移动网络流量").waitFor(1000)
        if (hint_dialog and config.getBoolean("dl_auto_use_net")) then
            ViewFinder().equalsText("是").tryClick()
        end
    end
else
    speak("搜索失败")
end

print("ok")
