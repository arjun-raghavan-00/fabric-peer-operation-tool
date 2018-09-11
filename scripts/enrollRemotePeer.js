'use strict';
var Fabric_Client = require('fabric-client');
var Fabric_CA_Client = require('fabric-ca-client');

var fs = require('fs');
var path = require('path');
var util = require('util');
var os = require('os');

var fabricClient = new Fabric_Client();
var fabricCaClient = null;
var adminCa = null;
var enrollId = null;
var enrollSecret = null;
var adminUser = null;
var memberUser = null;
var storePath = path.join(__dirname, '../hfc-key-store');
console.log(' Store path:'+storePath);

var peerId = process.argv[2];
var peerSecret = process.argv[3];
var orgName = process.argv[4];
var cprofDir = process.argv[5];

if (!orgName || orgName == '?') {
  orgName = 'PeerOrg1';
}
if (!cprofDir || cprofDir == '?') {
  // User is expected to be in same working directory as script
  cprofDir = './config/';
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

Fabric_Client.newDefaultKeyValueStore({ path: storePath
}).then((stateStore) => {
  fabricClient.setStateStore(stateStore);
  var cryptoSuite = Fabric_Client.newCryptoSuite();
  var cryptoStore = Fabric_Client.newCryptoKeyStore({path: storePath});
  cryptoSuite.setCryptoKeyStore(cryptoStore);
  fabricClient.setCryptoSuite(cryptoSuite);
  var	tlsOptions = {
    trustedRoots: [],
    verify: false
  };
  adminCa = creds.certificateAuthorities[Object.keys(creds.certificateAuthorities)[0]];
  enrollId = adminCa.registrar[0].enrollId;
  enrollSecret = adminCa.registrar[0].enrollSecret;
  fabricCaClient = new Fabric_CA_Client('https://' + enrollId + ':' + enrollSecret + '@' + adminCa.url.replace(/(^\w+:|^)\/\//, ''), null, adminCa.caName, cryptoSuite);
  return fabricClient.getUserContext(enrollId, true);
}).then((userFromStore) => {
  if (userFromStore && userFromStore.isEnrolled()) {
    console.log('Successfully loaded admin from persistence');
    adminUser = userFromStore;
  } else {
    throw new Error('Failed to get admin. Has an admin been enrolled?');
  }
  return fabricCaClient.enroll({enrollmentID: peerId, enrollmentSecret: peerSecret});
}).then((enrollment) => {
  console.log('Successfully enrolled member user ' + peerId);
  return fabricClient.createUser({
    username: peerId,
    mspid: adminCa['x-mspid'],
    cryptoContent: { privateKeyPEM: enrollment.key.toBytes(), signedCertPEM: enrollment.certificate }
  });
}).then((user) => {
   memberUser = user;
   return fabricClient.setUserContext(memberUser);
}).then(()=>{
   console.log(peerId + ' was successfully enrolled and is ready to interact with the fabric network');
}).catch((err) => {
  console.error('Failed to enroll: ' + err);
  if(err.toString().indexOf('Authorization') > -1) {
    console.error('Authorization failures may be caused by having admin credentials from a previous CA instance.\n' +
    'Try again after deleting the contents of the store directory '+storePath);
  }
});
