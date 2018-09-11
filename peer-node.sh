#!/bin/bash

# Help messages
function showHelp {
  echo "Usage: "
  echo "  peer.sh [command]"
  echo "  peer.sh [flags]"
  echo ""
  echo "Available commands: "
  echo "  enroll       Enroll an admin or a remote peer user: admin|remotepeer"
  echo "  channel      Operate a channel: join"
  echo "  chaincode    Operate a chaincode: install|instantiate|upgrade|invoke|query"
  echo ""
  echo "Global Flags: "
  echo "      --remote    Enables remote peer targeting (optional)"
  echo "  -o, --org       Organization name (optional, defaults to PeerOrg1)"
  echo "      --config    Configuration directory (optional, defaults to ./config/)"
  echo "  -h, --help      Show help (print this message)"
}

function showEnrollHelp {
  echo "Enroll an admin or a remote peer user: admin|remotepeer"
  echo ""
  echo "Usage: "
  echo "  peer.sh enroll [command]"
  echo "  peer.sh enroll [flags]"
  echo ""
  echo "Available commands: "
  echo "  admin         Enroll an admin user"
  echo "  remotepeer    Enroll a remote peer user"
  echo ""
  echo "Global Flags: "
  echo "      --remote    Enables remote peer targeting (optional) (no effect on enroll)"
  echo "  -o, --org       Organization name (optional, defaults to PeerOrg1)"
  echo "      --config    Configuration directory (optional, defaults to ./config/)"
  echo "  -h, --help      Show help (print this message)"
}

function showEnrollRemoteHelp {
  echo "Enroll a remote peer user"
  echo ""
  echo "Usage: "
  echo "  peer.sh enroll remotepeer [flags]"
  echo ""
  echo "Flags: "
  echo "  -u, --username <name>    Peer user name"
  echo "  -p, --password <pass>    Peer password"
  echo ""
  echo "Global Flags: "
  echo "      --remote    Enables remote peer targeting (optional) (no effect on enroll)"
  echo "  -o, --org       Organization name (optional, defaults to PeerOrg1)"
  echo "      --config    Configuration directory (optional, defaults to ./config/)"
  echo "  -h, --help      Show help (print this message)"
}

function showChannelHelp {
  echo "Operate a channel: join"
  echo ""
  echo "Usage: "
  echo "  peer.sh channel [command]"
  echo "  peer.sh channel [flags]"
  echo ""
  echo "Available commands: "
  echo "  join   Join a channel"
  echo ""
  echo "Global Flags: "
  echo "      --remote    Enables remote peer targeting (optional)"
  echo "  -o, --org       Organization name (optional, defaults to PeerOrg1)"
  echo "      --config    Configuration directory (optional, defaults to ./config/)"
  echo "  -h, --help      Show help (print this message)"
}

function showChannelJoinHelp() {
  echo "Join a channel"
  echo ""
  echo "Usage: "
  echo "  peer.sh channel join [flags]"
  echo ""
  echo "Flags: "
  echo "  -C, --channel <name>      Name of the channel"
  echo "  -r, --orderer <number>    Orderer number (optional, defaults to 0)"
  echo ""
  echo "  If --remote is enabled: "
  echo "  -i, --ip <address>        Peer's IP address"
  echo "  -p, --port <number>       Port to connect to the peer with"
  echo "      --cacert <cert>        Path to peer's CA certificate (optional, defaults to ./certs/cacert.pem)"
  echo "      --srvcert <cert>       Path to peer's server certificate (optional, defaults to ./certs/srvcert.pem)"
  echo ""
  echo "  If --remote is not enabled: "
  echo "  -n, --name <name>         Name of peer"
  echo ""
  echo "Global Flags: "
  echo "      --remote    Enables remote peer targeting (optional)"
  echo "  -o, --org       Organization name (optional, defaults to PeerOrg1)"
  echo "      --config    Configuration directory (optional, defaults to ./config/)"
  echo "  -h, --help      Show help (print this message)"
}

