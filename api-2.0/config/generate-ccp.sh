#!/bin/bash
function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG_NAME}/$1/" \
        -e "s/\${ORG}/$2/" \
        -e "s/\${P0PORT}/$3/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ./ccp-template.json
}

ORG=nida
ORG_NAME=NIDAOrg
P0PORT=7051
CAPORT=7054
ROOTCA=../../artifacts/channel/crypto-config/peerOrganizations/nida.example.com/ca/ca.nida.example.com-cert.pem
PEERPEM=../../artifacts/channel/crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com/tls/tlscacerts/tls-localhost-7054-ca-nida-example-com.pem
CAPEM=../../artifacts/channel/crypto-config/peerOrganizations/nida.example.com/msp/tlscacerts/ca.crt

echo "$(json_ccp $ORG $ORG_NAME $P0PORT $CAPORT $PEERPEM $CAPEM)" > connection-nida.json

ORG=dit
ORG_NAME=DITOrg
P0PORT=9051
CAPORT=10054
PEERPEM=../../artifacts/channel/crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com/tls/tlscacerts/tls-localhost-10054-ca-dit-example-com.pem
CAPEM=../../artifacts/channel/crypto-config/peerOrganizations/dit.example.com/msp/tlscacerts/ca.crt

echo "$(json_ccp $ORG $ORG_NAME $P0PORT $CAPORT $PEERPEM $CAPEM)" > connection-dit.json

ORG=nhif
ORG_NAME=NHIFOrg
P0PORT=11051
CAPORT=10154
PEERPEM=../../artifacts/channel/crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com/tls/tlscacerts/tls-localhost-10154-ca-nhif-example-com.pem
CAPEM=../../artifacts/channel/crypto-config/peerOrganizations/nhif.example.com/msp/tlscacerts/ca.crt

echo "$(json_ccp $ORG $ORG_NAME $P0PORT $CAPORT $PEERPEM $CAPEM)" > connection-nhif.json

ORG=rita
ORG_NAME=RITAOrg
P0PORT=13051
CAPORT=8054
PEERPEM=../../artifacts/channel/crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com/tls/tlscacerts/tls-localhost-8054-ca-rita-example-com.pem
CAPEM=../../artifacts/channel/crypto-config/peerOrganizations/rita.example.com/msp/tlscacerts/ca.crt

echo "$(json_ccp $ORG $ORG_NAME $P0PORT $CAPORT $PEERPEM $CAPEM)" > connection-rita.json

ORG=tra
ORG_NAME=TRAOrg
P0PORT=15051
CAPORT=10254
PEERPEM=../../artifacts/channel/crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com/tls/tlscacerts/tls-localhost-10254-ca-tra-example-com.pem
CAPEM=../../artifacts/channel/crypto-config/peerOrganizations/tra.example.com/msp/tlscacerts/ca.crt

echo "$(json_ccp $ORG $ORG_NAME $P0PORT $CAPORT $PEERPEM $CAPEM)" > connection-tra.json
