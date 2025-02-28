# Stacks Digital Asset Escrow

## Overview

Stacks Digital Asset Escrow is a Clarity smart contract designed to facilitate secure and trustless transactions for digital gaming assets on the Stacks blockchain. It ensures fair asset transfers between buyers and sellers through an escrow mechanism.

## Features

- **Trustless Escrow**: Holds digital asset transactions securely until conditions are met.
- **Automated Completion**: Finalizes transactions upon fulfillment of escrow conditions.
- **Buyer Refunds**: Allows refunds if an escrow fails or expires.
- **Expiration Handling**: Prevents indefinite holding by enforcing expiration time.

## Smart Contract Details

### Constants

- **ESCROW_MANAGER**: Designated manager with override permissions.
- **ESCROW_EXPIRATION_BLOCKS**: Defines the escrow validity period (~7 days).
- **Error Codes**: Includes unauthorized access, invalid escrow, failed transactions, etc.

### Functions

#### **Public Functions**
- `create-escrow(seller, asset-code, deposit)`: Initiates a new escrow.
- `finalize-escrow(escrow-id)`: Completes escrow and transfers assets to the buyer.
- `refund-buyer(escrow-id)`: Refunds the buyer in case of failed escrow.

#### **Read-Only Functions**
- `fetch-escrow(escrow-id)`: Retrieves escrow details.
- `latest-escrow-id()`: Returns the latest escrow ID.

## Installation & Deployment

### Prerequisites
- [Stacks Blockchain](https://www.stacks.co/)
- [Clarity Language](https://docs.stacks.co/docs/clarity)

### Deployment

1. Clone the repository:
   ```sh
   git clone https://github.com/your-username/stacks-digital-asset-escrow.git
   cd stacks-digital-asset-escrow
   ```
2. Deploy the contract using [Clarinet](https://github.com/hirosystems/clarinet):
   ```sh
   clarinet deploy
   ```

## Usage

1. **Create an escrow**  
   Call `create-escrow` with the seller’s principal, asset code, and deposit amount.

2. **Finalize the escrow**  
   The buyer (or manager) can complete the escrow with `finalize-escrow`.

3. **Refund the buyer**  
   If the escrow fails, `refund-buyer` allows returning the funds.

## License

This project is licensed under the MIT License.

## Contributions

Contributions, issues, and feature requests are welcome! Feel free to submit a PR or open an issue.
