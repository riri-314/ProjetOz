local
    % See project statement for API details.
    % !!! Please remove CWD identifier when submitting your project !!!
    CWD = '/home/riri/Documents/UCL/2021-2022/LINFO1104-oz/ProjetOz/project_template/' % Put here the **absolute** path to the project files
    [Project] = {Link [CWD#'Project2022.ozf']}
    Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Translate a note to the extended notation.
    fun {NoteToExtended Note Duration}
        case Note
        of Name#Octave then
            note(name:Name octave:{IntToFloat Octave} sharp:true duration:Duration instrument:none)
        [] Atom then
            case {AtomToString Atom}
            of [_] then
                note(name:Atom octave:4.0 sharp:false duration:Duration instrument:none)
            [] [N O] then
                note(name:{StringToAtom [N]} octave:{StringToFloat [O]} sharp:false duration:Duration instrument: none)
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {Lenght0 L A}
        case L of nil then A
        [] H|T then {Lenght0 T A+1}
        end
    end
    fun {Lenght L} %give lenght of list L
        {Lenght0 L 0}
    end

    fun {Drone L N I} %recursive function to creat list of smae note, L=list, N=amount, I=recurance
        if I<N then {Append L {Drone L N I+1}}
        else nil
        end
    end
   
    fun {NoteShifter N I} %L=list extended I=float, shift partition by I semitone, C C# D D# E F F# G G# A A# B
        if I<0.0 then
            case N
            of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:none) then
                if Name == b then
                    {NoteShifter note(name:a octave:Octave sharp:true duration:Duration instrument:none) I+1.0}
                elseif Name == a then
                    if Sharp == true then
                        note(name:Name octave:Octave sharp:false duration:Duration instrument:none)
                    else
                        {NoteShifter note(name:g octave:Octave sharp:true duration:Duration instrument:none) I+1.0}
                    end
                elseif Name == g then
                    if Sharp == true then
                        {NoteShifter note(name:Name octave:Octave sharp:false duration:Duration instrument:none) I+1.0}
                    else
                        {NoteShifter note(name:f octave:Octave sharp:true duration:Duration instrument:none) I+1.0}
                    end
                elseif Name == f then
                    if Sharp == true then
                        {NoteShifter note(name:Name octave:Octave sharp:false duration:Duration instrument:none) I+1.0}
                    else
                        {NoteShifter note(name:e octave:Octave sharp:false duration:Duration instrument:none) I+1.0}
                    end
                elseif Name == e then
                    {NoteShifter note(name:d octave:Octave sharp:true duration:Duration instrument:none) I+1.0}
                elseif Name == d then
                    if Sharp == true then
                        {NoteShifter note(name:Name octave:Octave sharp:false duration:Duration instrument:none) I+1.0}
                    else
                        {NoteShifter note(name:c octave:Octave sharp:true duration:Duration instrument:none) I+1.0}
                    end
                elseif Name == c then
                    if Sharp == true then
                        {NoteShifter note(name:Name octave:Octave sharp:false duration:Duration instrument:none) I+1.0}
                    else
                        {NoteShifter note(name:b octave:Octave-1 sharp:false duration:Duration instrument:none) I+1.0}
                    end
                else
                    error
                end
            [] nil then nil
            end
        elseif I>0.0 then
            case N
            of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:none) then
                if Name == b then
                    {NoteShifter note(name:c octave:Octave+1 sharp:false duration:Duration instrument:none) I-1.0}
                elseif Name == a then
                    if Sharp == true then
                        {NoteShifter note(name:b octave:Octave sharp:false duration:Duration instrument:none) I-1.0}
                    else
                        {NoteShifter note(name:Name octave:Octave sharp:true duration:Duration instrument:none) I-1.0}
                    end
                elseif Name == g then
                    if Sharp == true then
                        {NoteShifter note(name:a octave:Octave sharp:false duration:Duration instrument:none) I-1.0}
                    else
                        {NoteShifter note(name:Name octave:Octave sharp:true duration:Duration instrument:none) I-1.0}
                    end
                elseif Name == f then
                    if Sharp == true then
                        {NoteShifter note(name:g octave:Octave sharp:false duration:Duration instrument:none) I-1.0}
                    else
                        {NoteShifter note(name:Name octave:Octave sharp:true duration:Duration instrument:none) I-1.0}
                    end
                elseif Name == e then
                    {NoteShifter note(name:f octave:Octave sharp:true duration:Duration instrument:none) I-1.0}
                elseif Name == d then
                    if Sharp == true then
                        {NoteShifter note(name:e octave:Octave sharp:false duration:Duration instrument:none) I-1.0}
                    else
                        {NoteShifter note(name:Name octave:Octave sharp:true duration:Duration instrument:none) I-1.0}
                    end
                elseif Name == c then
                    if Sharp == true then
                        {NoteShifter note(name:d octave:Octave sharp:false duration:Duration instrument:none) I-1.0}
                    else
                        {NoteShifter note(name:Name octave:Octave sharp:true duration:Duration instrument:none) I-1.0}
                    end
                else
                    error
                end
            [] nil then nil
            end
        else
            N
        end
    end
    fun {TransT L I J} %J=0 L=Partition I=Number of semontone to shift
        case L
        of H1|T1 then
            case H1
            of H2|T2 then
                ({NoteShifter H2 I}|{TransT T2 I J})|{TransT T1 I J}
                %for chord
            [] H1 then
                {NoteShifter H1 I}|{TransT T1 I J}
                %for note
            end
        [] nil then L
        end
    end
    fun {StretchChord Chord Factor}
        case Chord
        of H1|T1 then 
            case H1 
            of silence(duration:R) then
                silence(duration:Factor*R)|{StretchChord T1 Factor}
            [] note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:none) then
                note(name:Name octave:Octave sharp:Sharp duration:Duration*Factor instrument:none)|{StretchChord T1 Factor}
            end
        else
            nil
        end
    end

    fun {Stretch Part Factor} %Partion can take Silence Note and Chord as input, Part is allready a extended list
        case Part 
        of H1|T1 then
            case H1
            of silence(duration:R) then
                silence(duration:Factor*R)|{Stretch T1 Factor}
            [] note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:none) then
                note(name:Name octave:Octave sharp:Sharp duration:Duration*Factor instrument:none)|{Stretch T1 Factor}
            [] H2|T2 then
                %{Append {Stretch H2 Factor} {Stretch T2 Factor}}|{Stretch T1 Factor} %Need a func StretchChord
                {StretchChord H1 Factor}|{Stretch T1 Factor} %Code is getting ugly...
            else
                {Stretch Factor T1}
            end
        else
            nil
        end
    end
    
    
    %Duration is just a fun that call Stretch with the good factor
    fun {TimeofPart Part J}
        case Part
        of H1|T1 then
            case H1
            of silence(duration:R) then
                {TimeofPart T1 J+R}
            [] note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:none) then
                {TimeofPart T1 J+Duration}
            [] H2|T2 then %dirty code
                
                case H2
                of silence(duration:R) then
                    {TimeofPart T1 J+R} %T1 because only need the time of oune note in a chord
                [] note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:none) then
                    {TimeofPart T1 J+Duration}
                end
            else
                {TimeofPart T1 J}
            end
        else
            J
        end
    end

    fun {SetDuration Part Time}
        {Stretch Part Time/{TimeofPart Part 0.0}}
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fun {ChrodToTimedList Chord}
        case Chord
        of H|T then
            {NoteToExtended H 1.0}|{ChrodToTimedList T} %only use | "pipe" when single ellement on head
        [] nil then
            nil
        end
    end

    fun {PartitionToTimedList L}
        {PartitionToTimedListAux L 1.0 1.0}
    end
    
    fun {PartitionToTimedListAux L T E} %L=List (Partiton) T=Time of the note (T=1.0 means that the note will last 1.0 sec)  E=stretch factor (ex: if T=1.5 and E=2.0 then the new T=3.0)
        case L
        of H1|T1 then
            case H1
        
            of H2|T2 then
                %({Append {PartitionToTimedListAux H2 T E} {PartitionToTimedListAux T2 T E}})|{PartitionToTimedListAux T1 T E} %Need to make a proper ChrodToTimedList func
                {ChrodToTimedList H1}|{PartitionToTimedListAux T1 1.0 1.0} %much simpler
            [] silence(duration:R) then
                H1|{PartitionToTimedListAux T1 T E} %pass silence to Mix, Mix pass silence to SilenceToAi, SilenceToAi make 0.0 sound
            [] nil then
                {PartitionToTimedListAux T1 T E}
            [] duration(1:P seconds:R) then 
                {Append {SetDuration {PartitionToTimedListAux P T E} R} {PartitionToTimedListAux T1 T E}}
                %{Append {PartitionToTimedListAux P (R/{IntToFloat {Lenght P}})*E E} {PartitionToTimedListAux T1 T E}}%Need to make a proper DurationToTimedList func
            [] stretch(1:P factor:R) then
                {Append {Stretch {PartitionToTimedListAux P T E} R} {PartitionToTimedListAux T1 T E}}
                %{Append {PartitionToTimedListAux P T*R R} {PartitionToTimedListAux T1 T E}} %Need to make a proper Stretch func
            [] drone(note:Nc amount:N) then
                {Append {Drone {PartitionToTimedListAux Nc T E} N 0} {PartitionToTimedListAux T1 T E}}
            [] transpose(1:P semitones:I) then
                {Append {TransT {PartitionToTimedListAux P T E} I 0} {PartitionToTimedListAux T1 T E}}
            [] Atom then
                {NoteToExtended H1 T}|{PartitionToTimedListAux T1 T E}
            
            else
                H1|{PartitionToTimedListAux T1 T E} %for robustness
            end
        else
            nil
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fun {Height Note} %C C# D D# E F F# G G# A A# B
        case Note
        of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:none) then
            if Name == b then
                2.0 + (Octave-4.0)
            elseif Name == a then
                if Sharp == true then
                    1.0 + (Octave-4.0)
                else
                    0.0
                end
            elseif Name == g then
                if Sharp == true then
                    ~1.0 + (Octave-4.0)
                else
                    ~2.0 + (Octave-4.0)
                end
            elseif Name == f then
                if Sharp == true then
                    ~3.0 + (Octave-4.0)
                else
                    ~4.0 + (Octave-4.0)
                end
            elseif Name == e then
                ~5.0 + (Octave-4.0)
            elseif Name == d then
                if Sharp == true then
                    ~6.0 + (Octave-4.0)
                else
                    ~7.0 + (Octave-4.0)
                end
            elseif Name == c then
                if Sharp == true then
                    ~8.0 + (Octave-4.0)
                else
                    ~9.0 + (Octave-4.0)
                end
            else
                error
            end
        [] nil then nil
        end
    end
        
    fun {Frequency H} %height of the Note in Hz
        {Pow 2.0 H/12.0} * 440.0
    end

    fun{SumAi Samples1 Samples2}
        case Samples1 
        of H1|T1 then
            case Samples2 
            of H2|T2 then
                H1+H2|{SumAi T1 T2}
            [] tail then
                Samples1
            else
                H1|{SumAi T1 nil}
            end
        else
            case Samples2 
            of H2|T2 then
                H2|{SumAi nil T2}
            else
                nil
            end
        end
    end
    Pi = 3.14159265359
    fun {NoteToAi F I J A} %F=frequency, I=number of NoteToAi to do ex:44100, J=number of the iteration ex:0.0, A=divide note intensitie by (Only used in ChordToAi)
        if J >= I then
            nil %Strange way to do it...Damn is Oz strange 
        else
            {Sin (2.0*Pi*F*J)/44100.0}/2.0|{NoteToAi F I J+1.0 A}
        end
    end

    fun{ChordToAi Chord N} %N = number of note in ai
        case Chord 
        of H|T then 
            case H
            of silence(duration:D) then
                {SumAi {SilenceToAi D*44100.0 0.0} {ChordToAi T N}}
            [] note(name:N octave:O sharp:S duration:D instrument:none) then
                {SumAi {NoteToAi {Frequency {Height H}} D*44100.0 0.0 N} {ChordToAi T N}}
            else
            
                {ChordToAi T N}
            end
        else
            nil
        end
    end

    fun {SilenceToAi Duration Acc} %Duration is the number of sample
        if Acc >= Duration then %I still dont understand this syntax, but it works
            nil
        else
            0.0|{SilenceToAi Duration Acc+1.0}
        end
    end

    fun {PartToAi Partition}
        case Partition 
        of H1|T1 then
            case H1 
            of silence(duration:D) then
                {Append {SilenceToAi 44100.0*D 0.0} {PartToAi T1}}
            [] note(name:N octave:O sharp:S duration:D instrument:none) then
                {Flatten {NoteToAi {Frequency {Height H1}} 44100.0*D 0.0 0.0}|{PartToAi T1}}
            [] H2|T2 then
                {Flatten {ChordToAi H1 {IntToFloat {List.length H1}}}|{PartToAi T1}}
            end
        else
            nil
        end
    end

    fun{Repeat Amount Music} %Amount is a Int !!!!!
        if Amount == 1 then
            Music
        else
            {Append Music {Repeat Amount-1 Music}}
        end
    end
    
    fun {Merge Music P2T}
        case Music 
        of H1|T1 then
            case H1
            of Factor#Music0 then
                {SumAi (Factor*{Mix P2T Music0}) {Merge T1 P2T}} 
            else
                nil
            end
        else 
            nil
        end
    end
    
    fun {Sample Samples}
        case Samples
        of H|T then
            {Append H {Sample T}}
        else
            Samples
        end
    end

    fun {Clip Low High Music}
        case Music of nil then nil
        [] H|T then 
            if H > High then High|{Clip Low High T}
            elseif H < Low then Low|{Clip Low High T}
            else H|{Clip Low High T}
            end
        end
    end

    fun {Echo Duration Decay Music P2T}
        local Clone Liste in
        Clone = {Append {SilenceToAi Duration*44100.0 0.0} Music}
        local
            fun {Multiply X Decay}{
                X * Decay
            }
            end
        in
        Liste = [Music {Map Clone Multiply}]
        {Merge Liste P2T}
            end
        end
    end

    fun {Loop Duration Music Acc}
        local Nofl in 
            %NumberOfLoop 
            Nofl = Duration/({IntToFloat {List.lenght Music}}/44100.0) %In float
            if (Nofl =< 1.0) then
                {Cut 0.0 Duration Music 0.0}
            else %Ex if Nofl = 4.67 => 4*Repeat + Cut 0.0 Duration-4
                if (Nofl - {IntToFloat {FloatToInt Nofl}} >= 0.0) then %53.3-53 => 53 repeat and cut form 0.0 to 0.3
                    {Append {Repeat {FloatToInt Nofl} Music} {Cut 0.0 (Duration-({IntToFloat {FloatToInt Nofl}}*({IntToFloat {List.lenght Music}}/44100.0))) Music 0.0}}
                else %Ex if Nofl = 53.99 => 54-1 repeat and cut from 0.0 to 53.99 - (54-1)
                    {Append {Repeat {FloatToInt Nofl} Music} {Cut 0.0 (Duration-({IntToFloat {FloatToInt Nofl}-1}*({IntToFloat {List.lenght Music}}/44100.0))) Music 0.0}}
                end
            end
        end

    end

    fun {Cut Start Finish Music Acc} %Acc = 0.0    
        if (Acc =< (Finish*44100.0)-1.0) then %-1.0 is for first ellement, bug resolution
            case Music of H|T then
                if (Acc < Start*44100.0) then %cut at start
                    {Cut Start Finish T Acc+1.0}
                else %Standard case
                    H|{Cut Start Finish T Acc+1.0}
                end
            else %Need a "else" statment, Oz is verry upset without one
                0.0|{Cut Start Finish nil Acc+1.0} %Add 0.0 when start ot stop is out of sample reach
            end
        else
            nil
        end
    end
    
    fun {FadeIn Factor Music Acc}
        case Music of H|T then
            if (Acc =< 1.0) then
                H*Acc | {FadeIn Factor T Acc+Factor}
            else
                music
            end
        else
            nil
        end
    end

    fun {Fade In Out Music} %if 5 sample to fade then 1/5 = 0.2 => factors = [0.8 0.6 0.4 0.2 0.0]
        if (In > 0.0) then
            {FadeIn 1.0/In*44100.0 Music 0.0}
        elseif (Out > 0.0) then
            {Reverse {FadeIn 1.0/In*44100.0 {Reverse Music} 0.0}} %So dirty but no time to do it the proper way
        else
            Music
        end
    end


    fun {Mix P2T Music}
        case Music 
        of H|T then
            case H 
            of partition(Partition) then %OK
                {Append {PartToAi {P2T Partition}} {Mix P2T T}} %OK
            [] merge(Intmusic) then %OK
                {Append {Merge Intmusic P2T} {Mix P2T T}}
            [] repeat(amount:Amount Music0) then %OK 
                {Append {Repeat Amount {Mix P2T Music0}} {Mix P2T T}}
            [] wave(FileName) then %OK
                {Append {Project.readFile FileName} {Mix P2T T}}
            [] samples(Samples) then %OK
                {Append {Sample Samples} {Mix P2T T}}
            [] reverse(1:Music1) then
                {Append {Reverse {Mix P2T Music1}} {Mix P2T T}}
            [] loop(seconds:Duration Music2) then
                {Append {Loop Duration {Mix P2T Music2} 0.0} {Mix P2T T}}
            [] cut(start:Start finish:Finish Music3) then
                {Append {Cut Start Finish Music3 0.0} {Mix P2T T}}
            [] clip(low:Low high:High Music4) then
                {Append {Clip Low High Music4} {Mix P2T T}}
            [] echo(duration:Duration decay:Decay Music5) then
                {Append {Echo Duration Decay Music5 P2T} {Mix P2T T}}
            [] nil then
                {Mix P2T T}
            else
                {Mix P2T T}
                %nil
            end
        else
            nil
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %super usefull link http://strasheela.sourceforge.net/strasheela/doc/01-Basics.html#sec77
 
    Music = {Project.load CWD#'joy.dj.oz'}

    Start

    % Uncomment next line to insert your tests.
    % \insert '/full/absolute/path/to/your/tests.oz'
    % !!! Remove this before submitting.
in
    Start = {Time}

    % Uncomment next line to run your tests.
    % {Test Mix PartitionToTimedList}

    % Add variables to this list to avoid "local variable used only once"
    % warnings.
    {ForAll [NoteToExtended Music] Wait}
   
    % Calls your code, prints the result and outputs the result to `out.wav`.
    % You don't need to modify this.
    {Browse {Project.run Mix PartitionToTimedList Music 'Doom_soundtrack.wav'}}


    % Shows the total time to run your code.
    {Browse {IntToFloat {Time}-Start} / 1000.0}
end
