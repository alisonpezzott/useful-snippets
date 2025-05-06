import pandas as pd

input_file = "input_path.csv"
df = pd.read_csv(input_file)

for group, group_df in df.groupby("Group"):
    output_file = f"{group.replace(' ', '_').lower()}.csv"
    group_df.to_csv(output_file, index=False)
