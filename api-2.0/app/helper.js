'use strict';

var { Gateway, Wallets, CouchDBWalletStore, X509WalletMixin } = require('fabric-network');
const path = require('path');
const FabricCAServices = require('fabric-ca-client');
const fs = require('fs');

const util = require('util');

const getCCP = async (org) => {
    let ccpPath = null;
    org == 'NIDAOrg' ? ccpPath = path.resolve(__dirname, '..', 'config', 'connection-nida.json') : null
    org == 'DITOrg' ? ccpPath = path.resolve(__dirname, '..', 'config', 'connection-dit.json') : null
    org == 'NHIFOrg' ? ccpPath = path.resolve(__dirname, '..', 'config', 'connection-nhif.json') : null
    org == 'RITAOrg' ? ccpPath = path.resolve(__dirname, '..', 'config', 'connection-rita.json') : null
    org == 'TRAOrg' ? ccpPath = path.resolve(__dirname, '..', 'config', 'connection-tra.json') : null
    const ccpJSON = fs.readFileSync(ccpPath, 'utf8')
    const ccp = JSON.parse(ccpJSON);
    return ccp
}

const getCaUrl = async (org, ccp) => {
    let caURL = null
    org == 'NIDAOrg' ? caURL = ccp.certificateAuthorities['ca.nida.example.com'].url : null
    org == 'DITOrg' ? caURL = ccp.certificateAuthorities['ca.dit.example.com'].url : null
    org == 'NHIFOrg' ? caURL = ccp.certificateAuthorities['ca.nhif.example.com'].url : null
    org == 'RITAOrg' ? caURL = ccp.certificateAuthorities['ca.rita.example.com'].url : null
    org == 'TRAOrg' ? caURL = ccp.certificateAuthorities['ca.tra.example.com'].url : null
    return caURL

}

const getWalletPath = async (org) => {
    let walletPath = null
    org == 'NIDAOrg' ? walletPath = path.join(process.cwd(), 'nida-wallet') : null
    org == 'DITOrg' ? walletPath = path.join(process.cwd(), 'dit-wallet') : null
    org == 'NHIFOrg' ? walletPath = path.join(process.cwd(), 'nhif-wallet') : null
    org == 'RITAOrg' ? walletPath = path.join(process.cwd(), 'rita-wallet') : null
    org == 'TRAOrg' ? walletPath = path.join(process.cwd(), 'tra-wallet') : null
    return walletPath
}


const getAffiliation = async (org) => {
    // Default in ca config file we have only two affiliations, if you want ti use org3 ca, you have to update config file with third affiliation
    //  Here already two Affiliation are there, using i am using "org2.department1" even for org3
    switch (org) {
        case "NIDAOrg":
            return 'NIDAOrg.department1';
        case "DITOrg":
            return 'DITOrg.department1';
        case "RITAOrg":
            return 'RITAOrg.department1';
        case "TRAOrg":
            return 'TRAOrg.department1';
        case "NHIFOrg":
            return 'NHIFOrg.department1';
        default:
            // Default affiliation if org is not recognized
            return 'NIDAOrg.department1';
    }
}

