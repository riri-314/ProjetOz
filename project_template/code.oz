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
            note(name:Name octave:Octave sharp:true duration:Duration instrument:none)
        [] Atom then
            case {AtomToString Atom}
            of [_] then
                note(name:Atom octave:4 sharp:false duration:Duration instrument:none)
            [] [N O] then
                note(name:{StringToAtom [N]}
                    octave:{StringToInt [O]}
                    sharp:false
                    duration:Duration
                    instrument: none)
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {Append L1 L2} %function to add to list, L1=first list to add, L2=second list to add
        case L1 
        of nil then 
            L2
        [] H|T then 
            H | {Append T L2}
        [] H then
            {Append [H] L2} 
        end
    end

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
                %fore note
            end
        [] nil then L
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {PartitionToTimedList L T E} %L=List (Partiton) T=Time of the note (T=1.0 means that the note will last 1.0 sec)  E=stretch factor (ex: if T=1.5 and E=2.0 then the new T=3.0)
        case L
        of H1|T1 then
            case H1
            of H2|T2 then
                ({Append {PartitionToTimedList H2 T E} {PartitionToTimedList T2 T E}})|{PartitionToTimedList T1 T E} %{NoteToExtended H2 T} 
            [] duration(1:P seconds:R) then 
                {Append {PartitionToTimedList P (R/{IntToFloat {Lenght P}})*E E} {PartitionToTimedList T1 T E}}
            [] stretch(1:P factor:R) then
                {Append {PartitionToTimedList P T*R R} {PartitionToTimedList T1 T E}}
            [] drone(note:Nc amount:N) then
                {Append {Drone {PartitionToTimedList Nc T E} N 0} {PartitionToTimedList T1 T E}}
            [] transpose(1:P semitones:I) then
                {Append {TransT {PartitionToTimedList P T E} I 0} {PartitionToTimedList T1 T E}}
            [] H1 then 
                {NoteToExtended H1 T}|{PartitionToTimedList T1 T E}
            end
        [] nil then 
            L 
        [] H3 then
            case H3
            of stretch(1:P factor:R) then
                {PartitionToTimedList P T*R R}
            [] duration(1:P seconds:R) then
                {Show durationh3} 
                {PartitionToTimedList P (R/{IntToFloat {Lenght P}})*E E}
            [] drone(note:Nc amount:N) then
                {Drone {PartitionToTimedList Nc T E} N 0}
            [] transpose(1:P semitones:I) then
                {TransT {PartitionToTimedList P T E} I 0}
            [] H3 then
                {NoteToExtended H3 T}
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {Mix P2T Music} %return samples, liste d'échantillons 
        {Project.readFile CWD#'wave/animals/chicken.wav'}
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    %HoYeah = {Project.readFile CWD#'wave/animals/cow.wav'} %debug
    %{Browse HoYeah} %debug
   
    Music = {Project.load CWD#'joy.dj.oz'}
    %Music = {Flatten MusicD} %debug
    {Browse Music} %for debug   

    %Np = Music.1.1

    %{Browse {Test Np}}
    %{Browse {NoteToExtended {Test Np}}}
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
    {Browse {Project.run Mix PartitionToTimedList Music 'out-chicken.wav'}}
    %{Browse {Project.run Mix Flaten Music 'out.wav'}}

    % Shows the total time to run your code.
    {Browse {IntToFloat {Time}-Start} / 1000.0}
end
