export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_NIDA_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com/tls/ca.crt

export PEER0_DIT_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com/tls/ca.crt

export PEER0_RITA_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com/tls/ca.crt

export PEER0_TRA_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com/tls/ca.crt

export PEER0_NHIF_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=mychannel

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



createChannel(){
    rm -rf ./channel-artifacts/*
    setGlobalsForPeer0Nida
    
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.example.com \
    -f ./artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

removeOldCrypto(){
    rm -rf ./api-1.4/crypto/*
    rm -rf ./api-1.4/fabric-client-kv-org1/*
    rm -rf ./api-2.0/org1-wallet/*
    rm -rf ./api-2.0/org2-wallet/*
}


joinChannel(){
    setGlobalsForPeer0Nida
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    
    setGlobalsForPeer0Dit
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
 
    setGlobalsForPeer0Rita
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    

    setGlobalsForPeer0Tra
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
  
    setGlobalsForPeer0Nhif
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    

}

updateAnchorPeers(){
    setGlobalsForPeer0Nida
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0Rita
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

    setGlobalsForPeer0Nhif
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0Dit
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

    setGlobalsForPeer0Tra
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

}

removeOldCrypto

createChannel
joinChannel
updateAnchorPeers