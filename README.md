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

### 1.2 Relationship Cardinality

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

## ER Diagram

![Hospital ERD](appointment_erd%20(3).png)


## 2. Queries

### 2.1 Functions and Procedures / Cursors and Records / Packages and Exceptions

#### PACKAGE: `pkg_patient_analytics`

The package `pkg_patient_analytics` provides analytical tools for working with patient
medical activity in the hospital database. It centralizes procedures and a function that
generate summaries, history reports, and doctor-visit analytics for patients.

1. **Procedure: `proc_patient_history`**  
   Retrieves full medical history for a given patient, including appointment dates,
   diagnoses, and doctor information.  
   Uses a **cursor** to print each record in chronological order.

2. **Procedure: `proc_frequent_patients`**  
   Identifies patients with five or more appointments and calculates their visit statistics,
   including total visit count and average interval between visits.  
   Uses a cursor and aggregate functions.

3. **Function: `fn_patient_most_frequent_doctor`**  
   Returns a formatted text report showing the doctor most frequently visited by a specific
   patient. Includes patient name, doctor name, specialization, department, and number of visits.

---

#### PACKAGE: `pkg_patient_risk`

The package `pkg_patient_risk` provides analytical functions to evaluate
a patient’s health risk based on demographic factors, physical indicators, diagnosis
history, and treatment activity. It centralizes risk-calculation logic and returns both
numerical scores and a formatted summary report.

1. **Function: `f_age_risk`**  
   Calculates the risk contribution associated with the patient’s age by determining age in
   years and assigning a score according to predefined thresholds.

2. **Function: `f_bmi_risk`**  
   Computes BMI from height and weight and returns a risk score based on whether the
   BMI indicates normal, overweight, or obese status.

3. **Function: `f_diag_risk`**  
   Counts the number of diagnoses recorded across all patient appointments and assigns a
   risk value reflecting clinical complexity.

4. **Function: `f_treat_risk`**  
   Evaluates how many treatments the patient has undergone; frequent treatments increase
   the risk level.

5. **Functions: `f_patient_risk_score` and `f_pr_sum`**  
   These two functions work together to evaluate a patient’s health risk:  
   - `f_patient_risk_score` calculates the total numerical score.  
   - `f_pr_sum` presents this result as a formatted summary with patient details, 
     component scores, and the final risk category.

---

#### PACKAGE: `pkg_treatment_analytics`

The package `pkg_treatment_analytics` organizes all treatment-related analytics
in one place. It helps monitor medicine stocks, identify common diagnoses, analyze
treatment trends, and summarize prescription usage. By keeping these procedures
together, the package makes the system easier to manage and more convenient for
generating medical reports.

1. **Procedure: `pr_low_stock_medicines(p_threshold)`**  
   Identifies medicines with stock levels below the given threshold.  
   Provides a list sorted by quantity and highlights critical shortages.

2. **Procedure: `pr_top_diagnoses(p_limit)`**  
   Displays the most common diagnoses based on the number of unique patients.  
   Useful for identifying medical trends and high-occurrence conditions.

3. **Procedure: `proc_treatment_trends(p_days)`**  
   Analyzes treatment usage trends over the last `p_days`.  
   Shows total assignments and unique patient counts for each treatment type.

4. **Procedure: `proc_prescription_summary(p_medicine_id)`**  
   Generates a summary for a specific medicine: total number of prescriptions,
   average treatment duration, and usage statistics.

5. **Procedure: `proc_frequent_treatments(p_limit)`**  
   Lists the most frequently assigned treatments.  
   Ranks them by total usage and number of unique patients.

---

#### Standalone Procedure: `proc_upcoming_appointments`

This procedure displays all upcoming appointments for a given doctor.
Using a cursor, it retrieves future appointment dates, times, and patient names,
printing each entry in chronological order.  
If no upcoming visits are found, it outputs a corresponding message.
Basic exception handling ensures stable execution and clear error reporting.

---

#### Standalone Procedure: `proc_doctor_daily_report`

This procedure produces a daily operational summary for a selected doctor.
It retrieves the doctor’s identifying information and specialization, then calculates key
activity indicators for the specified date, including:

- total number of appointments,
- number of unique patients,
- treatments performed,
- prescriptions issued.

By aggregating data from related clinical tables, the procedure presents a concise
overview of the doctor’s workload for that day. Exception handling ensures reliable
execution in cases of missing data or unexpected errors.

---

### 2.2 Collections

#### PACKAGE: `price_update_pkg` (Collection-Based Package)

The package `price_update_pkg` implements bulk price updates using PL/SQL
collections. It uses **BULK COLLECT** to retrieve data, **FORALL** to apply updates efficiently,
and collection-based storage to generate a detailed before-and-after price summary.

Main responsibilities:

- Load medicine names and prices into collections.  
- Apply percentage-based updates through bulk operations.  
- Produce a formatted report showing old and new prices.

1. **Function: `increase_prices`**  
   Increases all medicine prices using a collection-driven approach. It:

   - validates the input percentage,
   - retrieves medicine data into collections with BULK COLLECT,
   - performs a high-performance bulk update using FORALL,
   - reloads the updated prices into another collection,
   - returns a formatted summary comparing old and new values.

---

### 2.3 Triggers

#### Trigger: `trg_presc_dos`

Ensures data quality by preventing insertion of prescriptions with an empty dosage value.  
It validates the `dosage` field before a new record is added to the `PRESCRIPTIONS` table.  
If the dosage is missing, the trigger raises a clear custom error message and stops the insertion.

---

#### Trigger: `trg_bill_default_values`

Automatically assigns default values when a new bill is inserted:

- if `billing_date` is missing, it is set to the current system date;
- if `status` is not provided, it is set to `'UNPAID'`.

This ensures consistent and complete billing data without requiring manual input.

---

#### Trigger: `trg_bill_auto_payment`

Automatically creates a payment record whenever a bill’s status changes to `'PAID'`.  
It fires **after UPDATE** on the `BILLS` table and inserts a new row into `PAYMENTS` with:

- `bill_id` from the updated bill,
- `payment_date` set to the current date,
- `amount` copied from the bill.

This keeps financial data synchronized and guarantees that every fully paid bill
has a corresponding payment record.

