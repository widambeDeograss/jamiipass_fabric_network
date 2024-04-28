createcertificatesFornida() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/peerOrganizations/nida.example.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/nida.example.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca.nida.example.com --tls.certfiles ${PWD}/fabric-ca/nida/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-nida-example-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-nida-example-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-nida-example-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-nida-example-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/nida.example.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
  fabric-ca-client register --caname ca.nida.example.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/nida/tls-cert.pem

  echo
  echo "Register user"
  echo
  fabric-ca-client register --caname ca.nida.example.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/nida/tls-cert.pem

  echo
  echo "Register the org admin"
  echo
  fabric-ca-client register --caname ca.nida.example.com --id.name nidaadmin --id.secret nidaadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/nida/tls-cert.pem

  mkdir -p ../crypto-config/peerOrganizations/nida.example.com/peers

  # -----------------------------------------------------------------------------------
  #  Peer 0
  mkdir -p ../crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com

  echo
  echo "## Generate the peer0 msp"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.nida.example.com -M ${PWD}/../crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com/msp --csr.hosts peer0.nida.example.com --tls.certfiles ${PWD}/fabric-ca/nida/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/nida.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.nida.example.com -M ${PWD}/../crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com/tls --enrollment.profile tls --csr.hosts peer0.nida.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/nida/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/nida.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/nida.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/nida.example.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/nida.example.com/tlsca/tlsca.nida.example.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/nida.example.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/nida.example.com/peers/peer0.nida.example.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/nida.example.com/ca/ca.nida.example.com-cert.pem

  # --------------------------------------------------------------------------------------------------

  mkdir -p ../crypto-config/peerOrganizations/nida.example.com/users
  mkdir -p ../crypto-config/peerOrganizations/nida.example.com/users/User1@nida.example.com

  echo
  echo "## Generate the user msp"
  echo
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca.nida.example.com -M ${PWD}/../crypto-config/peerOrganizations/nida.example.com/users/User1@nida.example.com/msp --tls.certfiles ${PWD}/fabric-ca/nida/tls-cert.pem

  mkdir -p ../crypto-config/peerOrganizations/nida.example.com/users/Admin@nida.example.com

  echo
  echo "## Generate the org admin msp"
  echo
  fabric-ca-client enroll -u https://nidaadmin:nidaadminpw@localhost:7054 --caname ca.nida.example.com -M ${PWD}/../crypto-config/peerOrganizations/nida.example.com/users/Admin@nida.example.com/msp --tls.certfiles ${PWD}/fabric-ca/nida/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/nida.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/nida.example.com/users/Admin@nida.example.com/msp/config.yaml

}

# createcertificatesFornida

createCertificatesForrita() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p /../crypto-config/peerOrganizations/rita.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/rita.example.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca.rita.example.com --tls.certfiles ${PWD}/fabric-ca/rita/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-rita-example-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-rita-example-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-rita-example-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-rita-example-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/rita.example.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.rita.example.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/rita/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.rita.example.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/rita/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.rita.example.com --id.name ritaadmin --id.secret ritaadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/rita/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/rita.example.com/peers
  mkdir -p ../crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.rita.example.com -M ${PWD}/../crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com/msp --csr.hosts peer0.rita.example.com --tls.certfiles ${PWD}/fabric-ca/rita/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/rita.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.rita.example.com -M ${PWD}/../crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com/tls --enrollment.profile tls --csr.hosts peer0.rita.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/rita/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/rita.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/rita.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/rita.example.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/rita.example.com/tlsca/tlsca.rita.example.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/rita.example.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/rita.example.com/peers/peer0.rita.example.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/rita.example.com/ca/ca.rita.example.com-cert.pem

  # --------------------------------------------------------------------------------
 
  mkdir -p ../crypto-config/peerOrganizations/rita.example.com/users
  mkdir -p ../crypto-config/peerOrganizations/rita.example.com/users/User1@rita.example.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca.rita.example.com -M ${PWD}/../crypto-config/peerOrganizations/rita.example.com/users/User1@rita.example.com/msp --tls.certfiles ${PWD}/fabric-ca/rita/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/rita.example.com/users/Admin@rita.example.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://ritaadmin:ritaadminpw@localhost:8054 --caname ca.rita.example.com -M ${PWD}/../crypto-config/peerOrganizations/rita.example.com/users/Admin@rita.example.com/msp --tls.certfiles ${PWD}/fabric-ca/rita/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/rita.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/rita.example.com/users/Admin@rita.example.com/msp/config.yaml

}

