--[[  Perceptron training methods

Apply training methods to find weights for linear function.

Book: "Самообучающиеся системы", Николенко, Тулупьев
Chapter: 3

2024, Stanislav Mikhel ]]


local DATA_FILE = 'samples/perceptron1_data.lua'
local ETA = 0.1

--- Simple difference based training.
--  @param x list of samples {output, in1, in2, ...}
--  @return list of weights {w0, w1, w2, ...}
function training (x)
  local w = {}
  -- init weights
  for i = 0, #x[1] do
    w[i] = 0.1*(2*math.random()-1)  -- -0.1 ... 0.1
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
        for i = 1, #xj do 
          w[i] = w[i] + ETA*(t-o)*xj[i] 
        end
        w[0] = w[0] + ETA*(t-o)  -- xj[0] set 1
      end
    end
  end
  return w
end

--- Gradient descent based perceptron training.
--  @param x list of samples {output, in1, in2, ...}
--  @param steps required number of steps
--  @return list of weights {w0, w1, w2, ...}
function training_gradient_descent (x, steps)
  local number_of_steps = steps or 10
  local w, deltaw = {}, {}
  -- init weights
  for i = 0, #x[1] do
    w[i] = 0.1*(2*math.random()-1)  -- -0.1 ... 0.1
    deltaw[i] = 0
  end
  -- find gradient and upate
  for k = 1, number_of_steps do
    for i = 0, #deltaw do deltaw[i] = 0 end
    for _, xj in ipairs(x) do
      local t, o = xj[0], w[0]
      -- sum
      for i = 1, #w do o = o + w[i]*xj[i] end
      -- gradient
      for i = 1, #w do 
        deltaw[i] = deltaw[i] + ETA*(t-o)*xj[i] 
      end
      deltaw[0] = deltaw[0] + ETA*(t-o)  -- xj[0] set 1
    end
    -- update
    for i = 0, #w do w[i] = w[i] + deltaw[i] end
  end
  return w
end

--- Pretty print for a vector started from 0.
--  @param x vector to show.
--  @return string with the vector values.
local function vec_2_str (x)
  local t = {}
  for i = 0, #x do
    t[#t+1] = ('%s%.5f'):format(i == 0 and '[0]=' or '', x[i])
  end
  return '{'.. table.concat(t, ', ') ..'}'
end

--- Read input file, check data.
--  @param fname file name to read.
--  @return Lua table with data.
function load_and_check (fname)
  local gen = loadfile(fname)
  local data = gen()
  assert(data and #data > 0, "Wrong data structure")
  for i, x in ipairs(data) do
    assert(x[0], "goal not defined")
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
  w = training_gradient_descent(input)
  print( vec_2_str(w) )
end

