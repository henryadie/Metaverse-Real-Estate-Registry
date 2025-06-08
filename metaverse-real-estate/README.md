# Virtual World Land Ownership System

A decentralized smart contract system for managing land parcels in virtual worlds, built on the Stacks blockchain using Clarity smart contracts.

## 🌍 Overview

This project implements a comprehensive land ownership and trading system for virtual worlds, allowing users to claim, trade, and manage digital land parcels with full blockchain transparency and ownership verification.

## ✨ Features

### Core Functionality
- **Land Claiming**: Claim unclaimed land parcels with custom names and descriptions
- **Land Trading**: Set land for sale and purchase from other players
- **Land Transfers**: Gift land to other users
- **Ownership Tracking**: Complete ownership history and land count per user
- **Transaction History**: Full audit trail of all land transactions

### Smart Contract Features
- **Coordinate Validation**: Ensures land coordinates are within world boundaries
- **Access Control**: Owner-only functions for land management
- **Price Management**: Flexible pricing system for land sales
- **World Configuration**: Admin controls for world size and base pricing

## 🏗️ Architecture

### Smart Contract Structure

```
Virtual World Land Contract
├── Constants & Error Codes
├── Data Variables (world size, base price)
├── Maps
│   ├── lands (coordinate → land data)
│   ├── owner-land-count (owner → count)
│   └── land-history (transaction records)
├── Public Functions
│   ├── Land Management
│   ├── Trading Functions
│   └── Admin Functions
└── Read-Only Functions
```

### Data Structures

**Land Parcel:**
```clarity
{
  owner: principal,
  name: (string-ascii 50),
  description: (string-ascii 200),
  price: uint,
  for-sale: bool,
  last-updated: uint
}
```

**Transaction History:**
```clarity
{
  from: (optional principal),
  to: principal,
  price: uint,
  transaction-type: (string-ascii 20)
}
```

## 🚀 Getting Started

### Prerequisites

- [Stacks CLI](https://docs.stacks.co/docs/write-smart-contracts/overview)
- [Node.js](https://nodejs.org/) (v16+)
- [Clarinet](https://github.com/hirosystems/clarinet) (for local development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/virtual-world-land.git
   cd virtual-world-land
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Initialize Clarinet project** (if not already done)
   ```bash
   clarinet new virtual-world-land
   cd virtual-world-land
   ```

4. **Copy the contract**
   ```bash
   cp land-ownership.clar contracts/
   ```

### Local Development

1. **Start Clarinet console**
   ```bash
   clarinet console
   ```

2. **Deploy contract locally**
   ```clarity
   ::deploy_contract land-ownership
   ```

3. **Run tests**
   ```bash
   npm test
   ```

## 📖 Usage

### Claiming Land

```clarity
;; Claim a land parcel at coordinates (10, 15)
(contract-call? .land-ownership claim-land u10 u15 "My Estate" "A beautiful virtual property")
```

### Trading Land

```clarity
;; Set land for sale
(contract-call? .land-ownership set-land-for-sale u10 u15 u5000000) ;; 5 STX

;; Purchase land
(contract-call? .land-ownership buy-land u10 u15)

;; Remove from sale
(contract-call? .land-ownership remove-land-from-sale u10 u15)
```

### Transferring Land

```clarity
;; Gift land to another user
(contract-call? .land-ownership transfer-land u10 u15 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
```

### Querying Land Information

```clarity
;; Get land details
(contract-call? .land-ownership get-land-info u10 u15)

;; Check ownership
(contract-call? .land-ownership get-land-owner u10 u15)

;; Check if for sale
(contract-call? .land-ownership is-land-for-sale u10 u15)
```

## 🧪 Testing

The project includes comprehensive unit tests using Vitest:

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage
```

### Test Coverage

- ✅ Land claiming and validation
- ✅ Ownership verification
- ✅ Trading functionality
- ✅ Transfer operations
- ✅ Read-only functions
- ✅ Admin functions
- ✅ Error handling
- ✅ Edge cases

## 📋 API Reference

### Public Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `claim-land` | `x`, `y`, `name`, `description` | Claim an unclaimed land parcel |
| `update-land` | `x`, `y`, `name`, `description` | Update land information (owner only) |
| `set-land-for-sale` | `x`, `y`, `price` | Set land for sale at specified price |
| `remove-land-from-sale` | `x`, `y` | Remove land from marketplace |
| `buy-land` | `x`, `y` | Purchase land that's for sale |
| `transfer-land` | `x`, `y`, `new-owner` | Transfer land to another user |

### Read-Only Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `get-land-info` | `x`, `y` | Land data or none | Get complete land information |
| `is-valid-coordinates` | `x`, `y` | bool | Check if coordinates are valid |
| `get-owner-land-count` | `owner` | uint | Get owner's total land count |
| `is-land-owned` | `x`, `y` | bool | Check if land is claimed |
| `get-land-owner` | `x`, `y` | principal or none | Get land owner |
| `is-land-for-sale` | `x`, `y` | bool | Check if land is for sale |
| `get-land-price` | `x`, `y` | uint | Get land sale price |
| `get-world-size` | - | `{x: uint, y: uint}` | Get world dimensions |

### Admin Functions

| Function | Parameters | Description | Access |
|----------|------------|-------------|---------|
| `set-world-size` | `new-x`, `new-y` | Update world dimensions | Contract owner only |
| `set-base-land-price` | `new-price` | Update base land price | Contract owner only |

## 🔧 Configuration

### World Settings

- **Default World Size**: 1000 × 1000 parcels
- **Base Land Price**: 1,000,000 microSTX (1 STX)
- **Maximum Name Length**: 50 characters
- **Maximum Description Length**: 200 characters

### Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | `ERR_NOT_AUTHORIZED` | Unauthorized action |
| u101 | `ERR_LAND_NOT_EXISTS` | Land parcel doesn't exist |
| u102 | `ERR_LAND_ALREADY_OWNED` | Land already claimed |
| u103 | `ERR_NOT_LAND_OWNER` | Not the land owner |
| u104 | `ERR_INVALID_COORDINATES` | Invalid coordinates |
| u105 | `ERR_INSUFFICIENT_PAYMENT` | Insufficient payment |
| u106 | `ERR_LAND_NOT_FOR_SALE` | Land not for sale |

## 🚀 Deployment

### Testnet Deployment

1. **Configure Stacks CLI**
   ```bash
   stx make_keychain -t
   ```

2. **Deploy to testnet**
   ```bash
   clarinet deployments apply --network testnet
   ```

### Mainnet Deployment

1. **Configure for mainnet**
   ```bash
   clarinet deployments generate --network mainnet
   ```

2. **Deploy to mainnet**
   ```bash
   clarinet deployments apply --network mainnet
   ```

## 🔐 Security Considerations

- **Access Control**: All sensitive functions have proper authorization checks
- **Input Validation**: Coordinates and parameters are validated
- **Overflow Protection**: Uint operations are safe from overflow
- **State Consistency**: Land ownership counts are properly maintained
- **Transaction History**: Complete audit trail for all operations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Clarity best practices
- Add tests for new features
- Update documentation
- Ensure all tests pass
- Follow the existing code style

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on [Stacks Blockchain](https://www.stacks.co/)
- Powered by [Clarity Smart Contracts](https://clarity-lang.org/)
- Testing with [Vitest](https://vitest.dev/)

## 📞 Support

- 📖 [Documentation](https://docs.stacks.co/)
- 💬 [Discord Community](https://discord.gg/stacks)
- 🐛 [Issue Tracker](https://github.com/yourusername/virtual-world-land/issues)

---

**Happy Land Trading! 🏞️**