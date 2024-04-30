package main

import (
	"encoding/json"
	"fmt"
	"time"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"

)

// Identity represents the structure of an identity.
type Identity struct {
	TransactionId string   `json:"transactionId"`
    UserID       string    `json:"userID"`
    DocumentHash string    `json:"documentHash"`
    DocumentNo   string    `json:"documentNo"`
    HolderName   string    `json:"holderName"`
    ExpiryDate   time.Time `json:"expiryDate"`
    Organization string    `json:"organization"`
	Active        bool      `json:"active"`
}

// SmartContract provides functions for managing identities.
type SmartContract struct {
    contractapi.Contract
}

// CreateIdentity creates a new identity.
func (s *SmartContract) CreateIdentity(ctx contractapi.TransactionContextInterface, transactionId, userID, documentHash, documentNo, holderName, organization string, expiryDateStr string, active bool) error {
    // Parse expiry date
    expiryDate, err := time.Parse("2006-01-02", expiryDateStr)
    if err != nil {
        return fmt.Errorf("failed to parse expiry date: %s", err)
    }

    identity := Identity{
		TransactionId: transactionId,
        UserID:       userID,
        DocumentHash: documentHash,
        DocumentNo:   documentNo,
        HolderName:   holderName,
        ExpiryDate:   expiryDate,
        Organization: organization,
		Active: active,
    }

    identityJSON, err := json.Marshal(identity)
    if err != nil {
        return fmt.Errorf("failed to marshal identity: %s", err)
    }

    err = ctx.GetStub().PutState(transactionId, identityJSON)
    if err != nil {
        return fmt.Errorf("failed to put state: %s", err)
    }

    return nil
}

// GetIdentitiesByOrganization returns all identities for a given organization.
func (s *SmartContract) GetIdentitiesByOrganization(ctx contractapi.TransactionContextInterface, organization string) ([]*Identity, error) {
    query := fmt.Sprintf(`{
        "selector": {
            "organization": "%s"
        }
    }`, organization)

    return s.queryIdentities(ctx, query)
}

// GetIdentitiesByUserID returns the identities for a given user ID.
func (s *SmartContract) GetIdentitiesByUserID(ctx contractapi.TransactionContextInterface, userID string) ([]*Identity, error) {
    // Construct a query selector to match user ID
    query := fmt.Sprintf(`{
        "selector": {
            "userID": "%s"
        }
    }`, userID)

    // Execute the query to retrieve the matching identities
    return s.queryIdentities(ctx, query)
}


// queryIdentities executes the provided query and returns the resulting identities.
func (s *SmartContract) queryIdentities(ctx contractapi.TransactionContextInterface, query string) ([]*Identity, error) {
    resultsIterator, err := ctx.GetStub().GetQueryResult(query)
    if err != nil {
        return nil, fmt.Errorf("failed to get query result: %s", err)
    }
    defer resultsIterator.Close()

    var identities []*Identity
    for resultsIterator.HasNext() {
        queryResponse, err := resultsIterator.Next()
        if err != nil {
            return nil, fmt.Errorf("failed to get next query response: %s", err)
        }

        var identity Identity
        err = json.Unmarshal(queryResponse.Value, &identity)
        if err != nil {
            return nil, fmt.Errorf("failed to unmarshal query response: %s", err)
        }

        identities = append(identities, &identity)
    }

    return identities, nil
}

// GetIdentityByTransactionID returns the identity for a given transaction ID.
func (s *SmartContract) GetIdentityByTransactionID(ctx contractapi.TransactionContextInterface, txID string) (*Identity, error) {
    query := fmt.Sprintf(`{
        "selector": {
            "transactionId": "%s"
        }
    }`, txID)

    identities, err := s.queryIdentities(ctx, query)
    if err != nil {
        return nil, err
    }

    if len(identities) == 0 {
        return nil, fmt.Errorf("no identity found for transaction ID %s", txID)
    }

    // We assume there's only one identity per transaction ID
    return identities[0], nil
}