function showChaincodeHelp() {
  echo "Operate a chaincode: install|instantiate|upgrade|invoke|query"
  echo ""
  echo "Usage: "
  echo "  peer.sh chaincode [command]"
  echo "  peer.sh chaincode [flags]"
  echo ""
  echo "Available commands: "
  echo "  install        Install chaincode on a peer"
  echo "  instantiate    Instantiate chaincode on a channel"
  echo "  upgrade        Upgrade chaincode on a channel"
  echo "  invoke         Invoke the chaincode to send a transaction"
  echo "  query          Query the ledger using the chaincode"
  echo ""
  echo "Global Flags: "
  echo "      --remote    Enables remote peer targeting (optional)"
  echo "  -o, --org       Organization name (optional, defaults to PeerOrg1)"
  echo "      --config    Configuration directory (optional, defaults to ./config/)"
  echo "  -h, --help      Show help (print this message)"
}

function showChaincodeInstallHelp() {
  echo "Install chaincode on a peer"
  echo ""
  echo "Usage: "
  echo "  peer.sh chaincode install [flags]"
  echo ""
  echo "Flags: "
  echo "  -d, --dir <path>           Path to directory where chaincode is located (relative to \$GOCCPATH/src)"
  echo "  -c, --chaincode <name>     Chaincode name (aka chaincode ID)"
  echo "  -v, --version <version>    Chaincode version"
  echo ""
  echo "  If --remote is enabled: "
  echo "  -i, --ip <address>         Peer's IP address"
  echo "  -p, --port <number>        Port to connect to the peer with"
  echo "      --cacert <cert>        Path to peer's CA certificate (optional, defaults to ./certs/cacert.pem)"
  echo "      --srvcert <cert>       Path to peer's server certificate (optional, defaults to ./certs/srvcert.pem)"
  echo ""
  echo "  If --remote is not enabled: "
  echo "  -n, --name <name>          Name of peer"
  echo ""
  echo "Global Flags: "
  echo "      --remote    Enables remote peer targeting (optional)"
  echo "  -o, --org       Organization name (optional, defaults to PeerOrg1)"
  echo "      --config    Configuration directory (optional, defaults to ./config/)"
  echo "  -h, --help      Show help (print this message)"
}

function showChaincodeInstantiateHelp() {
  echo "Instantiate chaincode on a channel"
  echo ""
  echo "Usage: "
  echo "  peer.sh chaincode instantiate [flags]"
  echo ""
  echo "Flags: "
  echo "  -c, --chaincode <name>     Chaincode name (aka chaincode ID)"
  echo "  -v, --version <version>    Chaincode version"
  echo "  -C, --channel <name>       Channel to instantiate on"
  echo "  -r, --orderer <number>     Orderer number (optional, defaults to 0)"
  echo ""
  echo "  If --remote is enabled: "
  echo "  -i, --ip <address>         Peer's IP address"
  echo "  -p, --port <number>        Port to connect to the peer with"
  echo "      --cacert <cert>        Path to peer's CA certificate (optional, defaults to ./certs/cacert.pem)"
  echo "      --srvcert <cert>       Path to peer's server certificate (optional, defaults to ./certs/srvcert.pem)"
  echo ""
  echo "  If --remote is not enabled: "
  echo "  -n, --name <name>          Name of peer"
  echo ""
  echo "Global Flags: "
  echo "      --remote    Enables remote peer targeting (optional)"
  echo "  -o, --org       Organization name (optional, defaults to PeerOrg1)"
  echo "      --config    Configuration directory (optional, defaults to ./config/)"
  echo "  -h, --help      Show help (print this message)"
}

