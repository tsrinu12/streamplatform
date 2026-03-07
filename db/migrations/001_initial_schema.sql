-- Migration 001: Initial Schema
-- Description: Core tables for users, sessions, OTP
-- Environment: ALL

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pgtrgm";

-- USERS TABLE
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username VARCHAR(50) UNIQUE,
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(15) UNIQUE,
  password_hash TEXT,
  display_name VARCHAR(100),
  avatar_url TEXT,
  cover_url TEXT,
  bio TEXT DEFAULT '',
  role VARCHAR(20) NOT NULL DEFAULT 'viewer' CHECK (role IN ('viewer','creator','admin','moderator')),
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  is_banned BOOLEAN DEFAULT FALSE,
  ban_reason TEXT,
  
  -- Rewards
  reward_points BIGINT DEFAULT 0 CHECK (reward_points >= 0),
  lifetime_points BIGINT DEFAULT 0,
  level INT DEFAULT 1 CHECK (level >= 1),
  streak_days INT DEFAULT 0,
  last_active_date DATE,
  
  -- Auth
  google_id VARCHAR(255) UNIQUE,
  auth_provider VARCHAR(20) DEFAULT 'local' CHECK (auth_provider IN ('local','google','phone')),
  
  -- Preferences
  language_pref VARCHAR(5) DEFAULT 'en',
  region VARCHAR(50) DEFAULT 'IN',
  timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',
  dark_mode BOOLEAN DEFAULT FALSE,
  email_notifications BOOLEAN DEFAULT TRUE,
  push_notifications BOOLEAN DEFAULT TRUE,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- SESSIONS TABLE
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  refresh_token TEXT NOT NULL UNIQUE,
  device_info JSONB DEFAULT '{}',
  ip_address INET,
  user_agent TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  last_used_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- OTP TABLE
CREATE TABLE otp_codes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  identifier VARCHAR(255) NOT NULL,
  code VARCHAR(6) NOT NULL,
  purpose VARCHAR(20) NOT NULL DEFAULT 'login' CHECK (purpose IN ('login','signup','reset','verify','2fa')),
  channel VARCHAR(10) DEFAULT 'sms' CHECK (channel IN ('sms','email','whatsapp')),
  attempts INT DEFAULT 0,
  max_attempts INT DEFAULT 3,
  is_used BOOLEAN DEFAULT FALSE,
  metadata JSONB DEFAULT '{}',
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- SUBSCRIPTIONS TABLE
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  subscriber_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  creator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  notify BOOLEAN DEFAULT TRUE,
  notify_live BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_subscription UNIQUE (subscriber_id, creator_id),
  CONSTRAINT no_self_subscribe CHECK (subscriber_id != creator_id)
);

-- TRIGGER FOR updated_at
CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION trigger_set_updated_at();
