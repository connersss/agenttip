# AgentTip

Tip any Agent ID holder by their `.ai` name, on BNB Chain.

**Binance Agent ID Hackathon entry.** AgentTip is a single smart contract with no owner, no admin, no fees, and no upgrade path. It holds no funds: every tip is forwarded in full to the Agent ID owner in the same transaction.

## How it works

An Agent ID's `tokenId` on the Agent ID contract is `uint256(keccak256(label))`, where `label` is the name **without** the `.ai` suffix. For example:

```
keccak256("so1inaa") = 59088328980715246198704127149844337433332371872360914276839784929778082154039
```

That is the `tokenId` of `so1inaa.ai`, owned by `0x12e3C700DdB6F3b7B76BEF16e1a07f71B7aF7498`.

The contract:

1. `tip("so1inaa")` computes the `tokenId`, calls `ownerOf(tokenId)` on the Agent ID contract to get the recipient, and forwards the full `msg.value` to them. It reverts if the Agent ID does not exist or the value is zero.
2. `resolve("so1inaa")` returns the owner's address without sending anything.
3. Every tip emits `Tipped(sender, recipient, tokenId, agentId, amount)`.

Agent ID contract (SPACE ID Agent ID, ERC-721, non-transferable, BNB Chain mainnet):

```
0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F
```

AgentTip contract address: **TBD** (fill in after mainnet deployment).

## Frontend

A static page in `docs/` (GitHub Pages). It connects via the injected wallet provider (MetaMask / Binance Wallet, standard EIP-1193 — no QR-code login, no server session), resolves a name, and sends the tip. It also shows the 10 most recent `Tipped` events read from the chain.

Run it locally:

```sh
# serve the docs/ folder, e.g.
npx serve docs
# then open http://localhost:3000
```

After deployment, set `AGENT_TIP_ADDRESS` in `docs/index.html` to the deployed contract address.

## Development

Requires [Foundry](https://book.getfoundry.sh/getting-started/installation).

```sh
forge build
forge test
```

Tests:

- `test/AgentTip.t.sol` — unit tests against a mocked Agent ID contract (no fork needed).
- `test/AgentTipFork.t.sol` — fork tests against the real Agent ID contract on BSC mainnet (needs network access to the BSC RPC).

## Deploy

**Do not deploy without explicit confirmation.** Deployment broadcasts a real transaction and spends real BNB for gas.

Dry-run first:

```sh
forge script script/Deploy.s.sol --rpc-url bsc --dry-run
```

Then, only with confirmation:

```sh
forge script script/Deploy.s.sol --rpc-url bsc --broadcast \
  --account <account> --sender <address>
```

Verify the source on BscScan after deploy:

```sh
forge verify-contract <address> contracts/AgentTip.sol:AgentTip \
  --chain-id 56 --etherscan-api-key <key>
```

## Safety

- Tips are **irreversible** and go directly to the Agent ID owner.
- AgentTip never holds funds and never takes a cut.
- The contract has no owner or admin functions: nobody can pause it, change the Agent ID contract, or withdraw anything (there is nothing to withdraw).
- The contract only ever calls `ownerOf` on the Agent ID contract and forwards BNB to the resolved owner. It does not collect seed phrases, private keys, or any credentials.

## License

MIT. See [LICENSE](LICENSE).
