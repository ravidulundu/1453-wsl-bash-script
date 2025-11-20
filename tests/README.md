# Test Scripts

This directory contains development and integration test scripts for the 1453 WSL Setup Script.

## Test Files

### Go Module Tests
- **test-go-function.sh** - Unit tests for Go installation functions
- **test-go-integration.sh** - Integration tests for Go module

## Running Tests

```bash
# Run Go function tests
bash tests/test-go-function.sh

# Run Go integration tests
bash tests/test-go-integration.sh
```

## Validation Script

The main validation script `test-setup.sh` is located in the root directory. It validates the entire installation and should be run after setup completion.

```bash
# Run full validation
./test-setup.sh
```

## Adding New Tests

When adding new test scripts:
1. Name them `test-<module>-<type>.sh`
2. Place them in this `tests/` directory
3. Update this README with test documentation
4. Ensure they are executable: `chmod +x tests/test-*.sh`
