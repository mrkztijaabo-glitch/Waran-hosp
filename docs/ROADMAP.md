### Phase 1 – Foundation & Planning (Steps 1–11)

1.  Define overall HIS goals (patient registration, visits, labs, pharmacy).
2.  Choose cloud provider (DigitalOcean droplet).
3.  Select Odoo v16 as core HIS platform.
4.  Define specific Odoo modules/apps to be used (e.g., `base`, `account`, `stock` for pharmacy inventory, and any relevant community modules). [NEW]
5.  Plan for AI integration (placeholders only for now).
6.  Plan for WhatsApp integration (placeholders only for now).
7.  Draft budget & team responsibilities.
8.  Set project management tool (Trello, Jira).
9.  ⚠️ **Establish Version Control System (Git)** for all code, configurations, and documentation. [NEW]
10. Define initial data classification and review compliance requirements (e.g., HIPAA/GDPR basics). [NEW]
11. Outline initial documentation strategy (e.g., architecture diagrams, technical specifications, detailed team roles). [NEW]

### Phase 2 – Infrastructure Setup (Steps 12–23)

12. Provision DigitalOcean droplet (Ubuntu 22.04).
13. Implement Infrastructure as Code (IaC) for droplet provisioning (e.g., Terraform). [NEW]
14. Install Docker & Docker Compose.
15. Set up PostgreSQL 15 container.
16. Pin specific Docker image versions for Odoo, PostgreSQL, Prometheus, and Grafana. [NEW]
17. Define Docker Compose file structure, including named volumes for data persistence. [NEW]
18. Configure PostgreSQL (e.g., `shared_buffers`, `work_mem`) and Odoo (e.g., workers, memory limits, database name). [NEW]
19. Set up Odoo 16 container (HTTP, no TLS).
20. Add Prometheus + Grafana monitoring containers.
21. Configure firewall & security basics.
    *   Detail specific firewall rules (e.g., only expose necessary ports, restrict SSH access by IP). [NEW]
    *   Implement SSH key management for droplet access. [NEW]
    *   Configure database access control (e.g., dedicated Odoo user, strong passwords). [NEW]
22. Plan for centralized logging solution (e.g., ELK Stack, Loki). [NEW]
23. Test base Odoo installation, defining clear criteria for a successful test. [NEW]

### Phase 3 – Core HIS Modules (Steps 24–32)