// GetIdentitiesByTransactionIDs returns the identities for given transaction IDs.
func (s *SmartContract) GetIdentitiesByTransactionIDs(ctx contractapi.TransactionContextInterface, txIDs []string) ([]*Identity, error) {
    // Construct a query selector to match transaction IDs
    query := fmt.Sprintf(`{
        "selector": {
            "transactionId": {
                "$in": %s
            }
        }
    }`, toJSON(txIDs))

    // Execute the query to retrieve the matching identities
    return s.queryIdentities(ctx, query)
}

// GetIdentitiesByTransactionIDs returns the identities for given transaction IDs.
func (s *SmartContract) GetIdentitiesByTransactionIDs(ctx contractapi.TransactionContextInterface, txIDs []string) ([]*Identity, error) {
    // Construct a query selector to match transaction IDs
    query := fmt.Sprintf(`{
        "selector": {
            "transactionId": {
                "$in": %s
            }
        }
    }`, toJSON(txIDs))

    // Execute the query to retrieve the matching identities
    return s.queryIdentities(ctx, query)
}

// toJSON converts a slice of strings to a JSON array string.
func toJSON(values []string) string {
    jsonArray, err := json.Marshal(values)
    if err != nil {
        // Handle error, e.g., log it or return an empty array
        return "[]"
    }
    return string(jsonArray)
}

// UpdateIdentityByTransactionID updates an existing identity with a given transaction ID.
func (s *SmartContract) UpdateIdentityByTransactionID(ctx contractapi.TransactionContextInterface, txID string, updatedIdentity *Identity) error {
    // Retrieve the existing identity by transaction ID
    existingIdentity, err := s.GetIdentityByTransactionID(ctx, txID)
    if err != nil {
        return err
    }

    // Update the existing identity with the new values
    existingIdentity.UserID = updatedIdentity.UserID
    existingIdentity.DocumentHash = updatedIdentity.DocumentHash
    existingIdentity.DocumentNo = updatedIdentity.DocumentNo
    existingIdentity.HolderName = updatedIdentity.HolderName
    existingIdentity.ExpiryDate = updatedIdentity.ExpiryDate
    existingIdentity.Organization = updatedIdentity.Organization
	existingIdentity.Active = updatedIdentity.Active

    // Marshal the updated identity to JSON
    updatedIdentityJSON, err := json.Marshal(existingIdentity)
    if err != nil {
        return fmt.Errorf("failed to marshal updated identity: %s", err)
    }

    // Update the state with the updated identity
    err = ctx.GetStub().PutState(txID, updatedIdentityJSON)
    if err != nil {
        return fmt.Errorf("failed to update state: %s", err)
    }

    return nil
}

// DeleteIdentityByTransactionID deletes an identity with a given transaction ID.
func (s *SmartContract) DeleteIdentityByTransactionID(ctx contractapi.TransactionContextInterface, txID string) error {
    // Check if the identity exists
	identity, err := s.GetIdentityByTransactionID(ctx, txID)
    if err != nil {
        return err
    }

    // Delete the identity from the state
    err = ctx.GetStub().DelState(txID)
	errMsg := fmt.Sprintf("Error: %s. Identity: %+v", err, identity)
    if err != nil {
        return fmt.Errorf("failed to delete state: %s", errMsg)
    }

    // Log deletion of identity
    ctx.GetStub().SetEvent("IdentityDeleted", []byte(txID))

    return nil
}

// DeactivateExpiredIdentities deactivates identities that have expired.
func (s *SmartContract) DeactivateExpiredIdentities(ctx contractapi.TransactionContextInterface) error {
    currentTime := time.Now().UTC()

    // Get all identities
    identities, err := s.queryIdentities(ctx, `{"selector": { "transactionId": { "$exists": true }}}`)
    if err != nil {
        return err
    }

    for _, identity := range identities {
        if identity.ExpiryDate.Before(currentTime) && identity.Active {
            identity.Active = false
            if err := s.UpdateIdentityByTransactionID(ctx, identity.TransactionId, identity); err != nil {
                return fmt.Errorf("failed to update identity: %s", err)
            }
        }
    }

    return nil
}



// Main function
func main() {
    chaincode, err := contractapi.NewChaincode(new(SmartContract))
    if err != nil {
        fmt.Printf("Error creating identity chaincode: %s", err)
        return
    }

    if err := chaincode.Start(); err != nil {
        fmt.Printf("Error starting chaincode: %s", err)
    }
}