function showChaincodeUpgradeHelp() {
  echo "Upgrade chaincode on a channel"
  echo ""
  echo "Usage: "
  echo "  peer.sh chaincode upgrade [flags]"
  echo ""
  echo "Flags: "
  echo "  -c, --chaincode <name>     Chaincode name (aka chaincode ID)"
  echo "  -v, --version <version>    Chaincode version"
  echo "  -C, --channel <name>       Channel to upgrade on"
  echo "  -r, --orderer <number>     Orderer number (optional, defaults to 0)"
  echo ""
  echo "  If --remote is enabled: "
  echo "  -i, --ip <address>         Peer's IP address"
  echo "  -p, --port <number>        Port to connect to the peer with"
  echo "      --cacert <cert>        Path to peer's CA certificate (optional, defaults to ./certs/cacert.pem)"
  echo "      --srvcert <cert>       Path to peer's server certificate (optional, defaults to ./certs/srvcert.pem)"
  echo ""
  echo "  If --remote is not enabled: "
  echo "  -n, --name <name>          Name of peer"
  echo ""
  echo "Global Flags: "
  echo "      --remote    Enables remote peer targeting (optional)"
  echo "  -o, --org       Organization name (optional, defaults to PeerOrg1)"
  echo "      --config    Configuration directory (optional, defaults to ./config/)"
  echo "  -h, --help      Show help (print this message)"
}

function showChaincodeInvokeHelp() {
  echo "Invoke the chaincode to send a transaction"
  echo ""
  echo "Usage: "
  echo "  peer.sh chaincode invoke [flags]"
  echo ""
  echo "Flags: "
  echo "  -c, --chaincode <name>     Chaincode name (aka chaincode ID)"
  echo "  -f, --func <function>      Function to invoke"
  echo "  -a, --args <arguments>     Arguments to function (in the form of a JSON array string)"
  echo "  -C, --channel <name>       Channel to invoke on"
  echo "  -r, --orderer <number>     Orderer number (optional, defaults to 0)"
  echo ""
  echo "  If --remote is enabled: "
  echo "  -u, --username <name>      Username of peer to invoke"
  echo "  -i, --ip <address>         Peer's IP address"
  echo "  -p, --port <number>        Port to connect to the peer with"
  echo "      --cacert <cert>        Path to peer's CA certificate (optional, defaults to ./certs/cacert.pem)"
  echo "      --srvcert <cert>       Path to peer's server certificate (optional, defaults to ./certs/srvcert.pem)"
  echo ""
  echo "  If --remote is not enabled: "
  echo "  -n, --name <name>          Name of peer"
  echo ""
  echo "Global Flags: "
  echo "      --remote    Enables remote peer targeting (optional)"
  echo "  -o, --org       Organization name (optional, defaults to PeerOrg1)"
  echo "      --config    Configuration directory (optional, defaults to ./config/)"
  echo "  -h, --help      Show help (print this message)"
}

function showChaincodeQueryHelp() {
  echo "Query the ledger using the chaincode"
  echo ""
  echo "Usage: "
  echo "  peer.sh chaincode query [flags]"
  echo ""
  echo "Flags: "
  echo "  -c, --chaincode <name>     Chaincode name (aka chaincode ID)"
  echo "  -f, --func <function>      Function to use for query"
  echo "  -a, --args <arguments>     Arguments to function (in the form of a JSON array string)"
  echo "  -C, --channel <name>       Channel to query on"
  echo "  -r, --orderer <number>     Orderer number (optional, defaults to 0)"
  echo ""
  echo "  If --remote is enabled: "
  echo "  -u, --username <name>      Username of peer to query"
  echo "  -i, --ip <address>         Peer's IP address"
  echo "  -p, --port <number>        Port to connect to the peer with"
  echo "      --cacert <cert>        Path to peer's CA certificate (optional, defaults to ./certs/cacert.pem)"
  echo "      --srvcert <cert>       Path to peer's server certificate (optional, defaults to ./certs/srvcert.pem)"
  echo ""
  echo "  If --remote is not enabled: "
  echo "  -n, --name <name>          Name of peer"
  echo ""
  echo "Global Flags: "
  echo "      --remote    Enables remote peer targeting (optional)"
  echo "  -o, --org       Organization name (optional, defaults to PeerOrg1)"
  echo "      --config    Configuration directory (optional, defaults to ./config/)"
  echo "  -h, --help      Show help (print this message)"
}

