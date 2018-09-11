## Node.js Script Information

Each Node.js script accepts command-line arguments as shown below.

Note:

- The `<IS REMOTE>` parameter is optional, and tells the script that the target is a remote peer.
- The `<PEER NAME>` parameter is only required if the target is _not_ a remote peer, and is the name of the peer as displayed on the Network Monitor UI.
- The `<PEER URL>`, `<PEER PORT>`, `<PEER EVENT HUB PORT>`, and `<PEER USERNAME>` parameters are only required if the target _is_ a remote peer.
- The `<PEER USERNAME>` parameter must be the name of the remote peer enrolled by the `enrollRemotePeer.js` script.
- The `<CACERT>` parameter is optional and only needed if the target is a remote peer. It describes where the peer's CA cert is located. If the supplied path is not relative to your root (`/`) or home (`~/`) then it will be treated as relative to your working directory. It defaults to `../certs/cacert.pem`.
- The `<SRVCERT>` parameter is also optional and required only if the target is a remote peer. It describes where the peer's server cert is located. It defaults to `../certs/srvcert.pem`.
- The `<CHAINCODE PATH>` parameter must be relative to `$GOPATH/src` on your machine.
- The `<ARGUMENTS>` parameter must be entered in the form of a JSON string (e.g. `'["arg1", "arg2", ...]'`, including the single quotes).
- The `<ORG NAME>` parameter is optional and defaults to `PeerOrg1`; it tells the scripts which organization your remote peer is a part of. 
- The `<ORDERER NUMBER>` paramter is also optional and defaults to `0`; it tells the scripts which orderer you want to send transactions and requests to (the number specifically is an index for what orderer to choose under `orderers` in the connection profile).
- The `<CONFIG DIR>` parameter is optional and defaults to `./config/`; it tells the scripts where your connection profiles (in JSON format) are located. Try to ensure that the only JSON files inside the directory you supply are connection profiles; otherwise, the scripts may not work as expected.

```
scripts/enrollAdmin.js <ORG NAME> <CONFIG DIR> <SRVCERT>
```
```
scripts/enrollRemotePeer.js <PEER USERNAME> <PEER PASSWORD> <ORG NAME> <CONFIG DIR> <SRVCERT>
```
```
scripts/joinChannel.js <PEER URL> <PEER PORT> <CHANNEL NAME> <ORG NAME> <ORDERER NUMBER> <IS REMOTE> <PEER NAME> <CACERT> <CONFIG DIR> <SRVCERT>
```
```
scripts/installChaincode.js <CHAINCODE PATH> <CHAINCODE NAME> <CHAINCODE VERSION> <PEER URL> <PEER PORT> <ORG NAME> <IS REMOTE> <PEER NAME> <CACERT> <CONFIG DIR> <SRVCERT>
```
```
scripts/instantiateChaincode.js <CHAINCODE NAME> <CHAINCODE VERSION> <PEER URL> <PEER PORT> <CHANNEL NAME> <ORG NAME> <ORDERER NUMBER> <IS REMOTE> <PEER NAME> <CACERT> <CONFIG DIR> <SRVCERT>
```
```
scripts/upgradeChaincode.js <CHAINCODE NAME> <CHAINCODE VERSION> <PEER URL> <PEER PORT> <CHANNEL NAME> <ORG NAME> <ORDERER NUMBER> <IS REMOTE> <PEER NAME> <CACERT> <CONFIG DIR> <SRVCERT>
```
```
scripts/invokeTransaction.js <CHAINCODE NAME> <FUNCTION> <ARGUMENTS> <PEER USERNAME> <PEER URL> <PEER PORT> <CHANNEL NAME> <ORG NAME> <ORDERER NUMBER> <IS REMOTE> <PEER NAME> <CACERT> <CONFIG DIR> <SRVCERT>
```
```
scripts/queryLedger.js <CHAINCODE NAME> <FUNCTION> <ARGUMENTS> <PEER USERNAME> <PEER URL> <PEER PORT> <CHANNEL NAME> <ORG NAME> <ORDERER NUMBER> <IS REMOTE> <PEER NAME> <CACERT> <CONFIG DIR> <SRVCERT>
```