const getRegisteredUser = async (username, userOrg, isJson) => {
    let ccp = await getCCP(userOrg)

    const caURL = await getCaUrl(userOrg, ccp)
    console.log("ca url is ", caURL)
    const ca = new FabricCAServices(caURL);

    // const couchDBWalletStore = {
    //     url: 'http://admin:password@localhost:5990/', // Replace with your CouchDB URL
    //     walletPath: './couchdb_wallet',   // Replace with your desired wallet path
    //   };

    //   const wallet = await Wallets.newCouchDBWallet(couchDBWalletStore);

    const walletPath = await getWalletPath(userOrg)
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    console.log(`Wallet path: ${walletPath}`);

    const userIdentity = await wallet.get(username);
    if (userIdentity) {
        console.log(`An identity for the user ${username} already exists in the wallet`);
        var response = {
            success: true,
            message: username + ' enrolled Successfully',
        };
        return response
    }

    // Check to see if we've already enrolled the admin user.
    let adminIdentity = await wallet.get('admin');
    if (!adminIdentity) {
        console.log('An identity for the admin user "admin" does not exist in the wallet');
        await enrollAdmin(userOrg, ccp);
        adminIdentity = await wallet.get('admin');
        console.log("Admin Enrolled Successfully")
    }
    console.log("Admin Enrolled Successfully=====================================", adminIdentity)

    // build a user object for authenticating with the CA
    const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
    const adminUser = await provider.getUserContext(adminIdentity, 'admin');
    console.log("----------------adminUser-----------------------", adminUser)
    let secret;
    try {
        // Register the user, enroll the user, and import the new identity into the wallet.
        // affiliation: await getAffiliation(userOrg), 
        secret = await ca.register({ enrollmentID: username, role: 'client' }, adminUser);
        // const secret = await ca.register({ affiliation: 'org1.department1', enrollmentID: username, role: 'client', attrs: [{ name: 'role', value: 'approver', ecert: true }] }, adminUser);

        console.log(`Secret for the user with username: ${username} -------> ${secret}`)

    } catch (error) {
        return error.message
    }

    const enrollment = await ca.enroll({ enrollmentID: username, enrollmentSecret: secret });
    // const enrollment = await ca.enroll({ enrollmentID: username, enrollmentSecret: secret, attr_reqs: [{ name: 'role', optional: false }] });

    let x509Identity = {
        credentials: {
            certificate: enrollment.certificate,
            privateKey: enrollment.key.toBytes(),
        },
        mspId: userOrg == "NIDAOrg" ? "NIDAMSP" :
            userOrg == "DITOrg" ? "DITMSP" :
                userOrg == "RITAOrg" ? "RITAMSP" :
                    userOrg == "TRAOrg" ? "TRAMSP" :
                        userOrg == "NHIFOrg" ? "NHIFMSP" : "",
        type: 'X.509',
    };
    await wallet.put(username, x509Identity);

    console.log(`Successfully registered and enrolled admin user ${username} and imported it into the wallet`);

    var response = {
        success: true,
        message: username + ' enrolled Successfully',
    };
    return response
}

const isUserRegistered = async (username, userOrg) => {
    const walletPath = await getWalletPath(userOrg)
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    console.log(`Wallet path: ${walletPath}`);

    const userIdentity = await wallet.get(username);
    if (userIdentity) {
        console.log(`An identity for the user ${username} exists in the wallet`);
        return true
    }
    return false
}


const getCaInfo = async (org, ccp) => {
    let identityInfo = null
    org == 'NIDAOrg' ? identityInfo = ccp.certificateAuthorities['ca.nida.example.com'] : null
    org == 'DITOrg' ? identityInfo = ccp.certificateAuthorities['ca.dit.example.com'] : null
    org == 'NHIFOrg' ? identityInfo = ccp.certificateAuthorities['ca.nhif.example.com'] : null
    org == 'RITAOrg' ? identityInfo = ccp.certificateAuthorities['ca.rita.example.com'] : null
    org == 'TRAOrg' ? identityInfo = ccp.certificateAuthorities['ca.tra.example.com'] : null
    return identityInfo
}

const getOrgMSP = (org) => {
    let orgMSP = null
    org == "NIDAOrg" ? "NIDAMSP" : null
    org == "DITOrg" ? "DITMSP" : null
    org == "RITAOrg" ? "RITAMSP" : null
    org == "TRAOrg" ? "TRAMSP" : null
    org == "NHIFOrg" ? "NHIFMSP" : null

    return orgMSP

}

