let 
    func = ( base as number, exponent as number ) as number => 
    let 
        operation = Number.Power ( base, exponent )
    in
        operation,

    Documentation = type function (
        base as ( type number meta [
            Documentation.AllowedValues = {1..9},
            Documentation.FieldCaption = "base", 
            Documentation.FieldDescription = "The number that will be raised to a power"
        ]),
        exponent as ( type number meta [
            Documentation.AllowedValues = {1..9},
            Documentation.FieldCaption = "exponent", 
            Documentation.FieldDescription = "The power to which the base number is raised"
        ])
    ) as number
    meta [
        Documentation.Name = "Power", 
        Documentation.Description = "Returns the result of raising a base number to a specified exponent.",
        //Documentation.LongDescription = "Calculates the value resulting from multiplying the base by itself, as many times as indicated by the exponent.",
        Documentation.Category = "Power Query M", 
        Documentation.Version = "v0",
        Documentation.Source = "https://github.com/alisonpezzott/documentation-custom-power-query-m/edit/main/README.md", 
        Documentation.Author = "Alison Pezzott", 
        Documentation.Examples = {[
            Description =  "Calculates 2 raised to the power of 3", 
            Code = "Power(2, 3)", 
            Result = "8" 
        ]}
    ]
in 
    Value.ReplaceType ( func, Documentation )
