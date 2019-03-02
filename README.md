# truffle-ws-migrate-test

Test for truffle websocket migration

## Setup of poadevnet

### Create accounts

$ `geth --datadir node01/ account new`

- Save the address in accounts.txt
- Save the password in node01/password.txt

$ `geth --datadir node02/ account new`

- Save the address in accounts.txt
- Save the password in node02/password.txt

### Initialzie nodes

$ `geth --datadir node01/ init genesis.json`
$ `geth --datadir node02/ init genesis.json`

### Start node01

$ `./startnode01`

### Start node02

$ `./startnode02`

### Add node2 to node1

$ `./gethattach.sh`

> `admin.addPeer('enode://<enode address of node01>2@127.0.0.1:30312')``
