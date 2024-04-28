
# Delete existing artifacts
rm genesis.block mychannel.tx
rm -rf ../../channel-artifacts/*

#Generate Crypto artifactes for organizations
# cryptogen generate --config=./crypto-config.yaml --output=./crypto-config/



# System channel
SYS_CHANNEL="sys-channel"

# channel name defaults to "mychannel"
CHANNEL_NAME="mychannel"

echo $CHANNEL_NAME

# Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL  -outputBlock ./genesis.block


# Generate channel configuration block
configtxgen -profile BasicChannel -configPath . -outputCreateChannelTx ./$CHANNEL_NAME.tx -channelID $CHANNEL_NAME



echo "#######    Generating anchor peer update for NIDAMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./NIDAMSPanchors.tx -channelID $CHANNEL_NAME -asOrg NIDAMSP

echo "#######    Generating anchor peer update for DITMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./DITMSPanchors.tx -channelID $CHANNEL_NAME -asOrg DITMSP

echo "#######    Generating anchor peer update for RITAMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./RITAMSPanchors.tx -channelID $CHANNEL_NAME -asOrg RITAMSP

echo "#######    Generating anchor peer update for TRAMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./TRAMSPanchors.tx -channelID $CHANNEL_NAME -asOrg TRAMSP

echo "#######    Generating anchor peer update for NHIFMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./NHIFMSPanchors.tx -channelID $CHANNEL_NAME -asOrg NHIFMSP