const enrollAdmin = async (org, ccp) => {
    console.log('calling enroll Admin method')
    try {
        const caInfo = await getCaInfo(org, ccp) //ccp.certificateAuthorities['ca.org1.example.com'];
        const caTLSCACerts = caInfo.tlsCACerts.pem;
        const ca = new FabricCAServices(caInfo.url, { trustedRoots: caTLSCACerts, verify: false }, caInfo.caName);


        // const couchDBWalletStore = {
        //     url: 'http://admin:password@localhost:5990/', // Replace with your CouchDB URL
        //     walletPath: './couchdb_wallet',   // Replace with your desired wallet path
        //   };

        //   const wallet = await Wallets.newCouchDBWallet(couchDBWalletStore);

        // Create a new file system based wallet for managing identities.
        const walletPath = await getWalletPath(org) //path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the admin user.
        const identity = await wallet.get('admin');
        if (identity) {
            console.log('An identity for the admin user "admin" already exists in the wallet');
            return;
        }

        // Enroll the admin user, and import the new identity into the wallet.
        const enrollment = await ca.enroll({ enrollmentID: 'admin', enrollmentSecret: 'adminpw' });
        console.log("Enrollment object is : ", enrollment)
        let x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: org == "NIDAOrg" ? "NIDAMSP" :
                org == "DITOrg" ? "DITMSP" :
                    org == "RITAOrg" ? "RITAMSP" :
                        org == "TRAOrg" ? "TRAMSP" :
                            org == "NHIFOrg" ? "NHIFMSP" : "",
            type: 'X.509',
        };

        // const identityLabel = 'admin'; // Specify the identity label
        // const identity1 = X509WalletMixin.createIdentity('Org1MSP', certificate, privateKey);

        // await wallet.put(identityLabel, identity1);

        await wallet.put('admin', x509Identity);
        console.log('Successfully enrolled admin user "admin" and imported it into the wallet');
        return
    } catch (error) {
        console.error(`Failed to enroll admin user "admin": ${error}`);
    }
}

const registerAndGerSecret = async (username, userOrg) => {
    let ccp = await getCCP(userOrg)

    const caURL = await getCaUrl(userOrg, ccp)
    const ca = new FabricCAServices(caURL);

    const walletPath = await getWalletPath(userOrg)
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    console.log(`Wallet path: ${walletPath}`);

    const userIdentity = await wallet.get(username);
    if (userIdentity) {
        console.log(`An identity for the user ${username} already exists in the wallet`);
        var response = {
            success: true,
            message: username + ' enrolled Successfully',
        };
        return response
    }

    // Check to see if we've already enrolled the admin user.
    let adminIdentity = await wallet.get('admin');
    if (!adminIdentity) {
        console.log('An identity for the admin user "admin" does not exist in the wallet');
        await enrollAdmin(userOrg, ccp);
        adminIdentity = await wallet.get('admin');
        console.log("Admin Enrolled Successfully")
    }

    // build a user object for authenticating with the CA
    const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
    const adminUser = await provider.getUserContext(adminIdentity, 'admin');
    let secret;
    try {
        // Register the user, enroll the user, and import the new identity into the wallet.
        secret = await ca.register({ affiliation: await getAffiliation(userOrg), enrollmentID: username, role: 'client' }, adminUser);
        // const secret = await ca.register({ affiliation: 'org1.department1', enrollmentID: username, role: 'client', attrs: [{ name: 'role', value: 'approver', ecert: true }] }, adminUser);
        const enrollment = await ca.enroll({
            enrollmentID: username,
            enrollmentSecret: secret
        });
        let orgMSPId = getOrgMSP(userOrg)
        const x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: orgMSPId,
            type: 'X.509',
        };
        await wallet.put(username, x509Identity);
    } catch (error) {
        return error.message
    }

    var response = {
        success: true,
        message: username + ' enrolled Successfully',
        secret: secret
    };
    return response

}

exports.getRegisteredUser = getRegisteredUser

module.exports = {
    getCCP: getCCP,
    getWalletPath: getWalletPath,
    getRegisteredUser: getRegisteredUser,
    isUserRegistered: isUserRegistered,
    registerAndGerSecret: registerAndGerSecret

}