# Check for installed commands
function checkPrereqs {
  OUTPUTSTR="Please install the following missing prerequisites:\n"
  DEFAULTOUTPUT=$OUTPUTSTR
  if ! [[ -x "$(command -v ibmcloud)" ]] && ! [[ -x "$(command -v cf)" ]] ; then
    OUTPUTSTR="$OUTPUTSTR  - IBM Cloud CLI\n"
  fi
  if ! [[ -x "$(command -v jq)" ]] ; then
    OUTPUTSTR="$OUTPUTSTR  - jq\n"
  fi
  if ! [[ "$OUTPUTSTR" == "$DEFAULTOUTPUT" ]] ; then
    echo -e $OUTPUTSTR
    exit 1
  fi
}

function enrollAdmin {
  while [[ $# -ge 1 ]] ; do
    key="$1"
    case $key in
      --config )
        CONFIG="$2"
        shift
        ;;
      -o|--org )
        ORG="$2"
        shift
        ;;
      --remote )
        # Do nothing
        ;;
    esac
    shift
  done

  node scripts/enrollAdmin.js "${ORG:-?}" "${CONFIG:-?}"
  exit 0
}

function enrollRemotePeer() {
  while [[ $# -ge 1 ]] ; do
    key="$1"
    case $key in
      --config )
        CONFIG="$2"
        shift
        ;;
      -u|--username )
        user_flag=true
        USERNAME="$2"
        shift
        ;;
      -p|--password )
        pass_flag=true
        PASSWORD="$2"
        shift
        ;;
      -h|--help )
        showEnrollRemoteHelp
        exit 0
        ;;
      --remote )
        # Do nothing
        ;;
      -o|--org )
        ORG="$2"
        shift
        ;;
      * )
        echo "Unknown flag: $key"
        showEnrollRemoteHelp
        exit 1
        ;;
    esac
    shift
  done

  if [[ ! $user_flag || ! $pass_flag ]] ; then
    echo "Incorrect usage."
    showEnrollRemoteHelp
    exit 1
  fi

  node scripts/enrollRemotePeer.js "$USERNAME" "$PASSWORD" "${ORG:-?}" "${CONFIG:-?}"
  exit 0
}

function joinChannel {
  while [[ $# -ge 1 ]] ; do
    key="$1"
    case $key in
      --config )
        CONFIG="$2"
        shift
        ;;
      -o|--org )
        ORG="$2"
        shift
        ;;
      -r|--orderer )
        ORD="$2"
        shift
        ;;
      -h|--help )
        showChannelJoinHelp
        exit 0
        ;;
      --remote )
        rem_flag=true
        ;;
      --srvcert )
        SRVCERT="$2"
        shift
        ;;
      --cacert )
        CACERT="$2"
        shift
        ;;
      -n|--name )
        NAME="$2"
        name_flag=true
        shift
        ;;
      -i|--ip )
        ip_flag=true
        IP="$2"
        shift
        ;;
      -p|--port )
        port_flag=true
        PORT="$2"
        shift
        ;;
      -C|--channel )
        channel_flag=true
        CHANNEL="$2"
        shift
        ;;
      * )
        echo "Unknown flag: $key"
        showChannelJoinHelp
        exit 1
        ;;
    esac
    shift
  done

  if [[ ! $channel_flag || ( ! $rem_flag && ! $name_flag ) || ( $rem_flag && ( ! $ip_flag || ! $port_flag ) ) ]] ; then
    echo "Incorrect usage."
    showChannelJoinHelp
    exit 1
  fi

  if [[ $rem_flag ]] ; then REMOTE=1 ; else REMOTE=0 ; fi
  node scripts/joinChannel.js "${IP:-?}" "${PORT:-?}" "$CHANNEL" "${ORG:-?}" "${ORD:-0}" "$REMOTE" "$NAME" "${CACERT:-?}" "${CONFIG:-?}" "${SRVCERT:-?}"
  exit 0
}

