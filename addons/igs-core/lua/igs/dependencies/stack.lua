local link = {}
local mt = {
	__index = link,
}

function link:length()
	return self.tail - self.head + 1
end

function link:isempty()
	return self:length() == 0
end


function link:peek()
	return self.data[self.head]
end

function link:lpush(v)
	self.tail = self.tail + 1
	self.data[self.tail] = v
end

function link:rpush(v)
	self.head = self.head - 1
	self.data[self.head] = v
end

function link:lpop()
	if self.head > self.tail then return nil end
	local v = self.data[self.tail]
	self.data[self.tail] = nil
	self.tail = self.tail - 1
	return v
end

function link:rpop()
	if self.head > self.tail then return nil end
	local v = self.data[self.head]
	self.data[self.head] = nil
	self.head = self.head + 1
	return v
end

function IGStack(...)
	return setmetatable({
		head = 1,
		tail = select("#",...),
		data = {...},
	}, mt)
end


-- local S = IGStack()
-- S:lpush(1) S:lpush(2) S:lpush(3) -- 3 < 2 < 1
-- PRINT({len = S:length(), head = S:rpop(), tail = S:lpop()}) -- 1 3
-- S:rpush(1) S:lpush(3) S:lpush(4) -- вернули, что забрали и добавили слева 4
-- PRINT({len = S:length(), head = S:rpop(), all = S:table()})
