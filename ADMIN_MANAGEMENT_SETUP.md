# Admin Management Setup and Testing Guide

## Overview
This document provides instructions for setting up the first admin manually in Firebase and testing the admin management functionality.

## Manual Firebase Setup - First Admin

### Step 1: Create Admin in Firebase Authentication

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project
3. Navigate to **Authentication** → **Users**
4. Click **Add user**
5. Enter the admin credentials:
   - **Email**: `admin@example.com` (or your preferred email)
   - **Password**: Create a strong password
6. Click **Add user**
7. **Copy the User UID** - you'll need this for the next step

### Step 2: Create User Document in Firestore

**⚠️ CRITICAL: The Document ID MUST match the Firebase Auth UID exactly!**

1. In Firebase Console, navigate to **Firestore Database**
2. Go to the `users` collection
3. Click **Add document**
4. **IMPORTANT**: In the "Document ID" field, **paste the exact User UID** from Step 1 (the full UID, not a shortened version)
   - Do NOT let Firebase auto-generate the document ID
   - Do NOT use a different ID
   - The Document ID must be exactly the same as the Firebase Auth UID
5. Add the following fields:
   ```
   email: "admin@example.com" (String)
   role: "admin" (String)
   profileId: "" (String - leave empty for now, will be updated)
   createdAt: [Current Timestamp]
   ```
6. Click **Save**

**Verification**: After saving, verify that:
- The document ID in Firestore matches exactly with the User UID from Firebase Authentication
- You can see the document when you click on the `users` collection

### Step 3: Create Admin Profile in Firestore

1. In Firestore Database, go to the `adminProfiles` collection
2. Click **Add document** (let Firebase auto-generate the Document ID)
3. Add the following fields:
   ```
   userId: "[User UID from Step 1]" (String)
   firstName: "Admin" (String)
   lastName: "User" (String)
   accessLevel: "super_admin" (String) - IMPORTANT: Use "super_admin" for first admin
   createdAt: [Current Timestamp]
   ```
4. Click **Save**
5. **Copy the Document ID** of the admin profile you just created

### Step 4: Update User Document with Profile ID

1. Go back to the `users` collection
2. Open the user document you created in Step 2
3. Update the `profileId` field with the **Document ID** from Step 3
4. Click **Update**

### Summary of First Admin Setup

Your first admin should have:
- **Firebase Authentication**: User with email and password
- **Firestore `users` collection**: Document with:
  - Document ID = User UID
  - `email`: admin email
  - `role`: "admin"
  - `profileId`: admin profile document ID
- **Firestore `adminProfiles` collection**: Document with:
  - Auto-generated Document ID
  - `userId`: User UID
  - `firstName`: Admin first name
  - `lastName`: Admin last name
  - `accessLevel`: "super_admin" (this allows access to manage admins screen)

## Testing Steps

### Test 1: First Admin Login

1. **Start the application**
2. Navigate to **Admin Login** screen
3. Enter the credentials you created in Firebase:
   - Email: `admin@example.com`
   - Password: [your password]
4. Click **Login**
5. **Expected Result**: 
   - Login successful
   - Redirected to Admin Dashboard
   - You should see the "Manage Admins" menu item in the sidebar

### Test 2: Create New Admin

1. **While logged in as the first admin**, click on **"Manage Admins"** in the sidebar
2. Fill in the form:
   - **Full Name**: "John Admin"
   - **Email**: "john.admin@example.com"
   - **Password**: "SecurePass123!"
   - **Role**: Select "Admin"
3. Click **"Create Admin"**
4. **Expected Result**:
   - Success message: "Admin created successfully"
   - Form fields are cleared
   - New admin is created in Firebase Authentication
   - New user document is created in `users` collection with `role: "admin"`
   - New admin profile is created in `adminProfiles` collection with `accessLevel: "super_admin"`

### Test 3: Create New Recruiter

1. **While logged in as the first admin**, go to **"Manage Admins"** screen
2. Fill in the form:
   - **Full Name**: "Jane Recruiter"
   - **Email**: "jane.recruiter@example.com"
   - **Password**: "SecurePass123!"
   - **Role**: Select "Recruiter"
