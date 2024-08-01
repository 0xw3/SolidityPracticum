Swap smartcontract

1. When deploying the contract, specify the addresses of ERC20 tokens.
2. Owner must approve both tokens for swap smartcontract.
2. After deployment, the owner must call the initialize function, specifying how many tokens he wants to transfer to the swap smartcontract.

After that, the smartcontract can be used.

Some points
1. The exchange rate of tokens is 1 to 1.
2. Decimals of tokens must be the same.
3. Once the contract is initialized, it will not be possible to change tokens to other tokens.
4. Any user can directly top up the balance of the smart contract with any number of tokens. These tokens will be used for swap.