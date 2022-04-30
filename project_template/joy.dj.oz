% Ode To Joy
local
   Tune = [b#5 b c5 d5 d5 c5 b a g g a b]
   End1 = [stretch(factor:1.5 [b#5 b c5 d5 d5 c5 b a g g a b]) stretch(factor:0.5 [a]) stretch(factor:2.0 [a])]
   End2 = [stretch(factor:1.5 [a]) stretch(factor:0.5 [g]) stretch(factor:2.0 [g])]
   Interlude = [a a b g a stretch(factor:0.5 [b c5])
                    b g a stretch(factor:0.5 [b c5])
                b a g a stretch(factor:2.0 [d]) ]
   Doom = [duration([d#3 d#3 d#4 d#3 d#3 c#4 d#3 d#3 b3 d#3 d#3 a3 silence(duration:0.2) d#3 a#3 b3 d#3 d#3 d#4 d#3 d#3 c#4 d#3 d#3 b3 d#3 d#3 silence(duration: 0.2) a3 silence(duration: 0.6) d#3 d#3 d#4 d#3 d#3 c#4 d#3 d#3 b3 d#3 d#3 a3 d#3 d#3 a#3 b3 d#3 d#3 d#4 d#3] seconds:7.5)]
   Doom0 = [duration([d#4 [d#3 d#5] a#3] seconds:7.5)]
   
   % This is not a music.
   Partition = {Flatten [Doom0]} %flattened partition, output of PartitionToTimedList
   %Partition = {Flatten [Tune End1 Interlude End2]} %flattened partition, output of PartitionToTimedList
   %Partition = [Tune End1 Tune End2 Interlude Tune End2] %partition non-flattened, input of PartitionToTimedList
   %Partition = {Flatten [End2]}  %debug 

in
   % This is a music :)
   
   [partition(Partition)] %syntax
end