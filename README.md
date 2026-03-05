#  CSS Clinic

A full-featured web-based medical management system that connects patients with doctors, enabling seamless appointment scheduling, real-time communication, and comprehensive practice administration.

 **Live Demo:** [https://rendeerr.onrender.com](https://rendeerr.onrender.com)

>  **Status:** Project complete.

---

##  Features

###  Authentication & User Management
- User registration and login powered by **Devise**
- Two user roles: **Patient** and **Doctor**
- Admin panel for full user management and role assignment

###  Appointment Booking
- Create, edit, and cancel medical appointments
- Filter appointment list by status
- Status workflow: `Pending → Confirmed → Completed / Cancelled`
- Role-specific actions:
  - Patients can cancel their appointments
  - Doctors can confirm and mark appointments as completed

###  Real-Time Messaging
- Integrated chat between patient and doctor within each appointment
- Full conversation history per booking

###  Review System
- Patients can submit reviews for completed appointments
- Edit and delete your own reviews

###  Doctor Schedule Management
- Doctors can create and manage their own availability
- Edit or remove existing time slots

###  Nearby Pharmacy Finder
- Geolocation-based pharmacy search
- Integration with an external pharmacy API
- Responsive interface with real-time updates

###  Admin Panel
- Full management dashboard
- Promote users to Doctor role
- Oversee appointments and doctors across the platform

---

##  Tech Stack

| Layer         | Technology                        |
|---------------|-----------------------------------|
| Frontend      | Tailwind CSS                      |
| Backend       | Ruby on Rails                     |
| Database      | PostgreSQL (via Rails)            |
| Auth          | Devise                            |
| Deployment    | Render                            |

---

##  Installation & Setup

### Prerequisites

- Ruby & Bundler
- Node.js & Yarn
- PostgreSQL

### Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/IIC2143/CSS.Clinic.git
   cd 2025-2-grupo-60
   ```

2. **Install Ruby dependencies:**
   ```bash
   bundle install
   ```

3. **Install JavaScript dependencies:**
   ```bash
   yarn install
   ```

4. **Set up the database:**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

5. **Start the server:**
   ```bash
   rails server
   ```

6. Open your browser and navigate to `http://localhost:3000`.

---

##  Test Credentials

Use the following accounts to explore the platform:

| Role          | Email                    | Password |
|---------------|--------------------------|----------|
|  Doctor   | doctor@clinica.com       | 123456   |
|  Patient    | paciente@clinica.com     | 123456   |
|  Admin      | admin@clinica.com        | 123456   |

---

##  License

MIT — free to use, modify, and distribute.