function installCC {
  while [[ $# -ge 1 ]] ; do
    key="$1"
    case $key in
      --config )
        CONFIG="$2"
        shift
        ;;
      -h|--help )
        showChaincodeInstallHelp
        exit 0
        ;;
      -o|--org )
        ORG="$2"
        shift
        ;;
      --srvcert )
        SRVCERT="$2"
        shift
        ;;
      --cacert )
        CACERT="$2"
        shift
        ;;
      --remote )
        rem_flag=true
        ;;
      -d|--dir )
        path_flag=true
        CCPATH="$2"
        shift
        ;;
      -c|--chaincode )
        ccname_flag=true
        CCNAME="$2"
        shift
        ;;
      -v|--version )
        version_flag=true
        VERSION="$2"
        shift
        ;;
      -i|--ip )
        ip_flag=true
        IP="$2"
        shift
        ;;
      -p|--port )
        port_flag=true
        PORT="$2"
        shift
        ;;
      -n|--name )
        name_flag=true
        NAME="$2"
        shift
        ;;
      * )
        echo "Unknown flag: $key"
        showChaincodeInstallHelp
        exit 1
        ;;
    esac
    shift
  done

  if [[ ! $path_flag || ! $ccname_flag || ! $version_flag || ( ! $rem_flag && ! $name_flag ) || ( $rem_flag && ( ! $ip_flag || ! $port_flag ) ) ]] ; then
    echo "Incorrect usage."
    showChaincodeInstallHelp
    exit 1
  fi

  if [[ $rem_flag ]] ; then REMOTE=1 ; else REMOTE=0 ; fi
  node scripts/installChaincode.js "$CCPATH" "$CCNAME" "$VERSION" "${IP:-?}" "${PORT:-?}" "${ORG:-?}" "$REMOTE" "$NAME" "${CACERT:-?}" "${CONFIG:-?}" "${SRVCERT:-?}"
  exit 0
}

function instantiateCC {
  while [[ $# -ge 1 ]] ; do
    key="$1"
    case $key in
      --config )
        CONFIG="$2"
        shift
        ;;
      -h|--help )
        showChaincodeInstantiateHelp
        exit 0
        ;;
      -r|--orderer )
        ORD="$2"
        shift
        ;;
      -o|--org )
        ORG="$2"
        shift
        ;;
      --srvcert )
        SRVCERT="$2"
        shift
        ;;
      --cacert )
        CACERT="$2"
        shift
        ;;
      --remote )
        rem_flag=true
        ;;
      -c|--chaincode )
        ccname_flag=true
        CCNAME="$2"
        shift
        ;;
      -v|--version )
        version_flag=true
        VERSION="$2"
        shift
        ;;
      -i|--ip )
        ip_flag=true
        IP="$2"
        shift
        ;;
      -p|--port )
        port_flag=true
        PORT="$2"
        shift
        ;;
      -C|--channel )
        channel_flag=true
        CHANNEL="$2"
        shift
        ;;
      -n|--name )
        name_flag=tru
        NAME="$2"
        shift
        ;;
      * )
        echo "Unknown flag: $key"
        showChaincodeInstantiateHelp
        exit 1
        ;;
    esac
    shift
  done

  if [[ ! $ccname_flag || ! $version_flag || ! $channel_flag || ( ! $rem_flag && ! $name_flag ) || ( $rem_flag && ( ! $ip_flag || ! $port_flag ) ) ]] ; then
    echo "Incorrect usage."
    showChaincodeInstantiateHelp
    exit 1
  fi

  if [[ $rem_flag ]] ; then REMOTE=1 ; else REMOTE=0 ; fi
  node scripts/instantiateChaincode.js "$CCNAME" "$VERSION" "${IP:-?}" "${PORT:-?}" "${EVENT:-?}" "$CHANNEL" "${ORG:-?}" "${ORD:-0}" "$REMOTE" "$NAME" "${CACERT:-?}" "${CONFIG:-?}" "${SRVCERT:-?}"
  exit 0
}

