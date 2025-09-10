# Install the Semantic link Labs library
# %pip install semantic-link-labs

import sempy_labs as labs

# Resolve name and id from current workspace
workspace_meta = labs._workspaces.resolve_workspace_name_and_id()
print(f'Current workspace -> name: {workspace_meta[0]}, id: {workspace_meta[1]}') 

# Resolve workspace id for a given workspace name
workspace_name = 'SandboxFabric'
workspace_id = labs._workspaces.resolve_workspace_id(workspace_name)
print(f'Returns id {workspace_id} for workspace name: {workspace_name}')

# Resolve workspace name for a given workspace id
ws_id = workspace_id
ws_name = labs._workspaces.resolve_workspace_name_and_id(ws_id)
print(f'Returns name: {ws_name[0]} for workspace id: {ws_id}')
