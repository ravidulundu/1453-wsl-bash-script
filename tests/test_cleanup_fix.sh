#!/bin/bash
# Test script for BUG-030 fix in cleanup.sh

# Create a dummy bashrc
BASHRC_TEST="bashrc_test.tmp"
cat > "$BASHRC_TEST" << 'EOF'
# Some innocent comment about NVM_DIR
export MY_VAR="some value"

# NVM Configuration (Should be removed)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Another innocent line
echo "NVM_DIR is great"
EOF

echo "Original content:"
cat "$BASHRC_TEST"
echo "--------------------------------"

# Apply the fix commands (simulated)
sed '/export NVM_DIR=/d' "$BASHRC_TEST" > "${BASHRC_TEST}.tmp" && mv "${BASHRC_TEST}.tmp" "$BASHRC_TEST"
sed '/NVM_DIR\/nvm.sh/d' "$BASHRC_TEST" > "${BASHRC_TEST}.tmp" && mv "${BASHRC_TEST}.tmp" "$BASHRC_TEST"
sed '/NVM_DIR\/bash_completion/d' "$BASHRC_TEST" > "${BASHRC_TEST}.tmp" && mv "${BASHRC_TEST}.tmp" "$BASHRC_TEST"

echo "Modified content:"
cat "$BASHRC_TEST"
echo "--------------------------------"

# Verification
FAIL=0

if grep -q "export NVM_DIR=" "$BASHRC_TEST"; then
    echo "FAIL: export NVM_DIR= still exists"
    FAIL=1
fi

if grep -q "nvm.sh" "$BASHRC_TEST"; then
    echo "FAIL: nvm.sh source still exists"
    FAIL=1
fi

if ! grep -q "Some innocent comment about NVM_DIR" "$BASHRC_TEST"; then
    echo "FAIL: Innocent comment was removed"
    FAIL=1
fi

if ! grep -q "echo \"NVM_DIR is great\"" "$BASHRC_TEST"; then
    echo "FAIL: Innocent echo was removed"
    FAIL=1
fi

if [ $FAIL -eq 0 ]; then
    echo "SUCCESS: Fix verified!"
    rm "$BASHRC_TEST"
    exit 0
else
    echo "FAILURE: Verification failed"
    rm "$BASHRC_TEST"
    exit 1
fi