function upgradeCC {
  while [[ $# -ge 1 ]] ; do
    key="$1"
    case $key in
      --config )
        CONFIG="$2"
        shift
        ;;
      -h|--help )
        showChaincodeUpgradeHelp
        exit 0
        ;;
      -o|--org )
        ORG="$2"
        shift
        ;;
      -r|--orderer )
        ORD="$2"
        shift
        ;;
      --srvcert )
        SRVCERT="$2"
        shift
        ;;
      --cacert )
        CACERT="$2"
        shift
        ;;
      --remote )
        rem_flag=true
        ;;
      -c|--chaincode )
        ccname_flag=true
        CCNAME="$2"
        shift
        ;;
      -v|--version )
        version_flag=true
        VERSION="$2"
        shift
        ;;
      -i|--ip )
        ip_flag=true
        IP="$2"
        shift
        ;;
      -p|--port )
        port_flag=true
        PORT="$2"
        shift
        ;;
      -C|--channel )
        channel_flag=true
        CHANNEL="$2"
        shift
        ;;
      -n|--name )
        name_flag=true
        NAME="$2"
        shift
        ;;
      * )
        echo "Unknown flag: $key"
        showChaincodeUpgradeHelp
        exit 1
        ;;
    esac
    shift
  done

  if [[ ! $ccname_flag || ! $version_flag || ! $channel_flag || ( ! $rem_flag && ! $name_flag ) || ( $rem_flag && ( ! $ip_flag || ! $port_flag ) ) ]] ; then
    echo "Incorrect usage."
    showChaincodeUpgradeHelp
    exit 1
  fi

  if [[ $rem_flag ]] ; then REMOTE=1 ; else REMOTE=0 ; fi
  node scripts/upgradeChaincode.js "$CCNAME" "$VERSION" "${IP:-?}" "${PORT:-?}" "${EVENT:-?}" "$CHANNEL" "${ORG:-?}" "${ORD:-0}" "$REMOTE" "$NAME" "${CACERT:-?}" "${CONFIG:-?}" "${SRVCERT:-?}"
  exit 0
}

function invoke {
  while [[ $# -ge 1 ]] ; do
    key="$1"
    case $key in
      --config )
        CONFIG="$2"
        shift
        ;;
      -h|--help )
        showChaincodeInvokeHelp
        exit 0
        ;;
      -o|--org )
        ORG="$2"
        shift
        ;;
      -r|--orderer )
        ORD="$2"
        shift
        ;;
      --srvcert )
        SRVCERT="$2"
        shift
        ;;
      --cacert )
        CACERT="$2"
        shift
        ;;
      --remote )
        rem_flag=true
        ;;
      -c|--chaincode )
        ccname_flag=true
        CCNAME="$2"
        shift
        ;;
      -f|--func )
        fn_flag=true
        FUNC="$2"
        shift
        ;;
      -a|--args )
        args_flag=true
        ARGS="$2"
        shift
        ;;
      -u|--user )
        user_flag=true
        USER="$2"
        shift
        ;;
      -i|--ip )
        ip_flag=true
        IP="$2"
        shift
        ;;
      -p|--port )
        port_flag=true
        PORT="$2"
        shift
        ;;
      -C|--channel )
        channel_flag=true
        CHANNEL="$2"
        shift
        ;;
      -n|--name )
        name_flag=true
        NAME="$2"
        shift
        ;;
      * )
        "Unknown flag: $key"
        showChaincodeInvokeHelp
        exit 1
        ;;
    esac
    shift
  done

  if [[ ! $ccname_flag || ! $fn_flag || ! $args_flag || ! $channel_flag || ( ! $rem_flag && ! $name_flag ) || ( $rem_flag && ( ! $user_flag || ! $ip_flag || ! $port_flag ) ) ]] ; then
    echo "Incorrect usage."
    showChaincodeInvokeHelp
    exit 1
  fi

  if [[ $rem_flag ]] ; then REMOTE=1 ; else REMOTE=0 ; fi
  node scripts/invokeTransaction.js "$CCNAME" "$FUNC" "$ARGS" "${USER:-?}" "${IP:-?}" "${PORT:-?}" "${EVENT:-?}" "$CHANNEL" "${ORG:-?}" "${ORD:-0}" "$REMOTE" "$NAME" "${CACERT:-?}" "${CONFIG:-?}" "${SRVCERT:-?}"
  exit 0
}

