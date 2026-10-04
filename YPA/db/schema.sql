-- =========================================================================
-- db/schema.sql - YPA Academy
-- Creates the "ypa_academy" database, its five tables and some sample rows.
--
-- Run it with:   mysql -u root -p < db/schema.sql
--
-- WARNING: it DROPS the tables first, so running it again wipes their data.
-- Use it to set up a fresh development database. For later schema changes
-- on a database with real data, add new numbered scripts in db/migrations/.
-- =========================================================================

CREATE DATABASE IF NOT EXISTS ypa_academy
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE ypa_academy;

-- Drop in reverse order: events and students point at branches.
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS achievers;
DROP TABLE IF EXISTS professors;
DROP TABLE IF EXISTS branches;

-- -------------------------------------------------------------------------
-- branches: the academy's centres
-- -------------------------------------------------------------------------
CREATE TABLE branches (
    id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    name        VARCHAR(120)  NOT NULL,
    address     VARCHAR(255)  NOT NULL,
    phone       VARCHAR(30)   NULL,
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------------------
-- professors: shown as cards on the home page
--   accent_color  : hex colour for the card, e.g. #1E7B3C
--   display_order : lower numbers appear first
-- -------------------------------------------------------------------------
CREATE TABLE professors (
    id                INT UNSIGNED      NOT NULL AUTO_INCREMENT,
    name              VARCHAR(120)      NOT NULL,
    subject           VARCHAR(80)       NOT NULL,
    qualification     VARCHAR(120)      NULL,
    experience_years  TINYINT UNSIGNED  NOT NULL DEFAULT 0,
    bio               TEXT              NULL,
    photo_url         VARCHAR(255)      NULL,
    accent_color      CHAR(7)           NULL,
    display_order     INT               NOT NULL DEFAULT 0,
    created_at        DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_professors_display_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------------------
-- achievers: past students who cleared their exams
-- -------------------------------------------------------------------------
CREATE TABLE achievers (
    id            INT UNSIGNED       NOT NULL AUTO_INCREMENT,
    name          VARCHAR(120)       NOT NULL,
    exam          VARCHAR(120)       NOT NULL,
    rank_or_post  VARCHAR(120)       NOT NULL,
    `year`        SMALLINT UNSIGNED  NOT NULL,
    photo_url     VARCHAR(255)       NULL,
    created_at    DATETIME           NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------------------
-- events: seminars, mock tests, etc. branch_id NULL = all branches
-- -------------------------------------------------------------------------
CREATE TABLE events (
    id           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    title        VARCHAR(160)  NOT NULL,
    event_date   DATE          NOT NULL,
    description  TEXT          NULL,
    branch_id    INT UNSIGNED  NULL,
    created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_events_event_date (event_date),
    CONSTRAINT fk_events_branch FOREIGN KEY (branch_id)
        REFERENCES branches (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------------------
-- students: current students and their batch
-- -------------------------------------------------------------------------
CREATE TABLE students (
    id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    name        VARCHAR(120)  NOT NULL,
    batch       VARCHAR(80)   NOT NULL,
    branch_id   INT UNSIGNED  NULL,
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_students_branch FOREIGN KEY (branch_id)
        REFERENCES branches (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================================
-- Sample data (replace with your real details)
-- =========================================================================

INSERT INTO branches (id, name, address, phone) VALUES
    (1, 'Main Branch',        '12 Example Road, Your City 600001',   '+91 98765 43210'),
    (2, 'City Centre Branch', '45 Market Street, Your City 600002',  '+91 98765 43211'),
    (3, 'North Branch',       '7 Lake View Road, Your Town 600003',  '+91 98765 43212');

-- The first three use the green, blue and red accents; the rest use slate.
-- photo_url is NULL, so the site shows the round "Photo" placeholder.
INSERT INTO professors
    (name, subject, qualification, experience_years, bio, photo_url, accent_color, display_order)
VALUES
    ('Dr. Anitha Raman', 'General Studies', 'M.A., Ph.D. (History)', 14,
     'Teaches Indian history, culture and geography for prelims and mains. Known for crisp revision notes and weekly answer-writing practice.',
     NULL, '#1E7B3C', 1),
    ('Prof. Karthik Iyer', 'Quantitative Aptitude', 'M.Sc. Mathematics', 11,
     'Teaches arithmetic, data interpretation and shortcut methods for timed papers. His daily speed drills help students finish sections with time to spare.',
     NULL, '#0B6FA8', 2),
    ('Prof. Meera Nair', 'Reasoning', 'M.Sc., B.Ed.', 9,
     'Teaches logical and analytical reasoning, from puzzles to seating arrangements. Every class ends with a timed set of exam-level questions.',
     NULL, '#C0392B', 3),
    ('Mr. Suresh Babu', 'English', 'M.A. English Literature', 12,
     'Teaches grammar, reading comprehension and descriptive writing. Runs one-to-one essay reviews before every mains exam.',
     NULL, '#34495E', 4),
    ('Dr. Fathima Begum', 'Indian Polity', 'LL.M., Ph.D.', 10,
     'Explains the Constitution, governance and landmark judgements in plain language. Her chapter-wise mock tests mirror the latest exam pattern.',
     NULL, '#34495E', 5),
    ('Mr. Arun Prakash', 'Current Affairs', 'M.A. Journalism', 7,
     'Runs the daily news analysis class and the monthly current affairs magazine. Links each news story to the syllabus topics it can appear under.',
     NULL, '#34495E', 6);

INSERT INTO achievers (name, exam, rank_or_post, `year`, photo_url) VALUES
    ('Priya Shankar',   'State Civil Services (Group 1)', 'State Rank 12',            2025, NULL),
    ('Mohammed Irfan',  'Combined Graduate Level',        'Assistant Section Officer', 2025, NULL),
    ('Lakshmi Devi',    'Bank Probationary Officer',      'Probationary Officer',      2024, NULL),
    ('Vignesh Kumar',   'Civil Services Examination',     'All India Rank 214',        2024, NULL);

INSERT INTO events (title, event_date, description, branch_id) VALUES
    ('Free Orientation Seminar', '2026-10-18',
     'Meet the faculty, learn about the exam pattern and get a study plan for the coming year.', 1),
    ('Full-Length Mock Test',    '2026-10-25',
     'A timed prelims mock test with detailed answer review the following day.', NULL),
    ('Interview Guidance Workshop', '2026-11-08',
     'Mock interview panels with feedback from former officers and senior faculty.', 2),
    ('Current Affairs Marathon', '2026-11-22',
     'A one-day revision of the last six months of important news, topic by topic.', 3);

INSERT INTO students (name, batch, branch_id) VALUES
    ('Ananya Krishnan', 'Group 1 - Morning 2026',  1),
    ('Rahul Menon',     'Group 1 - Morning 2026',  1),
    ('Sneha Pillai',    'Banking - Evening 2026',  2),
    ('Arjun Reddy',     'Banking - Evening 2026',  2),
    ('Kavya Subramani', 'SSC CGL - Weekend 2026',  3),
    ('Nikhil Joseph',   'SSC CGL - Weekend 2026',  3);
