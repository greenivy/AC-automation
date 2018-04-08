local words = {}
local root = {
    Trie = {},
    fail = nil,
    text = "root"
}

local function insertWord(word, index)
    local tmp = root.Trie
    local final
    for k in string.gmatch(word, utf8.charpattern) do
        if tmp[k] == nil then
            tmp[k] = {Trie = {}, fail = nil, text = k}
        end
        final = tmp[k]
        tmp = tmp[k].Trie
    end
    final.index = index
    table.insert(words, word)
end

local function initWords()
    local f = io.open("./forbidden_words.txt", "r")
    local index = 1
    for word in f:lines() do
        insertWord(word, index)
        index = index + 1
    end
end

local function buildFailPoint()
    local q = {}
    table.insert(q, root)
    while #q > 0 do
        local now = table.remove(q, 1)
        for k,v in pairs(now.Trie) do
            if now == root then
                v.fail = root
            else
                local p = now.fail
                while p ~= nil do
                    if p.Trie[k] ~= nil then
                        v.fail = p.Trie[k]
                        break
                    end
                    p = p.fail
                end
                if p == nil then
                    v.fail = root
                end
            end
            table.insert(q, v)
        end
    end
end

local function matchWord(str)
    local ret = {}
    local now = root
    for k in string.gmatch(str, utf8.charpattern) do
        while not now.Trie[k] and now ~= root do
            now = now.fail
        end
        now = now.Trie[k]
        if not now then
            now = root
        end
        local p = now
        while p ~= root do
            if p.index then
                table.insert(ret, p.index)
            end
            p = p.fail
        end
    end
    return ret
end


initWords()
buildFailPoint()

local indexs = matchWord("hello, 我爱那个世界和你")
for _,v in ipairs(indexs) do
	print(words[v])
end
