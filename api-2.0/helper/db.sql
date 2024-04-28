
CREATE DATABASE jamii_pass_db;
CREATE EXTENSION IF NOT EXISTs "uuid-ossp";

CREATE TABLE users(
   user_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
   first_name VARCHAR(100) NOT NULL,
   middle_name VARCHAR(100),
   last_name VARCHAR(100) NOT NULL,
   nida_no VARCHAR(250) NOT NULL UNIQUE,
   email VARCHAR(250) NOT NULL UNIQUE,
   phone VARCHAR(20) NOT NULL UNIQUE,
   email_verified BOOLEAN,
   dob  DATE,
   password VARCHAR(250) NOT NULL,
   profile text,
   gender VARCHAR(25) NOT NULL,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   role INT
);

CREATE TABLE user_otps(
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    otp BIGINT NOT NULL,
    CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(user_id)
);

CREATE TABLE user_notifications(
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    notification TEXT,
    CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(user_id)
);

CREATE TABLE issuing_organizations(
    org_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_name TEXT UNIQUE NOT NULL,
    email VARCHAR(250) NOT NULL UNIQUE,
    password TEXT NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email_verified BOOLEAN,
    pic TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE organization_notification(
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id uuid NOT NULL,
    notification TEXT,
    CONSTRAINT fk_org FOREIGN KEY(org_id) REFERENCES issuing_organizations(org_id)

);

CREATE TABLE org_otps(
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id uuid NOT NULL,
    otp BIGINT NOT NULL,
    CONSTRAINT fk_org FOREIGN KEY(org_id) REFERENCES issuing_organizations(org_id)

);



CREATE TABLE corporates(
    corp_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    corp_name TEXT NOT NULL UNIQUE,
    email VARCHAR(250) NOT NULL UNIQUE,
    password VARCHAR(250) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email_verified BOOLEAN,
    pic TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE corp_otps(
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    corp_id uuid NOT NULL,
    otp BIGINT NOT NULL,
    CONSTRAINT fk_corp FOREIGN KEY(corp_id) REFERENCES corporates(corp_id)

);

CREATE TABLE corporate_notification(
     id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    corp_id uuid NOT NULL,
    notification TEXT,
    CONSTRAINT fk_corp FOREIGN KEY(corp_id) REFERENCES corporates(corp_id)

);

CREATE TABLE identifications(
    cert_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    cert_name VARCHAR(250) NOT NULL UNIQUE,
    org_id uuid NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_org FOREIGN KEY(org_id) REFERENCES issuing_organizations(org_id),
    
);

CREATE TABLE identification_requests(
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid,
    org_id uuid,
    card_no VARCHAR(250) NOT NULL,
    cert_id uuid NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    request_state VARCHAR(250) NOT NULL,
    CONSTRAINT fk_org FOREIGN KEY(org_id) REFERENCES issuing_organizations(org_id),
    CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(user_id),
    CONSTRAINT fk_cert FOREIGN KEY(cert_id) REFERENCES identifications(cert_id)
);


CREATE TABLE identification_share_history(
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    corp_id uuid,
    user_share uuid,
    shared_hash TEXT NOT NULL,
    cards TEXT NOT NULL,
    time_before_corrupt DATE,
    active BOOLEAN DEFAULT true,
    CONSTRAINT fk_corp FOREIGN KEY(corp_id) REFERENCES corporates(corp_id),
    CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(user_id),
    CONSTRAINT fk_usr_share FOREIGN KEY(user_share) REFERENCES users(user_id)

);

