--[[  ID3 for binary data

Book: "Самообучающиеся системы", Николенко, Тулупьев
Chapter: 1
Input: samples/id3_data.lua

2024, Stanislav Mikhel ]]


local LOG2 = math.log(2)

--- Find enthropy.
--  @param n   number of elements in first state.
--  @param tot total number of elements in both states.
--  @return found value.
local function enthropy (n, tot)
  if n == 0 or n == tot then return 0 end
  return -(n/tot)*math.log(n/tot)/LOG2
    - ((tot-n)/tot)*math.log((tot-n)/tot)/LOG2
end

--- Change in enthropy after adding new criteria.
--  @param arr data list.
--  @param n   column index.
--  @return gain value.
local function gain (arr, n)
  -- use first line as identificator
  local goal = arr[1][arr.goal]
  local pos = arr[1][n]
  -- count
  local k1, k2 = 0, 0
  local k1_goal, k2_goal = 0, 0
  local k_goal = 0
  for i, v in ipairs(arr) do
    is_goal = v[arr.goal] == goal
    if is_goal then k_goal = k_goal + 1 end
    if v[n] == pos then
      k1 = k1 + 1
      if is_goal then k1_goal = k1_goal + 1 end
    else
      k2 = k2 + 1
      if is_goal then k2_goal = k2_goal + 1 end
    end
  end
  local sum = enthropy(k1_goal, k1)*k1/#arr 
            + enthropy(k2_goal, k2)*k2/#arr
  return enthropy(k_goal, #arr) - sum
end

--- Divide data into two parts, 'positive' and 'negative'.
--  @param arr source array.
--  @param n   column index.
--  @return first list, second list, first value, second value
local function split (arr, n)
  -- copy common parts
  local a = {names=arr.names, goal=arr.goal}
  local b = {names=arr.names, goal=arr.goal}
  local x, y = arr[1][n], nil
  for _, v in ipairs(arr) do
    if v[n] == x then 
      table.insert(a, v) 
    else 
      y = v[n]
      table.insert(b, v) 
    end
  end
  return a, b, x, y
end

--- Apply ID3 algorithm for data classification.
--  Print binary tree for decision making.
--  @param arr     data array.
--  @param ntab    number of displacement steps.
--  @param visited list of used criteria.
local function id3 (arr, ntab, visited)
  local upd = {}
  local max, val = 0, 0
  for i = 1, #arr[1] do
    if visited[i] then
      upd[i] = true  -- make copy
    else
      -- find highest gain
      local g = gain(arr, i)
      if g > val then
        max, val = i, g
      end
    end
  end
  local majority = nil
  do 
    -- current goal status
    local a, b, x, y = split(arr, arr.goal)
    majority = (#a > #b) and x or y
  end
  local disp = string.rep(' ', 2*ntab)
  if max == 0 then 
    return print(disp .. majority)
  end
  upd[max] = true
  -- show tree
  local a, b, x, y = split(arr, max)
  print(disp .. string.format('%s=%s', arr.names[max], x))
  if #a == 0 then
    print(disp .. majority)
  else
    id3(a, ntab+1, upd)
  end
  print(disp .. string.format('%s=%s', arr.names[max], y))
  if #b == 0 then
    print(disp .. majority)
  else
    id3(b, ntab+1, upd)
  end
end

--- Read input file, check data.
--  @param fname file name to read.
--  @return Lua table with data.
local function load_and_check (fname)
  local gen = loadfile(fname)
  local data = gen()
  assert(data and data.names and data.goal and data.names[data.goal], "Wrong data structure")
  assert(#data > 0, "Wrong table len")
  local n = #data.names
  for i = 1, n do
    local t, k = {}, 0
    for j, v in ipairs(data) do
      local key = assert(v[i], "Wrong length of row " .. tostring(i))
      if not t[key] then
        t[key], k = true, k+1
      end
    end
    assert(k == 2, 
      string.format('Extected 2 values for parameter %s, found %d', data.names[i], k))
  end
  return data
end

--==========================


local input = load_and_check('samples/id3_data.lua')

print(string.format('%s = ?\n', input.names[input.goal]))

local visited = {[input.goal] = true}
id3(input, 0, visited)

