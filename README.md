# SQL-project
This project is a Hospital Database Management System (DBMS) built as a course project.   It demonstrates a full database design and implementation using  Oracle SQL, PL/SQL, and Oracle APEX.

### 🔗 Relationship Cardinality

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

