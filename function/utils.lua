function debug(...)
    if Config.EnableDebug then
        local args = { ... }

        for i = 1, #args do
            local arg = args[i]
            args[i] = type(arg) == 'table' and json.encode(arg, { sort_keys = true, indent = true }) or tostring(arg)
        end

        print('^1[DEBUG] ^7', table.concat(args, '\t'))
    end
end

function GeneratePlate()
    local plateLetters = {}
    local plateNumbers = {}

    for i = 1, 3 do
        local randomLetter = string.char(math.random(65, 90))
        table.insert(plateLetters, randomLetter)
    end

    for i = 1, 3 do
        local randomNumber = math.random(0, 9)
        table.insert(plateNumbers, randomNumber)
    end

    local numberPlate = table.concat(plateLetters) .. table.concat(plateNumbers)

    return numberPlate
end

function InfoKeybind()
    Scale = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS");
    while not HasScaleformMovieLoaded(Scale) do
        Citizen.Wait(0)
    end

    BeginScaleformMovieMethod(Scale, "CLEAR_ALL");
    EndScaleformMovieMethod();

    --Right
    BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT");
    ScaleformMovieMethodAddParamInt(0);
    PushScaleformMovieMethodParameterString("~INPUT_MOVE_RIGHT_ONLY~");
    PushScaleformMovieMethodParameterString("Rotate right");
    EndScaleformMovieMethod();

    --Left
    BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT");
    ScaleformMovieMethodAddParamInt(1);
    PushScaleformMovieMethodParameterString("~INPUT_MOVE_LEFT_ONLY~");
    PushScaleformMovieMethodParameterString("Rotate Left");
    EndScaleformMovieMethod();

    BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT");
    ScaleformMovieMethodAddParamInt(2);
    PushScaleformMovieMethodParameterString("~INPUT_CELLPHONE_CANCEL~");
    PushScaleformMovieMethodParameterString("Exit");
    EndScaleformMovieMethod();


    BeginScaleformMovieMethod(Scale, "DRAW_INSTRUCTIONAL_BUTTONS");
    ScaleformMovieMethodAddParamInt(0);
    EndScaleformMovieMethod();

    DrawScaleformMovieFullscreen(Scale, 255, 255, 255, 255, 0);
end