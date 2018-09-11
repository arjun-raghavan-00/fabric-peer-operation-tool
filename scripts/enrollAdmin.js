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

var orgName = process.argv[2];
var cprofDir = process.argv[3];

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

var store_path = path.join(__dirname, '../hfc-key-store');
console.log(' Store path:'+store_path);

// Create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
Fabric_Client.newDefaultKeyValueStore({ path: store_path
}).then((state_store) => {
    // Assign the store to the fabric client
    fabricClient.setStateStore(state_store);
    var cryptoSuite = Fabric_Client.newCryptoSuite();
    // Use the same location for the state store (where the users' certificate are kept)
    //  and the crypto store (where the users' keys are kept)
    var cryptoStore = Fabric_Client.newCryptoKeyStore({path: store_path});
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
        return null;
    } else {
        // Enroll with CA server
        return fabricCaClient.enroll({
          enrollmentID: enrollId,
          enrollmentSecret: enrollSecret
        }).then((enrollment) => {
          console.log('Successfully enrolled admin user "' + enrollId +' "');
          return fabricClient.createUser(
              {username: enrollId,
                  mspid: adminCa['x-mspid'],
                  cryptoContent: { privateKeyPEM: enrollment.key.toBytes(), signedCertPEM: enrollment.certificate }
              });
        }).then((user) => {
          adminUser = user;
          return fabricClient.setUserContext(adminUser);
        }).catch((err) => {
          console.error('Failed to enroll and persist admin. Error: ' + err.stack ? err.stack : err);
          throw new Error('Failed to enroll admin');
        });
    }
}).then(() => {
    console.log('Assigned the admin user to the fabric client ::' + adminUser.toString());
}).catch((err) => {
    console.error('Failed to enroll admin: ' + err);
});
