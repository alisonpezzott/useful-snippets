/*
Create parameters to local directory or SharePoint

	folder: "C:\Git\<your_folder>"
	site: "https://<your_domain>.sharepoint.com/sites/<SiteName>/"
*/

let

// Define the function
    fx_combine_sheets = (content as binary) as table =>
    let
    
        workbook = Excel.Workbook(content),

        fx_treat_sheet = (sheet as table) as table =>
        let
            headers = Table.PromoteHeaders(sheet, [PromoteAllScalars=true]),
            unpivot = Table.UnpivotOtherColumns(headers, {"Key"}, "Date", "Qty" ),
            changed_type = Table.TransformColumnTypes (
                unpivot, {
                    { "Key",  type text  }, 
                    { "Date", type date  }, 
                    { "Qty",  Int64.Type }
                }
            ) 
        in
            changed_type,

        treated_sheets = Table.TransformColumns ( 
            workbook, {
                { "Data", fx_treat_sheet, type table }
            } 
        ),

        combined_tables = Table.Combine( treated_sheets[Data])
    in
        combined_tables,

  
	// For SharePoint
	source = SharePoint.Contents(site, [ApiVersion = 15])
        {[Name = "Shared Files"]}[Content],

	// For local dir
	// source = Folder.Files(folder),

	// Just excel files
    just_xlsx_files = Table.SelectRows(source, each [Extension] = ".xlsx"),

	// Apply the function to combine each sheet for each worksheet
    combined_sheets = Table.TransformColumns( 
        just_xlsx_files, {
            { "Content", fx_combine_sheets, type table }
        } 
    ), 

	// Combine the Content column
    combined_worksheets = Table.Combine(combined_sheets[Content])
in
    combined_worksheets
