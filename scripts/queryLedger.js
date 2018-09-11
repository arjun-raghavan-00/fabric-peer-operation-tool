'use strict';

var Fabric_Client = require('fabric-client');
var path = require('path');
var util = require('util');
var os = require('os');
var fs = require('fs');
var x509 = require('x509');

var fabricClient = new Fabric_Client();

var ccName = process.argv[2];
var ccFcn = process.argv[3];
var ccArgs = process.argv[4];
var userName = process.argv[5];
var peerUrl = process.argv[6];
var peerPort = process.argv[7];
var channelName = process.argv[8];
var orgName = process.argv[9];
var ordererNum = process.argv[10];
var isRemote = process.argv[11];
var peerName = process.argv[12];
var caCertFile = process.argv[13];
var cprofDir = process.argv[14];
var srvCertFile = process.argv[15];

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

Fabric_Client.newDefaultKeyValueStore({ path: storePath
}).then((stateStore) => {
	fabricClient.setStateStore(stateStore);
	var cryptoSuite = Fabric_Client.newCryptoSuite();
	var cryptoStore = Fabric_Client.newCryptoKeyStore({path: storePath});
	cryptoSuite.setCryptoKeyStore(cryptoStore);
	fabricClient.setCryptoSuite(cryptoSuite);

  if (isRemote == 1) {
    return fabricClient.getUserContext(userName, true);
  } else {
    return fabricClient.getUserContext(adminCa.registrar[0].enrollId, true);
  }
}).then((userFromStore) => {
	if (userFromStore && userFromStore.isEnrolled()) {
		console.log('Successfully loaded ' + userName + ' from persistence');
		memberUser = userFromStore;
	} else {
		throw new Error('Failed to get ' + userName + '. Are you sure you\'ve enrolled it?');
	}

  var query = {
    chaincodeId: ccName,
    fcn: ccFcn,
    args: JSON.parse(ccArgs)
  }

  return channel.queryByChaincode(query);
}).then((results) => {
	console.log("Query has completed, checking results");
	if (results && results.length == 1) {
		if (results[0] instanceof Error) {
			console.error("error from query = ", results[0]);
		} else {
      var response = JSON.parse(results[0].toString());
			console.log("Response: ");
      console.log(util.inspect(response, {colors: true, depth: null, maxArrayLength: null, breakLength: 100}));
		}
	} else {
		console.log("No payloads were returned from query");
	}
}).catch((err) => {
	console.error('Failed to invoke successfully :: ' + err);
});
