-- ============================================================
-- Employee learning database (PostgreSQL)
-- Covers: joins, constraints, functions (stored proc style),
-- window functions practice-ready data.
-- ============================================================

-- Clean start (safe order)
DROP TABLE IF EXISTS employee_project CASCADE;
DROP TABLE IF EXISTS employee_salary CASCADE;
DROP TABLE IF EXISTS employee_title CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

-- -----------------------
-- 1) Core dimension tables
-- -----------------------
CREATE TABLE departments (
  dept_id      SERIAL PRIMARY KEY,
  dept_code    TEXT UNIQUE NOT NULL,
  dept_name    TEXT NOT NULL,
  location     TEXT NOT NULL
);

CREATE TABLE employees (
  emp_id       SERIAL PRIMARY KEY,
  emp_no       TEXT UNIQUE NOT NULL,          -- business key
  first_name   TEXT NOT NULL,
  last_name    TEXT NOT NULL,
  email        TEXT UNIQUE NOT NULL,
  hire_date    DATE NOT NULL,
  dept_id      INT REFERENCES departments(dept_id),
  manager_id   INT REFERENCES employees(emp_id),
  status       TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','INACTIVE')),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Titles change over time (SCD-ish)
CREATE TABLE employee_title (
  emp_id       INT NOT NULL REFERENCES employees(emp_id) ON DELETE CASCADE,
  title        TEXT NOT NULL,
  valid_from   DATE NOT NULL,
  valid_to     DATE,
  PRIMARY KEY (emp_id, valid_from),
  CHECK (valid_to IS NULL OR valid_to >= valid_from)
);

-- Salaries over time
CREATE TABLE employee_salary (
  emp_id       INT NOT NULL REFERENCES employees(emp_id) ON DELETE CASCADE,
  salary       NUMERIC(12,2) NOT NULL CHECK (salary > 0),
  currency     TEXT NOT NULL DEFAULT 'GBP',
  valid_from   DATE NOT NULL,
  valid_to     DATE,
  PRIMARY KEY (emp_id, valid_from),
  CHECK (valid_to IS NULL OR valid_to >= valid_from)
);

-- Projects and assignments
CREATE TABLE projects (
  project_id   SERIAL PRIMARY KEY,
  project_code TEXT UNIQUE NOT NULL,
  project_name TEXT NOT NULL,
  start_date   DATE NOT NULL,
  end_date     DATE,
  budget_gbp   NUMERIC(14,2) NOT NULL CHECK (budget_gbp >= 0),
  CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE employee_project (
  emp_id       INT NOT NULL REFERENCES employees(emp_id) ON DELETE CASCADE,
  project_id   INT NOT NULL REFERENCES projects(project_id) ON DELETE CASCADE,
  role         TEXT NOT NULL,
  allocation_pct INT NOT NULL CHECK (allocation_pct BETWEEN 1 AND 100),
  assigned_from DATE NOT NULL,
  assigned_to   DATE,
  PRIMARY KEY (emp_id, project_id, assigned_from),
  CHECK (assigned_to IS NULL OR assigned_to >= assigned_from)
);

-- Helpful indexes for joins/window queries
CREATE INDEX idx_employees_dept ON employees(dept_id);
CREATE INDEX idx_employees_mgr  ON employees(manager_id);
CREATE INDEX idx_salary_emp     ON employee_salary(emp_id, valid_from DESC);
CREATE INDEX idx_title_emp      ON employee_title(emp_id, valid_from DESC);
CREATE INDEX idx_emp_proj_pid   ON employee_project(project_id);

-- -----------------------
-- 2) Seed data
-- -----------------------
INSERT INTO departments (dept_code, dept_name, location) VALUES
('ENG','Engineering','Belfast'),
('DATA','Data Platform','London'),
('QA','Quality Engineering','Belfast'),
('HR','Human Resources','London'),
('FIN','Finance','Manchester'),
('OPS','Operations','Birmingham');

-- Employees (managers first, then reports)
INSERT INTO employees (emp_no, first_name, last_name, email, hire_date, dept_id, manager_id, status) VALUES
('E0001','Ava','Reed','ava.reed@corp.test','2019-01-15', (SELECT dept_id FROM departments WHERE dept_code='ENG'), NULL,'ACTIVE'),
('E0002','Noah','Patel','noah.patel@corp.test','2018-05-10', (SELECT dept_id FROM departments WHERE dept_code='DATA'), NULL,'ACTIVE'),
('E0003','Mia','Khan','mia.khan@corp.test','2020-03-05', (SELECT dept_id FROM departments WHERE dept_code='QA'), NULL,'ACTIVE'),
('E0004','Liam','Jones','liam.jones@corp.test','2021-07-20', (SELECT dept_id FROM departments WHERE dept_code='HR'), NULL,'ACTIVE'),

('E0101','Ankit','Singh','ankit.singh@corp.test','2022-02-01', (SELECT dept_id FROM departments WHERE dept_code='QA'),  (SELECT emp_id FROM employees WHERE emp_no='E0003'),'ACTIVE'),
('E0102','Olivia','Brown','olivia.brown@corp.test','2022-06-14',(SELECT dept_id FROM departments WHERE dept_code='ENG'), (SELECT emp_id FROM employees WHERE emp_no='E0001'),'ACTIVE'),
('E0103','Ethan','Wilson','ethan.wilson@corp.test','2023-01-09',(SELECT dept_id FROM departments WHERE dept_code='DATA'),(SELECT emp_id FROM employees WHERE emp_no='E0002'),'ACTIVE'),
('E0104','Sophia','Davis','sophia.davis@corp.test','2023-09-18',(SELECT dept_id FROM departments WHERE dept_code='ENG'), (SELECT emp_id FROM employees WHERE emp_no='E0001'),'ACTIVE'),
('E0105','James','Miller','james.miller@corp.test','2020-11-30',(SELECT dept_id FROM departments WHERE dept_code='FIN'), NULL,'ACTIVE'),
('E0106','Isla','Taylor','isla.taylor@corp.test','2024-04-22',(SELECT dept_id FROM departments WHERE dept_code='OPS'), NULL,'ACTIVE'),
('E0107','Lucas','Martin','lucas.martin@corp.test','2021-12-12',(SELECT dept_id FROM departments WHERE dept_code='QA'),  (SELECT emp_id FROM employees WHERE emp_no='E0003'),'ACTIVE'),
('E0108','Amelia','Clark','amelia.clark@corp.test','2022-10-03',(SELECT dept_id FROM departments WHERE dept_code='DATA'),(SELECT emp_id FROM employees WHERE emp_no='E0002'),'ACTIVE'),
('E0109','Henry','Lewis','henry.lewis@corp.test','2023-05-15',(SELECT dept_id FROM departments WHERE dept_code='ENG'), (SELECT emp_id FROM employees WHERE emp_no='E0001'),'INACTIVE');

-- Titles (some employees have multiple titles over time)
INSERT INTO employee_title (emp_id, title, valid_from, valid_to)
SELECT emp_id, 'Head of Engineering', '2019-01-15', NULL FROM employees WHERE emp_no='E0001';
INSERT INTO employee_title (emp_id, title, valid_from, valid_to)
SELECT emp_id, 'Head of Data', '2018-05-10', NULL FROM employees WHERE emp_no='E0002';
INSERT INTO employee_title (emp_id, title, valid_from, valid_to)
SELECT emp_id, 'QA Manager', '2020-03-05', NULL FROM employees WHERE emp_no='E0003';
INSERT INTO employee_title (emp_id, title, valid_from, valid_to)
SELECT emp_id, 'HR Manager', '2021-07-20', NULL FROM employees WHERE emp_no='E0004';

INSERT INTO employee_title (emp_id, title, valid_from, valid_to)
SELECT emp_id, 'QA Engineer', '2022-02-01', '2023-12-31' FROM employees WHERE emp_no='E0101';
INSERT INTO employee_title (emp_id, title, valid_from, valid_to)
SELECT emp_id, 'Senior QA Engineer', '2024-01-01', NULL FROM employees WHERE emp_no='E0101';

INSERT INTO employee_title (emp_id, title, valid_from, valid_to)
SELECT emp_id, 'Software Engineer', '2022-06-14', NULL FROM employees WHERE emp_no='E0102';
INSERT INTO employee_title (emp_id, title, valid_from, valid_to)
SELECT emp_id, 'Data Engineer', '2023-01-09', NULL FROM employees WHERE emp_no='E0103';
INSERT INTO employee_title (emp_id, title, valid_from, valid_to)
SELECT emp_id, 'Software Engineer', '2023-09-18', NULL FROM employees WHERE emp_no='E0104';
INSERT INTO employee_title (emp_id, title, valid_from, valid_to)
SELECT emp_id, 'Finance Analyst', '2020-11-30', NULL FROM employees WHERE emp_no='E0105';

-- Salaries (history)
INSERT INTO employee_salary (emp_id, salary, currency, valid_from, valid_to)
SELECT emp_id, 95000, 'GBP', '2019-01-15', NULL FROM employees WHERE emp_no='E0001';
INSERT INTO employee_salary (emp_id, salary, currency, valid_from, valid_to)
SELECT emp_id, 100000, 'GBP', '2018-05-10', NULL FROM employees WHERE emp_no='E0002';
INSERT INTO employee_salary (emp_id, salary, currency, valid_from, valid_to)
SELECT emp_id, 80000, 'GBP', '2020-03-05', NULL FROM employees WHERE emp_no='E0003';

INSERT INTO employee_salary (emp_id, salary, currency, valid_from, valid_to)
SELECT emp_id, 55000, 'GBP', '2022-02-01', '2023-12-31' FROM employees WHERE emp_no='E0101';
INSERT INTO employee_salary (emp_id, salary, currency, valid_from, valid_to)
SELECT emp_id, 65000, 'GBP', '2024-01-01', NULL FROM employees WHERE emp_no='E0101';

INSERT INTO employee_salary (emp_id, salary, currency, valid_from, valid_to)
SELECT emp_id, 70000, 'GBP', '2022-06-14', NULL FROM employees WHERE emp_no='E0102';
INSERT INTO employee_salary (emp_id, salary, currency, valid_from, valid_to)
SELECT emp_id, 75000, 'GBP', '2023-01-09', NULL FROM employees WHERE emp_no='E0103';
INSERT INTO employee_salary (emp_id, salary, currency, valid_from, valid_to)
SELECT emp_id, 68000, 'GBP', '2023-09-18', NULL FROM employees WHERE emp_no='E0104';
INSERT INTO employee_salary (emp_id, salary, currency, valid_from, valid_to)
SELECT emp_id, 52000, 'GBP', '2020-11-30', NULL FROM employees WHERE emp_no='E0105';
INSERT INTO employee_salary (emp_id, salary, currency, valid_from, valid_to)
SELECT emp_id, 48000, 'GBP', '2024-04-22', NULL FROM employees WHERE emp_no='E0106';
INSERT INTO employee_salary (emp_id, salary, currency, valid_from, valid_to)
SELECT emp_id, 51000, 'GBP', '2021-12-12', NULL FROM employees WHERE emp_no='E0107';
INSERT INTO employee_salary (emp_id, salary, currency, valid_from, valid_to)
SELECT emp_id, 72000, 'GBP', '2022-10-03', NULL FROM employees WHERE emp_no='E0108';

-- Projects
INSERT INTO projects (project_code, project_name, start_date, end_date, budget_gbp) VALUES
('P-PLAT','Platform Modernisation','2023-01-01',NULL, 500000),
('P-DATA','Data Lakehouse','2023-06-01',NULL, 650000),
('P-QA01','Test Automation Revamp','2024-01-01',NULL, 180000),
('P-FIN1','Finance Reporting','2022-09-01','2023-12-31', 120000);

-- Assignments
INSERT INTO employee_project (emp_id, project_id, role, allocation_pct, assigned_from, assigned_to)
SELECT e.emp_id, p.project_id, 'Tech Lead', 60, '2023-01-01', NULL
FROM employees e JOIN projects p ON e.emp_no='E0001' AND p.project_code='P-PLAT';

INSERT INTO employee_project (emp_id, project_id, role, allocation_pct, assigned_from, assigned_to)
SELECT e.emp_id, p.project_id, 'QA Lead', 70, '2024-01-01', NULL
FROM employees e JOIN projects p ON e.emp_no='E0101' AND p.project_code='P-QA01';

INSERT INTO employee_project (emp_id, project_id, role, allocation_pct, assigned_from, assigned_to)
SELECT e.emp_id, p.project_id, 'Engineer', 80, '2023-06-01', NULL
FROM employees e JOIN projects p ON e.emp_no='E0103' AND p.project_code='P-DATA';

INSERT INTO employee_project (emp_id, project_id, role, allocation_pct, assigned_from, assigned_to)
SELECT e.emp_id, p.project_id, 'Engineer', 50, '2023-09-18', NULL
FROM employees e JOIN projects p ON e.emp_no='E0104' AND p.project_code='P-PLAT';

INSERT INTO employee_project (emp_id, project_id, role, allocation_pct, assigned_from, assigned_to)
SELECT e.emp_id, p.project_id, 'Analyst', 60, '2022-09-01', '2023-12-31'
FROM employees e JOIN projects p ON e.emp_no='E0105' AND p.project_code='P-FIN1';

-- ============================================================
-- 3) Learning helpers: views (current title/salary)
-- ============================================================

