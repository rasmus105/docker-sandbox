# Usage
Perform this one-time setup once:
```bash
# Setup the Docker sandbox template.
./bin/setup

# Link `sbx-opencode` to a directory added to PATH (optional) 
ln -s /Users/kargo/git/personal/docker-sandbox/bin/sbx-opencode /Users/kargo/.local/bin/sbx-opencode
```
Then use it:
```bash
cd ~/git/my-project/
sbx-opencode
```

You will have to manually allow network permissions as needed. Run `sbx` to
open the Docker sandbox dashboard, where you will be able to interactively
allow and disallow networks.
