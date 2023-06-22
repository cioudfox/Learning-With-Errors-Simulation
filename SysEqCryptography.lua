math.randomseed( os.time() )

-- Private Key: Values for Variables(V,X,Y,Z)
local privatekey = {10, 5, 15, 30}

--[[ Changeable Values
     - sysEq: Table for system of equations
     - modVal: Prime number for Modular Calculations
     - Alphabet Size: Size of the Alphabet(A-Z = 26 characters)
     - Offset Value: Possible distance of error
       - Offset < [(alphsize) / (Variable number)]
       - 5 < [(523 / 26) / 4 ]   =>   5 < 5.02
]]

local sysEq = {}
local modVal = 523
local alphsize = modVal // 26
local offsetVal = 5

-- original msg -> HELLOWORLD
-- msg2: returned equation after encoding
local msg = {8,5,12,12,15,23,15,18,12,4}
local msg2 = {}

function generateLists()
  for i = 1,1000
  do
    -- Eq V + X + Y + Z
    local foo = {math.random(100),math.random(100),math.random(100),math.random(100)}
    -- Summation + Error mod 257
    local summ = ( (foo[1] * privatekey[1]) + (foo[2] * privatekey[2])
                  + (foo[3] * privatekey[3]) + (foo[4] * privatekey[4])
                  + math.random(offsetVal) ) % modVal

    sysEq[i] = {foo[1],foo[2],foo[3],foo[4],summ} 
  end
end


function generateEncoded()
  --Selection of 5 different unique indexes
  for i = 1, #msg
  do
  local i1 = math.random(200)
  local i2 = math.random(201,400)
  local i3 = math.random(401,600)
  local i4 = math.random(601,800)
  local i5 = math.random(801,1000)
  
  local foo = {sysEq[i1][1] + sysEq[i2][1] + sysEq[i3][1] + sysEq[i4][1] + sysEq[i5][1],
               sysEq[i1][2] + sysEq[i2][2] + sysEq[i3][2] + sysEq[i4][2] + sysEq[i5][2],
               sysEq[i1][3] + sysEq[i2][3] + sysEq[i3][3] + sysEq[i4][3] + sysEq[i5][3],
               sysEq[i1][4] + sysEq[i2][4] + sysEq[i3][4] + sysEq[i4][4] + sysEq[i5][4]
  }

  -- Sum of Summation Values
  local tempval = ((sysEq[i1][5] + sysEq[i2][5] + sysEq[i3][5] + sysEq[i4][5] + sysEq[i5][5]) % modVal)
  
  --[[ Partition of Equations 
       - Public Information:
         - List of 1000 equations with Errors
         - All results in the RHS of the "=" are values modulus 257
       - Bob selects a random partition of equations(5 in this example)
       - Sum up the 5 equations to formulate a new Equation
    ]]
  print("\nIndex Selection for Character #" .. i)
  print("Equation 1 : " .. sysEq[i1][1] .. "v + " .. sysEq[i1][2] .."x + " ..
        sysEq[i1][3] .. "y + " .. sysEq[i1][4] .. "z = " .. (sysEq[i1][5] % modVal))
  print("Equation 2 : " .. sysEq[i2][1] .. "v + " .. sysEq[i2][2] .."x + " ..
        sysEq[i2][3] .. "y + " .. sysEq[i2][4] .. "z = " .. (sysEq[i2][5] % modVal))
  print("Equation 3 : " .. sysEq[i3][1] .. "v + " .. sysEq[i3][2] .."x + " ..
        sysEq[i3][3] .. "y + " .. sysEq[i3][4] .. "z = " .. (sysEq[i3][5] % modVal))
  print("Equation 4 : " .. sysEq[i4][1] .. "v + " .. sysEq[i4][2] .."x + " ..
        sysEq[i4][3] .. "y + " .. sysEq[i4][4] .. "z = " .. (sysEq[i4][5] % modVal))
  print("Equation 5 : " .. sysEq[i5][1] .. "v + " .. sysEq[i5][2] .."x + " ..
        sysEq[i5][3] .. "y + " .. sysEq[i5][4] .. "z = " .. (sysEq[i5][5] % modVal))
  
  print("\nEquation Combined : " .. foo[1] .. "v + " .. foo[2] .. "x + " .. foo[3] ..
        "y + " .. foo[4] .. "z = " .. tempval)
      
  --[[ Encoding:
       - Partition modulus value 257 into 26 parts
       - 257 // 26 = 9
       - Each alphabet letter can correspond to a number 1 - 26
       - For example, adding a "c" can be done w/ 3 * 9 = 27 
         added to the combined equation right side of the equal 
  ]]
    tempfoo = ((msg[i] * alphsize) + tempval) % modVal
    msg2[i] = {foo[1],foo[2],foo[3],foo[4],tempfoo}
  end

end


function decodeMessage()
  --[[ Decoding:
       - Alice can calculate the actual values for the combined equations
       - Subtract Error Sums with Actual expected sums to get encErr
       - encErr contains both the message plus the error bit(1-4)
       - Integer division of the encErr by 9 gets the actual value
  ]]
  local accValList = {}
  
  --Calculate accurateValues using returned partition of system of equations w/ errors
  for i = 1, #msg2
  do
    local accVal = ((msg2[i][1] * privatekey[1]) + (msg2[i][2] * privatekey[2]) +
                   (msg2[i][3] * privatekey[3]) + (msg2[i][4] * privatekey[4]) ) % modVal
    table.insert(accValList, accVal)
  end
  
  --Calculate Message by Subtracting Error Summation by Actual Value
  print("")
  for i = 1, #msg2
  do
    local encErr = msg2[i][5] - accValList[i]
    --print(encErr)
    if encErr < 0
    then
      encErr = encErr + modVal
    end

    print("Value #"..i)
    print("Encoded Message w/ Error", encErr / alphsize)
    print("Decoded Value: ".. encErr // alphsize,"\n")
  end
  
end

generateLists()
generateEncoded()
decodeMessage()