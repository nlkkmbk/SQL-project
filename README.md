# SQL-project
This project is a Hospital Database Management System (DBMS) built as a course project.   It demonstrates a full database design and implementation using  Oracle SQL, PL/SQL, and Oracle APEX.
## 1. System Design and Architecture

### 1.1 About our dataset

This dataset represents a historical medical information system covering the years **2023–2025**.

The core structure is built around autonomous entities:

- **PATIENTS**
- **DOCTORS**
- **SPECIALIZATIONS**
- **DEPARTMENTS**

At the center is the **APPOINTMENT**, from which all dependent records originate:

- **DIAGNOSIS**
- **TREATMENT**
- **PRESCRIPTION**
- **BILL**
- **PAYMENT**

Diagnoses and prescriptions capture clinical decisions, while treatments may be linked to a diagnosis or performed directly during the appointment.

The financial model is streamlined:  
each appointment generates exactly **one bill**, which is settled by a **single payment**.

The historical nature of the data ensures full traceability of both clinical and financial events throughout **2023–2025**.

---

### 1.2 Entity Descriptions

#### PATIENT

Stores demographic and contact details.

- `patient_id` (PK)
- `first_name`, `last_name`
- `birth_date`, `gender`
- `phone`, `email`, `address`
- `weight`, `height`
- `emergency_contact`

---

#### APPOINTMENT

Represents patient–doctor interactions.

- `appointment_id` (PK)
- `patient_id` (FK → PATIENT)
- `doctor_id` (FK → DOCTOR)
- `department_id` (FK → DEPARTMENT)
- `appointment_date`
- `appointment_time`

---

#### DEPARTMENT

Hospital units (e.g., Cardiology, Pediatrics).

- `department_id` (PK)
- `department_name`

---

#### SPECIALIZATION

Medical specializations.

- `specialization_id` (PK)
- `specialization_name`

---

#### DOCTOR

Information about medical personnel.

- `doctor_id` (PK)
- `first_name`, `last_name`
- `email`
- `specialization_id` (FK → SPECIALIZATION)
- `department_id`   (FK → DEPARTMENT)

---

#### DIAGNOSIS

Diagnostic outcomes linked to appointments.

- `diagnosis_id` (PK)
- `appointment_id` (FK → APPOINTMENT)
- `diagnosis_name`

---

#### TREATMENT

Procedures based on a diagnosis and/or appointment.

- `treatment_id` (PK)
- `diagnosis_id`   (FK → DIAGNOSIS)
- `appointment_id` (FK → APPOINTMENT)
- `treatment_type`
- `treatment_cost`

---

#### MEDICINE

Medicine catalog.

- `medicine_id` (PK)
- `medicine_name`
- `price`
- `stock_quantity`

---

#### PRESCRIPTION

Links medicines to appointments.

- `prescription_id` (PK)
- `appointment_id` (FK → APPOINTMENT)
- `medicine_id`    (FK → MEDICINE)
- `dosage`
- `duration`

---

#### BILL

Financial charges for an appointment.

- `bill_id` (PK)
- `appointment_id` (FK → APPOINTMENT)
- `total_amount`
- `billing_date`
- `status`

---

#### PAYMENT

Records monetary transactions.

- `payment_id` (PK)
- `bill_id` (FK → BILL)
- `amount`
- `payment_date`

### 1.2 🔗 Relationship Cardinality

| Relationship              | Cardinality | Description                                                                 |
|---------------------------|------------|-----------------------------------------------------------------------------|
| Patient → Appointment     | 1 : M      | One patient can have many appointments.                                     |
| Appointment → Doctor      | M : 1      | Each appointment is with one doctor; one doctor can conduct many appointments. |
| Appointment → Department  | M : 1      | Each appointment belongs to one department; one department can host many appointments. |
| Appointment → Diagnosis   | 1 : M      | One appointment may result in multiple diagnoses.                           |
| Appointment → Treatment   | 1 : M      | Multiple treatments can be recorded for a single appointment/diagnosis.    |
| Appointment → Prescription| 1 : M      | Multiple prescriptions can be issued during one appointment.               |
| Medicine → Prescription   | 1 : M      | One medicine can appear in many prescriptions.                             |
| Doctor → Specialization   | M : 1      | Each doctor has one specialization; one specialization can be shared by many doctors. |
| Bill → Appointment        | 1 : 1      | One bill is generated for each appointment.                                |
| Payment → Bill            | M : 1      | Each payment belongs to one bill; one bill can have many payments.         |

## 🧬 ER Diagram

![Hospital ERD](appointment_erd%20(3).png)


