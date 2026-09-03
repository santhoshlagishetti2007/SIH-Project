# Community Group & Local Guide Verification Policy

## Overview
Sanchari enables travelers to connect with non-commercial, community-led local exploration groups, heritage walking clubs, photography circles, and passionate volunteer guides. To ensure safety, trust, and authentic community engagement, every group displayed in the app undergoes an administrative verification workflow before receiving the **`🛡️ VERIFIED COMMUNITY`** badge.

---

## 1. Eligibility Criteria for Community Groups

1. **Non-Commercial Charter**:
   - Groups must be operated primarily for community passion, cultural exchange, photography, fitness, or heritage preservation.
   - Commercial travel agencies or aggressive sales groups are not eligible for community verification.
2. **Designated Group Lead / Organizer**:
   - Each group must have a designated point of contact with verified contact credentials.
3. **Transparent Schedules & Public Meeting Points**:
   - Activities (e.g. morning walks, cycling meetups) must occur at well-known, public, and safe meeting locations.

---

## 2. Verification & Document Check Process

### Phase 1: Submission
When a community leader submits a new group via the Sanchari app or Admin Portal, the group is recorded with `verificationStatus: "pending"`:
- Group Name & Category (e.g., *Heritage Walk*, *Photography*, *Food Trails*, *Nature & Hiking*, *Art & Culture*)
- Destination City & Meeting Location
- Regular Meetup Schedule (e.g., *Every Saturday 7:00 AM*)
- Lead Organizer Name, Phone Number, WhatsApp, and Email
- Organizer Identification Document Reference:
  - Govt Photo ID (Aadhaar / Voter ID / Passport / Driver's License)
  - OR Ministry of Tourism / Certified Guide License (if applicable)
  - Social proof link (Instagram community page, Meetup.com, or public portfolio)

### Phase 2: Administrative Review & Reference Check
The Sanchari Admin team reviews submissions within 24–48 hours:
1. **Identity & Phone Verification**: Automated OTP or direct voice call to the group lead to verify active contact.
2. **Charter Review**: Ensuring no hidden ticketing fees, commercial advertisements, or unsafe remote night itineraries.
3. **Safety & Code of Conduct Agreement**: The organizer formally acknowledges Sanchari's Community Safety & Anti-Harassment Pledge.

### Phase 3: Approval & Badge Granting
Once approved via `PATCH /api/v1/groups/:id/verify`:
- `verificationStatus` transitions from `"pending"` to `"verified"`.
- The `🛡️ VERIFIED COMMUNITY` badge is immediately activated on the group's public listing in the Sanchari app.
- Travelers can freely discover the group, view schedules, and submit join requests or directly message the organizer.

---

## 3. Traveler Join & Message Workflow
- Travelers browsing a destination's verified groups can tap **"Request to Join / Message Lead"**.
- A custom message and traveler profile link are dispatched to the group lead.
- Direct deep-links to WhatsApp and phone contact are available for instant coordination.

---

## 4. Revocation & Safety Reporting
Community members and travelers can report safety violations or commercial bait-and-switch practices. Verified status is immediately revoked upon valid safety complaints.
