-include .env

build:; forge build

deploy-sepolia: 
	forge script script/FundMeScript.s.sol:FundMeScript --rpc-url $(SEPOLIA_RPC_URL) --account sepolia --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv