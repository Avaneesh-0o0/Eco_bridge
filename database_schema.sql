-- =====================================================
-- FOODBRIDGE AI
-- PRODUCTION V1 DATABASE SCHEMA
-- SUPABASE POSTGRESQL
-- =====================================================

-- =====================================================
-- ENUMS
-- =====================================================

CREATE TYPE user_role AS ENUM (
'donor',
'ngo',
'volunteer',
'admin'
);

CREATE TYPE organization_type AS ENUM (
'restaurant',
'hotel',
'marriage_hall',
'cafeteria',
'ngo',
'shelter',
'community_kitchen'
);

CREATE TYPE donation_status AS ENUM (
'available',
'accepted',
'pickup_assigned',
'picked_up',
'delivered',
'expired',
'cancelled'
);

CREATE TYPE task_status AS ENUM (
'pending',
'accepted',
'in_progress',
'completed',
'cancelled'
);

-- =====================================================
-- USER PROFILES
-- =====================================================

CREATE TABLE profiles (
id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

full_name TEXT NOT NULL,
email TEXT UNIQUE NOT NULL,
phone TEXT,

role user_role NOT NULL,

avatar_url TEXT,

is_verified BOOLEAN DEFAULT FALSE,
is_active BOOLEAN DEFAULT TRUE,

created_at TIMESTAMP DEFAULT NOW(),
updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- ORGANIZATIONS
-- =====================================================

CREATE TABLE organizations (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

organization_name TEXT NOT NULL,

organization_type organization_type NOT NULL,

description TEXT,

email TEXT,
phone TEXT,

address TEXT,

latitude DOUBLE PRECISION,
longitude DOUBLE PRECISION,

logo_url TEXT,

verification_status BOOLEAN DEFAULT FALSE,

created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- ORGANIZATION MEMBERS
-- =====================================================

CREATE TABLE organization_members (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,

profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

role_name TEXT DEFAULT 'member',

created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- NGO DETAILS
-- =====================================================

CREATE TABLE ngo_details (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

organization_id UUID NOT NULL REFERENCES organizations(id),

capacity INTEGER DEFAULT 0,

operating_hours TEXT,

accepted_food_categories TEXT[],

created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- VOLUNTEER DETAILS
-- =====================================================

CREATE TABLE volunteers (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

profile_id UUID NOT NULL REFERENCES profiles(id),

is_available BOOLEAN DEFAULT TRUE,

rating NUMERIC(2,1) DEFAULT 5.0,

completed_tasks INTEGER DEFAULT 0,

created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- FOOD LISTINGS
-- =====================================================

CREATE TABLE food_listings (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

donor_id UUID NOT NULL REFERENCES profiles(id),

organization_id UUID REFERENCES organizations(id),

food_name TEXT NOT NULL,

category TEXT,

description TEXT,

quantity_kg NUMERIC(10,2),

estimated_servings INTEGER,

preparation_time TIMESTAMP,

pickup_start_time TIMESTAMP,

pickup_end_time TIMESTAMP,

expiry_time TIMESTAMP,

pickup_address TEXT,

latitude DOUBLE PRECISION,
longitude DOUBLE PRECISION,

special_instructions TEXT,

status donation_status DEFAULT 'available',

created_at TIMESTAMP DEFAULT NOW(),

updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- FOOD IMAGES
-- =====================================================

CREATE TABLE food_images (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

listing_id UUID NOT NULL REFERENCES food_listings(id) ON DELETE CASCADE,

image_url TEXT NOT NULL,

created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- FOOD TAGS
-- =====================================================

CREATE TABLE food_tags (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

name TEXT UNIQUE NOT NULL
);

CREATE TABLE food_listing_tags (
listing_id UUID REFERENCES food_listings(id) ON DELETE CASCADE,
tag_id UUID REFERENCES food_tags(id) ON DELETE CASCADE,

PRIMARY KEY(listing_id, tag_id)
);

-- =====================================================
-- DONATION REQUESTS
-- =====================================================

CREATE TABLE donation_requests (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

listing_id UUID NOT NULL REFERENCES food_listings(id),

ngo_id UUID REFERENCES ngo_details(id),

volunteer_id UUID REFERENCES volunteers(id),

status donation_status DEFAULT 'accepted',

requested_at TIMESTAMP DEFAULT NOW(),

accepted_at TIMESTAMP,

delivered_at TIMESTAMP
);

-- =====================================================
-- DELIVERY TASKS
-- =====================================================

CREATE TABLE delivery_tasks (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

donation_request_id UUID REFERENCES donation_requests(id),

volunteer_id UUID REFERENCES volunteers(id),

task_status task_status DEFAULT 'pending',

pickup_started_at TIMESTAMP,

picked_up_at TIMESTAMP,

delivered_at TIMESTAMP,

created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- TRACKING EVENTS
-- =====================================================

CREATE TABLE tracking_events (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

listing_id UUID REFERENCES food_listings(id),

event_type TEXT NOT NULL,

event_description TEXT,

created_by UUID REFERENCES profiles(id),

created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- NOTIFICATIONS
-- =====================================================

CREATE TABLE notifications (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

user_id UUID NOT NULL REFERENCES profiles(id),

title TEXT NOT NULL,

message TEXT NOT NULL,

is_read BOOLEAN DEFAULT FALSE,

created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- RATINGS
-- =====================================================

CREATE TABLE ratings (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

from_user UUID REFERENCES profiles(id),

to_user UUID REFERENCES profiles(id),

listing_id UUID REFERENCES food_listings(id),

rating INTEGER CHECK (rating BETWEEN 1 AND 5),

review TEXT,

created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- IMPACT METRICS
-- =====================================================

CREATE TABLE impact_metrics (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

listing_id UUID REFERENCES food_listings(id),

meals_saved INTEGER DEFAULT 0,

food_rescued_kg NUMERIC(10,2),

carbon_saved_kg NUMERIC(10,2),

created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- ADMIN LOGS
-- =====================================================

CREATE TABLE admin_logs (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

admin_id UUID REFERENCES profiles(id),

action TEXT,

entity_type TEXT,

entity_id UUID,

created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX idx_food_status
ON food_listings(status);

CREATE INDEX idx_food_location
ON food_listings(latitude, longitude);

CREATE INDEX idx_ngo_location
ON organizations(latitude, longitude);

CREATE INDEX idx_notifications_user
ON notifications(user_id);

CREATE INDEX idx_tracking_listing
ON tracking_events(listing_id);

CREATE INDEX idx_donation_requests
ON donation_requests(listing_id);
