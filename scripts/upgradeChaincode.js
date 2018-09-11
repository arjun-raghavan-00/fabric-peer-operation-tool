'use strict';

var FabricClient = require('fabric-client');
var path = require('path');
var util = require('util');
var os = require('os');
var fs = require('fs');
var x509 = require('x509');

var fabricClient = new FabricClient();

var ccName = process.argv[2];
var ccVersion = process.argv[3];
var peerUrl = process.argv[4];
var peerPort = process.argv[5];
var peerEvHubPort = process.argv[6];
var channelName = process.argv[7];
var orgName = process.argv[8];
var ordererNum = process.argv[9];
var isRemote = process.argv[10];
var peerName = process.argv[11];
var caCertFile = process.argv[12];
var cprofDir = process.argv[13];
var srvCertFile = process.argv[14];

if (!ordererNum || ordererNum == -1) {
  ordererNum = 0;
}
if (!orgName || orgName == '?') {
  orgName = 'PeerOrg1';
}
if (!cprofDir || cprofDir == '?') {
  // User is expected to be in same working directory as script
  cprofDir = './config/';
}
if (!caCertFile || caCertFile == '?') {
  caCertFile = './certs/cacert.pem';
}
if (!srvCertFile || srvCertFile == '?') {
  srvCertFile = './certs/srvcert.pem';
}

var resolvedCprofDir;
if (cprofDir[0] === '/') resolvedCprofDir = cprofDir;
else if (cprofDir.substring(0,1) === '~/') resolvedCprofDir = path.resolve(cprofDir.substring(2));
else resolvedCprofDir = path.join(process.cwd(), cprofDir);

console.log(`Looking in ${cprofDir} for connection profile JSON files...`);
var credsFiles = fs.readdirSync(resolvedCprofDir).filter(filename => {
  var cprof = require(path.join(resolvedCprofDir, filename));
  if (cprof.client != null && cprof.client.organization == orgName) return filename;
});

// If empty, throw an error
if (credsFiles.length == 0) throw new Error(`Could not find any connection profiles with organization ${orgName} in directory ${cprofDir}.`);
// Should only be one such connection profile, but if there are multiple just use the first one
var creds = require(path.join(resolvedCprofDir, credsFiles[0]));

var peer;

if (isRemote == 1) {
  // All of this is required only if using remote peers
  var resolvedCaCertFile;
  if (caCertFile[0] === '/') resolvedCaCertFile = caCertFile;
  else if (caCertFile.substring(0,1) === '~/') resolvedCaCertFile = path.resolve(caCertFile.substring(2));
  else resolvedCaCertFile = path.join(process.cwd(), caCertFile);

  var resolvedSrvCertFile;
  if (srvCertFile[0] === '/') resolvedSrvCertFile = srvCertFile;
  else if (srvCertFile.substring(0,1) === '~/') resolvedSrvCertFile = path.resolve(srvCertFile.substring(2));
  else resolvedSrvCertFile = path.join(process.cwd(), srvCertFile);

  // Make sure the cert files exist, throw a customized error otherwise
  try { fs.accessSync(resolvedCaCertFile, fs.constants.R_OK) } catch  (ex) {
    throw new Error(`No root certificate could be found at ${caCertFile}. Make sure you've downloaded it from your peer`);
  }
  try { fs.accessSync(resolvedSrvCertFile, fs.constants.R_OK) } catch (ex) {
    throw new Error(`No server certificate could be found at ${srvCertFile}. Make sure you've downloaded it from your peer`);
  }

  var caCert = fs.readFileSync(resolvedCaCertFile);

  peer = fabricClient.newPeer('grpcs://' + peerUrl + ':' + peerPort, { 
    pem: Buffer.from(caCert).toString(), 
    'ssl-target-name-override': x509.getSubject(resolvedSrvCertFile).commonName
  });
} else {
  peer = fabricClient.newPeer(creds.peers[peerName].url, {
    pem: creds.peers[peerName].tlsCACerts.pem
  });
}
var channel = fabricClient.newChannel(channelName);
channel.addPeer(peer);
var credOrderer = creds.orderers[Object.keys(creds.orderers)[ordererNum]];
var orderer = fabricClient.newOrderer(credOrderer.url, { 
  pem: credOrderer.tlsCACerts.pem,
  'ssl-target-name-override': null
});
channel.addOrderer(orderer);

var adminCa = creds.certificateAuthorities[Object.keys(creds.certificateAuthorities)[0]];

var memberUser = null;
var storePath = path.join(__dirname, '../hfc-key-store');

console.log('Store path:'+storePath);

var txId = null;

FabricClient.newDefaultKeyValueStore({ path: storePath
}).then((stateStore) => {
	fabricClient.setStateStore(stateStore);
	var cryptoSuite = FabricClient.newCryptoSuite();
	var cryptoStore = FabricClient.newCryptoKeyStore({path: storePath});
	cryptoSuite.setCryptoKeyStore(cryptoStore);
	fabricClient.setCryptoSuite(cryptoSuite);

	return fabricClient.getUserContext(adminCa.registrar[0].enrollId, true);
}).then((userFromStore) => {
	if (userFromStore && userFromStore.isEnrolled()) {
		console.log('Successfully loaded admin from persistence');
		memberUser = userFromStore;
	} else {
		throw new Error('Failed to load admin...');
	}

	txId = fabricClient.newTransactionID();
	console.log("Assigning transactionId: ", txId._transaction_id);

  var upgradeChaincodeRequest = {
    targets: [ peer ],
    chaincodeId: ccName,
    chaincodeType: 'golang',
    chaincodeVersion: ccVersion,
    txId: txId,
    args: '[""]'
  };

  console.log('Upgrading chaincode ' + ccName + ' to version ' + ccVersion + ' on channel ' + channel.getName() + '...');
  return channel.sendUpgradeProposal(upgradeChaincodeRequest);
}).then((results) => {
	var proposalResponses = results[0];
	var proposal = results[1];
	let isProposalGood = false;
	if (proposalResponses && proposalResponses[0].response &&
		proposalResponses[0].response.status === 200) {
			isProposalGood = true;
			console.log('Transaction proposal was good');
		} else {
			console.error('Transaction proposal was bad');
		}
	if (isProposalGood) {
		console.log(util.format(
			'Successfully sent Proposal and received ProposalResponse: Status - %s, message - "%s"',
			proposalResponses[0].response.status, proposalResponses[0].response.message));

		// build up the request for the orderer to have the transaction committed
		var request = {
			proposalResponses: proposalResponses,
			proposal: proposal
		};

    return channel.sendTransaction(request);
	} else {
		console.error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
		throw new Error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
	}
}).then((results) => {
  console.log("Upgrade complete!");
}).catch((err) => {
	console.error('Failed to invoke successfully :: ' + err);
});
