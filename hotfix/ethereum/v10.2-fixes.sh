#!/bin/bash

FILE_PATH="/usr/lib/node_modules/lamassu-server/lib/plugins/wallet/geth/base.js"

# Ensure the file exists before attempting to modify it
if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File not found: $FILE_PATH"
  exit 1
fi

# Use sed to replace the maxPriorityFeePerGas line
sed -i "s/const maxPriorityFeePerGas = new BN(web3.utils.toWei('2.5', 'gwei')) \/\/ web3 default value/const maxPriorityFeePerGas = new BN(web3.utils.toWei('1.0', 'gwei')) \/\/ web3 default value/" "$FILE_PATH"

# Use sed to replace the maxFeePerGas calculation
sed -i "s/const maxFeePerGas = baseFeePerGas.plus(neededPriority)/const maxFeePerGas = baseFeePerGas.times(2).plus(maxPriorityFeePerGas)/" "$FILE_PATH"

# Remove the newGasPrice line if it exists
sed -i "/const newGasPrice = BN\.minimum(maxFeePerGas, baseFeePerGas\.plus(maxPriorityFeePerGas))/d" "$FILE_PATH"

# Remove the neededPriority line if it exists
sed -i "/const neededPriority = new BN(web3.utils.toWei('2.0', 'gwei'))/d" "$FILE_PATH"

# Replace the old usage of newGasPrice with maxFeePerGas in transaction calculation
sed -i "s/\? new BN(amount)\.minus(newGasPrice\.times(gas))/\? new BN(amount).minus(maxFeePerGas.times(gas))/" "$FILE_PATH"

# Restart services
supervisorctl restart lamassu-server lamassu-admin-server

echo "Modifications complete and services restarted."