# createCertificateForrita

createCertificatesFordit() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/peerOrganizations/dit.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/dit.example.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca.dit.example.com --tls.certfiles ${PWD}/fabric-ca/dit/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-dit-example-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-dit-example-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-dit-example-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-dit-example-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/dit.example.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.dit.example.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/dit/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.dit.example.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/dit/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.dit.example.com --id.name ditadmin --id.secret ditadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/dit/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/dit.example.com/peers
  mkdir -p ../crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca.dit.example.com -M ${PWD}/../crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com/msp --csr.hosts peer0.dit.example.com --tls.certfiles ${PWD}/fabric-ca/dit/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/dit.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca.dit.example.com -M ${PWD}/../crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com/tls --enrollment.profile tls --csr.hosts peer0.dit.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/dit/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/dit.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/dit.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/dit.example.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/dit.example.com/tlsca/tlsca.dit.example.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/dit.example.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/dit.example.com/peers/peer0.dit.example.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/dit.example.com/ca/ca.dit.example.com-cert.pem

  # --------------------------------------------------------------------------------

  mkdir -p ../crypto-config/peerOrganizations/dit.example.com/users
  mkdir -p ../crypto-config/peerOrganizations/dit.example.com/users/User1@dit.example.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:10054 --caname ca.dit.example.com -M ${PWD}/../crypto-config/peerOrganizations/dit.example.com/users/User1@dit.example.com/msp --tls.certfiles ${PWD}/fabric-ca/dit/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/dit.example.com/users/Admin@dit.example.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://ditadmin:ditadminpw@localhost:10054 --caname ca.dit.example.com -M ${PWD}/../crypto-config/peerOrganizations/dit.example.com/users/Admin@dit.example.com/msp --tls.certfiles ${PWD}/fabric-ca/dit/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/dit.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/dit.example.com/users/Admin@dit.example.com/msp/config.yaml

}

createCertificatesFornhif() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/peerOrganizations/nhif.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/nhif.example.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10154 --caname ca.nhif.example.com --tls.certfiles ${PWD}/fabric-ca/nhif/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10154-ca-nhif-example-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10154-ca-nhif-example-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10154-ca-nhif-example-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10154-ca-nhif-example-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/nhif.example.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.nhif.example.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/nhif/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.nhif.example.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/nhif/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.nhif.example.com --id.name nhifadmin --id.secret nhifadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/nhif/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/nhif.example.com/peers
  mkdir -p ../crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10154 --caname ca.nhif.example.com -M ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com/msp --csr.hosts peer0.nhif.example.com --tls.certfiles ${PWD}/fabric-ca/nhif/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10154 --caname ca.nhif.example.com -M ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com/tls --enrollment.profile tls --csr.hosts peer0.nhif.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/nhif/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/tlsca/tlsca.nhif.example.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/peers/peer0.nhif.example.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/ca/ca.nhif.example.com-cert.pem

  # --------------------------------------------------------------------------------

  mkdir -p ../crypto-config/peerOrganizations/nhif.example.com/users
  mkdir -p ../crypto-config/peerOrganizations/nhif.example.com/users/User1@nhif.example.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:10154 --caname ca.nhif.example.com -M ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/users/User1@nhif.example.com/msp --tls.certfiles ${PWD}/fabric-ca/nhif/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/nhif.example.com/users/Admin@nhif.example.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://nhifadmin:nhifadminpw@localhost:10154 --caname ca.nhif.example.com -M ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/users/Admin@nhif.example.com/msp --tls.certfiles ${PWD}/fabric-ca/nhif/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/nhif.example.com/users/Admin@nhif.example.com/msp/config.yaml

}