CREATE OR REPLACE VIEW v_employee_current_title AS
SELECT DISTINCT ON (emp_id)
  emp_id, title, valid_from, valid_to
FROM employee_title
WHERE valid_to IS NULL OR valid_to >= CURRENT_DATE
ORDER BY emp_id, valid_from DESC;

CREATE OR REPLACE VIEW v_employee_current_salary AS
SELECT DISTINCT ON (emp_id)
  emp_id, salary, currency, valid_from, valid_to
FROM employee_salary
WHERE valid_to IS NULL OR valid_to >= CURRENT_DATE
ORDER BY emp_id, valid_from DESC;

-- ============================================================
-- 4) "Stored procedure" style functions
-- ============================================================

-- Give raise to one employee (creates a new salary record; closes previous)
CREATE OR REPLACE FUNCTION give_raise(p_emp_no TEXT, p_new_salary NUMERIC, p_effective DATE)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_emp_id INT;
BEGIN
  SELECT emp_id INTO v_emp_id FROM employees WHERE emp_no = p_emp_no;
  IF v_emp_id IS NULL THEN
    RAISE EXCEPTION 'Employee % not found', p_emp_no;
  END IF;

  -- close current salary
  UPDATE employee_salary
  SET valid_to = p_effective - INTERVAL '1 day'
  WHERE emp_id = v_emp_id AND valid_to IS NULL;

  -- add new salary record
  INSERT INTO employee_salary(emp_id, salary, currency, valid_from, valid_to)
  VALUES (v_emp_id, p_new_salary, 'GBP', p_effective, NULL);
END;
$$;

-- Transfer employee to another department
CREATE OR REPLACE FUNCTION transfer_employee(p_emp_no TEXT, p_dept_code TEXT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_emp_id INT;
  v_dept_id INT;
BEGIN
  SELECT emp_id INTO v_emp_id FROM employees WHERE emp_no = p_emp_no;
  SELECT dept_id INTO v_dept_id FROM departments WHERE dept_code = p_dept_code;

  IF v_emp_id IS NULL THEN
    RAISE EXCEPTION 'Employee % not found', p_emp_no;
  END IF;
  IF v_dept_id IS NULL THEN
    RAISE EXCEPTION 'Department % not found', p_dept_code;
  END IF;

  UPDATE employees SET dept_id = v_dept_id WHERE emp_id = v_emp_id;
END;
$$;

-- Example calls (uncomment to try)
-- SELECT give_raise('E0102', 76000, '2025-01-01');
-- SELECT transfer_employee('E0107', 'ENG');

-- ============================================================
-- END
-- ============================================================