# Grant DAO

A simple governance smart contract for allocating treasury funds to approved grant proposals. Built with Clarity for the Stacks blockchain.

## Features

- **Deposit funds** into the DAO treasury  
- **Create grant proposals** specifying recipient and amount  
- **Vote** on proposals (yes/no)  
- **Execute proposals** after voting period and quorum are met  
- **View proposals** and voting status

## Contract Overview

- **Error Constants:** Standardized error codes for contract operations  
- **Configuration:** Voting duration and quorum settings  
- **Data Storage:** Proposal and vote tracking  
- **Public Functions:**  
  - `deposit(amount)`  
  - `create-proposal(recipient, amount)`  
  - `vote(proposal-id, support)`  
  - `execute(proposal-id)`  
- **Read-Only Functions:**  
  - `get-proposal(proposal-id)`  
  - `get-proposal-count()`  
  - `has-voted(proposal-id, who)`

## Usage

1. **Deposit Funds:**  
   Call `deposit(amount)` to add funds to the DAO treasury.

2. **Create Proposal:**  
   Call `create-proposal(recipient, amount)` to submit a new grant proposal.

3. **Vote:**  
   Call `vote(proposal-id, support)` to vote on a proposal (`support` is `true` for yes, `false` for no).

4. **Execute Proposal:**  
   After voting ends and quorum is met, call `execute(proposal-id)` to allocate funds.

5. **Query Proposals:**  
   Use `get-proposal(proposal-id)` and `get-proposal-count()` to view proposals.

## Development

- Contract file: grant-DAO.clar
- Written in [Clarity](https://docs.stacks.co/docs/clarity/overview/)
- Deploy and test using [Clarinet](https://github.com/stacks/clarinet)

