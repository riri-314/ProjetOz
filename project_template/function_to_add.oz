declare
fun {Clip Low High Music}
    case Music of nil then nil
    [] H|T then 
        if H > High then High|{Clip Low High T}
        elseif H < Low then Low|{Clip Low High T}
        else H|{Clip Low High T}
        end
    end
end

fun {Echo Duration Decay Music}
    local
    Clone = {Append {SilenceToAi Duration*44100.0 0.0} Music}
        fun {Multiply X Y}{
            X * Y
        }
        end
    in
    Liste = [Music {Map Clone {Multiply Decay}}]

    {Merge Liste}
    end
end


X = [1 2 3 4 5 6]

Low = 2

High = 4

{Browse {Clip Low High X}}