--[[  FindS algorithm for binary data

Find general hypothesis that describes the given observations.

Book: "Самообучающиеся системы", Николенко, Тулупьев
Chapter: 2

2024, Stanislav Mikhel ]]


local DATA_FILE = 'samples/id3_data.lua'
local ANY, NONE = '?', '#'

--- Select rows with the given parameter value.
--  @param arr data list.
--  @param val goal state.
--  @return table with found rows and list of column numbers.
local function positive (arr, val)
  local res, ids = {}, {}
  -- positive samples
  for _, v in ipairs(arr) do
    if v[arr.goal] == val then res[#res+1] = v end
  end
  -- column numbers
  for i = 1, #arr.names do
    if i ~= arr.goal then ids[#ids+1] = i end
  end
  return res, ids
end

--- Looking for the general hypothesis.
--  @param arr data list.
--  @param val goal state.
--  @return parameter status list and parameter index list.
function find_s (arr, val)
  -- filter
  local tests, ids = positive(arr, val)
  local hyp = {}
  if #tests == 0 then
    return hyp, ids
  end
  -- init
  for i, id in ipairs(ids) do hyp[i] = tests[1][id] end
  -- fill the rest
  for j = 2, #tests do
    local vj = tests[j]
    for i, id in ipairs(ids) do
      local hi = hyp[i]
      if hi ~= ANY then
        -- compare with previous value
        if vj[id] ~= hi then hyp[i] = ANY end
      end
    end
  end
  return hyp, ids
end

--- Read input file, check data.
--  @param fname file name to read.
--  @return Lua table with data.
function load_and_check (fname)
  local gen = loadfile(fname)
  local data = gen()
  assert(data and data.names and data.goal and data.names[data.goal], 
    "Wrong data structure")
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
      ('Extected 2 values for parameter %s, found %d'):format(data.names[i], k))
  end
  return data
end


-- ======= main logic =======
if arg[0] == 'find_s.lua' then
  local input = load_and_check(DATA_FILE)
  -- search
  local goal_val = input[1][input.goal]
  local hyp, ids = find_s(input, goal_val)
  -- names
  local names = {}
  for i, id in ipairs(ids) do names[i] = input.names[id] end
  print( ('(%s)'):format(table.concat(names, '|')) )
  -- show result
  print( ('(%s)'):format(table.concat(hyp, ', ')) )
end

