require "accessibility"
-- 正则：播放%
if runtime.DEBUG then
    p = openAppByWord("网易云", true)
    waitForApp(p)
    args = {""}
    -- args = {"音乐"}
    -- args = {"本地音乐"}
    -- args = {"纸短情长"}
    -- args = {"每日推荐"}
    -- args = {"我喜欢的音乐"}
    -- args = {"周杰伦的歌"}
    -- args = {"遥远的歌"}
    -- args = {"多余的解释"}
-- args = {"许嵩的有何不可"} --不再支持
end
-- 播放本地音乐
function playLike()
    inMyMusic("我喜欢的音乐")
end
-- 播放本地音乐
function playLocal()
    if (not inMyMusic("本地音乐")) then
        speak("未发现本地音乐")
    end
end
-- 都是在我的音乐 点击 再点击播放的操作
function inMyMusic(name)
    local mm = ViewFinder().type("Tab").waitFor()
    mm.tryClick()
    ViewFinder().equalsText(name).waitFor(2000).tryClick()
    mm.tryClick()
    local a = ViewFinder().equalsText("播放全部").waitFor(2000)
    if (a) then
        a.tryClick()
        return true
    else
        return false
    end
end
-- 搜索内容
function search(text)
    search = ViewFinder().desc({"搜索", "Search"}).await()
    search.tryClick()

    s = ViewFinder().id("search_src_text").await()
    s.setText(text)

    -- 无法获取弹框视图
    bounds = s.bounds --(154, 87 - 1055, 185)[1920x1080]
    x = (bounds.left + bounds.right) / 2
    y = bounds.bottom + 100 --276
    sleep(1000)
    click(x, y) --fixme
    i = 0
    while (waitForText("加载中", 200)) do --等待结果出现
        sleep(200)
    end
    back()
    print("结果出现") -- 可能网络错误
    s = ViewFinder().containsText("网络未连接").await(100)
    if (s) then
        speak("没网啦")
        return false
    end
    return true
end

-- 搜索歌手 播放
function playSinger(s, singer)
    search(s)
    --检查列表有此歌s
    songItem = ViewFinder().similaryText(s).type("TextView").findFirst()
    if (songItem and songItem.tryClick()) then
        print("播放" .. s)
    else
        --若无点击歌手页，播放
        v = ViewFinder().equalsText("歌手").type("TextView").await(2000)
        print(v)
        v.tryClick()

        ViewFinder().type("TextView").containsText(singer).await(2000).tryClick() --查找歌手

        ViewFinder().type("TextView").equalsText("1").await(3000).tryClick() -- 第一首
    end
end

-- 搜索播放歌曲s
function playSong(s)
    print(s)
    if (not search(s)) then -- 搜索
        return
    end
    songItem = ViewFinder().similaryText(s).type("TextView").await(2000)
    if (songItem and songItem.tryClick()) then
        print("成功")
    else
        print("搜索失败")
        speak("搜索失败")
    end
end

-- 每日推荐
function playDialy()
    local tab = ViewFinder().type("Tab")
    tab.waitFor()
    local mm = tab.find()[1]
    mm.tryClick()
    waitForText("每日推荐", 1000).tryClick()
    waitForText("播放全部", 5000).tryClick()
end

-- 获取参数
local arg = args[1]
if (not arg or arg == "" or arg == "音乐") then
    mediaResume()
elseif (arg == "本地音乐") then
    playLocal()
elseif arg == "每日推荐" then
    playDialy()
elseif arg == "我喜欢的音乐" then
    playLike()
else
    -- 匹配 %的%
    local s = matchValues(arg, "%的%")
    if (s) then
        if (s[1] == "歌") then
            playSinger(arg, s[0])
        else
            playSong(arg) -- 可能为..的..
        end
    else
        playSong(arg)
    end
end
