#!/bin/bash

cat <<EOF > ENVIRONMENT.md
# 🌱 Project Environment Layers

This project uses a layered environment system for variable management.

## 🔁 Load Order

1. **\`.env.defaults\`**  
   Provides fallback values only if the variable is not already set.

2. **\`.env\`**  
   Main environment file for project-level settings. Overrides defaults.

3. **\`.env.sh\`**  
   Optional shell script. Can contain logic and overrides. Executes directly.

## 🔐 Masking

Sensitive keys (e.g., \`*_SECRET\`, \`*_KEY\`, \`*_TOKEN\`, \`*_PASS\`) are masked in logs:
\`\`\`
🔐 API_KEY=******** (override)
\`\`\`

## 🧼 Cleanup

Every time \`pi-switcher switch <project>\` is run:
- Previously loaded keys are cleared
- A new list of active keys is stored in:
  \`~/.pi-project-switcher/last_env_keys.txt\`

## 🧪 Testing

To test what’s loaded:
\`\`\`bash
env | grep -E 'DEBUG|API|LOG|KEY|TOKEN'
\`\`\`

To verify clean switching:
\`\`\`bash
pi-switcher switch other-project
pi-switcher switch back-to-this-one
\`\`\`

EOF