createCertificatesFortra() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/peerOrganizations/tra.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/tra.example.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10254 --caname ca.tra.example.com --tls.certfiles ${PWD}/fabric-ca/tra/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10254-ca-tra-example-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10254-ca-tra-example-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10254-ca-tra-example-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10254-ca-tra-example-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/tra.example.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.tra.example.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/tra/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.tra.example.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/tra/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.tra.example.com --id.name traadmin --id.secret traadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/tra/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/tra.example.com/peers
  mkdir -p ../crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10254 --caname ca.tra.example.com -M ${PWD}/../crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com/msp --csr.hosts peer0.tra.example.com --tls.certfiles ${PWD}/fabric-ca/tra/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/tra.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10254 --caname ca.tra.example.com -M ${PWD}/../crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com/tls --enrollment.profile tls --csr.hosts peer0.tra.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/tra/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/tra.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/tra.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/tra.example.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/tra.example.com/tlsca/tlsca.tra.example.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/tra.example.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/tra.example.com/peers/peer0.tra.example.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/tra.example.com/ca/ca.tra.example.com-cert.pem

  # --------------------------------------------------------------------------------

  mkdir -p ../crypto-config/peerOrganizations/tra.example.com/users
  mkdir -p ../crypto-config/peerOrganizations/tra.example.com/users/User1@tra.example.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:10254 --caname ca.tra.example.com -M ${PWD}/../crypto-config/peerOrganizations/tra.example.com/users/User1@tra.example.com/msp --tls.certfiles ${PWD}/fabric-ca/tra/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/tra.example.com/users/Admin@tra.example.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://traadmin:traadminpw@localhost:10254 --caname ca.tra.example.com -M ${PWD}/../crypto-config/peerOrganizations/tra.example.com/users/Admin@tra.example.com/msp --tls.certfiles ${PWD}/fabric-ca/tra/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/tra.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/tra.example.com/users/Admin@tra.example.com/msp/config.yaml

}

createCretificatesForOrderer() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/ordererOrganizations/example.com

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/ordererOrganizations/example.com/msp/config.yaml

  echo
  echo "Register orderer"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  # echo
  # echo "Register orderer2"
  # echo
   
  # fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  # echo
  # echo "Register orderer3"
  # echo
   
  # fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register the orderer admin"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  mkdir -p ../crypto-config/ordererOrganizations/example.com/orderers
  # mkdir -p ../crypto-config/ordererOrganizations/example.com/orderers/example.com

  # ---------------------------------------------------------------------------
  #  Orderer

  mkdir -p ../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # -----------------------------------------------------------------------
  #  Orderer 2

  # mkdir -p ../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com

  # echo
  # echo "## Generate the orderer msp"
  # echo
   
  # fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp --csr.hosts orderer2.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/config.yaml

  # echo
  # echo "## Generate the orderer-tls certificates"
  # echo
   
  # fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls --enrollment.profile tls --csr.hosts orderer2.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/ca.crt
  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/signcerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.crt
  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/keystore/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.key

  # mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/tlscacerts
  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # ---------------------------------------------------------------------------
  #  Orderer 3
  # mkdir -p ../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com

  # echo
  # echo "## Generate the orderer msp"
  # echo
   
  # fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp --csr.hosts orderer3.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/config.yaml

  # echo
  # echo "## Generate the orderer-tls certificates"
  # echo
   
  # fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls --enrollment.profile tls --csr.hosts orderer3.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/ca.crt
  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/signcerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.crt
  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/keystore/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.key

  # mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/tlscacerts
  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # ---------------------------------------------------------------------------

  mkdir -p ../crypto-config/ordererOrganizations/example.com/users
  mkdir -p ../crypto-config/ordererOrganizations/example.com/users/Admin@example.com

  echo
  echo "## Generate the admin msp"
  echo
   
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml

}

# createCretificateForOrderer

sudo rm -rf ../crypto-config/*
# sudo rm -rf fabric-ca/*
createcertificatesFornida
createCertificatesForrita
createCertificatesFordit
createCertificatesFornhif
createCertificatesFortra

createCretificatesForOrderer

