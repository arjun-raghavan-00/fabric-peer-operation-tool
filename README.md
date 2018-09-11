# Hyperledger Fabric Peer Node.js SDK Operation Tool

This is a command-line tool which utilizes the [Hyperledger Fabric Client SDK for Node.js](https://github.com/hyperledger/fabric-sdk-node) to greatly facilitate the operation of a Hyperledger Fabric peer.
In addition to operating regular peers on a Hyperledger Fabric network, the tool also has special support for peers on an [IBM Blockchain Platform (IBP)](https://www.ibm.com/blockchain/platform) network, including both local IBP peers as well as [remote peers](https://console.stage1.bluemix.net/docs/services/blockchain/howto/remote_peer.html#remote-peer-overview).

The tool allows a user to carry out almost all essential tasks related to operating a peer, including:

- Joining a channel
- Installing, instantiating, and upgrading chaincode
- Invoking chaincode to send transactions
- Query a ledger using chaincode

Features that are currently in development include:

- Specifying more complex endorsement policies
- Creating a channel

The tool is built using a shell script wrapper around some Node.js scripts, allowing for both easy integration into a larger application as well as fast and straightforward automation of basic peer operation tasks (which might be useful for performance testing), not to mention general usage for an end-user.
It is completely flexible, allowing the user to manually specify the location of configuration files and certificates.
Of course, the tool itself abstracts as many tasks as is feasible while maintaining this flexibility; the amount of manual setup a user has to perform is minimized as far as possible.

## Prerequisites
* Ensure you have [Node.js and `npm`](https://nodejs.org/en/) installed as well.
* Check that you have [Go](https://golang.org/) installed on your machine and that the `GOPATH` environment variable is set.

## Setup

_Make sure you change your working directory to the root of the repository when you use the tool or run the scripts; otherwise, they won't be able to find the scripts and other files they need)._
1. Clone this branch somewhere onto your machine and `cd` into the repo's root directory:
    1. `cd <working directory>`
    2. If you are using an SSH key: 
       ```
       git clone --recurse-submodules git@github.ibm.com:arjunraghavan/peer-nodesdk-test-tool.git
       ```
       If you are using a PAT: 
       ```
       export PAT=<your token>
       git clone --recurse-submodules https://$PAT:x-oauth-basic@github.ibm.com/arjunraghavan/peer-nodesdk-test-tool.git
       ```
    3. `cd peer-node-test-tool`
2. Run `npm install`

Before proceeding, ensure that you have stored your network's connection profile(s) in a folder of your choice.
By default, the tool looks in a directory `./config/` for your network's connection profiles, but you can specify a different directory using the `--config` flag (see below)

If you are using remote peers, you need to download their server certificates and CA root certificates.

1. Open a shell on your remote peer:
    - If your remote peer is deployed on [IBM Cloud Private (ICp)](https://www.ibm.com/cloud/private):
        1. In the top-right corner of your ICp dashboard, press your user icon, select **Configure client**, and copy the provided commands into your shell.
        2. Run the following command to access your peer:
           ```
           kubectl exec -n <your namespace> -it <deployment name> bash
           ```
        3. The peer's CA root cert is found in `/mnt/certs/tls/cacert.pem`.  
           The peer's server cert is found in `/mnt/certs/tls/peer-cert.pem`.
    - If your remote peer is deployed on [Amazon Web Services](https://aws.amazon.com/):
        1. Navigate to **Services** > **Compute** > **EC2** on your AWS dashboard, select **Instances** from the left panel, and select your peer's EC2 instance from the list.
        2. Press the **Connect** button at the top of the screen and follow the instructions to SSH into your EC2 instance.
        3. Once inside the instance, run the following command to access your peer (the Docker container's name is `peer`, that is not a placeholder):
           ```
           docker exec -it peer bash
           ```
        4. The peer's CA root cert is found in `/etc/hyperledger/<peer name>/tls/ca.crt`.  
           The peer's server cert is found in `/etc/hyperledger/<peer name>/tls/server.crt`.
2. By default, the tool looks in a directory called `./certs/` for a CA root certificate file named `cacert.pem`. If you want to use this default setting:
    1. Create a new folder called `certs` in the same directory as the `peer-node.sh` file.
    2. Copy the peer's CA root cert into a new file `cacert.pem` and place it in the newly-created `certs` directory.
1. By default, the tool looks in `./certs/` for a server certificate file named `srvcert.pem`. If you want to use this default setting:
    1. Copy the peer's server cert into a new file `srvcert.pem` and place it in the `certs` directory.
    
Before you can use the tool to operate your peers, you need to enroll an admin user and sync it with your network (and, if you are using remote peers, you need to enroll your peer users):

1. Run `./peer-node.sh enroll admin` and make sure to sync the generated `admin` certificate with your network's peers:
    1. The aforementioned signing cert is created in the `hfc-key-store` folder.
    2. Open the file named `admin` and copy the certificate inside the quotation marks after the `certificate` field.
    3. Log in to your network on IBM Blockchain Platform, go to **Network Monitor** > **Members** > **Certificates**, and click **Add Certificate**. Give the certificate any name and paste the certificate copied in Step (ii). Click **Restart** to restart your peers.
2. If you are using remote peers:
    1. Run the command `./peer-node.sh enroll remotepeer`.
    2. Place the `admin` cert on your remote peer. Open a terminal on said peer:
        - For ICp, navigate to `/mnt/crypto/peer/peer/msp/admincerts/` and run the following command:
          ```
          echo -e "<certificate>" > certX.pem
          ```
          where `X` is any number so long as it does not conflict with another certificate in the same folder and `<certificate>` is the certificate copied in Step (ii).
        - For AWS, navigate to `/etc/hyperledger/<AWS peer name>/msp/admincerts/` and run the same command as above.

    3. Now that there are new admin certificates in the remote peer, you need to restart it:
        - For ICp, follow the instructions [here](https://console.stage1.bluemix.net/docs/services/blockchain/howto/remote_peer_operate_icp.html#remote-peer-restart).
        - For AWS, follow the instructions [here](https://console.stage1.bluemix.net/docs/services/blockchain/howto/remote_peer_operate_aws.html#remote-peer-aws-restart).
3. Navigate to **Channels** on the **Network Monitor**. For each of the channels you want your peers to join and/or interact on, click the menu button on the right (the three dots) and click **Sync Certificates**.

Note that the above admin enrollment steps must be repeated if you want to switch organizations.

## Command-Line Tool Usage

The script to run to use the tool is `./peer-node.sh`.

Add `-h` or `--help` after any command to view usage instructions (i.e. `./peer-node.sh --help` will show you the available commands and flags for `./peer-node.sh`, `./peer-node.sh chaincode install` will show you the available flags for that command, etc.).

If you want to use the individual Node.js scripts, see the [README file](https://github.ibm.com/arjunraghavan/rempeer-node-test-tool/blob/master/scripts/README.md) inside `./scripts/` for information on usage.

## Additional Parameter Information

- The `--remote` parameter is optional, and tells the script that the target is a remote peer.
- The `-n|--name` parameter is only required if the target is _not_ a remote peer, and is the name of the peer as displayed on the Network Monitor UI.
- The `-i|--ip`, `-p|--port`, and `-u|--username` parameters are only required if the target _is_ a remote peer.
- The `-u|--username` parameter must be the name of the remote peer enrolled by the `./peer-node.sh enroll remotepeer` command.
- The `--cacert` parameter is optional and only needed if the target is a remote peer. It describes where the peer's CA cert is located. If the supplied path is not relative to your root (`/`) or home (`~/`) then it will be treated as relative to your working directory. It defaults to `./certs/cacert.pem`.
- The `--srvcert` parameter is also optional and required only if the target is a remote peer. It describes where the peer's server cert is located. It defaults to `./certs/srvcert.pem`.
- The `-d|--dir` parameter refers to the path to the desired chaincode and must be relative to `$GOPATH/src` on your machine.
- The `-a|--args` parameter must be entered in the form of a JSON string (e.g. `'["arg1", "arg2", ...]'`, including the single quotes).
- The `-o|--org` parameter is optional and defaults to `PeerOrg1`; it tells the scripts which organization your remote peer is a part of. 
- The `-r|--orderer` paramter is also optional and defaults to `0`; it tells the scripts which orderer you want to send transactions and requests to (the number specifically is an index for what orderer to choose under `orderers` in the connection profile).
- The `--config` parameter is optional and defaults to `./config/`; it tells the scripts where your connection profiles (in JSON format) are located. Try to ensure that the only JSON files inside the directory you supply are connection profiles; otherwise, the scripts may not work as expected.