24. Patient module: demographics + Age (integer), MRN = WAR-{YYYY}-{####}.
25. Doctor module: user roles, linked to appointments.
26. Appointment module: schedule patient ↔ doctor.
27. Encounter module: doctor notes per visit.
28. Lab module: structured results (test, value, unit, reference, status) + attachments.
29. Pharmacy module: prescriptions linked to inventory, approval workflow.
30. Radiology module: structured results + attachments.
31. Define custom Odoo module development strategy (e.g., separate custom addons path, naming conventions). [NEW]
32. Outline initial database schema design for custom fields (e.g., MRN format, lab results structure) and plan for data migration if existing data needs import. [NEW]
33. Implement data validation and sanitization for all input fields. [NEW]
34. Plan for unit and integration testing for custom Odoo modules, and implement code quality checks (linting, static analysis). [NEW]
35. Draft detailed functional specifications and user acceptance criteria for each module. [NEW]

### Phase 4 – Data & Access Control (Steps 36–46)

36. Roles: Doctor, Nurse, Lab Tech, Pharmacist, Receptionist (limited: registration + billing), Admin.
37. Define access control per role, specifying Odoo's access control mechanisms (e.g., record rules, field-level security). [NEW]
38. Create audit trail & logging, detailing implementation (Odoo's built-in, custom logging) and data retention policy. [NEW]
39. Enable encrypted backups (scripts + cron container).
    *   Specify backup destination, retention policy (beyond 7-day later), and verification process. [NEW]
    *   Define encryption method for backups (e.g., GPG, LUKS) and key management strategy. [NEW]
40. Plan disaster recovery (DR), including RTO/RPO objectives and recovery steps. [NEW]
41. Prepare demo data (Somalia locale, SOS currency).
42. Test workflows with role-based access.
43. Document access control matrix. [NEW]
44. Document DR plan and schedule regular testing. [NEW]
45. Implement automated testing for role-based access control. [NEW]
46. Version and deploy backup scripts. [NEW]

### Phase 5 – AI Integration (Steps 47–54)

47. AI placeholders only (ChatGPT/Gemini pluggable).
48. Add config/env stubs for API keys.
49. Define specific AI service APIs to be integrated (e.g., OpenAI, Google AI Studio), integration method (e.g., Python library, direct HTTP calls), and data format for AI input/output. [NEW]
50. Securely store and retrieve API keys (e.g., Docker secrets, environment variables, vault). [NEW]
51. Plan for rate limiting/usage monitoring for AI APIs. [NEW]
52. Document doctor validation checkpoints.
53. Develop testing strategy for AI integration (mocking, integration tests). [NEW]
54. Plan deployment of AI-related code/services. [NEW]

### Phase 6 – WhatsApp Integration (Steps 55–62)

55. WhatsApp placeholders only (Meta/Twilio).
56. Stub webhook in Odoo.
57. Add env/config templates for API keys.
58. Prepare message template placeholders.
59. Define specific WhatsApp API provider (Meta Business API, Twilio API), webhook endpoint details (URL, authentication), and message template structure/approval process. [NEW]
60. Securely store and retrieve API keys, and implement webhook security (e.g., signature verification). [NEW]
61. Develop testing strategy for WhatsApp integration (mocking, end-to-end tests). [NEW]
62. Plan deployment of WhatsApp-related code/services and map user journeys for WhatsApp interactions. [NEW]

### Phase 7 – UI/UX & Patient Portal (Steps 63–70)

63. Customize Odoo frontend with HIS branding, specifying customization methods (e.g., QWeb templates, custom themes, web assets). [NEW]
64. Add patient self-registration portal.
65. Enable online appointment booking.
66. Enable patient to view lab results online.
67. Enable prescription download.
68. Enable secure doctor messaging, defining implementation (Odoo's chatter, custom module). [NEW]
69. Mobile responsiveness testing.
70. Plan for automated UI/UX testing (e.g., Selenium, Cypress) and performance testing for the patient portal under load. [NEW]
71. Define authentication for the patient portal (Odoo's portal users, custom) and ensure data privacy for patient data displayed. [NEW]
72. Develop UI/UX design mockups/wireframes and a mechanism for collecting user feedback. [NEW]

### Phase 8 – Security & Compliance (Steps 73–84)

73. Enable HTTPS later (currently HTTP).
    *   Implement HTTPS using a reverse proxy (e.g., Nginx/Caddy) and Let's Encrypt. [NEW]
74. Encrypted database at rest (documented).
    *   Specify database at rest encryption method (e.g., PostgreSQL TDE, filesystem encryption). [NEW]
75. Enable 2FA for doctors/admins, defining implementation (Odoo's built-in, external provider). [NEW]
76. Review HIPAA/GDPR basics.
    *   Define specific HIPAA/GDPR controls to be implemented. [NEW]
    *   Develop data anonymization/pseudonymization strategy. [NEW]
77. Restrict API access to AI & WhatsApp, specifying methods (e.g., API keys, OAuth, IP whitelisting). [NEW]
78. Audit logs enabled.
79. Penetration testing planned.
    *   Define penetration testing scope and vendor selection. [NEW]
80. Develop an incident response plan. [NEW]
81. Implement automated security scanning (SAST/DAST). [NEW]
82. Plan for regular security audits. [NEW]
83. Involve compliance officer/legal review. [NEW]
84. Plan for regular security patching strategy for OS, Docker, Odoo, and dependencies. [NEW]

### Phase 9 – Testing & Training (Steps 85–94)

85. Smoke tests for Odoo boot & addons.
86. Model tests for patient, doctor, appointment.
87. Integration tests: patient→doctor→appointment→encounter→lab→pharmacy→radiology.
88. Placeholder tests for WhatsApp/AI.
89. Performance load test (simulate 100 users).
90. Conduct training for doctors, nurses, receptionists.
91. Refine based on feedback.
92. Define specific testing frameworks/tools (e.g., Odoo's test framework, Pytest, Locust) and test data management. [NEW]
93. Integrate all tests into the CI/CD pipeline and set up a dedicated test environment. [NEW]
94. Plan for security testing (e.g., vulnerability scanning, fuzz testing). [NEW]
95. Develop training materials and establish a feedback loop for training and refinement. [NEW]

### Phase 10 – Go-Live & Monitoring (Steps 96–105)

96. Deploy HIS to production droplet.
    *   Define deployment strategy (e.g., blue/green, rolling updates). [NEW]
97. Enable monitoring with Prometheus & Grafana dashboards (System + DB + HIS KPIs).
    *   Define alerting thresholds and notification channels (e.g., email, Slack). [NEW]
98. Daily local backups (02:00) with 7-day retention.
99. 24/7 logging alerts.
    *   Implement log aggregation solution (e.g., ELK, Loki, Splunk). [NEW]
100. Supervised operation during first week.
101. Collect patient & doctor feedback.
102. Iterate improvements (Phase 11+ if needed).
103. Implement automated rollback strategy and post-deployment validation checks. [NEW]
104. Establish on-call rotation and incident management process. [NEW]
105. Define access control for monitoring dashboards and establish a communication plan for go-live and post-mortem process for incidents. [NEW]