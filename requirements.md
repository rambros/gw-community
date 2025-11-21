
# Simple Invoice App – Requirements

A mobile application that helps small business owners quickly create professional invoices on their device. Users can store their company details once, manage multiple clients, and generate invoices in British pounds with automatic calculations. Each invoice can be exported as a high-quality PDF and shared directly with customers for payment. The app is designed to be simple, fast and entirely usable offline.

## 1. Purpose

A mobile app that lets a small business owner:

- Store their **company details** once.
- Add and manage **clients**.
- Create **invoices linked to those clients**.
- Generate a **nice-looking PDF invoice in British pounds (£)**.
- Share that invoice with the client (e.g. via email, messages).

---

## 2. User Roles

- **Single user / small business owner**  
  No multi-user, no logins required in v1 (just a single device owner).

---

## 3. Core Use Cases

### 3.1 Manage Company Details (Settings)

**User goal:** Save my business information once so I don’t have to re-type it on every invoice.

**Must be able to:**

- Open a **Settings / Company** screen.
- Enter and save:
  - Company name
  - Address (line 1, line 2, town/city, county, postcode, country)
  - Phone number
  - Email address
  - Website (optional)
  - Company registration number (optional)
  - VAT registration number (optional)
  - Default payment terms (e.g. “14 days”, “30 days”)
  - Free-text **payment instructions** (e.g. bank details, “Please pay by bank transfer within 14 days.”)
- See current saved details when returning to the screen.
- Edit and re-save details at any time.

---

### 3.2 Manage Clients

**User goal:** Keep a list of clients and reuse them when creating invoices.

**Must be able to:**

- Open a **Clients** screen showing a list of clients.
- See, for each client:
  - Client name
  - Key contact name (if provided)
  - Email address
- Add a new client with:
  - Client name (required)
  - Contact name (optional)
  - Email (required)
  - Phone (optional)
  - Address (line 1, line 2, town/city, county, postcode, country)
  - Notes (optional)
- Edit existing client details.
- Delete a client (only if it doesn’t break invoices).
- Search or scroll to find a client.

---

### 3.3 Create an Invoice

**User goal:** Quickly create a new invoice for a client that includes all required information and calculates totals.

**Must be able to:**

- Start a new invoice from:
  - An **Invoices** list screen, or
  - A **Client detail** screen
- Select a client from the saved list.
- See an **invoice number** (auto-generated, but editable).
- Set:
  - Invoice date (default: today)
  - Due date (default: based on payment terms)
- Add **line items**, each with:
  - Description (required)
  - Quantity (required)
  - Unit price (required, GBP)
  - Line total = qty × unit price
- View:
  - Subtotal
  - VAT (toggle with configurable rate)
  - Grand total (GBP)
- Enter **notes** for the customer.
- All currency displayed as **£** with two decimal places.

---

### 3.4 View & Manage Invoices

- List of invoices with:
  - Invoice number
  - Client name
  - Date
  - Status (Draft, Sent, Paid, Overdue)
  - Total amount
- View invoice details.
- Edit invoice (if Draft or Sent).
- Mark invoice as Sent or Paid.
- Duplicate invoice.

---

### 3.5 Generate PDF Invoice

- PDF must include:
  - Company and client details
  - Invoice number, dates
  - Line items and totals in **£**
  - Notes and payment terms
- Visually clean and professional
- View or share PDF

---

### 3.6 Share / Send Invoice

- Share PDF via device sharing (email, etc.)
- Suggested subject:
  - `Invoice {invoiceNumber} from {companyName}`

---

## 4. Business Rules

- **Currency:** British pounds (format: `£1,234.56`).
- **Invoice number:** unique, auto-sequenced, user may override if unique.
- Required to save: company name, client, line items, invoice date.
- Required for PDF: due date + invoice number.
- New invoices start **Draft**.
- Sharing suggests **Sent** status.
- **Paid** set manually.
- Overdue based on due date*(optional logic)*.
- Changing company/client details later must not alter historical invoices.

---

## 5. Non-Functional Requirements

- Offline-first (local device data).
- Good performance for realistic usage.
- Clear validation and easy-to-use forms.
- Modern, professional UI.

---

## 6. MVP Checklist

✔ Save company details  
✔ Add/manage clients  
✔ Create invoices with correct totals  
✔ GBP formatting everywhere  
✔ View/ edit invoice  
✔ Generate good PDF  
✔ Share PDF  
✔ Update statuses including Paid  

---

End of requirements.
