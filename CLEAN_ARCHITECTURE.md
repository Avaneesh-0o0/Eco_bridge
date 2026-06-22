# FoodBridge AI - Flutter Clean Architecture

# Overview

This document defines the Flutter project structure, architecture pattern, state management strategy, dependency injection, navigation structure, and feature organization for FoodBridge AI.

Architecture Style:

Clean Architecture + Feature First + Riverpod

Goals:

* Scalability
* Maintainability
* Testability
* Separation of Concerns
* Easy Migration to Spring Boot

---

# Architecture Layers

Presentation Layer
↓
Domain Layer
↓
Data Layer
↓
Supabase

---

# Project Structure

lib/

core/
features/
shared/
routes/
main.dart

---

# Complete Folder Structure

lib/

core/

config/
constants/
errors/
network/
services/
theme/
utils/

shared/

widgets/
extensions/
models/

routes/

app_router.dart
route_names.dart

features/

auth/
dashboard/
donations/
organizations/
volunteers/
tracking/
notifications/
profile/
analytics/

---

# Core Module

Purpose:

Application-wide reusable components.

---

core/config/

app_config.dart

environment.dart

---

core/constants/

app_colors.dart

app_strings.dart

app_sizes.dart

app_assets.dart

supabase_constants.dart

---

core/errors/

exceptions.dart

failures.dart

---

core/network/

network_info.dart

---

core/services/

supabase_service.dart

storage_service.dart

notification_service.dart

location_service.dart

---

core/theme/

app_theme.dart

light_theme.dart

dark_theme.dart

---

core/utils/

validators.dart

date_utils.dart

distance_utils.dart

helpers.dart

---

# Shared Module

Reusable widgets and components.

---

shared/widgets/

custom_button.dart

custom_text_field.dart

custom_card.dart

custom_app_bar.dart

loading_widget.dart

empty_state_widget.dart

error_widget.dart

---

shared/models/

api_response.dart

pagination_model.dart

---

# Feature Structure

Each feature follows:

feature/

data/
domain/
presentation/

---

# Example

features/auth/

data/
domain/
presentation/

---

# Data Layer

Purpose:

External data access.

Contains:

Models
Repositories
Datasource

---

auth/data/

datasources/

auth_remote_datasource.dart

models/

user_model.dart

repositories/

auth_repository_impl.dart

---

# Domain Layer

Business Logic

Contains:

Entities
Repositories
UseCases

---

auth/domain/

entities/

user_entity.dart

repositories/

auth_repository.dart

usecases/

login_usecase.dart

register_usecase.dart

logout_usecase.dart

---

# Presentation Layer

UI

Contains:

Screens
Providers
Widgets

---

auth/presentation/

screens/

login_screen.dart

register_screen.dart

role_selection_screen.dart

providers/

auth_provider.dart

widgets/

login_form.dart

register_form.dart

---

# Feature Modules

---

AUTH

Purpose:

Authentication

Screens:

Login

Register

Role Selection

Forgot Password

---

DASHBOARD

Purpose:

Role-based dashboard

Screens:

Donor Dashboard

NGO Dashboard

Volunteer Dashboard

Admin Dashboard

---

DONATIONS

Purpose:

Food donation management

Screens:

Create Donation

Donation Details

Donation History

Donation Tracking

Files:

food_listing_entity.dart

food_listing_model.dart

create_donation_usecase.dart

donation_repository.dart

---

ORGANIZATIONS

Purpose:

NGO and Donor Organizations

Screens:

Organization Profile

Nearby Organizations

---

VOLUNTEERS

Purpose:

Volunteer task management

Screens:

Available Tasks

Task Details

Volunteer History

---

TRACKING

Purpose:

Donation Tracking

Screens:

Live Tracking

Tracking Timeline

---

NOTIFICATIONS

Purpose:

Push Notifications

Screens:

Notification List

Notification Details

---

PROFILE

Purpose:

User Profile

Screens:

Profile

Edit Profile

Settings

---

ANALYTICS

Purpose:

Impact Dashboard

Screens:

Impact Dashboard

Donation Analytics

---

# State Management

Riverpod

---

Providers

authProvider

userProvider

donationProvider

trackingProvider

notificationProvider

profileProvider

analyticsProvider

---

Provider Types

StateNotifierProvider

FutureProvider

StreamProvider

Provider

---

# Dependency Injection

Riverpod Dependency Injection

Example:

Repository

Datasource

UseCase

Provider

---

# Navigation

Package:

GoRouter

---

Route Groups

/auth

/dashboard

/donations

/organizations

/volunteers

/tracking

/notifications

/profile

/analytics

---

# Route Structure

/auth/login

/auth/register

/auth/role-selection

---

/dashboard/donor

/dashboard/ngo

/dashboard/volunteer

/dashboard/admin

---

/donations/create

/donations/details/:id

/donations/history

---

/tracking/:id

---

/profile

/profile/edit

---

# Supabase Integration

Supabase Client

Singleton Pattern

File:

supabase_service.dart

Responsibilities:

Authentication

Database

Storage

Realtime

---

# Storage Buckets

food-images

avatars

organization-logos

documents

---

# Realtime Channels

donations

tracking

notifications

---

# Error Handling

Custom Exception Layer

Examples:

AuthException

StorageException

DatabaseException

LocationException

---

# App Theme Structure

Theme:

Impact Flow

Files:

app_colors.dart

app_theme.dart

light_theme.dart

---

# Testing Structure

test/

features/

auth/

donations/

tracking/

analytics/

---

Tests

Unit Tests

Repository Tests

Provider Tests

Widget Tests

---

# Development Order

Phase 1

Authentication

Role Selection

Profile

---

Phase 2

Donation Module

NGO Module

Volunteer Module

---

Phase 3

Tracking

Notifications

Analytics

---

Phase 4

AI Features

Smart Matching

Impact Intelligence

Route Optimization

---

# MVP Screens

Splash

Onboarding

Login

Register

Role Selection

Donor Dashboard

Create Donation

Donation Details

NGO Dashboard

Volunteer Dashboard

Task Details

Tracking

Profile

Total MVP Screens: 13

---

# Final Architecture Principle

UI should never directly communicate with Supabase.

Screen
↓
Provider
↓
UseCase
↓
Repository
↓
Datasource
↓
Supabase

All business logic must remain in the Domain Layer.

This ensures future migration from Supabase to Spring Boot requires changing only the Data Layer while keeping the entire Flutter application intact.
