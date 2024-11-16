
local DATA_FILE = 'samples/perceptron1_data.lua'
local ETA = 0.1

function training (x)
  local w = {}
  -- init weights
  for i = 0, #x[1] do
    w[i] = (2*math.random()-1) / 10
  end
  local weight_changed = true
  -- check and update
  while weight_changed do
    weight_changed = false
    for _, xj in ipairs(x) do
      local t, o = xj[0], w[0]
      -- current sum
      for i = 1, #xj do o = o + w[i]*xj[i] end
      o = (o > 0) and 1 or -1
      if o ~= t then
        -- update
        weight_changed = true
        for i = 1, #xj do w[i] = w[i] + ETA*(t-o)*xj[i] end
        w[0] = w[0] + ETA*(t-o)
      end
    end
  end
  return w
end

local function vec_2_str (x)
  local t = {}
  for i = 0, #x do
    t[#t+1] = ('%s%.5f'):format(i == 0 and '[0]=' or '', x[i])
  end
  return '{'.. table.concat(t, ', ') ..'}'
end

function load_and_check (fname)
  local gen = loadfile(fname)
  local data = gen()
  assert(data and #data > 0, "Wrong data structure")
  for i, x in ipairs(data) do
    assert(x[0], "t not defined")
    assert(#x == #data[1], "Different rows")
  end
  return data
end


-- execute
if  arg[0] == 'perceptron.lua'
then
  local input = load_and_check(DATA_FILE)
  local w = training(input)
  print( vec_2_str(w) )
end
