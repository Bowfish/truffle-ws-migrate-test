# truffle-ws-migrate-test

Test for Truffle websocket migration

## Setup of poadevnet

### Create accounts
```
$ cd poadevnet
$ geth --datadir node01/ account new
```

- Save the address in accounts.txt
- Save the password in node01/password.txt

```
$ geth --datadir node02/ account new
```

- Save the address in accounts.txt
- Save the password in node02/password.txt

### Initialzie nodes
```
$ geth --datadir node01/ init genesis.json
$ geth --datadir node02/ init genesis.json
```

### Start node01
```
$ ./startnode01.sh
```

### Start node02
```
$ ./startnode02.sh
```

### Add node2 to node1
```
$ ./gethattach.sh
```

In geth console: 
```
> admin.addPeer('enode://<enode address of node02>@127.0.0.1:30312')
```

Or: Create a file static-nodes.json with the following content:
```
[
  "enode://<enode address of node01>@127.0.0.1:30312",
  "enode://<enode address of node02>@127.0.0.1:30312"
]
```

### Add signers
in geth console: 
```
> clique.propose('<address of account 1>', true)
> clique.propose('<address of account 2>', true)
```

with: 
```
> clique.getSigners()
```
you will get the list of all authorized signers

## Installing web3
```
$ cd ..
$ npm install --save
```

## Deploying the contracts
```
$ truffle migrate --reset --network poadevnet
```

## Reproducing the Error: connection not open on send()

When the last two functions of the contract SimpleStorage are commented out, then the deployment works. As soon as only one of the functions will be added to the contract again the deployment fails. I figured out that it doesn't matter what kind of function will be added.

To reproduce the error delete the comment marks which comment out the last two functions.
