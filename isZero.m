function [outputValue] = isZero(inputValue, resolution)

if inputValue > -1*resolution && inputValue < 0
    outputValue = 0;
else
    outputValue = inputValue;
   
end