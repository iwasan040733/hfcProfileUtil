#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/g" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${P1PORT}/$3/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s#\${ADMIN_PRIVATE_KEY}#$7#" \
        ccp-template.json 
}

function yaml_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/g" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${P1PORT}/$3/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s#\${ADMIN_PRIVATE_KEY}#$7#" \
        ccp-template.yaml | sed -e $'s/\\\\n/\\\n        /g'
}
function organizations_template {
    sed -e "s/\${ORG}/$1/g" \
        -e "s#\${ADMIN_PRIVATE_KEY}#$2#" \
        organizations-template.yaml | sed -e $'s/\\\\n/\\\n        /g'
}
function peers_template {
    local PP=$(one_line_pem $4)
    sed -e "s/\${ORG}/$1/g" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${P1PORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        peers-template.yaml | sed -e $'s/\\\\n/\\\n        /g'
}
function certificate_template {
    local CP=$(one_line_pem $3)    
    sed -e "s/\${ORG}/$1/g" \
        -e "s/\${CAPORT}/$2/" \
        -e "s#\${CAPEM}#$CP#" \
        certificate-template.yaml | sed -e $'s/\\\\n/\\\n        /g'
}
function yaml_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/g" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${P1PORT}/$3/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s#\${ADMIN_PRIVATE_KEY}#$ADMIN_PRIVATE_KEY#" \
        ccp-template.yaml | sed -e $'s/\\\\n/\\\n        /g'
}
ADMIN_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore && ls *_sk)
ORG=1
P0PORT=7051
P1PORT=8051
CAPORT=7054
PEERPEM=crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem
CAPEM=crypto-config/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem
echo "$(json_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM $ADMIN_PRIVATE_KEY)" > connection-org1.json
echo "$(yaml_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM $ADMIN_PRIVATE_KEY)" > connection-org1.yaml

ORGANIZATIONS=`organizations_template $ORG $ADMIN_PRIVATE_KEY`
PEERS=`peers_template $ORG $P0PORT $P1PORT $PEERPEM`
CERTIFICATE_AUTH=`certificate_template $ORG $CAPORT $PEERPEM`

ADMIN_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore && ls *_sk)
ORG=2
P0PORT=9051
P1PORT=10051
CAPORT=8054
PEERPEM=crypto-config/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem
CAPEM=crypto-config/peerOrganizations/org2.example.com/ca/ca.org2.example.com-cert.pem
echo "$(json_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM $ADMIN_PRIVATE_KEY)" > connection-org2.json
echo "$(yaml_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM $ADMIN_PRIVATE_KEY)" > connection-org2.yaml

ORGANIZATIONS+=`organizations_template $ORG $ADMIN_PRIVATE_KEY`
PEERS+=`peers_template $ORG $P0PORT $P1PORT $PEERPEM`
CERTIFICATE_AUTH+=`certificate_template $ORG $CAPORT $PEERPEM`

source=`cat ccp-template-allorg.yaml`
#文字列化
PARTS1="${ORGANIZATIONS}"
PARTS2="${PEERS}"
PARTS3="${CERTIFICATE_AUTH}"

res="${source/\$\{ORGANIZATIONS\}/$PARTS1}"
res="${res/\$\{PEERS\}/$PARTS2}"
echo "${res/\$\{CERTIFICATE_AUTH\}/$PARTS3}" > connection-org-all.yaml
