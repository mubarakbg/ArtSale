# Decentralized Art Auction Smart Contract

This project implements a decentralized art auction platform using smart contracts on the Stacks blockchain. Artists can submit their NFT art pieces to be bid on, with the entire process of bidding, winner selection, and token distribution managed by the smart contract.

## Features

- Auction-based NFT sales
- Automatic distribution of funds to the artist
- Timed bidding (24-hour auctions by default)
- Minimum bid and reserve price support

## Smart Contract Functions

### create-auction

Creates a new auction for an NFT.

Parameters:
- `nft-contract`: The principal of the NFT contract
- `nft-id`: The ID of the NFT to be auctioned
- `reserve-price`: The minimum price at which the NFT can be sold

### place-bid

Allows a user to place a bid on an active auction.

Parameters:
- `auction-id`: The ID of the auction
- `bid-amount`: The amount of STX to bid

### end-auction

Finalizes an auction after its duration has passed.

Parameters:
- `auction-id`: The ID of the auction to end

### get-auction-details

Retrieves the details of a specific auction.

Parameters:
- `auction-id`: The ID of the auction

### get-bid-details

Retrieves the details of a specific bid.

Parameters:
- `auction-id`: The ID of the auction
- `bidder`: The principal of the bidder

## Development

This project uses [Clarinet](https://github.com/hirosystems/clarinet) for smart contract development and testing.

### Prerequisites

- Install [Clarinet](https://docs.hiro.so/smart-contracts/clarinet)
- Familiarity with Clarity, the smart contract language for Stacks

### Testing

To run the tests:

1. Open a Clarinet console in the project directory:
   ```
   clarinet console
   ```
2. In the Clarinet console, run the test functions:
   ```
   (contract-call? .decentralized-art-auction-tests test-setup)
   (contract-call? .decentralized-art-auction-tests test-create-auction)
   (contract-call? .decentralized-art-auction-tests test-place-bid)
   (contract-call? .decentralized-art-auction-tests test-end-auction)
   ```

## Deployment

To deploy the contract to the Stacks blockchain:

1. Configure your network settings in `Clarinet.toml`
2. Use Clarinet's deployment command:
   ```
   clarinet deploy --network testnet
   ```

Replace `testnet` with `mainnet` for production deployment.

## Future Enhancements

- Implement token staking for premium auction listings
- Add support for open-ended bidding
- Integrate with a front-end application for a complete dApp experience

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.
