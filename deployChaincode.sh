export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_NIDA_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com/tls/ca.crt

export PEER0_DIT_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com/tls/ca.crt

export PEER0_RITA_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com/tls/ca.crt

export PEER0_TRA_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com/tls/ca.crt

export PEER0_NHIF_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp

}

setGlobalsForPeer0Nida(){
    export CORE_PEER_LOCALMSPID="NIDAMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_NIDA_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/nida.example.com/users/Admin@nida.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer0Dit(){
    export CORE_PEER_LOCALMSPID="DITMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_DIT_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/dit.example.com/users/Admin@dit.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
}

setGlobalsForPeer0Nhif(){
    export CORE_PEER_LOCALMSPID="NHIFMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_NHIF_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/nhif.example.com/users/Admin@nhif.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
}

setGlobalsForPeer0Rita(){
    export CORE_PEER_LOCALMSPID="RITAMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RITA_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/rita.example.com/users/Admin@rita.example.com/msp
    export CORE_PEER_ADDRESS=localhost:13051
}

setGlobalsForPeer0Tra(){
    export CORE_PEER_LOCALMSPID="TRAMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_TRA_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/tra.example.com/users/Admin@tra.example.com/msp
    export CORE_PEER_ADDRESS=localhost:15051
}


presetup() {
    echo Vendoring Go dependencies ...
    pushd ./artifacts/src/github.com/identities/go
    GO111MODULE=on go mod vendor
    popd
    echo Finished vendoring Go dependencies
}
# presetup

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="5"
SEQUENCE=5
CC_SRC_PATH="./artifacts/src/github.com/identities/go"
CC_NAME="id"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0Nida
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged ===================== "
}
# packageChaincode

installChaincode() {
    setGlobalsForPeer0Nida
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on Nida.org1 ===================== "

    setGlobalsForPeer0Dit
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on Dit.org2 ===================== "

    setGlobalsForPeer0Nhif
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on Nhif.org3 ===================== "

     setGlobalsForPeer0Tra
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on Dit.org2 ===================== "

    setGlobalsForPeer0Rita
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on Nhif.org3 ===================== "
}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0Nida
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org1 on channel ===================== "
}

# queryInstalled

# --collections-config ./artifacts/private-data/collections_config.json \
#         --signature-policy "OR('Org1MSP.member','Org2MSP.member')" \

approveForNida() {
    setGlobalsForPeer0Nida
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}
    # set +x

    echo "===================== chaincode approved from Nida 1 ===================== "

}
# queryInstalled
# approveForMyOrg1

# --signature-policy "OR ('Org1MSP.member')"
# --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA
# --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles $PEER0_ORG1_CA --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $PEER0_ORG2_CA
#--channel-config-policy Channel/Application/Admins
# --signature-policy "OR ('Org1MSP.peer','Org2MSP.peer')"

checkCommitReadyness() {
    setGlobalsForPeer0Nida
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

# checkCommitReadyness

approveForDIt() {
    setGlobalsForPeer0Dit

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}

    echo "===================== chaincode approved from Dit 2 ===================== "
}

# queryInstalled
# approveForMyOrg2

checkCommitReadyness() {

    setGlobalsForPeer0Dit
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_DIT_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from dit 1 ===================== "
}

# checkCommitReadyness

approveForMyNhif() {
    setGlobalsForPeer0Nhif

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}

    echo "===================== chaincode approved from Nhif 2 ===================== "
}

# queryInstalled
# approveForMyOrg3

checkCommitReadyness() {

    setGlobalsForPeer0Nhif
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_NHIF_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from Nhif 1 ===================== "
}

approveForTra() {
    setGlobalsForPeer0Tra

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}

    echo "===================== chaincode approved from Tra 2 ===================== "
}

# queryInstalled
# approveForMyOrg3

checkCommitReadyness() {

    setGlobalsForPeer0Tra
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:15051 --tlsRootCertFiles $PEER0_TRA_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from Tra 1 ===================== "
}

approveForRita() {
    setGlobalsForPeer0Rita

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}

    echo "===================== chaincode approved from org 2 ===================== "
}

# queryInstalled
# approveForMyOrg3

checkCommitReadyness() {

    setGlobalsForPeer0Rita
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:13051 --tlsRootCertFiles $PEER0_RITA_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from  Rita 1 ===================== "
}

# checkCommitReadyness

commitChaincodeDefination() {
    setGlobalsForPeer0Nida
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_NIDA_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_DIT_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_NHIF_CA \
        --peerAddresses localhost:13051 --tlsRootCertFiles $PEER0_RITA_CA \
        --peerAddresses localhost:15051 --tlsRootCertFiles $PEER0_TRA_CA \
        --version ${VERSION} --sequence ${SEQUENCE} --init-required

}

# commitChaincodeDefination

queryCommitted() {
    setGlobalsForPeer0Nida
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

# queryCommitted

chaincodeInvokeInit() {
    setGlobalsForPeer0Nida
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_NIDA_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_DIT_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_NHIF_CA \
        --peerAddresses localhost:13051 --tlsRootCertFiles $PEER0_RITA_CA \
        --peerAddresses localhost:15051 --tlsRootCertFiles $PEER0_TRA_CA \
        --isInit -c '{"Args":[]}'

}

# chaincodeInvokeInit

chaincodeInvoke() {
    setGlobalsForPeer0Nida

    # Invoke chaincode to create identity
    peer chaincode invoke \
        -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n $CC_NAME \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_NIDA_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_DIT_CA \
         --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_NHIF_CA \
        -c '{"function": "CreateIdentity", "Args":["16699976", "559927hhhh2552", "160013830jhghvhjdksghgkjhakjhvjhvgasdhds9939", "455456kkkk65","Widambe","NIDA","2024-03-23","true"]}'

}

# chaincodeInvoke

chaincodeInvokeDeleteAsset() {
    setGlobalsForPeer0Nida

    # Create Car
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA   \
        -c '{"function": "DeleteIdentityByTransactionID","Args":["1"]}'

}

# chaincodeInvokeDeleteAsset

chaincodeQuery() {
    setGlobalsForPeer0Nida
    # setGlobalsForOrg1
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "GetIdentitiesByUserID","Args":["5522552"]}'
}

# chaincodeQuery

# Run this function if you add any new dependency in chaincode
# presetup

# packageChaincode
# installChaincode
# queryInstalled
# approveForNida
# checkCommitReadyness
# approveForDIt
# checkCommitReadyness
# approveForMyNhif
# checkCommitReadyness
# approveForTra
# checkCommitReadyness
# approveForRita
# checkCommitReadyness
# commitChaincodeDefination
# queryCommitted
chaincodeInvokeInit
sleep 5
chaincodeInvoke
sleep 3
chaincodeQuery
