# FoodBridge AI - Screens, Navigation & App Router Document

# 1. Application Overview

FoodBridge AI consists of four user roles:

1. Donor
2. NGO
3. Volunteer
4. Admin

Each role has dedicated screens and permissions.

---

# 2. App Navigation Flow

Launch App
↓
Splash Screen
↓
Onboarding
↓
Authentication
↓
Role Selection

┌──────────┬──────────┬──────────┐
│          │          │
▼          ▼          ▼

Donor      NGO     Volunteer

│          │          │
▼          ▼          ▼

Role Based Dashboard

---

# 3. Common Screens

These screens are shared by all users.

---

## Splash Screen

Purpose:

* App branding
* Session check

Route:

* /splash

Next:

* Login
* Dashboard

---

## Onboarding Screen

Purpose:

* Explain platform
* Show key benefits

Route:

* /onboarding

---

## Login Screen

Features:

* Email Login
* Password Login

Route:

* /login

---

## Register Screen

Features:

* Name
* Email
* Phone
* Password

Route:

* /register

---

## Role Selection Screen

Roles:

* Donor
* NGO
* Volunteer

Route:

* /role-selection

---

## Forgot Password Screen

Route:

* /forgot-password

---

# 4. Donor Module

---

## Donor Dashboard

Route:

* /donor/dashboard

Features:

* Active Donations
* Completed Donations
* Impact Summary

Cards:

* Meals Saved
* Donations Made
* Food Rescued

---

## Create Donation Screen

Route:

* /donor/create-donation

Fields:

Food Name

Category

Quantity

Estimated Servings

Description

Pickup Address

Pickup Time

Expiry Time

Upload Images

---

## Donation Details Screen

Route:

* /donor/donation/:id

Features:

* Food Information
* NGO Assigned
* Pickup Status
* Delivery Status

---

## Donation History Screen

Route:

* /donor/history

Features:

* Active Donations
* Completed Donations
* Expired Donations

---

## Donor Profile Screen

Route:

* /donor/profile

---

# 5. NGO Module

---

## NGO Dashboard

Route:

* /ngo/dashboard

Cards:

* Available Donations
* Accepted Donations
* Completed Deliveries

---

## Nearby Donations Screen

Route:

* /ngo/nearby-donations

Features:

* List View
* Map View

Filters:

* Distance
* Food Category
* Servings

---

## Donation Request Screen

Route:

* /ngo/donation/:id

Actions:

* Accept
* Reject

---

## NGO Deliveries Screen

Route:

* /ngo/deliveries

Status:

* Pending
* Accepted
* Completed

---

## NGO Profile Screen

Route:

* /ngo/profile

Fields:

* Organization Name
* Capacity
* Address

---

# 6. Volunteer Module

---

## Volunteer Dashboard

Route:

* /volunteer/dashboard

Cards:

* Active Pickups
* Completed Deliveries

---

## Available Tasks Screen

Route:

* /volunteer/tasks

Features:

* Donation Details
* Distance
* NGO Details

Action:

* Accept Task

---

## Task Details Screen

Route:

* /volunteer/task/:id

Actions:

Start Pickup

Confirm Pickup

Confirm Delivery

---

## Volunteer History Screen

Route:

* /volunteer/history

---

## Volunteer Profile Screen

Route:

* /volunteer/profile

---

# 7. Shared Tracking Module

---

## Live Tracking Screen

Route:

* /tracking/:id

Features:

Google Maps

Pickup Location

Destination Location

Current Status

ETA

---

## Status Timeline Screen

Route:

* /tracking/timeline/:id

Stages:

Donation Created

Accepted

Pickup Started

Picked Up

Delivered

Completed

---

# 8. Impact Module

---

## Impact Dashboard

Route:

* /impact

Metrics:

Meals Saved

Food Rescued

NGOs Supported

Volunteers Active

Carbon Emissions Prevented

---

## Donation Analytics Screen

Route:

* /analytics

Charts:

Monthly Donations

Food Categories

Meals Saved

Top Donors

---

# 9. Notifications Module

---

## Notifications Screen

Route:

* /notifications

Types:

Donation Accepted

Pickup Assigned

Delivery Completed

System Alerts

---

# 10. Settings Module

---

## Settings Screen

Route:

* /settings

Options:

Edit Profile

Change Password

Privacy Policy

Logout

---

# 11. Admin Module

---

## Admin Dashboard

Route:

* /admin/dashboard

Metrics:

Users

NGOs

Volunteers

Donations

Impact Statistics

---

## User Management

Route:

* /admin/users

---

## Donation Management

Route:

* /admin/donations

---

## NGO Management

Route:

* /admin/ngos

---

## Analytics Management

Route:

* /admin/analytics

---

# 12. Bottom Navigation

DONOR

Home
Create Donation
History
Profile

---

NGO

Home
Donations
Deliveries
Profile

---

VOLUNTEER

Home
Tasks
History
Profile

---

# 13. MVP Screens (Build First)

Priority 1

Splash
Login
Register
Role Selection
Donor Dashboard
Create Donation
NGO Dashboard
Nearby Donations
Donation Details
Volunteer Tasks
Tracking Screen
Profile

Total MVP Screens:
12

---

# 14. Phase 2 Screens

Impact Dashboard
Analytics
Notifications
Admin Panel

---

# 15. Future Screens

AI Food Analysis
Food Recommendation
CSR Dashboard
Government Dashboard
Disaster Relief Mode
Community Food Bank Module

---

# Recommended Flutter Navigation

GoRouter

Main Route Groups:

/auth/*
/donor/*
/ngo/*
/volunteer/*
/tracking/*
/impact/*
/admin/*

This structure supports future migration to Spring Boot or Microservices without changing frontend routing.
