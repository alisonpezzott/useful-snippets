// Real solution to: https://discord.com/channels/1279778182941245503/1331323911526289418

let    
    entrada = #table(
        type table [
            id = Int64.Type,
            category = text,
            equipment_list = text
        ],
        List.Transform(
            {
                { 1, "A", "[{""model"":""SOFT 900-SEMEADEIRA MONODISCO SOFT 900"",""product"":""SOFT 900-SEMEADEIRA MONODISCO SOFT 900"",""chassis"":""ADCE-002370"",""financing_bank"":"""",""year"":2024,""price"":6500}]" },
                { 2, "B", "[{""model"":""210G-ESCAVADEIRA HIDRAULICA 210G"",""product"":""210G-ESCAVADEIRA HIDRAULICA 210G"",""chassis"":""1F9210GXCRD523707"",""financing_bank"":""07237373011245-BANCO DO NORDESTE DO BRASIL S.A"",""year"":2025,""price"":850000}]" },
                { 3, "C", "[{""model"":""AF4000 USADO-AF 4000"",""product"":""AF4000 USADO-AF 4000"",""chassis"":""CP400105"",""financing_bank"":"""",""year"":2014,""price"":400000}]" }   
            },
            each _
        )
    ),

    funcao = (texto as text) =>
    let
        caracteresRemovidos = Text.Remove(texto, {"[", "]", "{", "}", """"}),
        paraLista = Text.Split(caracteresRemovidos, ","),
        linhaParaLista = List.Transform(paraLista, each Text.Split(_, ":")),
        linhaParaRegistro = List.Transform(linhaParaLista, each Record.FromList({_{1}}, {_{0}})),
        registroCombinado = Record.Combine(linhaParaRegistro)
    in
        registroCombinado,

    linhasParaRegistros = Table.TransformColumns(entrada, {{"equipment_list", funcao}}),
    equipment_list_Expandido = Table.ExpandRecordColumn(linhasParaRegistros, "equipment_list", {"model", "product", "chassis", "financing_bank", "year", "price"}, {"model", "product", "chassis", "financing_bank", "year", "price"}),
    tipoAlterado = Table.TransformColumnTypes(equipment_list_Expandido,{{"model", type text}, {"product", type text}, {"chassis", type text}, {"financing_bank", type text}, {"year", Int64.Type}, {"price", Currency.Type}})
in
    tipoAlterado