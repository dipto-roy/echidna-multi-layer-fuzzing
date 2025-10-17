#!/bin/bash

# Multi-Layer Fuzzing Optimization Framework Build and Test Script

echo "🚀 Building Echidna with Multi-Layer Fuzzing Optimization Framework..."

# Navigate to echidna directory
cd ~/echidna_dev/echidna_1/echidna

# Clean previous builds
echo "🧹 Cleaning previous builds..."
stack clean

# Build with verbose output
echo "🔨 Building Echidna..."
stack build --verbose

if [ $? -ne 0 ]; then
    echo "❌ Build failed! Please check the errors above."
    exit 1
fi

echo "✅ Build successful!"

# Install the binary
echo "📦 Installing Echidna binary..."
stack install

# Create corpus directory if it doesn't exist
mkdir -p corpus

echo "🧪 Testing Multi-Layer Fuzzing Framework..."

echo "📋 Testing Configuration:"
echo "- Pre-Dilution Functions: transfer, approve, withdraw, deposit, burn, mint, swap"
echo "- Pre-Dilution Weight: 35%"
echo "- Smart Mutation: Enabled"
echo "- Differential Treatment: Enabled"
echo "- Adaptive Fuzzing: Enabled"
echo ""

# Test 1: Basic buggy contract
echo "🎯 Test 1: Running basic buggy contract test..."
timeout 30s stack exec echidna -- buggy_contract.sol --config echidna_config.yaml --verbose

echo ""
echo "🎯 Test 2: Running comprehensive multi-layer test..."
timeout 60s stack exec echidna -- multilayer_test_contract.sol --config echidna_config.yaml --verbose

echo ""
echo "🎯 Test 3: Running with increased test limits for better optimization..."
stack exec echidna -- multilayer_test_contract.sol --config echidna_config.yaml --test-limit 20000 --seq-len 200 --verbose

echo ""
echo "📊 Multi-Layer Fuzzing Results:"
echo "Check the corpus/ directory for generated test cases and coverage reports."
echo ""
echo "🎉 Multi-Layer Fuzzing Optimization Framework testing completed!"
echo ""
echo "📈 Expected Optimizations:"
echo "✓ Priority functions (transfer, approve, withdraw, etc.) called 35% more frequently"
echo "✓ Enhanced mutation strategies for complex arrays and states"
echo "✓ Differential gas limits and sequence lengths for different function types"
echo "✓ Adaptive strategy adjustment based on coverage and bug discovery"
echo "✓ Genetic algorithm-inspired crossover and elitism for test case evolution"