3. Click **"Create Recruiter"**
4. **Expected Result**:
   - Success message: "Recruiter created successfully"
   - Form fields are cleared
   - New recruiter is created in Firebase Authentication
   - New user document is created in `users` collection with `role: "admin"`
   - New admin profile is created in `adminProfiles` collection with `accessLevel: "recruiter"`

### Test 4: Login as New Admin

1. **Logout** from the current admin session
2. Navigate to **Admin Login** screen
3. Enter the new admin credentials:
   - Email: `john.admin@example.com`
   - Password: `SecurePass123!`
4. Click **Login**
5. **Expected Result**:
   - Login successful
   - Redirected to Admin Dashboard
   - You should see the "Manage Admins" menu item in the sidebar (because accessLevel is "super_admin")

### Test 5: Login as Recruiter

1. **Logout** from the current session
2. Navigate to **Admin Login** screen
3. Enter the recruiter credentials:
   - Email: `jane.recruiter@example.com`
   - Password: `SecurePass123!`
4. Click **Login**
5. **Expected Result**:
   - Login successful
   - Redirected to Admin Dashboard
   - You should **NOT** see the "Manage Admins" menu item in the sidebar (because accessLevel is "recruiter")
   - Recruiter can access all other admin features (Jobs, Candidates, Documents)

### Test 6: Verify Signup is Removed

1. Navigate to **Admin Login** screen
2. **Expected Result**:
   - There should be **NO** "Sign Up" link or button
   - Only login functionality is available

### Test 7: Verify Data in Firebase

1. Go to Firebase Console
2. Check **Firebase Authentication** → **Users**:
   - Should see all created admins and recruiters
3. Check **Firestore Database** → `users` collection:
   - Each user should have:
     - `email`: user email
     - `role`: "admin" (for both admins and recruiters)
     - `profileId`: reference to admin profile
4. Check **Firestore Database** → `adminProfiles` collection:
   - Each profile should have:
     - `userId`: reference to user UID
     - `firstName` and `lastName`: user's name
     - `accessLevel`: "super_admin" for admins, "recruiter" for recruiters

## Access Level Reference

- **`super_admin`**: Full admin access, can see and use "Manage Admins" screen
- **`recruiter`**: Limited admin access, cannot see "Manage Admins" screen

## Troubleshooting

### Issue: "User data not found. Please contact support." error
- **Most Common Cause**: The Document ID in the `users` collection does NOT match the Firebase Auth UID
- **Solution**: 
  1. Go to Firebase Authentication and copy the **exact User UID**
  2. Go to Firestore `users` collection
  3. Check if a document with that exact UID exists
  4. If the document ID is different, you have two options:
     - **Option A (Recommended)**: Delete the incorrect document and create a new one with the correct UID as the document ID
     - **Option B**: Rename the document ID to match the Firebase Auth UID (if your Firestore console supports this)

### Issue: Cannot login after manual setup
- **Solution**: Verify that:
  1. User exists in Firebase Authentication
  2. User document exists in `users` collection with **Document ID = Firebase Auth UID** (exact match required!)
  3. User document has correct `role: "admin"`
  4. Admin profile exists in `adminProfiles` collection
  5. `profileId` in user document matches the admin profile document ID
  6. `userId` in admin profile matches the Firebase Auth UID

### Issue: "Manage Admins" menu not showing
- **Solution**: Check that:
  1. Admin profile has `accessLevel: "super_admin"` (not "recruiter")
  2. User document has correct `profileId` pointing to admin profile

### Issue: Cannot create admin/recruiter
- **Solution**: Verify that:
  1. You are logged in as an admin with `accessLevel: "super_admin"`
  2. Email is not already in use
  3. Password meets requirements (minimum 6 characters)
  4. All form fields are filled correctly

## Notes

- Both admins and recruiters have `role: "admin"` in the `users` collection
- The difference is in the `accessLevel` field in `adminProfiles` collection
- Only users with `accessLevel: "super_admin"` can access the "Manage Admins" screen
- The first admin must be created manually in Firebase
- All subsequent admins and recruiters can be created through the "Manage Admins" screen