function query {
  while [[ $# -ge 1 ]] ; do
    key="$1"
    case $key in
      --config )
        CONFIG="$2"
        shift
        ;;
      -h|--help )
        showChaincodeInvokeHelp
        exit 0
        ;;
      -o|--org )
        ORG="$2"
        shift
        ;;
      -r|--orderer )
        ORD="$2"
        shift
        ;;
      --srvcert )
        SRVCERT="$2"
        shift
        ;;
      --cacert )
        CACERT="$2"
        shift
        ;;
      --remote )
        rem_flag=true
        ;;
      -c|--chaincode )
        ccname_flag=true
        CCNAME="$2"
        shift
        ;;
      -f|--func )
        fn_flag=true
        FUNC="$2"
        shift
        ;;
      -a|--args )
        args_flag=true
        ARGS="$2"
        shift
        ;;
      -u|--user )
        user_flag=true
        USER="$2"
        shift
        ;;
      -i|--ip )
        ip_flag=true
        IP="$2"
        shift
        ;;
      -p|--port )
        port_flag=true
        PORT="$2"
        shift
        ;;
      -C|--channel )
        channel_flag=true
        CHANNEL="$2"
        shift
        ;;
      -n|--name )
        name_flag=true
        NAME="$2"
        shift
        ;;
      * )
        "Unknown flag: $key"
        showChaincodeQueryHelp
        exit 1
        ;;
    esac
    shift
  done

  if [[ ! $ccname_flag || ! $fn_flag || ! $args_flag || ! $channel_flag || ( ! $rem_flag && ! $name_flag ) || ( $rem_flag && ( ! $user_flag || ! $ip_flag || ! $port_flag ) ) ]] ; then
    echo "Incorrect usage."
    showChaincodeQueryHelp
    exit 1
  fi

  if [[ $rem_flag ]] ; then REMOTE=1 ; else REMOTE=0 ; fi
  node scripts/queryLedger.js "$CCNAME" "$FUNC" "$ARGS" "${USER:-?}" "${IP:-?}" "${PORT:-?}" "$CHANNEL" "${ORG:-?}" "${ORD:-0}" "$REMOTE" "$NAME" "${CACERT:-?}" "${CONFIG:-?}" "${SRVCERT:-?}"
  exit 0
}

function enroll {
  if [[ $# -eq 0 ]] ; then
    showEnrollHelp
    exit 1
  fi

  case $1 in
    admin )
      shift
      enrollAdmin "$@"
      ;;
    remotepeer )
      shift
      enrollRemotePeer "$@"
      ;;
    -h|--help )
      showEnrollHelp
      exit 0
      ;;
    * )
      echo "Unknown command or flag: $2"
      showEnrollHelp
      exit 1
      ;;
  esac
}

function channel {
  if [[ $# -eq 0 ]] ; then
    showChannelHelp
    exit 1
  fi

  case $1 in
    join )
      shift
      joinChannel "$@"
      ;;
    -h|--help )
      showChannelHelp
      exit 0
      ;;
    * )
      echo "Unknown command or flag: $2"
      showChannelHelp
      exit 1
      ;;
  esac
}

function chaincode {
  if [[ $# -eq 0 ]] ; then
    showChaincodeHelp
    exit 1
  fi

  case $1 in
    install )
      shift
      installCC "$@"
      ;;
    instantiate )
      shift
      instantiateCC "$@"
      ;;
    upgrade )
      shift
      upgradeCC "$@"
      ;;
    invoke )
      shift
      invoke "$@"
      ;;
    query )
      shift
      query "$@"
      ;;
    -h|--help )
      showChaincodeHelp
      exit 0
      ;;
    * )
      echo "Unknown command or flag: $2"
      showChaincodeHelp
      exit 1
      ;;
  esac
}

set -e -o pipefail

if [[ $# -eq 0 ]] ; then
  showHelp
  exit 1
fi

checkPrereqs

OP=$1
shift # past argument
case $OP in
  enroll )
    enroll "$@"
    ;;
  channel )
    channel "$@"
    ;;
  chaincode )
    chaincode "$@"
    ;;
  -h|--help )
    showHelp
    exit 0
    ;;
  * )
    echo "Unknown command or flag: $2"
    showHelp
    exit 1
    ;;
esac
